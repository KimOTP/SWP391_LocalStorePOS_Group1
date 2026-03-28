package com.swp391pos.repository;

import com.swp391pos.entity.StockIn;
import com.swp391pos.entity.StockInDetail;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface StockInDetailRepository extends JpaRepository<StockInDetail, Long> {
    @Query("SELECT d FROM StockInDetail d WHERE d.stockIn = :stockIn")
    List<StockInDetail> findByStockIn(@Param("stockIn") StockIn stockIn);
}