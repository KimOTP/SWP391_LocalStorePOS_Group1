package com.swp391pos.controller.customer;


import com.swp391pos.entity.Customer;
import com.swp391pos.service.CustomerService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;

@Controller
@RequestMapping("/customers")
public class CustomerController {
    @Autowired
    private CustomerService customerService;
    @GetMapping
    public String listCustomers(Model model,
                                @RequestParam(required = false) String keyword,
                                @RequestParam(required = false) Integer minPoint,
                                @RequestParam(required = false) Integer status,    // Mới thêm
                                @RequestParam(required = false) String timePeriod) { // Mới thêm

        // 1. Gọi Service "Ultimate"
        List<Customer> customers = customerService.getCustomers(keyword, minPoint, status, timePeriod);
        model.addAttribute("customers", customers);

        // 2. Trả lại giá trị cho View để giữ trạng thái Selected
        model.addAttribute("keyword", keyword);
        model.addAttribute("minPoint", minPoint);
        model.addAttribute("status", status);
        model.addAttribute("timePeriod", timePeriod);

        // 3. Stats (Giữ nguyên)
        model.addAttribute("totalCustomer", customerService.getTotalCustomers());
        model.addAttribute("totalPoints", customerService.getTotalPoints());
        model.addAttribute("totalSpending", customerService.getTotalSpending());
        model.addAttribute("avgSpending", customerService.getAverageSpending());

        return "customer/customer-list";
    }
}
