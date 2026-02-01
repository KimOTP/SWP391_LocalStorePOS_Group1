package com.swp391pos.repository;

import com.swp391pos.entity.StockOut;
import org.springframework.data.jpa.repository.JpaRepository;

public interface StockOutRepository extends JpaRepository<StockOut, Integer> {
}