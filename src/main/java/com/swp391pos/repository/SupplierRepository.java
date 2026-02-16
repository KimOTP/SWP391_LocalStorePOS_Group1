package com.swp391pos.repository;

import com.swp391pos.entity.Supplier;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import java.util.List;

public interface SupplierRepository extends JpaRepository<Supplier, Integer> {
    @Query("SELECT s.supplierId, s.supplierName, s.contactName, s.email, " +
            "SUM(sid.receivedQuantity * sid.unitCost) " +
            "FROM Supplier s " +
            "LEFT JOIN StockIn si ON s.supplierId = si.supplier.supplierId " +
            "LEFT JOIN StockInDetail sid ON si.stockInId = sid.stockIn.stockInId " +
            "GROUP BY s.supplierId,s.supplierName, s.contactName, s.email")
    List<Object[]> findAllSuppliersWithTotalValue();
}