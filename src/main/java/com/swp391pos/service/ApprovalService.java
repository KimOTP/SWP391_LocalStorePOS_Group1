package com.swp391pos.service;

import com.swp391pos.entity.*;
import com.swp391pos.repository.*;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.*;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class ApprovalService {
    @Autowired
    private StockInRepository stockInRepo;
    @Autowired private StockOutRepository stockOutRepo;
    @Autowired private AuditSessionRepository auditRepo;
    @Autowired private InventoryRepository inventoryRepo;
    @Autowired private InvLogHeaderRepository logHeaderRepo;
    @Autowired private InvLogDetailRepository logDetailRepo;
    @Autowired private TransactionStatusRepository statusRepo;
    @Autowired private EmployeeRepository employeeRepo;

    @Transactional
    public void processApproval(String type, Integer id, boolean isApproved, Account approverAccount) {
        TransactionStatus newStatus = statusRepo.findById(isApproved ? 4 : 3)
                .orElseThrow(() -> new RuntimeException("Status not found"));
        InvLogHeader header = new InvLogHeader();
        Employee approver = approverAccount.getEmployee();
        header.setApprover(approver);
        header.setCreatedAt(LocalDateTime.now());

        // 3. Xử lý theo từng loại giao dịch (Ví dụ: Stock-in)
        if ("Stock-in".equalsIgnoreCase(type)) {
            StockIn si = stockInRepo.findById(id).orElseThrow();
            si.setStatus(newStatus);
            si.setApprover(approver);

            header.setStockInId(si);
            header.setStaff(si.getStaff());
            for (StockInDetail d : si.getDetails()) {
                Inventory inv = inventoryRepo.findByProductId(d.getProduct().getProductId());
                int oldQty = inv.getCurrentQuantity();
                int newQty = oldQty;
                if (isApproved) {
                    newQty = oldQty + d.getReceivedQuantity();
                    inv.setCurrentQuantity(newQty);
                    inventoryRepo.save(inv);
                }
                saveLogDetail(header, d.getProduct(), oldQty, newQty, d.getUnitCost());
            }
            stockInRepo.save(si);
//        } else if ("Stock-out".equals(type)) {
//            StockOut so = stockOutRepo.findById(id).orElseThrow();
//            so.setStatus(status);
//            header.setStockOutId(so);
//            header.setStaff(so.getRequester());
//            if (isApproved) updateInventoryForStockOut(so, header);
//            stockOutRepo.save(so);
//        }
        // Audit processing tương tự...
        logHeaderRepo.save(header);
    }
    }



    private void saveLogDetail(InvLogHeader h, Product p, int oldQ, int newQ, BigDecimal cost) {
        InvLogDetail ld = new InvLogDetail();
        ld.setHeader(h);
        ld.setProduct(p);
        ld.setOldQuantity(oldQ);
        ld.setNewQuantity(newQ);
        ld.setUnitCost(cost);
        logDetailRepo.save(ld);
    }

    public List<Map<String, Object>> getAllPendingApprovals() {
        List<Map<String, Object>> queue = new ArrayList<>();

        // 1. Lấy Stock-in chờ duyệt (Status 2)
        stockInRepo.findByStatusId(2).forEach(si -> {
            Map<String, Object> item = new HashMap<>();
            item.put("id", si.getStockInId());
            item.put("type", "Stock-in");
            item.put("prefix", "SI-");
            item.put("staff", si.getStaff() != null ? si.getStaff().getFullName() : "N/A");
            item.put("time", si.getReceivedAt() != null ? si.getReceivedAt() : si.getCreatedAt());
            queue.add(item);
        });

        // 2. Lấy Stock-out chờ duyệt (Status 2)
        stockOutRepo.findByStatusId(2).forEach(so -> {
            Map<String, Object> item = new HashMap<>();
            item.put("id", so.getStockOutId());
            item.put("type", "Stock-out");
            item.put("prefix", "SO-");
            item.put("staff", so.getRequester() != null ? so.getRequester().getFullName() : "N/A");
            item.put("time", so.getCreatedAt() != null ? so.getCreatedAt() : LocalDateTime.now());
            queue.add(item);
        });

        // 3. Lấy Audit chờ duyệt (Status 2)
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
