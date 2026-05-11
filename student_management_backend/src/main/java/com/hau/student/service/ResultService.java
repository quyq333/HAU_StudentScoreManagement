package com.hau.student.service;

import com.hau.student.dto.GpaResponse;
import com.hau.student.entity.StudentResult;
import com.hau.student.repository.StudentResultRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ResultService {

    private final StudentResultRepository resultRepository;

    public List<StudentResult> getResultsBySemester(String maSV, Integer semesterId) {
        return resultRepository.findByStudent_MaSVAndSemester_Id(maSV, semesterId);
    }

    public List<StudentResult> getFailedSubjects(String maSV) {
        List<StudentResult> allResults = resultRepository.findByStudent_MaSV(maSV);
        return allResults.stream()
                .filter(r -> r.getDiemTongKet() < 4.0 || "F".equals(r.getDiemChu()))
                .collect(Collectors.toList());
    }

    public GpaResponse getGpaStats(String maSV) {
        List<StudentResult> allResults = resultRepository.findByStudent_MaSV(maSV);
        
        if (allResults.isEmpty()) {
            return new GpaResponse(0.0, 0.0, 0);
        }

        int totalCredits = 0;
        double totalGradePoints = 0;

        for (StudentResult result : allResults) {
            int credits = result.getSubject().getSoTinChi();
            totalCredits += credits;
            totalGradePoints += convertTo4PointScale(result.getDiemTongKet()) * credits;
        }

        double cumulativeGpa = totalCredits > 0 ? (totalGradePoints / totalCredits) : 0.0;
        // Mock currentGpa as same as cumulative for simplicity, or we can filter by latest semester.
        double currentGpa = cumulativeGpa; 

        return new GpaResponse(Math.round(currentGpa * 100.0) / 100.0, 
                               Math.round(cumulativeGpa * 100.0) / 100.0, 
                               totalCredits);
    }

    private double convertTo4PointScale(double scale10) {
        if (scale10 >= 8.5) return 4.0;
        if (scale10 >= 8.0) return 3.5;
        if (scale10 >= 7.0) return 3.0;
        if (scale10 >= 6.5) return 2.5;
        if (scale10 >= 5.5) return 2.0;
        if (scale10 >= 5.0) return 1.5;
        if (scale10 >= 4.0) return 1.0;
        return 0.0;
    }
}
