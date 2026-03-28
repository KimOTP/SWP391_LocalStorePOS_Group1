package com.swp391pos.service;

import com.swp391pos.entity.Inventory;
import com.swp391pos.repository.EmployeeRepository;
import com.swp391pos.repository.InventoryRepository;
import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.scheduling.annotation.Async;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class EmailService {
    @Autowired
    private JavaMailSender mailSender;
    @Autowired
    private EmployeeRepository employeeRepository;
    @Autowired
    private InventoryRepository inventoryRepository;
    @Async
    public void sendEmailToManagers(List<String> recipients, String subject, String htmlContent) {
        if (recipients == null || recipients.isEmpty()) return;
        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
            helper.setBcc(recipients.toArray(new String[0])); // Gửi ẩn danh sách người nhận
            helper.setSubject(subject);
            helper.setText(htmlContent, true);
            mailSender.send(message);
        } catch (MessagingException e) {
            System.err.println("Email Automation Error: " + e.getMessage());
        }
    }
    @Async
    public void notifyNewAction(String type, String prefix, Integer id, String staffName) {
        List<String> managers = employeeRepository.findAllManagerEmails();
        String subject = "[LocalStorePOS] New Approval Required: " + prefix + id;
        String content = "<div style='font-family: Arial; border-left: 4px solid #2563eb; padding: 20px; background: #f8fafc;'>" +
                "<h2 style='color: #1e293b;'>Pending Approval Notification</h2>" +
                "<p>Staff <b>" + staffName + "</b> has submitted a new <b>" + type + "</b> request.</p>" +
                "<p>Log ID: <span style='color: #2563eb; font-weight: bold;'>" + prefix + id + "</span></p>" +
                "<br>" +
                "<a href='http://localhost:8080/inventory/approval/queue' " +
                "style='display: inline-block; padding: 10px 20px; background: #2563eb; color: white; border-radius: 8px; text-decoration: none;'>Review Queue</a>" +
                "</div>";
        sendEmailToManagers(managers, subject, content);
    }
    @Async
    public void notifySupplierForRestock(String supplierEmail, String supplierName, String poNumber, String orderDetailsHtml) {
        String subject = "[LocalStorePOS] Purchase Order / Restock Request: " + poNumber;
        String content = "<div style='font-family: Arial; border-left: 4px solid #16a34a; padding: 20px; background: #f0fdf4;'>" +
                "<h2 style='color: #14532d;'>Restock Request</h2>" +
                "<p>Dear <b>" + supplierName + "</b>,</p>" +
                "<p>We would like to request a restock for our store. Please find the order details below:</p>" +
                "<p>Order Ref: <span style='color: #16a34a; font-weight: bold;'>" + poNumber + "</span></p>" +
                "<div style='background: white; padding: 15px; border-radius: 5px; margin-top: 10px; border: 1px solid #dcfce3;'>" +
                orderDetailsHtml +
                "</div>" +
                "<p>Please confirm the receipt of this request and provide an estimated delivery date.</p>" +
                "<p>Best regards,<br>LocalStorePOS Management</p>" +
                "</div>";

        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
            helper.setTo(supplierEmail);
            helper.setSubject(subject);
            helper.setText(content, true);
            mailSender.send(message);
        } catch (MessagingException e) {
            System.err.println("Supplier Email Error: " + e.getMessage());
        }
    }

    @Scheduled(cron = "0 35 7 * * ?")
    public void sendScheduledLowStockAlert() {
        List<Inventory> lowStockItems = inventoryRepository.findAllLowStock();
        if (lowStockItems == null || lowStockItems.isEmpty()) return;

        List<String> managers = employeeRepository.findAllManagerEmails();
        String subject = "[LocalStorePOS] DAILY CRITICAL: Low Stock Report (" + lowStockItems.size() + " items)";

        // Build bảng HTML
        StringBuilder content = new StringBuilder();
        content.append("<div style='font-family: Arial; border-top: 4px solid #dc2626; padding: 20px; background: #fff1f2;'>")
                .append("<h2 style='color: #991b1b;'>Daily Inventory Alert</h2>")
                .append("<p>The following items are below their minimum threshold and require immediate restocking:</p>")
                .append("<table style='width: 100%; border-collapse: collapse; margin-top: 15px; background: white;'>")
                .append("<tr style='background-color: #fecaca; text-align: left;'>")
                .append("<th style='padding: 10px; border: 1px solid #f87171;'>Product Name</th>")
                .append("<th style='padding: 10px; border: 1px solid #f87171;'>Current Stock</th>")
                .append("<th style='padding: 10px; border: 1px solid #f87171;'>Min Threshold</th>")
                .append("</tr>");
        for (Inventory inv : lowStockItems) {
            content.append("<tr>")
                    .append("<td style='padding: 10px; border: 1px solid #fca5a5;'><b>").append(inv.getProduct().getProductName()).append("</b></td>")
                    .append("<td style='padding: 10px; border: 1px solid #fca5a5; color: #dc2626; font-weight: bold;'>").append(inv.getCurrentQuantity()).append("</td>")
                    .append("<td style='padding: 10px; border: 1px solid #fca5a5;'>").append(inv.getMinThreshold()).append("</td>")
                    .append("</tr>");
        }
        content.append("</table>")
                .append("<br>")
                .append("<a href='http://localhost:8080/inventory/stock-in' style='display: inline-block; padding: 10px 20px; background: #dc2626; color: white; border-radius: 8px; text-decoration: none;'>Create Stock-in Request</a>")
                .append("</div>");
        sendEmailToManagers(managers, subject, content.toString());
    }
}