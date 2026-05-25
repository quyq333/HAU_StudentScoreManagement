package com.hau.student.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "PhongHoc")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Classroom {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "Id")
    private Long id;
    
    @Column(name = "TenPhong", nullable = false, length = 50)
    private String tenPhong;
    
    @Column(name = "ToaNha", length = 50)
    private String toaNha;
    
    @Column(name = "SucChua")
    private Integer sucChua;

    @Column(name = "LoaiPhong", length = 50)
    private String loaiPhong;
}
