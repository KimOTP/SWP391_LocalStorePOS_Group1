package com.swp391pos.controller.customer;


import com.swp391pos.entity.Customer;
import com.swp391pos.service.CustomerService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.List;

@Controller
@RequestMapping("/customers")
public class CustomerController {
    @Autowired
    private CustomerService customerService;
    @GetMapping
    public String listCustomer(Model model) {
        List<Customer> customers = customerService.getAllCustomer();
        model.addAttribute("customers", customers);
        model.addAttribute("totalCustomer", customerService.getTotalCustomers());
        model.addAttribute("totalPoint", customerService.getTotalPoints());
        model.addAttribute("totalSpending", customerService.getTotalSpending());
        model.addAttribute("avgSpending", customerService.getAverageSpending());
        return "customer/customer-list";
    }
}
