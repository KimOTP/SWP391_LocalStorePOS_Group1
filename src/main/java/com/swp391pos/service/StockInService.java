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
    @Autowired private EmailService emailService;

    // Request Order Process
    public Map<String, String> getSupplierEmail(String name) {
        return supplierRepo.findBySupplierName(name)
                .map(s -> Map.of("email", s.getEmail()))
                .orElse(null);
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
        Supplier supplier = supplierRepo.findById(supplierId).orElseThrow();
        si.setSupplier(supplier);
        si.setCreatedAt(LocalDateTime.now());
        si.setStatus(transactionStatusRepo.findById(1).get()); // Status 1: Pending Notification
        StockIn savedSi = stockInRepo.save(si);
        StringBuilder orderDetails = new StringBuilder();
        orderDetails.append("<table style='width: 100%; border-collapse: collapse; text-align: left;'>")
                .append("<tr>")
                .append("<th style='border-bottom: 1px solid #ddd; padding: 8px;'>SKU</th>")
                .append("<th style='border-bottom: 1px solid #ddd; padding: 8px;'>Product Name</th>")
                .append("<th style='border-bottom: 1px solid #ddd; padding: 8px;'>Qty Requested</th>")
                .append("</tr>");

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
            orderDetails.append("<tr>")
                    .append("<td style='padding: 8px; border-bottom: 1px solid #eee;'>").append(product.getProductId()).append("</td>")
                    .append("<td style='padding: 8px; border-bottom: 1px solid #eee;'>").append(product.getProductName()).append("</td>")
                    .append("<td style='padding: 8px; border-bottom: 1px solid #eee; font-weight: bold;'>").append(item.getQty()).append("</td>")
                    .append("</tr>");
        }
        orderDetails.append("</table>");
        if (supplier.getEmail() != null && !supplier.getEmail().isEmpty()) {
            emailService.notifySupplierForRestock(
                    supplier.getEmail(),
                    supplier.getSupplierName(),
                    "PO-" + savedSi.getStockInId(),
                    orderDetails.toString()
            );
        }
    }

    public List<StockIn> getPendingNotifications() {
        return stockInRepo.findByStatusId(1);
    }

    public StockIn getStockInForProcessing(Integer id) {
        return stockInRepo.findByStockInId(id);
    }

    public void processStaffInput(Integer stockInId, List<Map<String, Object>> actualData, Account staffAccount) {
        StockIn si = stockInRepo.findById(stockInId).orElseThrow();
        TransactionStatus status = transactionStatusRepo.findById(2)
                .orElseThrow(() -> new RuntimeException("Status not found"));

        si.setStaff(staffAccount.getEmployee());
        si.setReceivedAt(LocalDateTime.now());
        si.setStatus(status);
        stockInRepo.save(si);

        for (Map<String, Object> data : actualData) {
            StockInDetail detail = detailRepo.findById(Long.parseLong(data.get("detailId").toString()))
                    .orElseThrow(() -> new RuntimeException("Detail not found"));

            int actualQty = Integer.parseInt(data.get("actualQty").toString());
            detail.setReceivedQuantity(actualQty);
            detailRepo.save(detail);

            String productId = detail.getProduct().getProductId();
            Inventory inv = inventoryRepo.findById(productId).orElse(null);
            if (inv != null) {
                BigDecimal currentCost = inv.getUnitCost();
                BigDecimal newCost = detail.getUnitCost();
                if ((currentCost == null || currentCost.compareTo(BigDecimal.ZERO) == 0)
                        && newCost != null && newCost.compareTo(BigDecimal.ZERO) > 0) {

                    inv.setUnitCost(newCost);
                    inventoryRepo.save(inv);
                }
            }
        }

        String staffName = staffAccount.getEmployee().getFullName();
        emailService.notifyNewAction("Stock-In Approval", "STK-", si.getStockInId(), staffName);
    }

    //stock-in detail
    public StockIn getStockInById(Integer id) {
        return stockInRepo.findById(id).orElseThrow();
    }
}
