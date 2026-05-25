package com.hau.student.repository;

import com.hau.student.entity.Schedule;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

@Repository
public interface ScheduleRepository extends JpaRepository<Schedule, Long> {
    List<Schedule> findBySubjectMaMonHoc(String maMonHoc);
    
    @Query("SELECT s FROM Schedule s JOIN StudentResult sr ON s.subject.maMonHoc = sr.subject.maMonHoc WHERE sr.student.maSV = :maSV")
    List<Schedule> findByStudentId(@Param("maSV") String maSV);
}
