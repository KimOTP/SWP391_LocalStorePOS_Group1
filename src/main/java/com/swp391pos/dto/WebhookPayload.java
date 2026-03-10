package com.swp391pos.dto;

import java.math.BigDecimal;

public class WebhookPayload {
    private String gatewayOrderCode;
    private String transactionId;
    private BigDecimal amount;

    // PAID | FAILED | CANCELLED
    private String status;

    // PayOS signature fields
    private String signature;

    public String getGatewayOrderCode() { return gatewayOrderCode; }
    public void setGatewayOrderCode(String s) { this.gatewayOrderCode = s; }
    public String getTransactionId() { return transactionId; }
    public void setTransactionId(String s) { this.transactionId = s; }
    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal a) { this.amount = a; }
    public String getStatus() { return status; }
    public void setStatus(String s) { this.status = s; }
    public String getSignature() { return signature; }
    public void setSignature(String s) { this.signature = s; }
}
