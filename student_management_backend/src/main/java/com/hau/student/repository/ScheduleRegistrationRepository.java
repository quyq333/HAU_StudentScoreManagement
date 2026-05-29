package com.hau.student.repository;

import com.hau.student.entity.ScheduleRegistration;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ScheduleRegistrationRepository extends JpaRepository<ScheduleRegistration, Long> {
    Optional<ScheduleRegistration> findByStudentMaSVAndScheduleId(String maSV, Long scheduleId);
    List<ScheduleRegistration> findByStudentMaSV(String maSV);
    List<ScheduleRegistration> findByStudentMaSVAndScheduleIsConfirmedTrue(String maSV);
    List<ScheduleRegistration> findBySchedule_Subject_MaMonHoc(String maMonHoc);
    boolean existsByStudent_MaSVAndSchedule_Subject_MaMonHoc(String maSV, String maMonHoc);
    boolean existsByStudent_MaSVAndSchedule_Subject_MaMonHocAndSchedule_IsConfirmedTrue(String maSV, String maMonHoc);
    long countByScheduleId(Long scheduleId);
}
