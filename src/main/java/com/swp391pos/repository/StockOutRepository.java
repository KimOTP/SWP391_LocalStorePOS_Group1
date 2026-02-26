package com.swp391pos.repository;

import com.swp391pos.entity.StockOut;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface StockOutRepository extends JpaRepository<StockOut, Integer> {
    @Query("SELECT s FROM StockOut s WHERE s.status.transactionStatusId = :statusId")
    List<StockOut> findByStatusId(@Param("statusId") Integer statusId);
    StockOut findByStockOutId(int stockOutId);

    @Query("SELECT COALESCE(SUM(d.quantity * d.costAtExport),0) FROM StockOut so JOIN so.details d WHERE so.status.transactionStatusId = :statusId")
    Double sumTotalValue(@Param("statusId") Integer statusId);
}