package com.swp391pos.service;

import com.swp391pos.dto.PaymentRequest;
import com.swp391pos.dto.PaymentResponse;
import com.swp391pos.dto.WebhookPayload;
import com.swp391pos.entity.Inventory;
import com.swp391pos.entity.Order;
import com.swp391pos.entity.OrderItem;
import com.swp391pos.entity.Payment;
import com.swp391pos.entity.PosReceipt;
import com.swp391pos.enums.PaymentMethod;
import com.swp391pos.enums.PaymentStatus;
import com.swp391pos.gateway.PaymentGateway;
import com.swp391pos.repository.InventoryRepository;
import com.swp391pos.repository.OrderItemRepository;
import com.swp391pos.repository.OrderRepository;
import com.swp391pos.repository.PaymentRepository;
import com.swp391pos.repository.PosReceiptRepository;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class PaymentService {

    private static final Logger log = LoggerFactory.getLogger(PaymentService.class);

    private static final int FALLBACK_THRESHOLD_SECONDS = 30;

    private final PaymentRepository paymentRepository;
    private final OrderRepository orderRepository;
    private final PaymentGateway paymentGateway;
    private final PosReceiptRepository posReceiptRepository;
    private final OrderItemRepository orderItemRepository;
    private final InventoryRepository inventoryRepository;
    private final ProductService productService;
    private final InventoryService inventoryService;
    private final OrderItemService orderItemService;

    // -------------------------------------------------------------------------
    // validateStockBeforePayment
    // -------------------------------------------------------------------------

    @Transactional(readOnly = true)
    public String validateStockBeforePayment(Long orderId) {
        Order order = orderRepository.findById(orderId).orElse(null);
        if (order == null) return "Order not found";

        List<OrderItem> items = orderItemService.findByOrder(order);
        for (OrderItem item : items) {
            if (item.getProduct() != null) {
                String productId = item.getProduct().getProductId();
                int required = item.getQuantity();
                int current = inventoryService.findById(productId).map(i -> i.getCurrentQuantity()).orElse(0);
                if (required > current) {
                    return "Not enough inventory for " + item.getProduct().getProductName() + ". Available: " + current + ", Required: " + required;
                }
            } else if (item.getCombo() != null) {
                for (com.swp391pos.entity.ComboDetail cd : item.getCombo().getComboDetails()) {
                    if (cd.getProduct() != null) {
                        String productId = cd.getProduct().getProductId();
                        int required = cd.getQuantity() * item.getQuantity();
                        int current = inventoryService.findById(productId).map(i -> i.getCurrentQuantity()).orElse(0);
                        if (required > current) {
                            return "Not enough inventory for " + cd.getProduct().getProductName() + " (in combo " + item.getCombo().getComboName() + "). Available: " + current + ", Required: " + required;
                        }
                    }
                }
            }
        }
        return null;
    }

    // -------------------------------------------------------------------------
    // CRUD cơ bản
    // -------------------------------------------------------------------------
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

    @Transactional(readOnly = true)
    public List<Payment> findByOrderId(Long orderId) {
        return paymentRepository.findByOrder_OrderId(orderId);
    }

    // -------------------------------------------------------------------------
    // createQR
    // -------------------------------------------------------------------------

    @Transactional
    public PaymentResponse createQR(PaymentRequest request) {
        Order order = orderRepository.findById(request.getOrderId())
                .orElseThrow(() -> new RuntimeException("Order not found: " + request.getOrderId()));

        String paymentSessionId = UUID.randomUUID().toString();
        String gatewayOrderCode = generateGatewayCode(order.getOrderId());

        Payment payment = new Payment();
        payment.setPaymentSessionId(paymentSessionId);
        payment.setOrder(order);
        payment.setGatewayOrderCode(gatewayOrderCode);
        payment.setAmount(request.getAmount());
        payment.setAmountPaid(BigDecimal.ZERO);
        payment.setChangeAmount(BigDecimal.ZERO);
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

        payment.setPaymentStatus(PaymentStatus.PAID);
        payment.setPaymentMethod(PaymentMethod.CASH);
        payment.setPaidAt(LocalDateTime.now());

        // vì @ManyToOne đã load sẵn (hoặc lazy load khi access)
        Order order = payment.getOrder();
        boolean isFirstPaymentForOrder = order.getPaidAt() == null;
        if (isFirstPaymentForOrder) {
            order.setPaidAt(LocalDateTime.now());
            // Nếu có setOrderStatus thì set ở đây:
            // order.setOrderStatus(orderStatusRepository.findByName("PAID"));
            orderRepository.save(order);
        }

        paymentRepository.save(payment);

        if (isFirstPaymentForOrder) {
            deductStockAfterPayment(order.getOrderId());
        }
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

        // Payment.order là @ManyToOne -> dùng thẳng, không cần query lại
        Order order = payment.getOrder();

        if (PaymentStatus.PAID.name().equals(payload.getStatus())) {
            payment.setPaymentStatus(PaymentStatus.PAID);
            payment.setPaidAt(LocalDateTime.now());
            payment.setAmountPaid(payment.getAmount());
            if (order != null) {
                boolean isFirstPaymentForOrder = order.getPaidAt() == null;
                if (isFirstPaymentForOrder) {
                    order.setPaidAt(LocalDateTime.now());
                    orderRepository.save(order);
                }

                if (isFirstPaymentForOrder) {
                    deductStockAfterPayment(order.getOrderId());
                }

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
                payment.setAmountPaid(payment.getAmount());

                Order order = payment.getOrder();
                if (order != null) {
                    boolean isFirstPaymentForOrder = order.getPaidAt() == null;
                    if (isFirstPaymentForOrder) {
                        order.setPaidAt(LocalDateTime.now());
                        orderRepository.save(order);
                        deductStockAfterPayment(order.getOrderId());
                    }
                }
            }

            paymentRepository.save(payment);
        }

        return gatewayStatus;
    }

    // -------------------------------------------------------------------------
    // Expire stale payments — chạy mỗi 1 phút
    // -------------------------------------------------------------------------

    @Scheduled(fixedRate = 60_000)
    @Transactional
    public void expireStalePayments() {
        LocalDateTime cutoff = LocalDateTime.now();

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

    private String generateGatewayCode(Long orderId) {
        // PayOS yêu cầu orderCode là số nguyên dương, unique, max 13 chữ số
        // Format: orderId (tối đa 7 chữ số) + 6 chữ số random → tổng 13 chữ số
        int random = (int)(Math.random() * 900000) + 100000; // 100000–999999
        return String.valueOf(orderId * 1_000_000L + random);
    }

    // -------------------------------------------------------------------------
    // deductStockAfterPayment — trừ tồn kho sau khi thanh toán thành công
    // -------------------------------------------------------------------------

    @Transactional
    public void deductStockAfterPayment(Long orderId) {
        List<OrderItem> items = orderItemRepository.findByOrder_OrderId(orderId);
        for (OrderItem item : items) {
            if (item.getProduct() != null) {
                deductProductStock(item.getProduct().getProductId(), item.getQuantity());
            } else if (item.getCombo() != null) {
                for (com.swp391pos.entity.ComboDetail cd : item.getCombo().getComboDetails()) {
                    if (cd.getProduct() != null) {
                        deductProductStock(cd.getProduct().getProductId(), cd.getQuantity() * item.getQuantity());
                    }
                }
            }
        }
    }

    private void deductProductStock(String productId, int quantityToDeduct) {
        Optional<Inventory> inventoryOpt = inventoryRepository.findById(productId);
        Inventory inventory;

        if (inventoryOpt.isEmpty()) {
            log.warn("[Stock] Inventory not found for productId={}, attempting to create default record", productId);
            try {
                com.swp391pos.entity.Product product = productService.getProductById(productId);
                if (product == null) {
                    log.error("[Stock] Cannot create inventory: Product {} not found", productId);
                    return;
                }
                inventory = new Inventory();
                inventory.setProduct(product);
                inventory.setCurrentQuantity(0);
                inventory = inventoryRepository.save(inventory);
                log.info("[Stock] Created missing inventory record for product {}", productId);
            } catch (Exception e) {
                log.error("[Stock] Failed to create inventory for product {}: {}", productId, e.getMessage());
                return;
            }
        } else {
            inventory = inventoryOpt.get();
        }

        int newQty = Math.max(0, inventory.getCurrentQuantity() - quantityToDeduct);
        inventory.setCurrentQuantity(newQty);
        inventoryRepository.save(inventory);

        productService.updateStockAndSyncStatus(productId, newQty);
        log.info("[Stock] Product {} deducted by {}, new qty={}", productId, quantityToDeduct, newQty);
    }
}