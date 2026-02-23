package com.swp391pos.repository;

import com.swp391pos.entity.Product;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ProductRepository extends JpaRepository<Product,Integer> {

    Product findProductByProductId(String id);

    // Đếm tổng số sản phẩm
    long count();

    long countByStatus_ProductStatusName(String statusName);

    @Query(value = "SELECT DISTINCT p.* FROM Product p " +
            "JOIN StockInDetail sid ON p.productId = sid.productId " +
            "JOIN StockIn si ON sid.stockInId = si.stockInId " +
            "JOIN Supplier s ON si.supplierId = s.supplierId " +
            "WHERE s.supplierName = :supplierName", nativeQuery = true)
    List<Product> searchBySupplierName(@Param("supplierName") String supplierName);
}
