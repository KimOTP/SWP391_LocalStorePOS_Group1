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


    @Query("SELECT p FROM Product p WHERE " +
            "(:kw IS NULL OR LOWER(p.productName) LIKE LOWER(CONCAT('%', :kw, '%')) OR p.productId LIKE %:kw%) AND " +
            "(:sIds IS NULL OR p.status.productStatusName IN :sIds) AND " +
            "(:cNames IS NULL OR p.category.categoryName IN :cNames) AND " +
            "(:units IS NULL OR p.unit IN :units)")
    List<Product> searchProductManager(
            @Param("kw") String keyword,
            @Param("sIds") List<String> statusNames,
            @Param("cNames") List<String> categoryNames,
            @Param("units") List<String> units,
            Sort sort
    );

    @Query(value = "SELECT DISTINCT p.* FROM Product p " +
            "JOIN StockInDetail sid ON p.productId = sid.productId " +
            "JOIN StockIn si ON sid.stockInId = si.stockInId " +
            "JOIN Supplier s ON si.supplierId = s.supplierId " +
            "WHERE s.supplierName = :supplierName", nativeQuery = true)
    List<Product> searchBySupplierName(@Param("supplierName") String supplierName);
}
