package com.swp391pos.service;

import com.swp391pos.entity.*;
import com.swp391pos.repository.*;
import org.springframework.beans.factory.annotation.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class StockOutService {
    @Autowired private StockOutRepository stockOutRepo;
    @Autowired private StockOutDetailRepository detailRepo;
    @Autowired private ProductRepository productRepo;
    @Autowired private TransactionStatusRepository statusRepo;
    @Autowired private InventoryRepository inventoryRepo;

    @Transactional
    public void createStockOut(String generalNote, List<Map<String, Object>> items, Account account) {
        StockOut so = new StockOut();
        so.setRequester(account.getEmployee());
        so.setGeneralReason(generalNote);
        so.setCreatedAt(LocalDateTime.now());
        // Trạng thái 1: In Progress
        TransactionStatus status = statusRepo.findById(2)
                .orElseThrow(() -> new RuntimeException("Status ID 1 not found"));
        so.setStatus(status);
        StockOut savedSo = stockOutRepo.save(so);
        for (Map<String, Object> item : items) {
            StockOutDetail detail = new StockOutDetail();
            detail.setStockOut(savedSo);
            Product p = productRepo.findProductByProductId((String) item.get("sku"));
            Inventory i = inventoryRepo.findByProductId((String) item.get("sku"));
            detail.setProduct(p);
            detail.setQuantity(Integer.parseInt(item.get("qty").toString()));
            detail.setReason((String) item.get("reason"));

            detail.setCostAtExport(i.getUnitCost());
            detailRepo.save(detail);
        }
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> searchProductsWithStock(String query) {
        // Giả sử bạn có InventoryRepository để lấy số lượng tồn
        List<Product> products = productRepo.findByProductNameContainingIgnoreCase(query);
        List<Map<String, Object>> result = new ArrayList<>();

        for (Product p : products) {
            Inventory inv = inventoryRepo.findByProductId(p.getProductId());
            Map<String, Object> map = new HashMap<>();
            map.put("sku", p.getProductId());
            map.put("name", p.getProductName());
            map.put("unit", p.getUnit());
            map.put("currentStock", inv != null ? inv.getCurrentQuantity() : 0);
            result.add(map);
        }
        return result;
    }

    public StockOut getStockOutById(Integer id) {
        return stockOutRepo.findById(id).orElseThrow(() -> new RuntimeException("StockOut ID not found"));
    }
}
