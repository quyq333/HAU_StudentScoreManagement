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

import java.time.LocalDate;
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
            schedule.setThuTrongTuan(getStringValue(payload.get("thuTrongTuan")));
            schedule.setCaHoc(getStringValue(payload.get("caHoc")));
            schedule.setIsConfirmed(false);
            
            if (payload.containsKey("ngayBatDau")) {
                String ngayBatDauStr = getStringValue(payload.get("ngayBatDau"));
                if (ngayBatDauStr != null && !ngayBatDauStr.trim().isEmpty()) {
                    schedule.setNgayBatDau(LocalDate.parse(ngayBatDauStr));
                }
            }
            if (payload.containsKey("ngayKetThuc")) {
                String ngayKetThucStr = getStringValue(payload.get("ngayKetThuc"));
                if (ngayKetThucStr != null && !ngayKetThucStr.trim().isEmpty()) {
                    schedule.setNgayKetThuc(LocalDate.parse(ngayKetThucStr));
                }
            }

            if (payload.containsKey("maGV")) {
                String maGV = getStringValue(payload.get("maGV"));
                if (maGV != null) {
                    lecturerRepository.findById(maGV).ifPresent(schedule::setLecturer);
                }
            }
            if (payload.containsKey("maMonHoc")) {
                String maMonHoc = getStringValue(payload.get("maMonHoc"));
                if (maMonHoc != null) {
                    subjectRepository.findById(maMonHoc).ifPresent(schedule::setSubject);
                }
            }
            if (payload.containsKey("idPhong")) {
                Long idPhong = getLongValue(payload.get("idPhong"));
                if (idPhong != null) {
                    classroomRepository.findById(idPhong).ifPresent(schedule::setClassroom);
                }
            }
            
            return ResponseEntity.ok(scheduleRepository.save(schedule));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> updateSchedule(@PathVariable Long id, @RequestBody Map<String, Object> payload) {
        try {
            return scheduleRepository.findById(id).map(schedule -> {
                if (payload.containsKey("thuTrongTuan")) {
                    schedule.setThuTrongTuan(getStringValue(payload.get("thuTrongTuan")));
                }
                if (payload.containsKey("caHoc")) {
                    schedule.setCaHoc(getStringValue(payload.get("caHoc")));
                }
                if (payload.containsKey("isConfirmed")) {
                    Boolean isConfirmed = getBooleanValue(payload.get("isConfirmed"));
                    if (isConfirmed != null) {
                        schedule.setIsConfirmed(isConfirmed);
                    }
                }

                if (payload.containsKey("ngayBatDau")) {
                    String ngayBatDauStr = getStringValue(payload.get("ngayBatDau"));
                    if (ngayBatDauStr != null && !ngayBatDauStr.trim().isEmpty()) {
                        schedule.setNgayBatDau(LocalDate.parse(ngayBatDauStr));
                    } else {
                        schedule.setNgayBatDau(null);
                    }
                }
                if (payload.containsKey("ngayKetThuc")) {
                    String ngayKetThucStr = getStringValue(payload.get("ngayKetThuc"));
                    if (ngayKetThucStr != null && !ngayKetThucStr.trim().isEmpty()) {
                        schedule.setNgayKetThuc(LocalDate.parse(ngayKetThucStr));
                    } else {
                        schedule.setNgayKetThuc(null);
                    }
                }

                if (payload.containsKey("maGV")) {
                    String maGV = getStringValue(payload.get("maGV"));
                    if (maGV != null) {
                        lecturerRepository.findById(maGV).ifPresent(schedule::setLecturer);
                    }
                }
                if (payload.containsKey("maMonHoc")) {
                    String maMonHoc = getStringValue(payload.get("maMonHoc"));
                    if (maMonHoc != null) {
                        subjectRepository.findById(maMonHoc).ifPresent(schedule::setSubject);
                    }
                }
                if (payload.containsKey("idPhong")) {
                    Long idPhong = getLongValue(payload.get("idPhong"));
                    if (idPhong != null) {
                        classroomRepository.findById(idPhong).ifPresent(schedule::setClassroom);
                    }
                }
                return ResponseEntity.ok(scheduleRepository.save(schedule));
            }).orElse(ResponseEntity.notFound().build());
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    private String getStringValue(Object value) {
        if (value == null) {
            return null;
        }
        String text = value.toString().trim();
        return text.isEmpty() ? null : text;
    }

    private Long getLongValue(Object value) {
        if (value instanceof Number number) {
            return number.longValue();
        }
        String text = getStringValue(value);
        return text == null ? null : Long.parseLong(text);
    }

    private Boolean getBooleanValue(Object value) {
        if (value instanceof Boolean boolValue) {
            return boolValue;
        }
        String text = getStringValue(value);
        return text == null ? null : Boolean.parseBoolean(text);
    }

    @PostMapping("/{id}/confirm")
    public ResponseEntity<?> confirmSchedule(@PathVariable Long id) {
        return scheduleRepository.findById(id).map(schedule -> {
            schedule.setIsConfirmed(true);
            return ResponseEntity.ok(scheduleRepository.save(schedule));
        }).orElse(ResponseEntity.notFound().build());
    }

    @PostMapping("/{id}/unconfirm")
    public ResponseEntity<?> unconfirmSchedule(@PathVariable Long id) {
        return scheduleRepository.findById(id).map(schedule -> {
            schedule.setIsConfirmed(false);
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
