package com.swp391pos.dto;

import lombok.Data;

@Data
public class PaymentResponse {
    private String qrCodeUrl;
    private String checkoutUrl;
    private String paymentSessionId;
    private String gatewayOrderCode;
}