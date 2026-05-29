package com.hau.student.repository;

import com.hau.student.entity.ExamRegistration;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface ExamRegistrationRepository extends JpaRepository<ExamRegistration, Long> {
    Optional<ExamRegistration> findByExamSchedule_IdAndStudent_MaSV(Long examScheduleId, String maSV);
    boolean existsByStudent_MaSVAndExamSchedule_Subject_MaMonHoc(String maSV, String maMonHoc);
    List<ExamRegistration> findByStudent_MaSVAndExamSchedule_Subject_MaMonHoc(String maSV, String maMonHoc);
    boolean existsByStudent_MaSVAndExamSchedule_NgayThiAndExamSchedule_CaThi(String maSV, LocalDate ngayThi, String caThi);
    List<ExamRegistration> findByExamSchedule_Id(Long examScheduleId);
}
