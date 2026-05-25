package com.hau.student.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Entity
@Table(name = "DangKyLichHoc", uniqueConstraints = {
    @UniqueConstraint(columnNames = {"MaSV", "IdLichHoc"})
})
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ScheduleRegistration {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "Id")
    private Long id;
    
    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "MaSV", nullable = false)
    private Student student;
    
    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "IdLichHoc", nullable = false)
    private Schedule schedule;
    
    @Column(name = "NgayDangKy")
    @Builder.Default
    private LocalDateTime ngayDangKy = LocalDateTime.now();
}
