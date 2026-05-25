package com.hau.student.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "GiangVien")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Lecturer {
    
    @Id
    @Column(name = "MaGV", length = 20)
    private String maGV;
    
    @Column(name = "HoTen", nullable = false, length = 100)
    private String hoTen;
    
    @Column(name = "Email", length = 100)
    private String email;
    
    @Column(name = "SoDienThoai", length = 20)
    private String soDienThoai;
    
    @Column(name = "Khoa", length = 100)
    private String khoa;
}
