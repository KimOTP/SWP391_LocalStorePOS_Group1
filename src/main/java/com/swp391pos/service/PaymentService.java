package com.swp391pos.service;

import com.swp391pos.dto.PaymentRequest;
import com.swp391pos.dto.PaymentResponse;
import com.swp391pos.dto.WebhookPayload;
import com.swp391pos.entity.Order;
import com.swp391pos.entity.Payment;
import com.swp391pos.entity.PosReceipt;
import com.swp391pos.enums.PaymentMethod;
import com.swp391pos.enums.PaymentStatus;
import com.swp391pos.gateway.PaymentGateway;
import com.swp391pos.repository.OrderRepository;
import com.swp391pos.repository.PaymentRepository;
import com.swp391pos.repository.PosReceiptRepository;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class PaymentService {

    private static final Logger log = LoggerFactory.getLogger(PaymentService.class);

    private static final int FALLBACK_THRESHOLD_SECONDS = 30;

    // [FIX #1] Gộp lại thành 1 bộ field duy nhất, đặt tên thống nhất
    private final PaymentRepository paymentRepository;
    private final OrderRepository orderRepository;
    private final PaymentGateway paymentGateway;
    private final PosReceiptRepository posReceiptRepository;

    // -------------------------------------------------------------------------
    // CRUD cơ bản
    // -------------------------------------------------------------------------

    // [FIX #2] Bỏ readOnly = true trên write operation
    @Transactional
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

    // -------------------------------------------------------------------------
    // createQR
    // -------------------------------------------------------------------------

    @Transactional
    public PaymentResponse createQR(PaymentRequest request) {
        // [FIX #4] findById trả về Order entity, ép đúng kiểu
        Order order = orderRepository.findById(request.getOrderId())
                .orElseThrow(() -> new RuntimeException("Order not found: " + request.getOrderId()));

        String paymentSessionId = UUID.randomUUID().toString();
        String gatewayOrderCode = generateGatewayCode();

        Payment payment = new Payment();
        payment.setPaymentSessionId(paymentSessionId);
        payment.setOrder(order);                          // [FIX #4] setOrder() nhận Order object, không phải Long
        payment.setGatewayOrderCode(gatewayOrderCode);
        payment.setAmount(request.getAmount());
        payment.setPaymentMethod(PaymentMethod.BANKING);
        payment.setPaymentStatus(PaymentStatus.PENDING);

        paymentRepository.save(payment);

        PaymentRequest gatewayRequest = new PaymentRequest();
        gatewayRequest.setOrderId(request.getOrderId());
        gatewayRequest.setAmount(request.getAmount());
        gatewayRequest.setGatewayOrderCode(gatewayOrderCode);
        gatewayRequest.setPaymentSessionId(paymentSessionId);

        return paymentGateway.createQR(gatewayRequest);
    }

    // -------------------------------------------------------------------------
    // payCash
    // -------------------------------------------------------------------------

    @Transactional
    public void payCash(String paymentSessionId) {
        Payment payment = paymentRepository.findByPaymentSessionId(paymentSessionId)
                .orElseThrow(() -> new RuntimeException("Payment not found: " + paymentSessionId));

        if (PaymentStatus.PAID.equals(payment.getPaymentStatus())) {
            throw new IllegalStateException("Payment already completed for session: " + paymentSessionId);
        }

        if (PaymentStatus.EXPIRED.equals(payment.getPaymentStatus())) {
            throw new IllegalStateException("Payment session has expired: " + paymentSessionId);
        }

        // [FIX #3] getPaymentStatus() không nhận argument -> phải dùng setPaymentStatus()
        payment.setPaymentStatus(PaymentStatus.PAID);
        payment.setPaymentMethod(PaymentMethod.CASH);
        payment.setPaidAt(LocalDateTime.now());

        // [FIX #5] payment.getOrder() trả về Order entity, không cần findById nữa
        // vì @ManyToOne đã load sẵn (hoặc lazy load khi access)
        Order order = payment.getOrder();
        order.setPaidAt(LocalDateTime.now());
        // Nếu có setOrderStatus thì set ở đây:
        // order.setOrderStatus(orderStatusRepository.findByName("PAID"));

        paymentRepository.save(payment);
        orderRepository.save(order);
    }

    // -------------------------------------------------------------------------
    // handleWebhook
    // -------------------------------------------------------------------------

    @Transactional
    public void handleWebhook(WebhookPayload payload) {
        Payment payment = paymentRepository.findByGatewayOrderCode(payload.getGatewayOrderCode())
                .orElse(null);

        if (payment == null) return;

        if (PaymentStatus.PAID.equals(payment.getPaymentStatus())) return;

        payment.setTransactionId(payload.getTransactionId());

        // [FIX #5] Dùng payment.getOrder() thay vì orderRepo.findById(payment.getOrderId())
        // Payment.order là @ManyToOne -> dùng thẳng, không cần query lại
        Order order = payment.getOrder();

        if (PaymentStatus.PAID.name().equals(payload.getStatus())) {
            payment.setPaymentStatus(PaymentStatus.PAID);
            payment.setPaidAt(LocalDateTime.now());
            if (order != null) {
                order.setPaidAt(LocalDateTime.now());
                orderRepository.save(order);

                // Tạo PosReceipt cho thanh toán online (QR/Banking)
                boolean receiptExists = posReceiptRepository
                        .findByReceiptNumber("RCP-" + order.getOrderId() + "-ONLINE")
                        .isPresent();
                if (!receiptExists) {
                    PosReceipt receipt = new PosReceipt();
                    receipt.setOrder(order);
                    receipt.setReceiptNumber("RCP-" + order.getOrderId() + "-" + System.currentTimeMillis());
                    receipt.setPrintedAt(LocalDateTime.now());
                    receipt.setPrintedBy(order.getEmployee());
                    posReceiptRepository.save(receipt);
                    log.info("[Webhook] PosReceipt created for orderId={}", order.getOrderId());
                }
            }
        } else if (PaymentStatus.CANCELLED.name().equals(payload.getStatus())
                || PaymentStatus.FAILED.name().equals(payload.getStatus())) {
            payment.setPaymentStatus(PaymentStatus.valueOf(payload.getStatus()));
        }

        paymentRepository.save(payment);
        log.info("[Webhook] payment={} -> status={}", payment.getPaymentSessionId(), payment.getPaymentStatus());
    }

    // -------------------------------------------------------------------------
    // getPaymentStatus — có fallback khi webhook fail
    // -------------------------------------------------------------------------

    @Transactional
    public PaymentStatus getPaymentStatus(String paymentSessionId) {
        Payment payment = paymentRepository.findByPaymentSessionId(paymentSessionId)
                .orElse(null);

        if (payment == null) return null;

        if (!PaymentStatus.PENDING.equals(payment.getPaymentStatus())) {
            return payment.getPaymentStatus();
        }

        LocalDateTime fallbackThreshold = payment.getCreatedAt()
                .plusSeconds(FALLBACK_THRESHOLD_SECONDS);

        if (LocalDateTime.now().isBefore(fallbackThreshold)) {
            return PaymentStatus.PENDING;
        }

        log.warn("[Fallback] Payment {} PENDING > {}s, checking PayOS directly",
                paymentSessionId, FALLBACK_THRESHOLD_SECONDS);

        return applyGatewayFallback(payment);
    }

    private PaymentStatus applyGatewayFallback(Payment payment) {
        PaymentStatus gatewayStatus;

        try {
            gatewayStatus = paymentGateway.checkPaymentStatus(payment.getGatewayOrderCode());
        } catch (Exception e) {
            log.error("[Fallback] Gateway call failed for payment={}: {}",
                    payment.getPaymentSessionId(), e.getMessage());
            return PaymentStatus.PENDING;
        }

        if (gatewayStatus == null) {
            return PaymentStatus.PENDING;
        }

        if (!gatewayStatus.equals(payment.getPaymentStatus())) {
            log.info("[Fallback] Reconciling payment={}: {} -> {}",
                    payment.getPaymentSessionId(), payment.getPaymentStatus(), gatewayStatus);

            payment.setPaymentStatus(gatewayStatus);

            if (PaymentStatus.PAID.equals(gatewayStatus)) {
                payment.setPaidAt(LocalDateTime.now());

                // [FIX #5] Dùng payment.getOrder() thay vì query lại
                Order order = payment.getOrder();
                if (order != null) {
                    order.setPaidAt(LocalDateTime.now());
                    orderRepository.save(order);
                }
            }

            paymentRepository.save(payment);
        }

        return gatewayStatus;
    }

    // -------------------------------------------------------------------------
    // cancelPayment
    // -------------------------------------------------------------------------

    @Transactional
    public void cancelPayment(String paymentSessionId) {
        Payment payment = paymentRepository.findByPaymentSessionId(paymentSessionId)
                .orElseThrow(() -> new RuntimeException("Payment not found: " + paymentSessionId));

        if (PaymentStatus.PAID.equals(payment.getPaymentStatus())) {
            throw new IllegalStateException("Cannot cancel a PAID payment");
        }

        payment.setPaymentStatus(PaymentStatus.CANCELLED);
        paymentRepository.save(payment);
    }

    // -------------------------------------------------------------------------
    // Expire stale payments — chạy mỗi 1 phút
    // -------------------------------------------------------------------------

    @Scheduled(fixedRate = 60_000)
    @Transactional
    public void expireStalePayments() {
        LocalDateTime cutoff = LocalDateTime.now();
        // [FIX #7] findByPaymentStatusAndExpiredAtBefore (đúng field name trong Payment entity)
        List<Payment> stale = paymentRepository.findByPaymentStatusAndExpiredAtBefore(
                PaymentStatus.PENDING, cutoff);

        for (Payment p : stale) {
            p.setPaymentStatus(PaymentStatus.EXPIRED);
        }

        if (!stale.isEmpty()) {
            paymentRepository.saveAll(stale);
            log.info("[Scheduler] Expired {} stale payments", stale.size());
        }
    }

    // -------------------------------------------------------------------------
    // Helpers
    // -------------------------------------------------------------------------

    private String generateGatewayCode() {
        return String.valueOf(System.currentTimeMillis() % 1_000_000_000_000L);
    }
}