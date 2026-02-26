package com.swp391pos.repository;

import com.swp391pos.entity.Order;
import com.swp391pos.entity.OrderItem;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface OrderItemRepository extends JpaRepository<OrderItem, Long> {

    // Lấy tất cả OrderItem của một Order.
    List<OrderItem> findByOrder(Order order);

    /**
     * Xóa tất cả OrderItem của một Order.
     * Dùng khi cần xóa thủ công trước khi xóa Order
     * (nếu không dùng CascadeType.REMOVE trong entity).
     *
     * @Modifying và @Transactional cần được thêm ở impl nếu dùng @Query,
     * nhưng Spring Data tự xử lý với deleteBy.
     */
    void deleteByOrder(Order order);
}