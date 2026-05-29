package com.hau.student.entity;

import jakarta.persistence.*;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "TaiLieuHocTap")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class StudyMaterial {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "Id")
    private Long id;
    
    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "MaMonHoc")
    @JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
    private Subject subject;
    
    @Column(name = "TenTaiLieu", nullable = false, columnDefinition = "NVARCHAR(200)")
    private String tenTaiLieu;
    
    @Column(name = "LoaiTaiLieu", columnDefinition = "NVARCHAR(50)")
    private String loaiTaiLieu; // PDF, DOCX, LINK, VIDEO
    
    @Column(name = "DuongDan", columnDefinition = "NVARCHAR(500)")
    private String duongDan;
    
    @Column(name = "NgayTaiLen")
    private LocalDateTime ngayTaiLen;
}
