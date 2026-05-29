package com.hau.student.repository;

import com.hau.student.entity.ExamSchedule;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ExamScheduleRepository extends JpaRepository<ExamSchedule, Long> {
    List<ExamSchedule> findByRegistrations_Student_MaSVOrderByNgayThiAscCaThiAsc(String maSV);
    boolean existsByRegistrations_Student_MaSVAndSubject_MaMonHoc(String maSV, String maMonHoc);
}
