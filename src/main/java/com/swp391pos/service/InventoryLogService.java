package com.swp391pos.service;

import com.swp391pos.entity.*;
import com.swp391pos.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class InventoryLogService {
    @Autowired private StockInRepository stockInRepo;
    @Autowired private StockOutRepository stockOutRepo;
    @Autowired private AuditSessionRepository auditRepo;

    public List<Map<String, Object>> getAllInventoryLogs() {
        List<Map<String, Object>> logs = new ArrayList<>();

        // 1. Thu thập Stock-in
        stockInRepo.findAll().forEach(si -> {
            Map<String, Object> map = new HashMap<>();
            map.put("id", si.getStockInId());
            map.put("prefix", "SI-");
            map.put("type", "Stock-in");
            map.put("staff", si.getStaff() != null ? si.getStaff().getFullName() : "N/A");
            map.put("time", si.getReceivedAt() != null ? si.getReceivedAt() : si.getCreatedAt());
            map.put("statusId", si.getStatus().getTransactionStatusId());
            map.put("approver", si.getApprover() != null ? si.getApprover().getFullName() : "N/A");
            map.put("isPending", si.getStatus().getTransactionStatusId() == 2); // Đánh dấu trùng Queue
            logs.add(map);
        });

        // 2. Thu thập Stock-out
        stockOutRepo.findAll().forEach(so -> {
            Map<String, Object> map = new HashMap<>();
            map.put("id", so.getStockOutId());
            map.put("prefix", "SO-");
            map.put("type", "Stock-out");
            map.put("staff", so.getRequester() != null ? so.getRequester().getFullName() : "N/A");
            map.put("time", so.getCreatedAt());
            map.put("statusId", so.getStatus().getTransactionStatusId());
            map.put("approver", so.getApprover() != null ? so.getApprover().getFullName() : "N/A");
            map.put("isPending", so.getStatus().getTransactionStatusId() == 2);
            logs.add(map);
        });

        // 3. Thu thập Audit
        auditRepo.findAll().forEach(au -> {
            Map<String, Object> map = new HashMap<>();
            map.put("id", au.getAuditId());
            map.put("prefix", "KK-");
            map.put("type", "Audit");
            map.put("staff", au.getStaff() != null ? au.getStaff().getFullName() : "N/A");
            map.put("time", au.getAuditDate() != null ? au.getAuditDate() : LocalDateTime.now());
            map.put("statusId", au.getStatus().getTransactionStatusId());
            map.put("approver", au.getApprover() != null ? au.getApprover().getFullName() : "N/A");
            map.put("isPending", au.getStatus().getTransactionStatusId() == 2);
            logs.add(map);
        });

        // Sắp xếp theo thời gian mới nhất
        logs.sort((a, b) -> ((LocalDateTime) b.get("time")).compareTo((LocalDateTime) a.get("time")));
        return logs;
    }
}
