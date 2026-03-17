package com.swp391pos.service;

import com.swp391pos.repository.OrderRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

@Service
public class DashboardService {

    @Autowired
    private OrderRepository orderRepository;

    private LocalDateTime[] getTodayRange() {
        LocalDateTime startOfDay = LocalDate.now().atStartOfDay();           // 00:00:00
        LocalDateTime endOfDay   = LocalDate.now().atTime(LocalTime.MAX);    // 23:59:59.999
        return new LocalDateTime[]{startOfDay, endOfDay};
    }

    public long getOrdersToday() {
        LocalDateTime[] range = getTodayRange();
        return orderRepository.countOrdersToday(range[0], range[1]);
    }
}