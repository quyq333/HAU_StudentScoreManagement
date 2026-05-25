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
    long countByScheduleId(Long scheduleId);
}
