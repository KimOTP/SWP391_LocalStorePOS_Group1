package com.swp391pos.service;

import com.swp391pos.entity.*;
import com.swp391pos.repository.*;
import jakarta.servlet.http.HttpSession;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class StockInService {
    @Autowired private StockInRepository stockInRepo;
    @Autowired private StockInDetailRepository detailRepo;
    @Autowired private TransactionStatusRepository transactionStatusRepo;
    @Autowired private SupplierRepository supplierRepo;
    @Autowired private InventoryRepository inventoryRepo;
    @Autowired private ProductRepository productRepo;
    @Autowired private EmployeeRepository employeeRepo;
    @Autowired private StockOutRepository stockOutRepo;
    @Autowired private AuditSessionRepository auditRepo;

    // Request Order Process
    public Map<String, String> getSupplierEmail(String name) {
        return supplierRepo.findBySupplierName(name)
                .map(s -> Map.of("email", s.getEmail()))
                .orElse(null);
    }

    public List<Product> getProductsBySupplier(String name) {
        return productRepo.searchBySupplierName(name);
    }

    public Map<String, Object> getProductDetails(String sku) {
        Product product = productRepo.findProductByProductId(sku);
        if (product == null) return null;

        Inventory inventory = inventoryRepo.findById(sku).orElse(null);
        Map<String, Object> response = new HashMap<>();
        response.put("productName", product.getProductName());
        response.put("unitCost", (inventory != null) ? inventory.getUnitCost() : BigDecimal.ZERO);
        return response;
    }

    @Transactional
    public void createRequest(String supplierName, List<Map<String, Object>> items, Account requester) {
        // 1. Lưu StockIn
        StockIn si = new StockIn();
        si.setRequester(employeeRepo.getEmployeeByEmployeeId(1));
        si.setSupplier(supplierRepo.findBySupplierName(supplierName).get());
        si.setCreatedAt(java.time.LocalDateTime.now());
        si.setStatus(transactionStatusRepo.findById(1).get());
        StockIn savedSi = stockInRepo.save(si);
        //2. Lưu StockInDetail
        for (Map<String, Object> item : items) {
            StockInDetail sid = new StockInDetail();
            sid.setStockIn(savedSi);
            Product product = productRepo.findProductByProductId((String) item.get("sku"));
            sid.setProduct(product);

            Object priceObj = item.get("price");
            if (priceObj != null) {
                sid.setUnitCost(new java.math.BigDecimal(priceObj.toString()));
            } else {
                Inventory inv = inventoryRepo.findById(product.getProductId()).orElse(null);
                sid.setUnitCost(inv != null ? inv.getUnitCost() : java.math.BigDecimal.ZERO);
            }

            sid.setRequestedQuantity(Integer.parseInt(item.get("qty").toString()));
            sid.setReceivedQuantity(0);

            detailRepo.save(sid);
        }
    }

    public List<StockIn> getPendingNotifications() {
        return stockInRepo.findByStatusId(1);
    }

    // Stock-in process
    public StockIn getStockInForProcessing(Integer id) {
        return stockInRepo.findByStockInId(id);
    }

    @Transactional
    public void processStaffInput(Integer stockInId, List<Map<String, Object>> actualData, Account staffAccount) {
        StockIn si = stockInRepo.findById(stockInId).orElseThrow();
        TransactionStatus status = transactionStatusRepo.findById(2)
                .orElseThrow(() -> new RuntimeException("Status not found"));
        //si.sefStaff(staffAccount.getEmployee());
        si.setStaff(employeeRepo.getEmployeeByEmployeeId(2));
        si.setReceivedAt(LocalDateTime.now());
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
