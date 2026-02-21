package com.swp391pos.repository;

import com.swp391pos.entity.Product;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ProductRepository extends JpaRepository<Product,Integer> {

    Product findProductByProductId(String id);

    // Đếm tổng số sản phẩm
    long count();

    // Đếm theo tên trạng thái
    long countByStatus_ProductStatusName(String statusName);
}
