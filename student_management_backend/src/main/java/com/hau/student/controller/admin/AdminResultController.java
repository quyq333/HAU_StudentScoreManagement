package com.hau.student.controller.admin;

import com.hau.student.entity.StudentResult;
import com.hau.student.entity.Student;
import com.hau.student.entity.Subject;
import com.hau.student.entity.Semester;
import com.hau.student.repository.StudentResultRepository;
import com.hau.student.repository.StudentRepository;
import com.hau.student.repository.SubjectRepository;
import com.hau.student.repository.SemesterRepository;
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

            Student student = studentRepository.findById(maSV)
                    .orElseThrow(() -> new RuntimeException("Student not found"));
            Subject subject = subjectRepository.findById(maMonHoc)
                    .orElseThrow(() -> new RuntimeException("Subject not found"));
            Semester semester = semesterRepository.findById(idHocKy)
                    .orElseThrow(() -> new RuntimeException("Semester not found"));

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
                calculateAndSetScores(result, payload);
                
                return ResponseEntity.ok(studentResultRepository.save(result));
            } catch (Exception e) {
                return ResponseEntity.badRequest().build();
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

    private void calculateAndSetScores(StudentResult result, Map<String, Object> payload) {
        if (payload.containsKey("diemChuyenCan")) result.setDiemChuyenCan(Double.parseDouble(payload.get("diemChuyenCan").toString()));
        if (payload.containsKey("diemKiemTra")) result.setDiemKiemTra(Double.parseDouble(payload.get("diemKiemTra").toString()));
        if (payload.containsKey("diemThi")) result.setDiemThi(Double.parseDouble(payload.get("diemThi").toString()));

        Double cc = result.getDiemChuyenCan() != null ? result.getDiemChuyenCan() : 0.0;
        Double kt = result.getDiemKiemTra() != null ? result.getDiemKiemTra() : 0.0;
        Double thi = result.getDiemThi() != null ? result.getDiemThi() : 0.0;

        double tk = (cc * 0.1) + (kt * 0.3) + (thi * 0.6);
        tk = Math.round(tk * 10.0) / 10.0;
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
}
