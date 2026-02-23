package com.swp391pos.service;

import com.swp391pos.entity.*;
import com.swp391pos.repository.*;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

@Service
public class InventoryService {
    @Autowired private StockInRepository stockInRepo;
    @Autowired private StockInDetailRepository detailRepo;
    @Autowired private TransactionStatusRepository transactionStatusRepo;
    @Autowired private SupplierRepository supplierRepo;
    @Autowired private InventoryRepository inventoryRepo;
    @Autowired private ProductRepository productRepo;

    // Request Order Process
    @Transactional
    public void createRequest(Map<String, Object> data) {
        StockIn si = new StockIn();
        String sName = (String) data.get("supplierName");
        Supplier supplier = supplierRepo.findBySupplierName(sName)
                .orElseThrow(() -> new RuntimeException("Cannot find supplier: " + sName));
        si.setSupplier(supplier);
        TransactionStatus status = transactionStatusRepo.findById(1)
                .orElseThrow(() -> new RuntimeException("Status not found"));
        si.setStatus(status);
        StockIn saved = stockInRepo.save(si);

        List<Map<String, Object>> items = (List<Map<String, Object>>) data.get("items");
        for (Map<String, Object> item : items) {
            StockInDetail detail = new StockInDetail();
            detail.setStockIn(saved);
            detail.setProduct(productRepo.findProductByProductId((String) item.get("productId")));
            detail.setRequestedQuantity(Integer.parseInt(item.get("qty").toString()));
            detail.setReceivedQuantity(0);
            Inventory inventory = inventoryRepo.findByProductId((String) item.get("productId"));
            detail.setUnitCost(inventory.getUnitCost());
            detailRepo.save(detail);
        }
    }

    // Giai đoạn 2: Staff nhập số lượng thực tế (Chuyển sang trạng thái 2: Approval-Pending)
    @Transactional
    public void processStaffInput(Integer stockInId, List<Map<String, Object>> actualData) {
        StockIn si = stockInRepo.findById(stockInId).orElseThrow();
        TransactionStatus status = transactionStatusRepo.findById(2)
                .orElseThrow(() -> new RuntimeException("Status not found"));
        si.setStatus(status);
        stockInRepo.save(si);

        for (Map<String, Object> data : actualData) {
            StockInDetail detail = detailRepo.findById(Long.parseLong(data.get("detailId").toString())).get();
            detail.setReceivedQuantity(Integer.parseInt(data.get("actualQty").toString()));
            detailRepo.save(detail);
        }
    }

    // Giai đoạn 3: Manager duyệt (Trạng thái 4: Approved -> CẬP NHẬT KHO)
    @Transactional
    public void approveStockIn(Integer stockInId) {
        StockIn si = stockInRepo.findById(stockInId).orElseThrow();
        TransactionStatus status = transactionStatusRepo.findById(4)
                .orElseThrow(() -> new RuntimeException("Status not found"));
        si.setStatus(status); // Approved
        stockInRepo.save(si);

        List<StockInDetail> details = detailRepo.findByStockIn(si);
        for (StockInDetail d : details) {
            Inventory inventory = new Inventory();
            inventory.setCurrentQuantity(inventory.getCurrentQuantity() + d.getReceivedQuantity());
            inventoryRepo.save(inventory);
        }
    }
}
