package com.swp391pos.service;

import com.swp391pos.dto.StockInItemDTO;
import com.swp391pos.entity.*;
import com.swp391pos.repository.*;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDateTime;
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
    @Autowired private ProductRepository productRepo;;

    // Request Order Process
    public Map<String, String> getSupplierEmail(String name) {
        return supplierRepo.findBySupplierName(name)
                .map(s -> Map.of("email", s.getEmail()))
                .orElse(null);
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
    
    public List<Inventory> getPrioritizedInventory() {
        return inventoryRepo.findAll().stream()
                .sorted((a, b) -> {
                    boolean aLow = a.getCurrentQuantity() <= a.getMinThreshold();
                    boolean bLow = b.getCurrentQuantity() <= b.getMinThreshold();
                    if (aLow && !bLow) return -1;
                    if (!aLow && bLow) return 1;
                    return a.getProduct().getProductName().compareTo(b.getProduct().getProductName());
                }).toList();
    }

    public List<Supplier> getAllSuppliers() {
        return supplierRepo.findAll();
    }

    @Transactional
    public void createRequest(Integer supplierId, List<StockInItemDTO> items, Account requester) {
        StockIn si = new StockIn();
        si.setRequester(requester.getEmployee());
        si.setSupplier(supplierRepo.findById(supplierId).orElseThrow());
        si.setCreatedAt(LocalDateTime.now());
        si.setStatus(transactionStatusRepo.findById(1).get()); // Status 1: Pending Notification
        StockIn savedSi = stockInRepo.save(si);

        for (StockInItemDTO item : items) {
            StockInDetail sid = new StockInDetail();
            sid.setStockIn(savedSi);
            Product product = productRepo.findProductByProductId(item.getSku());
            if (product == null) {
                throw new RuntimeException("Product not found: " + item.getSku());
            }
            sid.setProduct(product);
            if (item.getPrice() != null) {
                sid.setUnitCost(item.getPrice());
            } else {
                Inventory inv = inventoryRepo.findById(product.getProductId()).orElse(null);
                sid.setUnitCost(inv != null ? inv.getUnitCost() : BigDecimal.ZERO);
            }
            sid.setRequestedQuantity(item.getQty());
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
        si.setStaff(staffAccount.getEmployee());
        si.setReceivedAt(LocalDateTime.now());
        si.setStatus(status);
        stockInRepo.save(si);

        for (Map<String, Object> data : actualData) {
            StockInDetail detail = detailRepo.findById(Long.parseLong(data.get("detailId").toString())).get();
            detail.setReceivedQuantity(Integer.parseInt(data.get("actualQty").toString()));
            detailRepo.save(detail);
        }
    }

    //stock-in detail
    public StockIn getStockInById(Integer id) {
        return stockInRepo.findById(id).orElseThrow();
    }
}
