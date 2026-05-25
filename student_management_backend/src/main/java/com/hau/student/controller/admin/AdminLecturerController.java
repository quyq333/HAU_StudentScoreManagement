package com.hau.student.controller.admin;

import com.hau.student.entity.Lecturer;
import com.hau.student.repository.LecturerRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/admin/lecturers")
@RequiredArgsConstructor
@PreAuthorize("hasRole('ADMIN')")
public class AdminLecturerController {

    private final LecturerRepository lecturerRepository;

    @GetMapping
    public ResponseEntity<List<Lecturer>> getAllLecturers() {
        return ResponseEntity.ok(lecturerRepository.findAll());
    }

    @PostMapping
    public ResponseEntity<Lecturer> createLecturer(@RequestBody Lecturer lecturer) {
        return ResponseEntity.ok(lecturerRepository.save(lecturer));
    }

    @PutMapping("/{maGV}")
    public ResponseEntity<Lecturer> updateLecturer(@PathVariable String maGV, @RequestBody Lecturer lecturerDetails) {
        return lecturerRepository.findById(maGV).map(lecturer -> {
            lecturer.setHoTen(lecturerDetails.getHoTen());
            lecturer.setEmail(lecturerDetails.getEmail());
            lecturer.setSoDienThoai(lecturerDetails.getSoDienThoai());
            lecturer.setKhoa(lecturerDetails.getKhoa());
            return ResponseEntity.ok(lecturerRepository.save(lecturer));
        }).orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{maGV}")
    public ResponseEntity<?> deleteLecturer(@PathVariable String maGV) {
        return lecturerRepository.findById(maGV).map(lecturer -> {
            lecturerRepository.delete(lecturer);
            return ResponseEntity.ok().build();
        }).orElse(ResponseEntity.notFound().build());
    }
}
