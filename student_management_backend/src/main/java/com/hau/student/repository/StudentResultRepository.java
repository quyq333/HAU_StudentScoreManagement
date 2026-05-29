package com.hau.student.repository;

import com.hau.student.entity.StudentResult;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface StudentResultRepository extends JpaRepository<StudentResult, Integer> {
    List<StudentResult> findByStudent_MaSV(String maSV);
    List<StudentResult> findByStudent_MaSVAndSemester_Id(String maSV, Integer semesterId);
    List<StudentResult> findByStudent_MaSVAndSubject_MaMonHocOrderByIdAsc(String maSV, String maMonHoc);
    Optional<StudentResult> findByStudentMaSVAndSubjectMaMonHoc(String maSV, String maMonHoc);

    @org.springframework.data.jpa.repository.Modifying
    @org.springframework.transaction.annotation.Transactional
    @org.springframework.data.jpa.repository.Query(value = "UPDATE KetQuaHocTap SET MaMonHoc = :newId WHERE MaMonHoc = :oldId", nativeQuery = true)
    void updateSubjectId(@org.springframework.data.repository.query.Param("oldId") String oldId, @org.springframework.data.repository.query.Param("newId") String newId);
}
