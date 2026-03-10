package com.swp391pos.dto;

import java.math.BigDecimal;

public class PaymentRequest {
    private Long orderId;
    private BigDecimal amount;

    // [FIX] Them gatewayOrderCode va paymentSessionId
    // de gateway nhan du thong tin, khong dung request goc tu POS
    private String gatewayOrderCode;
    private String paymentSessionId;

    public Long getOrderId() { return orderId; }
    public void setOrderId(Long orderId) { this.orderId = orderId; }
    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }
    public String getGatewayOrderCode() { return gatewayOrderCode; }
    public void setGatewayOrderCode(String s) { this.gatewayOrderCode = s; }
    public String getPaymentSessionId() { return paymentSessionId; }
    public void setPaymentSessionId(String s) { this.paymentSessionId = s; }
}
