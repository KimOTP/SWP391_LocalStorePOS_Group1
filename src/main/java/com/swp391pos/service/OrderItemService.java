package com.swp391pos.service;

import com.swp391pos.entity.Order;
import com.swp391pos.entity.OrderItem;
import com.swp391pos.repository.OrderItemRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class OrderItemService {
    @Autowired
    private final OrderItemRepository orderItemRepository;

    //Lưu một OrderItem.
    @Transactional
    public OrderItem save(OrderItem orderItem) {
        return orderItemRepository.save(orderItem);
    }

    //Lấy danh sách OrderItem theo Order cha.
    @Transactional(readOnly = true)
    public List<OrderItem> findByOrder(Order order) {
        return orderItemRepository.findByOrder(order);
    }

    //Xóa toàn bộ OrderItem của một Order.
    @Transactional
    public void deleteByOrder(Order order) {
        orderItemRepository.deleteByOrder(order);
    }
}
