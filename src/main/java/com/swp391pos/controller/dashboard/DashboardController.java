package com.swp391pos.controller.dashboard;

import com.swp391pos.repository.ProductRepository;
import com.swp391pos.service.DashboardService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

@Controller
public class DashboardController {

    @Autowired
    private ProductRepository productRepository;

    @Autowired
    private DashboardService dashboardService;

    // Giả sử bạn có OrderRepository để đếm đơn hàng
    // @Autowired
    // private OrderRepository orderRepository;

    @GetMapping("/dashboard")
    public String showDashboard(Model model) {
        model.addAttribute("ordersToday",     dashboardService.getOrdersToday());
        model.addAttribute("totalProducts",   productRepository.count());
        model.addAttribute("currentDate",
                LocalDate.now().format(DateTimeFormatter.ofPattern("EEEE, MM/dd/yyyy")));

        return "dashboard/dashboard";
    }
}
