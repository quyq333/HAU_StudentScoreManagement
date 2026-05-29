package com.hau.student.controller;

import com.hau.student.entity.Schedule;
import com.hau.student.entity.ScheduleRegistration;
import com.hau.student.entity.Student;
import com.hau.student.entity.StudentResult;
import com.hau.student.repository.ScheduleRegistrationRepository;
import com.hau.student.repository.ScheduleRepository;
import com.hau.student.repository.StudentRepository;
import com.hau.student.repository.StudentResultRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/v1/schedules")
@RequiredArgsConstructor
@PreAuthorize("hasAnyRole('STUDENT', 'ADMIN')")
public class ScheduleRegistrationController {

    private final ScheduleRegistrationRepository scheduleRegistrationRepository;
    private final ScheduleRepository scheduleRepository;
    private final StudentRepository studentRepository;
    private final StudentResultRepository studentResultRepository;

    @PostMapping("/register")
    public ResponseEntity<?> registerSchedule(@RequestBody Map<String, Object> payload) {
        try {
            String maSV = (String) payload.get("maSV");
            Number scheduleIdNum = (Number) payload.get("scheduleId");
            if (maSV == null || scheduleIdNum == null) {
                return ResponseEntity.badRequest().body("Mã sinh viên và ID lịch học không được để trống.");
            }

            Long scheduleId = scheduleIdNum.longValue();

            Optional<Student> studentOpt = studentRepository.findById(maSV);
            if (studentOpt.isEmpty()) {
                return ResponseEntity.badRequest().body("Không tìm thấy sinh viên với mã: " + maSV);
            }
            Student student = studentOpt.get();

            Optional<Schedule> scheduleOpt = scheduleRepository.findById(scheduleId);
            if (scheduleOpt.isEmpty()) {
                return ResponseEntity.badRequest().body("Không tìm thấy lịch học với ID: " + scheduleId);
            }
            Schedule schedule = scheduleOpt.get();

            // 1. Kiểm tra lịch học đã được xác nhận chưa
            if (schedule.getIsConfirmed() != null && schedule.getIsConfirmed()) {
                return ResponseEntity.badRequest().body("Lịch học đã được xác nhận bởi admin, không thể đăng ký.");
            }

            // 2. Kiểm tra sĩ số tối đa (max 10)
            long currentCount = scheduleRegistrationRepository.countByScheduleId(scheduleId);
            if (currentCount >= 10) {
                return ResponseEntity.badRequest().body("Lịch học đã đầy sinh viên đăng ký (tối đa 10).");
            }

            // 3. Kiểm tra xem đã đăng ký lịch này chưa
            Optional<ScheduleRegistration> existing = scheduleRegistrationRepository
                    .findByStudentMaSVAndScheduleId(maSV, scheduleId);
            if (existing.isPresent()) {
                return ResponseEntity.badRequest().body("Bạn đã đăng ký lịch học này rồi.");
            }

            List<ScheduleRegistration> studentRegistrations = scheduleRegistrationRepository.findByStudentMaSV(maSV);

            // 4. Kiểm tra xem sinh viên đã đăng ký lịch khác của cùng môn học chưa
            boolean hasSameSubjectRegistration = studentRegistrations.stream()
                    .map(ScheduleRegistration::getSchedule)
                    .anyMatch(registeredSchedule -> isSameSubject(registeredSchedule, schedule));
            if (hasSameSubjectRegistration) {
                return ResponseEntity.badRequest().body("Bạn đã đăng ký một lịch học của môn này rồi.");
            }

            // 5. Kiểm tra trùng thời gian với các môn đã đăng ký
            Optional<Schedule> conflictingSchedule = studentRegistrations.stream()
                    .map(ScheduleRegistration::getSchedule)
                    .filter(registeredSchedule -> !isSameSubject(registeredSchedule, schedule))
                    .filter(registeredSchedule -> isScheduleTimeOverlapping(registeredSchedule, schedule))
                    .findFirst();
            if (conflictingSchedule.isPresent()) {
                Schedule conflict = conflictingSchedule.get();
                String subjectName = conflict.getSubject() != null
                        ? conflict.getSubject().getTenMonHoc()
                        : "môn học khác";
                return ResponseEntity.badRequest().body("Trùng lịch với môn " + subjectName + " đã đăng ký.");
            }

            // 6. Kiểm tra xem sinh viên đã có điểm A môn này chưa
            String maMonHoc = schedule.getSubject().getMaMonHoc();
            Optional<StudentResult> resultOpt = studentResultRepository
                    .findByStudentMaSVAndSubjectMaMonHoc(maSV, maMonHoc);
            if (resultOpt.isPresent()) {
                String diemChu = resultOpt.get().getDiemChu();
                if (diemChu != null && diemChu.equalsIgnoreCase("A")) {
                    return ResponseEntity.badRequest().body("Bạn đã có điểm A môn học này, không thể đăng ký học lại.");
                }
            }

            // Tiến hành lưu đăng ký
            ScheduleRegistration registration = ScheduleRegistration.builder()
                    .student(student)
                    .schedule(schedule)
                    .build();

            ScheduleRegistration saved = scheduleRegistrationRepository.save(registration);
            return ResponseEntity.ok(saved);

        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Có lỗi xảy ra: " + e.getMessage());
        }
    }

    private boolean isSameSubject(Schedule first, Schedule second) {
        if (first == null || second == null || first.getSubject() == null || second.getSubject() == null) {
            return false;
        }

        return Objects.equals(first.getSubject().getMaMonHoc(), second.getSubject().getMaMonHoc());
    }

    private boolean isScheduleTimeOverlapping(Schedule first, Schedule second) {
        if (first == null || second == null) {
            return false;
        }

        if (!Objects.equals(first.getThuTrongTuan(), second.getThuTrongTuan())) {
            return false;
        }

        if (!Objects.equals(first.getCaHoc(), second.getCaHoc())) {
            return false;
        }

        LocalDate firstStart = first.getNgayBatDau();
        LocalDate firstEnd = first.getNgayKetThuc();
        LocalDate secondStart = second.getNgayBatDau();
        LocalDate secondEnd = second.getNgayKetThuc();

        if (firstStart == null || firstEnd == null || secondStart == null || secondEnd == null) {
            return true;
        }

        return !firstStart.isAfter(secondEnd) && !secondStart.isAfter(firstEnd);
    }

    @DeleteMapping("/cancel")
    public ResponseEntity<?> cancelRegistration(@RequestParam String maSV, @RequestParam Long scheduleId) {
        try {
            Optional<ScheduleRegistration> regOpt = scheduleRegistrationRepository
                    .findByStudentMaSVAndScheduleId(maSV, scheduleId);
            if (regOpt.isEmpty()) {
                return ResponseEntity.notFound().build();
            }

            ScheduleRegistration registration = regOpt.get();

            // Kiểm tra xem lịch học đã được xác nhận chưa
            if (registration.getSchedule().getIsConfirmed() != null && registration.getSchedule().getIsConfirmed()) {
                return ResponseEntity.badRequest().body("Lịch học đã được xác nhận, không thể hủy đăng ký.");
            }

            scheduleRegistrationRepository.delete(registration);
            return ResponseEntity.ok().build();

        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Có lỗi xảy ra: " + e.getMessage());
        }
    }

    @GetMapping("/registered/{maSV}")
    public ResponseEntity<?> getRegisteredSchedules(@PathVariable String maSV) {
        try {
            List<ScheduleRegistration> regs = scheduleRegistrationRepository.findByStudentMaSV(maSV);
            List<Schedule> schedules = regs.stream()
                    .map(ScheduleRegistration::getSchedule)
                    .collect(Collectors.toList());
            return ResponseEntity.ok(schedules);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Có lỗi xảy ra: " + e.getMessage());
        }
    }
}
