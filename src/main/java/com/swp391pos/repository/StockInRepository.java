package com.swp391pos.repository;

import com.swp391pos.entity.StockIn;
import org.springframework.data.jpa.repository.JpaRepository;

public interface StockInRepository extends JpaRepository<StockIn, Integer> {
}