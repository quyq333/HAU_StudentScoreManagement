package com.hau.student.controller.admin;

import com.hau.student.entity.Semester;
import com.hau.student.repository.SemesterRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/admin/semesters")
@RequiredArgsConstructor
@PreAuthorize("hasRole('ADMIN')")
public class AdminSemesterController {

    private final SemesterRepository semesterRepository;

    @GetMapping
    public ResponseEntity<List<Semester>> getAllSemesters() {
        return ResponseEntity.ok(semesterRepository.findAll());
    }

    @PostMapping
    public ResponseEntity<Semester> createSemester(@RequestBody Semester semester) {
        return ResponseEntity.ok(semesterRepository.save(semester));
    }

    @PutMapping("/{id}")
    public ResponseEntity<Semester> updateSemester(@PathVariable Integer id, @RequestBody Semester semesterDetails) {
        return semesterRepository.findById(id).map(semester -> {
            semester.setTenHocKy(semesterDetails.getTenHocKy());
            semester.setNamHoc(semesterDetails.getNamHoc());
            return ResponseEntity.ok(semesterRepository.save(semester));
        }).orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteSemester(@PathVariable Integer id) {
        return semesterRepository.findById(id).map(semester -> {
            semesterRepository.delete(semester);
            return ResponseEntity.ok().build();
        }).orElse(ResponseEntity.notFound().build());
    }
}
