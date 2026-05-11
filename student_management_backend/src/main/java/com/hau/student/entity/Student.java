package com.hau.student.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Date;

@Entity
@Table(name = "SinhVien")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Student {
    
    @Id
    @Column(name = "MaSV", length = 20)
    private String maSV;
    
    @Column(name = "HoTen", nullable = false, length = 100)
    private String hoTen;
    
    @Column(name = "NgaySinh")
    private Date ngaySinh;
    
    @Column(name = "Lop", length = 50)
    private String lop;
    
    @Column(name = "MatKhau", nullable = false)
    private String matKhau;
    
    @Column(name = "Role", length = 20)
    private String role = "ROLE_STUDENT";
}
