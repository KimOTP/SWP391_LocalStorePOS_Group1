package com.swp391pos.repository;

import com.swp391pos.entity.Inventory;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.List;

public interface InventoryRepository extends JpaRepository<Inventory, String> {
    Inventory findByProductId(String productId);
    @Query("SELECT COUNT(i) FROM Inventory i WHERE i.currentQuantity <= i.minThreshold")
    long countLowStock();

    @Query("SELECT SUM(i.currentQuantity * i.product.price) FROM Inventory i")
    Double calculateTotalInventoryValue();

    // Tìm kiếm theo tên sản phẩm hoặc SKU
    @Query("SELECT i FROM Inventory i WHERE i.product.productName LIKE %:keyword% OR i.product.productId LIKE %:keyword%")
    List<Inventory> searchInventory(@Param("keyword") String keyword);
}