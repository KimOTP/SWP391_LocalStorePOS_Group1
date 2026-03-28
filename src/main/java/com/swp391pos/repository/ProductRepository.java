package com.swp391pos.repository;

import com.swp391pos.entity.Product;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ProductRepository extends JpaRepository<Product,Integer> {

    Product findProductByProductId(String id);

    // Find last SKU
    @Query("SELECT p.productId FROM Product p WHERE p.productId LIKE 'SKU-PROD-%' ORDER BY p.productId DESC LIMIT 1")
    String findLastSku();

    // Đếm tổng số sản phẩm
    long count();

    long countByStatus_ProductStatusName(String statusName);

    @Query("SELECT DISTINCT p.unit FROM Product p WHERE p.unit IS NOT NULL")
    List<String> findAllDistinctUnits();

    List<Product> findByProductNameContainingIgnoreCase(String productName);

        // Tìm sản phẩm dựa trên tên, category và thuộc tính
    boolean existsByProductNameAndCategory_CategoryIdAndAttribute(String name, Integer categoryId, String attribute);

}
