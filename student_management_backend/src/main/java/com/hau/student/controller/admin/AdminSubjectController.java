package com.hau.student.controller.admin;

import com.hau.student.entity.Subject;
import com.hau.student.repository.SubjectRepository;
import com.hau.student.repository.SemesterRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/admin/subjects")
@RequiredArgsConstructor
@PreAuthorize("hasRole('ADMIN')")
public class AdminSubjectController {

    private final SubjectRepository subjectRepository;
    private final SemesterRepository semesterRepository;

    @GetMapping
    public ResponseEntity<List<Subject>> getAllSubjects() {
        return ResponseEntity.ok(subjectRepository.findAll());
    }

    @GetMapping("/semester/{semesterId}")
    public ResponseEntity<List<Subject>> getSubjectsBySemester(@PathVariable Integer semesterId) {
        return ResponseEntity.ok(subjectRepository.findBySemester_Id(semesterId));
    }

    @PostMapping
    public ResponseEntity<?> createSubject(@RequestBody Map<String, Object> payload) {
        try {
            Subject subject = new Subject();
            subject.setMaMonHoc((String) payload.get("maMonHoc"));
            subject.setTenMonHoc((String) payload.get("tenMonHoc"));
            subject.setSoTinChi((Integer) payload.get("soTinChi"));
            
            if (payload.containsKey("idHocKy") && payload.get("idHocKy") != null) {
                Integer idHocKy = (Integer) payload.get("idHocKy");
                semesterRepository.findById(idHocKy).ifPresent(subject::setSemester);
            }
            
            return ResponseEntity.ok(subjectRepository.save(subject));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    @PutMapping("/{maMonHoc}")
    public ResponseEntity<?> updateSubject(@PathVariable String maMonHoc, @RequestBody Map<String, Object> payload) {
        return subjectRepository.findById(maMonHoc).map(subject -> {
            if (payload.containsKey("tenMonHoc")) subject.setTenMonHoc((String) payload.get("tenMonHoc"));
            if (payload.containsKey("soTinChi")) subject.setSoTinChi((Integer) payload.get("soTinChi"));
            
            if (payload.containsKey("idHocKy") && payload.get("idHocKy") != null) {
                Integer idHocKy = (Integer) payload.get("idHocKy");
                semesterRepository.findById(idHocKy).ifPresent(subject::setSemester);
            }
            
            return ResponseEntity.ok(subjectRepository.save(subject));
        }).orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{maMonHoc}")
    public ResponseEntity<?> deleteSubject(@PathVariable String maMonHoc) {
        return subjectRepository.findById(maMonHoc).map(subject -> {
            subjectRepository.delete(subject);
            return ResponseEntity.ok().build();
        }).orElse(ResponseEntity.notFound().build());
    }
}
