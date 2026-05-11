package com.hau.student.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class GpaResponse {
    private double currentGpa;
    private double cumulativeGpa;
    private int totalCredits;
}
