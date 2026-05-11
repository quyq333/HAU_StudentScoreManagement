package com.hau.student.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "HocKy")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Semester {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "Id")
    private Integer id;
    
    @Column(name = "TenHocKy", nullable = false, length = 50)
    private String tenHocKy;
    
    @Column(name = "NamHoc", nullable = false, length = 20)
    private String namHoc;
}
