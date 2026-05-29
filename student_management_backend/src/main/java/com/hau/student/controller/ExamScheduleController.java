package com.hau.student.controller;

import com.hau.student.entity.ExamSchedule;
import com.hau.student.repository.ExamScheduleRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/v1/exam-schedules")
@RequiredArgsConstructor
@PreAuthorize("hasAnyRole('STUDENT', 'ADMIN')")
public class ExamScheduleController {

    private final ExamScheduleRepository examScheduleRepository;

    @GetMapping("/student/{maSV}")
    public ResponseEntity<List<ExamSchedule>> getExamSchedulesByStudent(@PathVariable String maSV) {
        return ResponseEntity.ok(
                examScheduleRepository.findByRegistrations_Student_MaSVOrderByNgayThiAscCaThiAsc(maSV)
        );
    }
}
