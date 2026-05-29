package com.hau.student.controller.admin;

import com.hau.student.entity.ExamRegistration;
import com.hau.student.entity.ExamSchedule;
import com.hau.student.entity.ScheduleRegistration;
import com.hau.student.entity.Student;
import com.hau.student.repository.ClassroomRepository;
import com.hau.student.repository.ExamRegistrationRepository;
import com.hau.student.repository.ExamScheduleRepository;
import com.hau.student.repository.ScheduleRegistrationRepository;
import com.hau.student.repository.StudentRepository;
import com.hau.student.repository.SubjectRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.text.Collator;
import java.time.LocalDate;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/admin/exam-schedules")
@RequiredArgsConstructor
@PreAuthorize("hasRole('ADMIN')")
public class AdminExamScheduleController {

    private final ExamScheduleRepository examScheduleRepository;
    private final ExamRegistrationRepository examRegistrationRepository;
    private final SubjectRepository subjectRepository;
    private final ClassroomRepository classroomRepository;
    private final StudentRepository studentRepository;
    private final ScheduleRegistrationRepository scheduleRegistrationRepository;

    private static final Collator VI_COLLATOR = Collator.getInstance(new Locale("vi", "VN"));

    @GetMapping
    public ResponseEntity<List<ExamSchedule>> getAllExamSchedules() {
        return ResponseEntity.ok(examScheduleRepository.findAll());
    }

    @PostMapping
    public ResponseEntity<?> createExamSchedule(@RequestBody Map<String, Object> payload) {
        try {
            ExamSchedule examSchedule = new ExamSchedule();
            applyPayload(examSchedule, payload);
            return ResponseEntity.ok(examScheduleRepository.save(examSchedule));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> updateExamSchedule(@PathVariable Long id, @RequestBody Map<String, Object> payload) {
        try {
            return examScheduleRepository.findById(id).map(examSchedule -> {
                applyPayload(examSchedule, payload);
                return ResponseEntity.ok(examScheduleRepository.save(examSchedule));
            }).orElse(ResponseEntity.notFound().build());
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteExamSchedule(@PathVariable Long id) {
        return examScheduleRepository.findById(id).map(examSchedule -> {
            examScheduleRepository.delete(examSchedule);
            return ResponseEntity.ok().build();
        }).orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/{id}/eligible-students")
    public ResponseEntity<?> getEligibleStudents(@PathVariable Long id) {
        return examScheduleRepository.findById(id).map(examSchedule -> {
            String maMonHoc = examSchedule.getSubject().getMaMonHoc();
            Map<String, Student> uniqueStudents = new LinkedHashMap<>();
            scheduleRegistrationRepository.findBySchedule_Subject_MaMonHoc(maMonHoc)
                    .stream()
                    .map(ScheduleRegistration::getStudent)
                    .forEach(student -> uniqueStudents.putIfAbsent(student.getMaSV(), student));

            List<Student> students = uniqueStudents.values().stream()
                    .sorted(Comparator
                            .comparing((Student student) -> getNameSortKey(student.getHoTen()), VI_COLLATOR)
                            .thenComparing(Student::getHoTen, VI_COLLATOR))
                    .toList();
            return ResponseEntity.ok(students);
        }).orElse(ResponseEntity.notFound().build());
    }

    @PostMapping("/{id}/students/{maSV}")
    public ResponseEntity<?> addStudentToExam(@PathVariable Long id, @PathVariable String maSV) {
        try {
            ExamSchedule examSchedule = examScheduleRepository.findById(id)
                    .orElseThrow(() -> new RuntimeException("Không tìm thấy lịch thi."));
            Student student = studentRepository.findById(maSV)
                    .orElseThrow(() -> new RuntimeException("Không tìm thấy sinh viên."));
            String maMonHoc = examSchedule.getSubject().getMaMonHoc();

            boolean hasScheduleRegistration = scheduleRegistrationRepository
                    .existsByStudent_MaSVAndSchedule_Subject_MaMonHoc(maSV, maMonHoc);
            if (!hasScheduleRegistration) {
                return ResponseEntity.badRequest().body("Sinh viên chưa đăng ký lịch học của môn này.");
            }

            if (examRegistrationRepository.findByExamSchedule_IdAndStudent_MaSV(id, maSV).isPresent()) {
                return ResponseEntity.ok(examSchedule);
            }

            if (examRegistrationRepository.existsByStudent_MaSVAndExamSchedule_Subject_MaMonHoc(maSV, maMonHoc)) {
                return ResponseEntity.badRequest().body("Sinh viên đã được xếp lịch thi khác cho môn học này.");
            }

            if (examRegistrationRepository.existsByStudent_MaSVAndExamSchedule_NgayThiAndExamSchedule_CaThi(maSV, examSchedule.getNgayThi(), examSchedule.getCaThi())) {
                return ResponseEntity.badRequest().body("Sinh viên bị trùng lịch thi vào ca này.");
            }

            examRegistrationRepository.save(ExamRegistration.builder()
                    .examSchedule(examSchedule)
                    .student(student)
                    .build());

            return ResponseEntity.ok(examScheduleRepository.findById(id).orElse(examSchedule));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    @DeleteMapping("/{id}/students/{maSV}")
    public ResponseEntity<?> removeStudentFromExam(@PathVariable Long id, @PathVariable String maSV) {
        return examRegistrationRepository.findByExamSchedule_IdAndStudent_MaSV(id, maSV).map(registration -> {
            examRegistrationRepository.delete(registration);
            return ResponseEntity.ok().build();
        }).orElse(ResponseEntity.notFound().build());
    }

    private void applyPayload(ExamSchedule examSchedule, Map<String, Object> payload) {
        if (payload.containsKey("maMonHoc")) {
            String maMonHoc = getStringValue(payload.get("maMonHoc"));
            if (maMonHoc != null) {
                examSchedule.setSubject(subjectRepository.findById(maMonHoc)
                        .orElseThrow(() -> new RuntimeException("Không tìm thấy môn học.")));
            }
        }

        if (payload.containsKey("idPhong")) {
            Long idPhong = getLongValue(payload.get("idPhong"));
            if (idPhong == null) {
                examSchedule.setClassroom(null);
            } else {
                examSchedule.setClassroom(classroomRepository.findById(idPhong)
                        .orElseThrow(() -> new RuntimeException("Không tìm thấy phòng học.")));
            }
        }

        if (payload.containsKey("ngayThi")) {
            String ngayThi = getStringValue(payload.get("ngayThi"));
            if (ngayThi == null) {
                throw new RuntimeException("Ngày thi không được để trống.");
            }
            examSchedule.setNgayThi(LocalDate.parse(ngayThi));
        }

        if (payload.containsKey("caThi")) {
            String caThi = getStringValue(payload.get("caThi"));
            if (caThi == null) {
                throw new RuntimeException("Ca thi không được để trống.");
            }
            examSchedule.setCaThi(caThi);
        }

        if (payload.containsKey("ghiChu")) {
            examSchedule.setGhiChu(getStringValue(payload.get("ghiChu")));
        }
    }

    private String getStringValue(Object value) {
        if (value == null) return null;
        String text = value.toString().trim();
        return text.isEmpty() ? null : text;
    }

    private Long getLongValue(Object value) {
        if (value == null) return null;
        if (value instanceof Number number) {
            return number.longValue();
        }
        String text = getStringValue(value);
        return text == null ? null : Long.parseLong(text);
    }

    private String getNameSortKey(String fullName) {
        if (fullName == null || fullName.isBlank()) {
            return "";
        }
        String[] parts = fullName.trim().split("\\s+");
        return parts[parts.length - 1] + " " + fullName;
    }
}
