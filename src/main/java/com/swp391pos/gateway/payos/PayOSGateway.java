package com.swp391pos.gateway.payos;

import com.swp391pos.dto.PaymentRequest;
import com.swp391pos.dto.PaymentResponse;
import com.swp391pos.enums.PaymentStatus;
import com.swp391pos.gateway.PaymentGateway;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import vn.payos.PayOS;
import vn.payos.model.v2.paymentRequests.CreatePaymentLinkRequest;
import vn.payos.model.v2.paymentRequests.CreatePaymentLinkResponse;
import vn.payos.model.v2.paymentRequests.PaymentLink;
import vn.payos.model.v2.paymentRequests.PaymentLinkStatus;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

@Service
public class PayOSGateway implements PaymentGateway {

    private static final Logger log = LoggerFactory.getLogger(PayOSGateway.class);

    private final PayOS payOS;

    @Value("${payos.return-url:http://localhost:8080/pos/payment/banking-return}")
    private String returnUrl;

    @Value("${payos.cancel-url:http://localhost:8080/pos/payment/banking-cancel}")
    private String cancelUrl;

    public PayOSGateway(PayOS payOS) {
        this.payOS = payOS;
    }

    /**
     * Kiểm tra PayOS có available không bằng cách gọi API lấy thông tin 1 orderCode giả.
     * Nếu PayOS trả về lỗi network/503/maintenance → false.
     * Nếu trả về 404 (order not found) → server vẫn hoạt động → true.
     */
    @Override
    public boolean isAvailable() {
        try {
            payOS.paymentRequests().get(1L); // orderCode 1 chắc chắn không tồn tại
            return true;
        } catch (Exception e) {
            String msg = e.getMessage() != null ? e.getMessage().toLowerCase() : "";
            // 404 = server hoạt động, chỉ không tìm thấy order → OK
            if (msg.contains("not found") || msg.contains("404") || msg.contains("payment link not found")) {
                return true;
            }
            // Maintenance, network error, 503 → false
            log.warn("[PayOS] isAvailable check failed: {}", e.getMessage());
            return false;
        }
    }

    @Override
    public PaymentResponse createQR(PaymentRequest request) {
        try {
            long orderCode = Long.parseLong(request.getGatewayOrderCode());
            long amount    = request.getAmount().longValue();

            CreatePaymentLinkRequest paymentData = CreatePaymentLinkRequest.builder()
                    .orderCode(orderCode)
                    .amount(amount)
                    .description("Don hang " + request.getOrderId())
                    .returnUrl(returnUrl)
                    .cancelUrl(cancelUrl)
                    .build();

            CreatePaymentLinkResponse data = payOS.paymentRequests().create(paymentData);

            // getQrCode() trả về chuỗi EMV QR raw (00020101...)
            // Dùng Google Chart API để render thành ảnh PNG
            String emvQrRaw = data.getQrCode();
            String qrImageUrl = buildQrImageUrl(emvQrRaw);

            PaymentResponse response = new PaymentResponse();
            response.setQrCodeUrl(qrImageUrl);
            response.setCheckoutUrl(data.getCheckoutUrl());
            response.setPaymentSessionId(request.getPaymentSessionId());
            response.setGatewayOrderCode(request.getGatewayOrderCode());

            log.info("[PayOS] Created link for order={}, orderCode={}", request.getOrderId(), orderCode);
            return response;

        } catch (Exception e) {
            log.error("[PayOS] createQR failed for order={}: {}", request.getOrderId(), e.getMessage());
            PaymentResponse fallback = new PaymentResponse();
            fallback.setPaymentSessionId(request.getPaymentSessionId());
            fallback.setGatewayOrderCode(request.getGatewayOrderCode());
            fallback.setQrCodeUrl(null);
            return fallback;
        }
    }

    /**
     * Build URL ảnh QR từ chuỗi EMV raw dùng qrserver.com API.
     * https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=<encoded>
     */
    private String buildQrImageUrl(String emvQrRaw) {
        try {
            String encoded = URLEncoder.encode(emvQrRaw, StandardCharsets.UTF_8);
            return "https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=" + encoded;
        } catch (Exception e) {
            return null;
        }
    }

    @Override
    public PaymentStatus checkPaymentStatus(String gatewayOrderCode) {
        try {
            long orderCode = Long.parseLong(gatewayOrderCode);
            PaymentLink data = payOS.paymentRequests().get(orderCode);
            PaymentLinkStatus status = data.getStatus();
            log.info("[PayOS] checkStatus orderCode={} -> {}", orderCode, status);
            return mapStatus(status);
        } catch (Exception e) {
            log.warn("[PayOS] checkPaymentStatus failed for orderCode={}: {}", gatewayOrderCode, e.getMessage());
            return null;
        }
    }

    private PaymentStatus mapStatus(PaymentLinkStatus payosStatus) {
        if (payosStatus == null) return null;
        return switch (payosStatus) {
            case PAID      -> PaymentStatus.PAID;
            case CANCELLED -> PaymentStatus.CANCELLED;
            case EXPIRED   -> PaymentStatus.EXPIRED;
            default        -> PaymentStatus.PENDING;
        };
    }
}