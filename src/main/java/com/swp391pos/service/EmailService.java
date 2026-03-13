package com.swp391pos.service;

import com.swp391pos.entity.Inventory;
import com.swp391pos.repository.EmployeeRepository;
import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class EmailService {
    @Autowired
    private JavaMailSender mailSender;
    @Autowired
    private EmployeeRepository employeeRepository;

    @Async
    public void sendEmailToManagers(List<String> recipients, String subject, String htmlContent) {
        if (recipients == null || recipients.isEmpty()) return;
        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
            helper.setBcc(recipients.toArray(new String[0])); // Use BCC for privacy
            helper.setSubject(subject);
            helper.setText(htmlContent, true);
            mailSender.send(message);
        } catch (MessagingException e) {
            System.err.println("Email Automation Error: " + e.getMessage());
        }
    }

    public void notifyNewAction(String type, String prefix, Integer id, String staffName) {
        List<String> managers = employeeRepository.findAllManagerEmails();
        String subject = "[LocalStorePOS] New Approval Required: " + prefix + id;
        String content = "<div style='font-family: Arial; border-left: 4px solid #2563eb; padding: 20px; background: #f8fafc;'>" +
                "<h2 style='color: #1e293b;'>Pending Approval Notification</h2>" +
                "<p>Staff <b>" + staffName + "</b> has submitted a new <b>" + type + "</b> request.</p>" +
                "<p>Log ID: <span style='color: #2563eb; font-weight: bold;'>" + prefix + id + "</span></p>" +
                "<a href='http://localhost:8080/inventory/approval/queue' " +
                "style='display: inline-block; padding: 10px 20px; background: #2563eb; color: white; border-radius: 8px; text-decoration: none;'>Review Queue</a>" +
                "</div>";
        sendEmailToManagers(managers, subject, content);
    }



    private void triggerLowStockEmail(Inventory inv) {
        List<String> managers = employeeRepository.findAllManagerEmails();
        String subject = "[LocalStorePOS] CRITICAL: Low Stock Alert - " + inv.getProduct().getProductName();
        String content = "<div style='font-family: Arial; border-top: 4px solid #dc2626; padding: 20px; background: #fff1f2;'>" +
                "<h2 style='color: #991b1b;'>Inventory Alert</h2>" +
                "<p>Product: <b>" + inv.getProduct().getProductName() + "</b> (SKU: " + inv.getProductId() + ")</p>" +
                "<p>Current Stock: <span style='color: #dc2626; font-weight: bold;'>" + inv.getCurrentQuantity() + "</span></p>" +
                "<p>Minimum Threshold: " + inv.getMinThreshold() + "</p>" +
                "<p>Please initiate a <b>Stock-in Request</b> immediately.</p>" +
                "</div>";
        sendEmailToManagers(managers, subject, content);
    }
}