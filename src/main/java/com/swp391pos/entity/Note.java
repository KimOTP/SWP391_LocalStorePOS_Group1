package com.swp391pos.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "Note")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Note {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "noteId")
    private Integer noteId;

    // Liên kết với bảng Employee (Người viết ghi chú)
    @ManyToOne
    @JoinColumn(name = "senderId", referencedColumnName = "employeeId", nullable = false)
    private Employee sender;

    // Liên kết với bảng WorkShift (Thông tin ca làm việc)
    @ManyToOne
    @JoinColumn(name = "shiftId", referencedColumnName = "shiftId", nullable = false)
    private WorkShift workShift;

    @Column(name = "workDate", nullable = false)
    private LocalDate workDate;

    @Column(nullable = false, columnDefinition = "nvarchar(255)")
    private String content;

    @Column(name = "createdAt")
    private LocalDateTime createdAt = LocalDateTime.now();
}