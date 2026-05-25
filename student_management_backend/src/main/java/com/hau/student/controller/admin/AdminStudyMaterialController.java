package com.hau.student.controller.admin;

import com.hau.student.entity.StudyMaterial;
import com.hau.student.repository.StudyMaterialRepository;
import com.hau.student.repository.SubjectRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/admin/materials")
@RequiredArgsConstructor
@PreAuthorize("hasRole('ADMIN')")
public class AdminStudyMaterialController {

    private final StudyMaterialRepository studyMaterialRepository;
    private final SubjectRepository subjectRepository;

    @GetMapping
    public ResponseEntity<List<StudyMaterial>> getAllMaterials() {
        return ResponseEntity.ok(studyMaterialRepository.findAll());
    }

    @PostMapping
    public ResponseEntity<?> createMaterial(@RequestBody Map<String, Object> payload) {
        try {
            StudyMaterial material = new StudyMaterial();
            material.setTenTaiLieu((String) payload.get("tenTaiLieu"));
            material.setLoaiTaiLieu((String) payload.get("loaiTaiLieu"));
            material.setDuongDan((String) payload.get("duongDan"));
            material.setNgayTaiLen(LocalDateTime.now());
            
            if (payload.containsKey("maMonHoc")) {
                subjectRepository.findById((String) payload.get("maMonHoc")).ifPresent(material::setSubject);
            }
            
            return ResponseEntity.ok(studyMaterialRepository.save(material));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> updateMaterial(@PathVariable Long id, @RequestBody Map<String, Object> payload) {
        return studyMaterialRepository.findById(id).map(material -> {
            if (payload.containsKey("tenTaiLieu")) material.setTenTaiLieu((String) payload.get("tenTaiLieu"));
            if (payload.containsKey("loaiTaiLieu")) material.setLoaiTaiLieu((String) payload.get("loaiTaiLieu"));
            if (payload.containsKey("duongDan")) material.setDuongDan((String) payload.get("duongDan"));
            
            if (payload.containsKey("maMonHoc")) {
                subjectRepository.findById((String) payload.get("maMonHoc")).ifPresent(material::setSubject);
            }
            return ResponseEntity.ok(studyMaterialRepository.save(material));
        }).orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteMaterial(@PathVariable Long id) {
        return studyMaterialRepository.findById(id).map(material -> {
            studyMaterialRepository.delete(material);
            return ResponseEntity.ok().build();
        }).orElse(ResponseEntity.notFound().build());
    }
}
