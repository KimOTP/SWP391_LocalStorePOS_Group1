package com.swp391pos.service;

import com.swp391pos.entity.OrderStatus;
import com.swp391pos.repository.OrderStatusRepository;
import lombok.AllArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
@AllArgsConstructor
public class OrderStatusService {
    @Autowired
    private final OrderStatusRepository orderStatusRepository;

    public OrderStatus findByOrderStatusName(OrderStatus.OrderStatusName statusName) {
        return orderStatusRepository.findByOrderStatusName(statusName)
                .orElseThrow(() -> new RuntimeException("Order status not found: " + statusName));
    }


}
