package com.hau.student.repository;

import com.hau.student.entity.StudyMaterial;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

@Repository
public interface StudyMaterialRepository extends JpaRepository<StudyMaterial, Long> {
    List<StudyMaterial> findBySubjectMaMonHoc(String maMonHoc);
    
    @Query("SELECT sm FROM StudyMaterial sm JOIN StudentResult sr ON sm.subject.maMonHoc = sr.subject.maMonHoc WHERE sr.student.maSV = :maSV")
    List<StudyMaterial> findByStudentId(@Param("maSV") String maSV);
}
