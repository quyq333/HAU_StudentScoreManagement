package com.hau.student.controller.admin;

import com.hau.student.entity.StudentResult;
import com.hau.student.entity.Student;
import com.hau.student.entity.Subject;
import com.hau.student.entity.Semester;
import com.hau.student.entity.ExamRegistration;
import com.hau.student.repository.StudentResultRepository;
import com.hau.student.repository.StudentRepository;
import com.hau.student.repository.SubjectRepository;
import com.hau.student.repository.SemesterRepository;
import com.hau.student.repository.ScheduleRegistrationRepository;
import com.hau.student.repository.ExamRegistrationRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/admin/results")
@RequiredArgsConstructor
@PreAuthorize("hasRole('ADMIN')")
public class AdminResultController {

    private final StudentResultRepository studentResultRepository;
    private final StudentRepository studentRepository;
    private final SubjectRepository subjectRepository;
    private final SemesterRepository semesterRepository;
    private final ScheduleRegistrationRepository scheduleRegistrationRepository;
    private final ExamRegistrationRepository examRegistrationRepository;

    @GetMapping
    public ResponseEntity<List<StudentResult>> getAllResults() {
        return ResponseEntity.ok(studentResultRepository.findAll());
    }

    @GetMapping("/student/{studentId}/semester/{semesterId}")
    public ResponseEntity<List<StudentResult>> getResultsByStudentAndSemester(
            @PathVariable String studentId,
            @PathVariable Integer semesterId) {
        return ResponseEntity.ok(studentResultRepository.findByStudent_MaSVAndSemester_Id(studentId, semesterId));
    }

    @PostMapping
    public ResponseEntity<?> createResult(@RequestBody Map<String, Object> payload) {
        try {
            String maSV = (String) payload.get("maSV");
            String maMonHoc = (String) payload.get("maMonHoc");
            Integer idHocKy = (Integer) payload.get("idHocKy");

            validateScoreInputEligibility(maSV, maMonHoc);

            Student student = studentRepository.findById(maSV)
                    .orElseThrow(() -> new RuntimeException("Student not found"));
            Subject subject = subjectRepository.findById(maMonHoc)
                    .orElseThrow(() -> new RuntimeException("Subject not found"));
            Semester semester = semesterRepository.findById(idHocKy)
                    .orElseThrow(() -> new RuntimeException("Semester not found"));

            List<StudentResult> existingResults = studentResultRepository
                    .findByStudent_MaSVAndSubject_MaMonHocOrderByIdAsc(maSV, maMonHoc);
            if (!existingResults.isEmpty()) {
                StudentResult existingResult = existingResults.get(0);
                appendRetakeScore(existingResult, payload);
                return ResponseEntity.ok(studentResultRepository.save(existingResult));
            }

            StudentResult result = new StudentResult();
            result.setStudent(student);
            result.setSubject(subject);
            result.setSemester(semester);
            
            calculateAndSetScores(result, payload);

            return ResponseEntity.ok(studentResultRepository.save(result));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> updateResult(@PathVariable Integer id, @RequestBody Map<String, Object> payload) {
        return studentResultRepository.findById(id).map(result -> {
            try {
                validateScoreInputEligibility(result.getStudent().getMaSV(), result.getSubject().getMaMonHoc());
                calculateAndSetScores(result, payload);
                
                return ResponseEntity.ok(studentResultRepository.save(result));
            } catch (Exception e) {
                return ResponseEntity.badRequest().body(e.getMessage());
            }
        }).orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteResult(@PathVariable Integer id) {
        return studentResultRepository.findById(id).map(result -> {
            studentResultRepository.delete(result);
            return ResponseEntity.ok().build();
        }).orElse(ResponseEntity.notFound().build());
    }

    private void validateScoreInputEligibility(String maSV, String maMonHoc) {
        boolean hasScheduleConfirmed = scheduleRegistrationRepository
                .existsByStudent_MaSVAndSchedule_Subject_MaMonHocAndSchedule_IsConfirmedTrue(maSV, maMonHoc);
        if (!hasScheduleConfirmed) {
            throw new RuntimeException("Sinh viên chưa đăng ký học môn này không thể nhập");
        }

        List<ExamRegistration> examRegistrations = examRegistrationRepository
                .findByStudent_MaSVAndExamSchedule_Subject_MaMonHoc(maSV, maMonHoc);
        if (examRegistrations.isEmpty()) {
            throw new RuntimeException("Sinh viên chưa đăng ký học môn này không thể nhập");
        }

        java.time.LocalDate today = java.time.LocalDate.now();
        boolean hasPassedExam = false;
        for (ExamRegistration reg : examRegistrations) {
            if (reg.getExamSchedule() != null && reg.getExamSchedule().getNgayThi() != null) {
                java.time.LocalDate examDate = reg.getExamSchedule().getNgayThi();
                if (!examDate.isAfter(today)) {
                    hasPassedExam = true;
                    break;
                }
            }
        }
        if (!hasPassedExam) {
            throw new RuntimeException("Lịch thi chưa diễn ra, không thể nhập điểm.");
        }
    }

    private void validateRetakeCanBeScored(String maSV, String maMonHoc) {
        boolean hasSchedule = scheduleRegistrationRepository
                .existsByStudent_MaSVAndSchedule_Subject_MaMonHoc(maSV, maMonHoc);
        if (!hasSchedule) {
            throw new RuntimeException("Sinh viên học lại phải có lịch học trước khi nhập điểm mới.");
        }

        boolean hasExamSchedule = examRegistrationRepository
                .existsByStudent_MaSVAndExamSchedule_Subject_MaMonHoc(maSV, maMonHoc);
        if (!hasExamSchedule) {
            throw new RuntimeException("Sinh viên học lại phải có lịch thi trước khi nhập điểm mới.");
        }
    }

    private void appendRetakeScore(StudentResult result, Map<String, Object> payload) {
        Double newTk = calculateTotalScore(
                getDoubleValue(payload.get("diemChuyenCan")),
                getDoubleValue(payload.get("diemKiemTra")),
                getDoubleValue(payload.get("diemThi"))
        );

        if (payload.containsKey("diemChuyenCan")) result.setDiemChuyenCan(getDoubleValue(payload.get("diemChuyenCan")));
        if (payload.containsKey("diemKiemTra")) result.setDiemKiemTra(getDoubleValue(payload.get("diemKiemTra")));
        if (payload.containsKey("diemThi")) result.setDiemThi(getDoubleValue(payload.get("diemThi")));

        String currentDisplay = result.getDiemTongKetHienThi();
        if (currentDisplay == null || currentDisplay.isBlank()) {
            currentDisplay = formatScore(result.getDiemTongKet());
        }
        result.setDiemTongKetHienThi(currentDisplay + "|" + formatScore(newTk));

        Double bestScore = Math.max(result.getDiemTongKet() != null ? result.getDiemTongKet() : 0.0, newTk);
        setSummaryScores(result, bestScore);
    }

    private void calculateAndSetScores(StudentResult result, Map<String, Object> payload) {
        if (payload.containsKey("diemChuyenCan")) result.setDiemChuyenCan(getDoubleValue(payload.get("diemChuyenCan")));
        if (payload.containsKey("diemKiemTra")) result.setDiemKiemTra(getDoubleValue(payload.get("diemKiemTra")));
        if (payload.containsKey("diemThi")) result.setDiemThi(getDoubleValue(payload.get("diemThi")));

        Double cc = result.getDiemChuyenCan() != null ? result.getDiemChuyenCan() : 0.0;
        Double kt = result.getDiemKiemTra() != null ? result.getDiemKiemTra() : 0.0;
        Double thi = result.getDiemThi() != null ? result.getDiemThi() : 0.0;

        Double tk = calculateTotalScore(cc, kt, thi);
        result.setDiemTongKetHienThi(formatScore(tk));
        setSummaryScores(result, tk);
    }

    private Double calculateTotalScore(Double cc, Double kt, Double thi) {
        double tk = ((cc != null ? cc : 0.0) * 0.1)
                + ((kt != null ? kt : 0.0) * 0.3)
                + ((thi != null ? thi : 0.0) * 0.6);
        return Math.round(tk * 10.0) / 10.0;
    }

    private void setSummaryScores(StudentResult result, Double tk) {
        result.setDiemTongKet(tk);
        String chu;
        double he4;
        if (tk < 4.0) {
            chu = "F";
            he4 = 0.0;
        } else if (tk < 5.5) {
            chu = "D";
            he4 = 1.0;
        } else if (tk < 7.0) {
            chu = "C";
            he4 = 2.0;
        } else if (tk < 8.5) {
            chu = "B";
            he4 = 3.0;
        } else {
            chu = "A";
            he4 = 4.0;
        }
        
        result.setDiemChu(chu);
        result.setDiemHe4(he4);
    }

    private Double getDoubleValue(Object value) {
        if (value == null) {
            return 0.0;
        }
        if (value instanceof Number number) {
            return number.doubleValue();
        }
        String text = value.toString().trim();
        return text.isEmpty() ? 0.0 : Double.parseDouble(text);
    }

    private String formatScore(Double value) {
        return String.format(java.util.Locale.US, "%.1f", value != null ? value : 0.0);
    }
}
