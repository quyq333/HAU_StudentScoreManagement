package com.hau.student.controller;

import com.hau.student.dto.GpaResponse;
import com.hau.student.entity.StudentResult;
import com.hau.student.service.ResultService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/v1/results")
@RequiredArgsConstructor
public class ResultController {

    private final ResultService resultService;

    @GetMapping("/{semesterId}")
    public ResponseEntity<List<StudentResult>> getResultsBySemester(
            @PathVariable Integer semesterId,
            Authentication authentication) {
        String maSV = authentication.getName();
        return ResponseEntity.ok(resultService.getResultsBySemester(maSV, semesterId));
    }

    @GetMapping
    public ResponseEntity<List<StudentResult>> getAllResults(Authentication authentication) {
        String maSV = authentication.getName();
        return ResponseEntity.ok(resultService.getAllResults(maSV));
    }

    @GetMapping("/failed")
    public ResponseEntity<List<StudentResult>> getFailedSubjects(Authentication authentication) {
        String maSV = authentication.getName();
        return ResponseEntity.ok(resultService.getFailedSubjects(maSV));
    }

    @GetMapping("/gpa")
    public ResponseEntity<GpaResponse> getGpaStats(Authentication authentication) {
        String maSV = authentication.getName();
        return ResponseEntity.ok(resultService.getGpaStats(maSV));
    }
}
