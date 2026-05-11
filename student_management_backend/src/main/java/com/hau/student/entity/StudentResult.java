package com.hau.student.entity;

import jakarta.persistence.*;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "KetQuaHocTap")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class StudentResult {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "Id")
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "MaSV", nullable = false)
    @JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
    private Student student;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "MaMonHoc", nullable = false)
    @JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
    private Subject subject;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "IdHocKy", nullable = false)
    @JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
    private Semester semester;

    @Column(name = "DiemChuyenCan")
    private Double diemChuyenCan;

    @Column(name = "DiemKiemTra")
    private Double diemKiemTra;

    @Column(name = "DiemThi")
    private Double diemThi;

    @Column(name = "DiemTongKet")
    private Double diemTongKet;

    @Column(name = "DiemChu", length = 5)
    private String diemChu;
}
