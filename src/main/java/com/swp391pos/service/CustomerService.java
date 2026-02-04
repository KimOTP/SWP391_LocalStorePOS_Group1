package com.swp391pos.service;


import com.swp391pos.entity.Customer;
import com.swp391pos.repository.CustomerRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;

@Service
public class CustomerService {
    @Autowired
    private CustomerRepository customerRepository;
    public List<Customer> getAllCustomer() {
        return customerRepository.findAll();
    }
    //các hàm thống kê ở màn customer-management
    public long getTotalCustomers() {
        return customerRepository.count();
    }
    public Long getTotalPoints() {
        Long points = customerRepository.sumTotalPoints();
        return (points != null) ? points : 0L;
    }
    public BigDecimal getTotalSpending() {
        BigDecimal total = customerRepository.sumTotalSpending();
        return (total != null) ? total : BigDecimal.ZERO;
    }
    public BigDecimal getAverageSpending() {
        long count = getTotalCustomers();
        BigDecimal total = getTotalSpending();
        if(count == 0) return BigDecimal.ZERO;
        return total.divide(BigDecimal.valueOf(count), 0, RoundingMode.HALF_UP);
    }
    public List<Customer> getCustomers(String keyword) {
        if(keyword != null && !keyword.trim().isEmpty()) {
            return customerRepository.searchByNameOrPhone(keyword);
        }
        return customerRepository.findAll();
    }
}
