package com.hau.student.controller;

import com.hau.student.entity.Schedule;
import com.hau.student.repository.ScheduleRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/schedules")
@RequiredArgsConstructor
@PreAuthorize("hasAnyRole('STUDENT', 'ADMIN')")
public class ScheduleController {

    private final ScheduleRepository scheduleRepository;

    @GetMapping("/subject/{maMonHoc}")
    public ResponseEntity<List<Schedule>> getSchedulesBySubject(@PathVariable String maMonHoc) {
        return ResponseEntity.ok(scheduleRepository.findBySubjectMaMonHoc(maMonHoc));
    }
    
    @GetMapping("/student/{maSV}")
    public ResponseEntity<List<Schedule>> getSchedulesByStudent(@PathVariable String maSV) {
        return ResponseEntity.ok(scheduleRepository.findByStudentId(maSV));
    }
}
