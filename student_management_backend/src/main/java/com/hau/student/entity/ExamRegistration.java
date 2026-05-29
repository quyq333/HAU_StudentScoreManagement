package com.hau.student.entity;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(
        name = "DangKyLichThi",
        uniqueConstraints = @UniqueConstraint(columnNames = {"IdLichThi", "MaSV"})
)
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ExamRegistration {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "Id")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "IdLichThi", nullable = false)
    @JsonIgnoreProperties("registrations")
    private ExamSchedule examSchedule;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "MaSV", nullable = false)
    @JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
    private Student student;
}
