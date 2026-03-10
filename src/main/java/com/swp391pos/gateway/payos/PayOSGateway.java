package com.swp391pos.gateway.payos;

import com.swp391pos.dto.PaymentRequest;
import com.swp391pos.dto.PaymentResponse;
import com.swp391pos.enums.PaymentStatus;
import com.swp391pos.gateway.PaymentGateway;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

@Service
public class PayOSGateway implements PaymentGateway {

    private static final Logger log = LoggerFactory.getLogger(PayOSGateway.class);

    @Override
    public PaymentResponse createQR(PaymentRequest request) {
        // TODO: Goi PayOS API that su
        // request da co day du thong tin: orderId, amount, gatewayOrderCode, paymentSessionId

        PaymentResponse response = new PaymentResponse();
        response.setQrCodeUrl("https://pay.payos.vn/qr/" + request.getGatewayOrderCode());
        response.setPaymentSessionId(request.getPaymentSessionId());
        response.setGatewayOrderCode(request.getGatewayOrderCode());
        return response;
    }

    /**
     * Chu dong check trang thai payment tren PayOS.
     *
     * PayOS API: GET /v2/payment-requests/{orderCode}
     * Response chua truong "status": PENDING | PAID | CANCELLED | EXPIRED
     *
     * @return PaymentStatus mapped tu PayOS, hoac null neu call that bai
     */
    @Override
    public PaymentStatus checkPaymentStatus(String gatewayOrderCode) {
        try {
            // TODO: Goi PayOS GET /v2/payment-requests/{orderCode} that su
            // PayOSPaymentInfo info = payOSClient.getPaymentInfo(gatewayOrderCode);
            // return mapStatus(info.getStatus());

            // --- Placeholder cho den khi co PayOS client that ---
            log.info("[PayOSGateway] checkPaymentStatus called for orderCode={}", gatewayOrderCode);
            return null; // null = khong xac dinh duoc, service se giu PENDING

        } catch (Exception e) {
            // Khong throw: de service xu ly gracefully, khong crash UI
            log.warn("[PayOSGateway] checkPaymentStatus failed for orderCode={}: {}",
                    gatewayOrderCode, e.getMessage());
            return null;
        }
    }

    /**
     * Map trang thai PayOS sang PaymentStatus noi bo.
     * PayOS status: PENDING, PAID, CANCELLED, EXPIRED
     */
    private PaymentStatus mapStatus(String payosStatus) {
        if (payosStatus == null) return null;
        return switch (payosStatus.toUpperCase()) {
            case "PAID"      -> PaymentStatus.PAID;
            case "CANCELLED" -> PaymentStatus.CANCELLED;
            case "EXPIRED"   -> PaymentStatus.EXPIRED;
            default          -> PaymentStatus.PENDING;
        };
    }
}
