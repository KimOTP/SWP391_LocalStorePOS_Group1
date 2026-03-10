package com.swp391pos.controller.hr;

import com.swp391pos.entity.Account;
import com.swp391pos.entity.Notification;
import com.swp391pos.repository.NotificationRepository;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;

import java.util.List;

@ControllerAdvice
public class NotificationController {

    @Autowired
    private NotificationRepository notificationRepository;

    @ModelAttribute
    public void loadNotifications(Model model, HttpSession session){

        Account account = (Account) session.getAttribute("account");

        if(account == null) return;

        Integer empId = account.getEmployee().getEmployeeId();

        List<Notification> notifications =
                notificationRepository
                        .findTop10ByReceiver_EmployeeIdOrderByCreatedAtDesc(empId);

        List<Notification> unread =
                notificationRepository
                        .findByReceiver_EmployeeIdAndIsReadFalse(empId);

        model.addAttribute("todayNotifications", notifications);
        model.addAttribute("notificationCount", unread.size());
    }
}