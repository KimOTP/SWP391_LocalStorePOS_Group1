package com.swp391pos.dto;

import lombok.Data;

import java.math.BigDecimal;

@Data
public class WebhookPayload {
    private String gatewayOrderCode;
    private String transactionId;
    private BigDecimal amount;

    // PAID | FAILED | CANCELLED
    private String status;

    // PayOS signature fields
    private String signature;

}
