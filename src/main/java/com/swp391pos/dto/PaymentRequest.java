package com.swp391pos.dto;

import lombok.Data;

import java.math.BigDecimal;

@Data
public class PaymentRequest {
    private Long orderId;
    private BigDecimal amount;
    private String gatewayOrderCode;
    private String paymentSessionId;

}
