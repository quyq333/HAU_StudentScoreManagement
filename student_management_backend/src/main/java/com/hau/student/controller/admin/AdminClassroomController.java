package com.hau.student.controller.admin;

import com.hau.student.entity.Classroom;
import com.hau.student.repository.ClassroomRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/admin/classrooms")
@RequiredArgsConstructor
@PreAuthorize("hasRole('ADMIN')")
public class AdminClassroomController {

    private final ClassroomRepository classroomRepository;

    @GetMapping
    public ResponseEntity<List<Classroom>> getAllClassrooms() {
        return ResponseEntity.ok(classroomRepository.findAll());
    }

    @PostMapping
    public ResponseEntity<?> createClassroom(@RequestBody Classroom classroom) {
        try {
            return ResponseEntity.ok(classroomRepository.save(classroom));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> updateClassroom(@PathVariable Long id, @RequestBody Classroom classroomDetails) {
        return classroomRepository.findById(id).map(classroom -> {
            classroom.setTenPhong(classroomDetails.getTenPhong());
            classroom.setToaNha(classroomDetails.getToaNha());
            classroom.setSucChua(classroomDetails.getSucChua());
            classroom.setLoaiPhong(classroomDetails.getLoaiPhong());
            return ResponseEntity.ok(classroomRepository.save(classroom));
        }).orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteClassroom(@PathVariable Long id) {
        return classroomRepository.findById(id).map(classroom -> {
            classroomRepository.delete(classroom);
            return ResponseEntity.ok().build();
        }).orElse(ResponseEntity.notFound().build());
    }
}
