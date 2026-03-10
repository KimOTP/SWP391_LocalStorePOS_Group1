package com.swp391pos.dto;

import lombok.Data;

import java.math.BigDecimal;

@Data
public class PaymentRequest {
    private Long orderId;
    private BigDecimal amount;

    // [FIX] Them gatewayOrderCode va paymentSessionId
    // de gateway nhan du thong tin, khong dung request goc tu POS
    private String gatewayOrderCode;
    private String paymentSessionId;

}
