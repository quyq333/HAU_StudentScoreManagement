package com.hau.student.service;

import com.hau.student.dto.GpaResponse;
import com.hau.student.entity.StudentResult;
import com.hau.student.repository.StudentResultRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;
import com.hau.student.dto.SemesterGpa;
import java.util.Map;
import java.util.HashMap;
import java.util.ArrayList;
import java.util.Comparator;

@Service
@RequiredArgsConstructor
public class ResultService {

    private final StudentResultRepository resultRepository;

    public List<StudentResult> getResultsBySemester(String maSV, Integer semesterId) {
        return resultRepository.findByStudent_MaSVAndSemester_Id(maSV, semesterId);
    }

    public List<StudentResult> getAllResults(String maSV) {
        return resultRepository.findByStudent_MaSV(maSV);
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
            return new GpaResponse(0.0, 0.0, 0, new ArrayList<>());
        }

        int totalCredits = 0;
        double totalGradePoints = 0;
        
        Map<String, Integer> semesterCredits = new HashMap<>();
        Map<String, Double> semesterPoints = new HashMap<>();

        for (StudentResult result : allResults) {
            String subjectName = result.getSubject().getTenMonHoc().toLowerCase();
            if (subjectName.contains("giáo dục quốc phòng") || subjectName.contains("giáo dục thể chất") ||
                subjectName.contains("gdqp") || subjectName.contains("gdtc")) {
                continue;
            }

            int credits = result.getSubject().getSoTinChi();
            totalCredits += credits;
            double he4 = result.getDiemHe4() != null ? result.getDiemHe4() : convertTo4PointScale(result.getDiemTongKet());
            totalGradePoints += he4 * credits;
            
            String semesterName = result.getSemester().getTenHocKy();
            semesterCredits.put(semesterName, semesterCredits.getOrDefault(semesterName, 0) + credits);
            semesterPoints.put(semesterName, semesterPoints.getOrDefault(semesterName, 0.0) + (he4 * credits));
        }

        double cumulativeGpa = totalCredits > 0 ? (totalGradePoints / totalCredits) : 0.0;
        // Mock currentGpa as same as cumulative for simplicity, or we can filter by latest semester.
        double currentGpa = cumulativeGpa; 
        
        List<SemesterGpa> semesterGpas = new ArrayList<>();
        for (String sName : semesterCredits.keySet()) {
            int cred = semesterCredits.get(sName);
            double pts = semesterPoints.get(sName);
            double gpa = cred > 0 ? (pts / cred) : 0.0;
            semesterGpas.add(new SemesterGpa(sName, Math.round(gpa * 100.0) / 100.0));
        }
        
        // Sort semester Gpas alphabetically by semester name
        semesterGpas.sort(Comparator.comparing(SemesterGpa::getSemesterName));

        return new GpaResponse(Math.round(currentGpa * 100.0) / 100.0, 
                               Math.round(cumulativeGpa * 100.0) / 100.0, 
                               totalCredits, semesterGpas);
    }

    private double convertTo4PointScale(Double scale10) {
        if (scale10 == null) return 0.0;
        if (scale10 < 4.0) return 0.0;
        if (scale10 < 5.5) return 1.0;
        if (scale10 < 7.0) return 2.0;
        if (scale10 < 8.5) return 3.0;
        return 4.0;
    }
}
