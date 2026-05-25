package com.hau.student.controller;

import com.hau.student.entity.StudyMaterial;
import com.hau.student.repository.StudyMaterialRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/materials")
@RequiredArgsConstructor
@PreAuthorize("hasAnyRole('STUDENT', 'ADMIN')")
public class StudyMaterialController {

    private final StudyMaterialRepository studyMaterialRepository;

    @GetMapping("/subject/{maMonHoc}")
    public ResponseEntity<List<StudyMaterial>> getMaterialsBySubject(@PathVariable String maMonHoc) {
        return ResponseEntity.ok(studyMaterialRepository.findBySubjectMaMonHoc(maMonHoc));
    }
    
    @GetMapping("/student/{maSV}")
    public ResponseEntity<List<StudyMaterial>> getMaterialsByStudent(@PathVariable String maSV) {
        return ResponseEntity.ok(studyMaterialRepository.findByStudentId(maSV));
    }
}
