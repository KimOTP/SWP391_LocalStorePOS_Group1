package com.swp391pos.entity;

import jakarta.persistence.*;
import java.util.List;

@Entity
@Table(name = "[Combo]")
public class Combo {

    @Id
    @Column(name = "comboId", length = 50)
    private String comboId;

    @Column(name = "comboName", nullable = false)
    private String comboName;

    @Column(name = "totalPrice")
    private Double totalPrice;

    @Enumerated(EnumType.STRING)
    @Column(name = "statusCombo")
    private Status statusCombo;

    @Column(name = "imageUrl", nullable = true)
    private String imageUrl;

    @OneToMany(mappedBy = "combo", cascade = CascadeType.ALL)
    private List<ComboDetail> comboDetails;

    public enum Status {
        DISCONTINUED("Discontinued"),
        ACTIVE("Active"),
        PENDING_APPROVAL ("Pending Approval"),;

        private final String displayName;

        Status(String displayName) {
            this.displayName = displayName;
        }

        public String getDisplayName() {
            return displayName;
        }
    }

    // --- Getters & Setters ---
    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }
    public String getComboId() { return comboId; }
    public void setComboId(String comboId) { this.comboId = comboId; }

    public String getComboName() { return comboName; }
    public void setComboName(String comboName) { this.comboName = comboName; }

    public Double getTotalPrice() { return totalPrice; }
    public void setTotalPrice(Double totalPrice) { this.totalPrice = totalPrice; }

    public Status getStatusCombo() { return statusCombo; }
    public void setStatusCombo(Status statusCombo) { this.statusCombo = statusCombo; }

    public List<ComboDetail> getComboDetails() { return comboDetails; }
    public void setComboDetails(List<ComboDetail> comboDetails) { this.comboDetails = comboDetails; }
}
