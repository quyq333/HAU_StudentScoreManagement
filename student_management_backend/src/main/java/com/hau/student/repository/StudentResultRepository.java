package com.hau.student.repository;

import com.hau.student.entity.StudentResult;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface StudentResultRepository extends JpaRepository<StudentResult, Integer> {
    List<StudentResult> findByStudent_MaSV(String maSV);
    List<StudentResult> findByStudent_MaSVAndSemester_Id(String maSV, Integer semesterId);
}
