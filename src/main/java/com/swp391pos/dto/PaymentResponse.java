package com.swp391pos.dto;

import lombok.Data;

@Data
public class PaymentResponse {
    private String qrCodeUrl;
    private String paymentSessionId;

    //Them gatewayOrderCode de debug/trace de dang hon
    private String gatewayOrderCode;

}
