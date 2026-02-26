package com.swp391pos.service;

import com.swp391pos.entity.Order;
import com.swp391pos.repository.OrderRepository;
import lombok.AllArgsConstructor;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@AllArgsConstructor
public class OrderService {

    @Autowired
    private final OrderRepository orderRepository;

    public Order findById(Long id) {
        // findById trả về Optional<Order>
        return orderRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("No orders found with that ID: " + id));
    }

    /**
     * Lưu Order.
     * Hoạt động:
     *   - Nếu order.orderId == null  → INSERT (tạo đơn DRAFT mới)
     *   - Nếu order.orderId != null  → UPDATE (đổi status sang COMPLETED / CANCELLED)
     * @Transactional đảm bảo nếu có lỗi giữa chừng thì rollback,
     * tránh tình trạng Order được lưu nhưng OrderItems thì không.
     */

    @Transactional
    public Order save(Order order) {
        return orderRepository.save(order);
    }

    @Transactional(readOnly = true)
    public List<Order> findAll() {
        return orderRepository.findAll();
    }

    @Transactional
    public void deleteById(Long orderId) {
        orderRepository.deleteById(orderId);
    }
}
