package com.swp391pos.repository;

import com.swp391pos.entity.Order;
import com.swp391pos.entity.Payment;
import com.swp391pos.enums.PaymentStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface PaymentRepository extends JpaRepository<Payment, Long> {
    // Lấy tất cả Payment của một Order.
    List<Payment> findByOrder(Order order);

    Optional<Payment> findByPaymentSessionId(String paymentSessionId);

    Optional<Payment> findByGatewayOrderCode(String gatewayOrderCode);

    //Dung cho scheduled job expire PENDING payments
    List<Payment> findByPaymentStatusAndExpiredAtBefore(PaymentStatus paymentStatus, LocalDateTime cutoff);

    // Lấy tất cả Payment theo orderId – dùng cho receipt detail API.
    List<Payment> findByOrder_OrderId(Long orderId);
}