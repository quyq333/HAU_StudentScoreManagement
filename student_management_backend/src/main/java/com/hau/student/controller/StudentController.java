package com.hau.student.controller;

import com.hau.student.entity.Student;
import com.hau.student.repository.StudentRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Optional;

@RestController
@RequestMapping("/api/v1/student")
@RequiredArgsConstructor
public class StudentController {

    private final StudentRepository studentRepository;

    @GetMapping("/profile")
    public ResponseEntity<?> getProfile(Authentication authentication) {
        String maSV = authentication.getName();
        Optional<Student> studentOpt = studentRepository.findByMaSV(maSV);
        
        if (studentOpt.isPresent()) {
            Student student = studentOpt.get();
            // Xóa mật khẩu trước khi trả về
            student.setMatKhau(null);
            return ResponseEntity.ok(student);
        }
        
        return ResponseEntity.notFound().build();
    }
}
