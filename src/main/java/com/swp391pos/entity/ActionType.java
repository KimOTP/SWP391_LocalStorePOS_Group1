package com.swp391pos.entity;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Data;

@Entity
@Data
@Table(name = "ActionType")
public class ActionType {
    @Id
    private Integer actionTypeId;
    private String actionTypeName;
}
