package com.hau.student.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "MonHoc")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Subject {
    
    @Id
    @Column(name = "MaMonHoc", length = 20)
    private String maMonHoc;
    
    @Column(name = "TenMonHoc", nullable = false, length = 200)
    private String tenMonHoc;
    
    @Column(name = "SoTinChi", nullable = false)
    private Integer soTinChi;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "IdHocKy")
    @JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
    private Semester semester;
}
