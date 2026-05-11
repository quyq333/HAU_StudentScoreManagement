package com.hau.student.repository;

import com.hau.student.entity.Student;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface StudentRepository extends JpaRepository<Student, String> {
    Optional<Student> findByMaSV(String maSV);
    List<Student> findByLop(String lop);
    
    @Query("SELECT DISTINCT s.lop FROM Student s WHERE s.lop IS NOT NULL")
    List<String> findDistinctLop();
}
