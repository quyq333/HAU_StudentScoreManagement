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
    private final com.hau.student.repository.StudentResultRepository studentResultRepository;

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
    @org.springframework.transaction.annotation.Transactional
    public ResponseEntity<?> updateSubject(@PathVariable String maMonHoc, @RequestBody Map<String, Object> payload) {
        return subjectRepository.findById(maMonHoc).map(subject -> {
            String newMaMonHoc = payload.containsKey("maMonHoc") ? (String) payload.get("maMonHoc") : maMonHoc;
            
            if (!maMonHoc.equals(newMaMonHoc)) {
                if (subjectRepository.existsById(newMaMonHoc)) {
                    throw new RuntimeException("Mã môn học mới đã tồn tại!");
                }
                
                Subject newSubject = new Subject();
                newSubject.setMaMonHoc(newMaMonHoc);
                newSubject.setTenMonHoc(payload.containsKey("tenMonHoc") ? (String) payload.get("tenMonHoc") : subject.getTenMonHoc());
                newSubject.setSoTinChi(payload.containsKey("soTinChi") ? (Integer) payload.get("soTinChi") : subject.getSoTinChi());
                
                if (payload.containsKey("idHocKy") && payload.get("idHocKy") != null) {
                    Integer idHocKy = (Integer) payload.get("idHocKy");
                    semesterRepository.findById(idHocKy).ifPresent(newSubject::setSemester);
                } else {
                    newSubject.setSemester(subject.getSemester());
                }
                
                subjectRepository.save(newSubject);
                studentResultRepository.updateSubjectId(maMonHoc, newMaMonHoc);
                subjectRepository.delete(subject);
                
                return ResponseEntity.ok(newSubject);
            } else {
                if (payload.containsKey("tenMonHoc")) subject.setTenMonHoc((String) payload.get("tenMonHoc"));
                if (payload.containsKey("soTinChi")) subject.setSoTinChi((Integer) payload.get("soTinChi"));
                
                if (payload.containsKey("idHocKy") && payload.get("idHocKy") != null) {
                    Integer idHocKy = (Integer) payload.get("idHocKy");
                    semesterRepository.findById(idHocKy).ifPresent(subject::setSemester);
                }
                
                return ResponseEntity.ok(subjectRepository.save(subject));
            }
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
