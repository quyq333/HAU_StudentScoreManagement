package com.hau.student.entity;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "LichThi")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ExamSchedule {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "Id")
    private Long id;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "MaMonHoc", nullable = false)
    @JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
    private Subject subject;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "IdPhong")
    private Classroom classroom;

    @Column(name = "NgayThi", nullable = false)
    @JsonFormat(pattern = "yyyy-MM-dd")
    private LocalDate ngayThi;

    @Column(name = "CaThi", nullable = false, columnDefinition = "NVARCHAR(20)")
    private String caThi;

    @Column(name = "GhiChu", columnDefinition = "NVARCHAR(255)")
    private String ghiChu;

    @OneToMany(mappedBy = "examSchedule", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.LAZY)
    @JsonIgnoreProperties("examSchedule")
    @Builder.Default
    private List<ExamRegistration> registrations = new ArrayList<>();
}
