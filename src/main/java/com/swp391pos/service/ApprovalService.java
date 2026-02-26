package com.swp391pos.service;

import com.swp391pos.entity.*;
import com.swp391pos.repository.*;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.*;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class ApprovalService {
    @Autowired private StockInRepository stockInRepo;
    @Autowired private StockOutRepository stockOutRepo;
    @Autowired private AuditSessionRepository auditRepo;
    @Autowired private InventoryRepository inventoryRepo;
    @Autowired private TransactionStatusRepository statusRepo;

    @Transactional
    public void processApproval(String type, Integer id, boolean isApproved, Account approverAccount) {
        // 1. Xác định trạng thái: 4 (Approved) hoặc 3 (Rejected)
        TransactionStatus newStatus = statusRepo.findById(isApproved ? 4 : 3)
                .orElseThrow(() -> new RuntimeException("Status not found"));
        Employee approver = approverAccount.getEmployee();

        // 2. Xử lý STOCK-IN (Nhập kho - Cộng thêm)
        if ("Stock-in".equalsIgnoreCase(type)) {
            StockIn si = stockInRepo.findById(id).orElseThrow();
            si.setStatus(newStatus);
            si.setApprover(approver);

            if (isApproved) {
                for (StockInDetail d : si.getDetails()) {
                    Inventory inv = inventoryRepo.findByProductId(d.getProduct().getProductId());
                    if (inv != null) {
                        inv.setCurrentQuantity(inv.getCurrentQuantity() + d.getReceivedQuantity());
                        inventoryRepo.save(inv);
                    }
                }
            }
            stockInRepo.save(si);

            // 3. Xử lý STOCK-OUT (Xuất kho - Trừ đi)
        } else if ("Stock-out".equalsIgnoreCase(type)) {
            StockOut so = stockOutRepo.findById(id).orElseThrow();
            so.setStatus(newStatus);
            so.setApprover(approver);

            if (isApproved) {
                for (StockOutDetail d : so.getDetails()) {
                    Inventory inv = inventoryRepo.findByProductId(d.getProduct().getProductId());
                    if (inv != null) {
                        int updatedQty = inv.getCurrentQuantity() - d.getQuantity();
                        inv.setCurrentQuantity(Math.max(0, updatedQty));
                        inventoryRepo.save(inv);
                    }
                }
            }
            stockOutRepo.save(so);

            // 4. Xử lý AUDIT (Kiểm kê - Cân bằng kho)
        } else if ("Audit".equalsIgnoreCase(type)) {
            AuditSession au = auditRepo.findById(id).orElseThrow();
            au.setStatus(newStatus);
            au.setApprover(approver);

            if (isApproved) {
                for (AuditDetail d : au.getDetails()) {
                    Inventory inv = inventoryRepo.findByProductId(d.getProduct().getProductId());
                    if (inv != null) {
                        inv.setCurrentQuantity(d.getActualQuantity());
                        inventoryRepo.save(inv);
                    }
                }
            }
            auditRepo.save(au);
        }
    }

    public List<Map<String, Object>> getAllPendingApprovals() {
        List<Map<String, Object>> queue = new ArrayList<>();

        // Lấy Stock-in chờ duyệt
        stockInRepo.findByStatusId(2).forEach(si -> {
            Map<String, Object> item = new HashMap<>();
            item.put("id", si.getStockInId());
            item.put("type", "Stock-in");
            item.put("prefix", "SI-");
            item.put("staff", si.getStaff() != null ? si.getStaff().getFullName() : "N/A");
            item.put("time", si.getReceivedAt() != null ? si.getReceivedAt() : si.getCreatedAt());
            queue.add(item);
        });

        // Lấy Stock-out chờ duyệt
        stockOutRepo.findByStatusId(2).forEach(so -> {
            Map<String, Object> item = new HashMap<>();
            item.put("id", so.getStockOutId());
            item.put("type", "Stock-out");
            item.put("prefix", "SO-");
            item.put("staff", so.getRequester() != null ? so.getRequester().getFullName() : "N/A");
            item.put("time", so.getCreatedAt());
            queue.add(item);
        });

        // Lấy Audit chờ duyệt
        auditRepo.findByStatusId(2).forEach(au -> {
            Map<String, Object> item = new HashMap<>();
            item.put("id", au.getAuditId());
            item.put("type", "Audit");
            item.put("prefix", "KK-");
            item.put("staff", au.getStaff() != null ? au.getStaff().getFullName() : "N/A");
            item.put("time", au.getAuditDate() != null ? au.getAuditDate() : LocalDateTime.now());
            queue.add(item);
        });

        queue.sort((a, b) -> ((LocalDateTime) b.get("time")).compareTo((LocalDateTime) a.get("time")));
        return queue;
    }
}