package com.swp391pos.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "Notification")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Notification {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "notificationId")
    private Integer notificationId;

    // Thiết lập mối quan hệ với bảng Employee
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "receiverId", referencedColumnName = "employeeId", nullable = false)
    private Employee receiver;

    @Column(nullable = false, length = 255)
    private String title;

    @Column(nullable = false, length = 255)
    private String message;

    @Column(length = 50)
    private String type; // Shift, System, News

    @Column(name = "isRead", columnDefinition = "bit default 0")
    private Boolean isRead = false;

    @Column(name = "createdAt")
    private LocalDateTime createdAt = LocalDateTime.now();

    @ManyToOne
    @JoinColumn(name = "noteId")
    private Note note;
}
