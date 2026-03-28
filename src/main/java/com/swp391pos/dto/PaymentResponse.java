package com.swp391pos.dto;

import lombok.Data;

@Data
public class PaymentResponse {
    private String qrCodeUrl;
    private String checkoutUrl;      // URL trang PayOS có QR VietQR đẹp
    private String paymentSessionId;
    private String gatewayOrderCode;
}