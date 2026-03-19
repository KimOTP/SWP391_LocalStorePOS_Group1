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
    @Autowired private EmailService emailService;

    @Transactional
    public void saveAuditSession(List<Map<String, Object>> items, Account account) {
        AuditSession session = new AuditSession();
        session.setStaff(account.getEmployee());
        session.setAuditDate(LocalDateTime.now());

        boolean hasDiscrepancy = false;
        List<AuditDetail> detailsToSave = new ArrayList<>();

        for (Map<String, Object> item : items) {
            AuditDetail detail = new AuditDetail();

            String productId = (String) item.get("productId");
            Inventory inv = inventoryRepo.findByProductId(productId);

            int expected = inv.getCurrentQuantity();
            int actual = Integer.parseInt(item.get("actual").toString());

            // Kiểm tra sai lệch
            if (expected != actual) {
                hasDiscrepancy = true;
            }

            detail.setProduct(inv.getProduct());
            detail.setExpectedQuantity(expected);
            detail.setActualQuantity(actual);
            detail.setDiscrepancyReason((String) item.get("note"));
            detail.setUnitCostAtAudit(inv.getUnitCost());

            detailsToSave.add(detail);
        }
        if (!hasDiscrepancy) {
            TransactionStatus completedStatus = statusRepo.findById(4)
                    .orElseThrow(() -> new RuntimeException("Status Completed not found"));
            session.setStatus(completedStatus);
        } else {
            TransactionStatus pendingStatus = statusRepo.findById(2)
                    .orElseThrow(() -> new RuntimeException("Status Pending not found"));
            session.setStatus(pendingStatus);
        }
        AuditSession savedSession = auditRepo.save(session);
        for (AuditDetail detail : detailsToSave) {
            detail.setAuditSession(savedSession);
            auditDetailRepo.save(detail);
        }

        if (hasDiscrepancy) {
            String staffName = account.getEmployee().getFullName();
            emailService.notifyNewAction(
                    "Inventory Audit (Discrepancy Detected)",
                    "AUD-",
                    savedSession.getAuditId(),
                    staffName
            );
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

    public AuditSession getAuditById(Integer id) {
        return auditRepo.findById(id).orElseThrow();
    }
}
