package com.swp391pos.repository;

import com.swp391pos.entity.StockOutSale;
import org.springframework.data.jpa.repository.JpaRepository;

public interface StockOutSaleRepository extends JpaRepository<StockOutSale, Long> {
}