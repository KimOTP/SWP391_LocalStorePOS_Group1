package com.swp391pos.service;

import com.swp391pos.entity.Order;
import com.swp391pos.entity.Payment;
import com.swp391pos.repository.PaymentRepository;
import org.springframework.transaction.annotation.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class PaymentService {
    @Autowired
    private final PaymentRepository paymentRepository;

    // Lưu Payment.
    @Transactional(readOnly = true)
    public Payment save(Payment payment) {
        return paymentRepository.save(payment);
    }

    @Transactional(readOnly = true)
    public Optional<Payment> findById(Long paymentId) {
        return paymentRepository.findById(paymentId);
    }

    @Transactional(readOnly = true)
    public List<Payment> findByOrder(Order order) {
        return paymentRepository.findByOrder(order);
    }
}
