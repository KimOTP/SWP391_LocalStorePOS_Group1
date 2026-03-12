package com.swp391pos.controller.hr;

import com.swp391pos.entity.Account;
import com.swp391pos.entity.Note;
import com.swp391pos.entity.Notification;
import com.swp391pos.repository.NoteRepository;
import com.swp391pos.repository.NotificationRepository;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;

import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

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

        LocalDate today = LocalDate.now();

        List<Notification> todayNotifications = notifications.stream()
                .filter(n -> n.getCreatedAt().toLocalDate().equals(today))
                .collect(Collectors.toList());

        List<Notification> oldNotifications = notifications.stream()
                .filter(n -> !n.getCreatedAt().toLocalDate().equals(today))
                .collect(Collectors.toList());

        List<Notification> unread =
                notificationRepository
                        .findByReceiver_EmployeeIdAndIsReadFalse(empId);

        model.addAttribute("todayNotifications", todayNotifications);
        model.addAttribute("oldNotifications", oldNotifications);
        model.addAttribute("notificationCount", unread.size());
    }
}