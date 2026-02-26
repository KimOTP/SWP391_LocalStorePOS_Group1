package com.swp391pos.repository;

import com.swp391pos.entity.StockIn;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;


import java.util.List;

public interface StockInRepository extends JpaRepository<StockIn, Integer> {
    @Query("SELECT s FROM StockIn s WHERE s.status.transactionStatusId = :statusId")
    List<StockIn> findByStatusId(@Param("statusId") Integer statusId);
    StockIn findByStockInId(int stockInId);

    @Query("SELECT COALESCE(SUM(d.receivedQuantity * d.unitCost),0) FROM StockIn si JOIN si.details d WHERE si.status.transactionStatusId = :statusId")
    Double sumTotalValue(@Param("statusId") Integer statusId);
}