package com.swp391pos.service;

import org.springframework.stereotype.Service;
import com.swp391pos.entity.*;
import com.swp391pos.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class InventoryService {
    @Autowired private InventoryRepository inventoryRepo;
    @Autowired private StockInRepository stockInRepo;
    @Autowired private StockOutRepository stockOutRepo;

    public Map<String, Object> getDashboardStats() {
        Map<String, Object> stats = new HashMap<>();
        stats.put("totalReceipt", stockInRepo.sumTotalValue(4)); // Tổng giá trị hàng nhập
        stats.put("totalStockOut", stockOutRepo.sumTotalValue(4)); // Tổng giá trị hàng xuất
        stats.put("inventoryValue", inventoryRepo.calculateTotalInventoryValue());
        stats.put("alertCount", inventoryRepo.countLowStock());
        return stats;
    }

    public List<Inventory> getInventoryList(String keyword) {
        if (keyword != null && !keyword.isEmpty()) {
            return inventoryRepo.searchInventory(keyword);
        }
        return inventoryRepo.findAll();
    }

    @Transactional
    public void updateMinThreshold(String productId, Integer newMin) {
        Inventory inv = inventoryRepo.findById(productId)
                .orElseThrow(() -> new RuntimeException("Product not found in inventory"));
        inv.setMinThreshold(newMin);
        inventoryRepo.save(inv);
    }
}
