package com.hau.student.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class JwtAuthResponse {
    private String token;
    private String type = "Bearer";
    private String maSV;

    public JwtAuthResponse(String token, String maSV) {
        this.token = token;
        this.maSV = maSV;
    }
}
