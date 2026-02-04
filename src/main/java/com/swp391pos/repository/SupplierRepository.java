package com.swp391pos.repository;

import com.swp391pos.entity.Supplier;
import org.springframework.data.jdbc.repository.query.Query;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface SupplierRepository extends JpaRepository<Supplier, Integer> {
    @Query("SELECT s.supplierId, s.supplierName, s.contactName, s.email, " +
            "SUM(sid.actualQuantity * sid.unitPriceAtPurchase) " +
            "FROM Supplier s " +
            "LEFT JOIN StockIn si ON s.supplierId = si.supplier.supplierId " +
            "LEFT JOIN StockInDetail sid ON si.stockInId = sid.stockIn.stockInId " +
            "GROUP BY s.supplierId")
    List<Object[]> findAllSuppliersWithTotalValue();
}