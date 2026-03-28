package com.swp391pos.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "ComboDetail")
public class ComboDetail {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "comboDetailId")
    private Long comboDetailId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "comboId", nullable = false)
    private Combo combo;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "productId", nullable = false)
    private Product product;

    @Column(name = "quantity")
    private Integer quantity;

    public Long getComboDetailId() {
        return comboDetailId;
    }

    public void setComboDetailId(Long comboDetailId) {
        this.comboDetailId = comboDetailId;
    }

    public Combo getCombo() {
        return combo;
    }
    public void setCombo(Combo combo) {
        this.combo = combo;
    }

    public Product getProduct() {
        return product;
    }
    public void setProduct(Product product) {
        this.product = product;
    }

    public Integer getQuantity() {
        return quantity;
    }
    public void setQuantity(Integer quantity) {
        this.quantity = quantity;
    }
}