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
public class AuditService {
    @Autowired private AuditSessionRepository auditRepo;
    @Autowired private AuditDetailRepository auditDetailRepo;
    @Autowired private InventoryRepository inventoryRepo;
    @Autowired private TransactionStatusRepository statusRepo;
    @Autowired private ProductRepository productRepo;

    @Transactional
    public void saveAuditSession(List<Map<String, Object>> items, Account account) {
        AuditSession session = new AuditSession();
        session.setStaff(account.getEmployee());
        session.setAuditDate(LocalDateTime.now());

        // Trạng thái 2: Pending Approval (Chờ duyệt)
        TransactionStatus status = statusRepo.findById(2).orElseThrow();
        session.setStatus(status);

        AuditSession savedSession = auditRepo.save(session);

        for (Map<String, Object> item : items) {
            AuditDetail detail = new AuditDetail();
            detail.setAuditSession(savedSession);

            // Lấy thông tin tồn kho hiện tại làm Expected Quantity
            String productId = (String) item.get("productId");
            Inventory inv = inventoryRepo.findByProductId(productId);

            detail.setProduct(inv.getProduct());
            detail.setExpectedQuantity(inv.getCurrentQuantity());
            detail.setActualQuantity(Integer.parseInt(item.get("actual").toString()));
            detail.setDiscrepancyReason((String) item.get("note"));
            detail.setUnitCostAtAudit(inv.getUnitCost());

            auditDetailRepo.save(detail);
        }
    }

    public List<Map<String, Object>> getAllProductsWithStock() {
        List<Product> products = productRepo.findAll();
        List<Map<String, Object>> result = new ArrayList<>();

        for (Product p : products) {
            Inventory inv = inventoryRepo.findByProductId(p.getProductId());

            Map<String, Object> map = new HashMap<>();
            map.put("sku", p.getProductId());
            map.put("name", p.getProductName());
            map.put("unit", p.getUnit());
            map.put("stock", inv != null ? inv.getCurrentQuantity() : 0);

            result.add(map);
        }
        return result;
    }
}
