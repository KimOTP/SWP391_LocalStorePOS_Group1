package com.swp391pos.repository;

import com.swp391pos.entity.StockOutDetail;
import org.springframework.data.jpa.repository.JpaRepository;

public interface StockOutDetailRepository extends JpaRepository<StockOutDetail, Long> {
}