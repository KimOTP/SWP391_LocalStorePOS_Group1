package com.swp391pos.dto;

public class PaymentResponse {
    private String qrCodeUrl;
    private String paymentSessionId;

    // [FIX] Them gatewayOrderCode de debug/trace de dang hon
    private String gatewayOrderCode;

    public String getQrCodeUrl() { return qrCodeUrl; }
    public void setQrCodeUrl(String s) { this.qrCodeUrl = s; }
    public String getPaymentSessionId() { return paymentSessionId; }
    public void setPaymentSessionId(String s) { this.paymentSessionId = s; }
    public String getGatewayOrderCode() { return gatewayOrderCode; }
    public void setGatewayOrderCode(String s) { this.gatewayOrderCode = s; }
}
