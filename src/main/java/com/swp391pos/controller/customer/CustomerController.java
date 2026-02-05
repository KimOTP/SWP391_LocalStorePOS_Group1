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
    public String listCustomer(Model model, @RequestParam(name = "keyword", required = false) String keyword) {

        List<Customer> customers = customerService.getCustomers(keyword);
        model.addAttribute("customers", customers);
        model.addAttribute("keyword", keyword);
        model.addAttribute("totalCustomer", customerService.getTotalCustomers());
        model.addAttribute("totalPoints", customerService.getTotalPoints());
        model.addAttribute("totalSpending", customerService.getTotalSpending());
        model.addAttribute("avgSpending", customerService.getAverageSpending());
        return "customer/customer-list";
    }
}
