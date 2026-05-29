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

    @Column(name = "DiemTongKetHienThi", columnDefinition = "NVARCHAR(100)")
    private String diemTongKetHienThi;

    @Column(name = "DiemChu", length = 5)
    private String diemChu;

    @Column(name = "DiemHe4")
    private Double diemHe4;

    public Double getDiemHe4() {
        if (this.diemHe4 != null) {
            return this.diemHe4;
        }
        if (this.diemTongKet == null) return null;
        if (this.diemTongKet >= 8.5) return 4.0;
        if (this.diemTongKet >= 7.0) return 3.0;
        if (this.diemTongKet >= 5.5) return 2.0;
        if (this.diemTongKet >= 4.0) return 1.0;
        return 0.0;
    }
}
