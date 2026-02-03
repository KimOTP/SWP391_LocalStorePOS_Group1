package com.swp391pos.entity;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;

@Entity
@Data
@Table(name = "SystemSetting")
public class SystemSetting {

    @Id
    @Column(name = "settingKey", length = 50)
    private String settingKey;

    @Column(name = "settingValue", nullable = false)
    private String settingValue;

    @Column(name = "description")
    private String description;

    @Column(name = "updatedAt")
    private LocalDateTime updatedAt = LocalDateTime.now();

    // FK tới Employee (updated_by INT NULL)
    @ManyToOne
    @JoinColumn(name = "updatedBy")
    private Employee updatedBy;
}