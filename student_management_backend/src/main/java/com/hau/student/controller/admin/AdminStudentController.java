package com.hau.student.controller.admin;

import com.hau.student.entity.Student;
import com.hau.student.repository.StudentRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/admin/students")
@RequiredArgsConstructor
@PreAuthorize("hasRole('ADMIN')")
public class AdminStudentController {

    private final StudentRepository studentRepository;

    @GetMapping
    public ResponseEntity<List<Student>> getAllStudents() {
        return ResponseEntity.ok(studentRepository.findAll());
    }

    @GetMapping("/classes")
    public ResponseEntity<List<String>> getAllClasses() {
        return ResponseEntity.ok(studentRepository.findDistinctLop());
    }

    @GetMapping("/class/{lop}")
    public ResponseEntity<List<Student>> getStudentsByClass(@PathVariable String lop) {
        return ResponseEntity.ok(studentRepository.findByLop(lop));
    }

    @PostMapping
    public ResponseEntity<Student> createStudent(@RequestBody Student student) {
        if (student.getRole() == null || student.getRole().isEmpty()) {
            student.setRole("ROLE_STUDENT");
        }
        return ResponseEntity.ok(studentRepository.save(student));
    }

    @PutMapping("/{maSV}")
    public ResponseEntity<Student> updateStudent(@PathVariable String maSV, @RequestBody Student studentDetails) {
        return studentRepository.findByMaSV(maSV).map(student -> {
            student.setHoTen(studentDetails.getHoTen());
            student.setNgaySinh(studentDetails.getNgaySinh());
            student.setLop(studentDetails.getLop());
            if (studentDetails.getMatKhau() != null && !studentDetails.getMatKhau().isEmpty()) {
                student.setMatKhau(studentDetails.getMatKhau());
            }
            if (studentDetails.getRole() != null && !studentDetails.getRole().isEmpty()) {
                student.setRole(studentDetails.getRole());
            }
            return ResponseEntity.ok(studentRepository.save(student));
        }).orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{maSV}")
    public ResponseEntity<?> deleteStudent(@PathVariable String maSV) {
        return studentRepository.findByMaSV(maSV).map(student -> {
            studentRepository.delete(student);
            return ResponseEntity.ok().build();
        }).orElse(ResponseEntity.notFound().build());
    }
}
