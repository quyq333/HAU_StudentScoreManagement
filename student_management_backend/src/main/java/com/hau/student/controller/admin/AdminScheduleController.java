package com.hau.student.controller.admin;

import com.hau.student.entity.Schedule;
import com.hau.student.repository.ClassroomRepository;
import com.hau.student.repository.LecturerRepository;
import com.hau.student.repository.ScheduleRepository;
import com.hau.student.repository.SubjectRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/admin/schedules")
@RequiredArgsConstructor
@PreAuthorize("hasRole('ADMIN')")
public class AdminScheduleController {

    private final ScheduleRepository scheduleRepository;
    private final SubjectRepository subjectRepository;
    private final ClassroomRepository classroomRepository;
    private final LecturerRepository lecturerRepository;

    @GetMapping
    public ResponseEntity<List<Schedule>> getAllSchedules() {
        return ResponseEntity.ok(scheduleRepository.findAll());
    }

    @PostMapping
    public ResponseEntity<?> createSchedule(@RequestBody Map<String, Object> payload) {
        try {
            Schedule schedule = new Schedule();
            schedule.setThuTrongTuan((String) payload.get("thuTrongTuan"));
            schedule.setCaHoc((String) payload.get("caHoc"));
            schedule.setIsConfirmed(false);
            
            if (payload.containsKey("ngayBatDau")) {
                String ngayBatDauStr = (String) payload.get("ngayBatDau");
                if (ngayBatDauStr != null && !ngayBatDauStr.trim().isEmpty()) {
                    schedule.setNgayBatDau(java.time.LocalDate.parse(ngayBatDauStr));
                }
            }
            if (payload.containsKey("ngayKetThuc")) {
                String ngayKetThucStr = (String) payload.get("ngayKetThuc");
                if (ngayKetThucStr != null && !ngayKetThucStr.trim().isEmpty()) {
                    schedule.setNgayKetThuc(java.time.LocalDate.parse(ngayKetThucStr));
                }
            }

            if (payload.containsKey("maGV")) {
                String maGV = (String) payload.get("maGV");
                if (maGV != null) {
                    lecturerRepository.findById(maGV).ifPresent(schedule::setLecturer);
                }
            }
            if (payload.containsKey("maMonHoc")) {
                subjectRepository.findById((String) payload.get("maMonHoc")).ifPresent(schedule::setSubject);
            }
            if (payload.containsKey("idPhong")) {
                Number idPhong = (Number) payload.get("idPhong");
                classroomRepository.findById(idPhong.longValue()).ifPresent(schedule::setClassroom);
            }
            
            return ResponseEntity.ok(scheduleRepository.save(schedule));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> updateSchedule(@PathVariable Long id, @RequestBody Map<String, Object> payload) {
        return scheduleRepository.findById(id).map(schedule -> {
            if (payload.containsKey("thuTrongTuan")) schedule.setThuTrongTuan((String) payload.get("thuTrongTuan"));
            if (payload.containsKey("caHoc")) schedule.setCaHoc((String) payload.get("caHoc"));
            if (payload.containsKey("isConfirmed")) schedule.setIsConfirmed((Boolean) payload.get("isConfirmed"));
            
            if (payload.containsKey("ngayBatDau")) {
                String ngayBatDauStr = (String) payload.get("ngayBatDau");
                if (ngayBatDauStr != null && !ngayBatDauStr.trim().isEmpty()) {
                    schedule.setNgayBatDau(java.time.LocalDate.parse(ngayBatDauStr));
                } else {
                    schedule.setNgayBatDau(null);
                }
            }
            if (payload.containsKey("ngayKetThuc")) {
                String ngayKetThucStr = (String) payload.get("ngayKetThuc");
                if (ngayKetThucStr != null && !ngayKetThucStr.trim().isEmpty()) {
                    schedule.setNgayKetThuc(java.time.LocalDate.parse(ngayKetThucStr));
                } else {
                    schedule.setNgayKetThuc(null);
                }
            }

            if (payload.containsKey("maGV")) {
                String maGV = (String) payload.get("maGV");
                if (maGV != null) {
                    lecturerRepository.findById(maGV).ifPresent(schedule::setLecturer);
                }
            }
            if (payload.containsKey("maMonHoc")) {
                subjectRepository.findById((String) payload.get("maMonHoc")).ifPresent(schedule::setSubject);
            }
            if (payload.containsKey("idPhong")) {
                Number idPhong = (Number) payload.get("idPhong");
                classroomRepository.findById(idPhong.longValue()).ifPresent(schedule::setClassroom);
            }
            return ResponseEntity.ok(scheduleRepository.save(schedule));
        }).orElse(ResponseEntity.notFound().build());
    }

    @PostMapping("/{id}/confirm")
    public ResponseEntity<?> confirmSchedule(@PathVariable Long id) {
        return scheduleRepository.findById(id).map(schedule -> {
            schedule.setIsConfirmed(true);
            return ResponseEntity.ok(scheduleRepository.save(schedule));
        }).orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteSchedule(@PathVariable Long id) {
        return scheduleRepository.findById(id).map(schedule -> {
            scheduleRepository.delete(schedule);
            return ResponseEntity.ok().build();
        }).orElse(ResponseEntity.notFound().build());
    }
}
