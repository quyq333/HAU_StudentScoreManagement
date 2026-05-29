package com.hau.student.entity;

import jakarta.persistence.*;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.util.List;
import java.util.ArrayList;

@Entity
@Table(name = "LichHoc")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Schedule {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "Id")
    private Long id;
    
    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "MaMonHoc")
    @JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
    private Subject subject;
    
    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "IdPhong")
    private Classroom classroom;
    
    @Column(name = "ThuTrongTuan", columnDefinition = "NVARCHAR(20)")
    private String thuTrongTuan; // Ví dụ: "Thứ 2", "Thứ 3"
    
    @Column(name = "CaHoc", columnDefinition = "NVARCHAR(20)")
    private String caHoc; // Ví dụ: "Ca sáng", "Ca chiều", "Ca tối"
    
    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "MaGV")
    @JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
    private Lecturer lecturer;

    @Column(name = "NgayBatDau")
    @com.fasterxml.jackson.annotation.JsonFormat(pattern = "yyyy-MM-dd")
    private java.time.LocalDate ngayBatDau;

    @Column(name = "NgayKetThuc")
    @com.fasterxml.jackson.annotation.JsonFormat(pattern = "yyyy-MM-dd")
    private java.time.LocalDate ngayKetThuc;

    @Column(name = "IsConfirmed", nullable = false)
    @Builder.Default
    private Boolean isConfirmed = false;

    @OneToMany(mappedBy = "schedule", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @JsonIgnoreProperties("schedule")
    @Builder.Default
    private List<ScheduleRegistration> registrations = new ArrayList<>();
}
