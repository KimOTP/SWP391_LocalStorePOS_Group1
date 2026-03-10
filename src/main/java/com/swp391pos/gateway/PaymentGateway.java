package com.swp391pos.gateway;

import com.swp391pos.dto.PaymentRequest;
import com.swp391pos.dto.PaymentResponse;
import com.swp391pos.enums.PaymentStatus;

public interface PaymentGateway {

    /**
     * Tao QR payment, tra ve QR URL va session info.
     */
    PaymentResponse createQR(PaymentRequest request);

    /**
     * Fallback: chu dong check trang thai payment tren gateway.
     *
     * Duoc goi khi webhook FAIL (timeout/network) va payment van PENDING
     * qua nguong thoi gian cho phep (mac dinh: 30 giay).
     *
     * @param gatewayOrderCode ma don hang phia gateway (PayOS order code)
     * @return trang thai hien tai tren gateway, null neu khong xac dinh duoc
     */
    PaymentStatus checkPaymentStatus(String gatewayOrderCode);
}
