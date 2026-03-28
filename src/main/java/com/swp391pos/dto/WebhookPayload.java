package com.swp391pos.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import java.math.BigDecimal;

/**
 * PayOS webhook payload format:
 * {
 *   "code": "00",
 *   "desc": "success",
 *   "data": {
 *     "orderCode": 123456,
 *     "amount": 50000,
 *     "description": "...",
 *     "accountNumber": "...",
 *     "reference": "TXN_ID",
 *     "transactionDateTime": "...",
 *     "currency": "VND",
 *     "paymentLinkId": "...",
 *     "code": "00",
 *     "desc": "Thành công",
 *     "counterAccountBankId": "...",
 *     "counterAccountBankName": "...",
 *     "counterAccountName": "...",
 *     "counterAccountNumber": "...",
 *     "virtualAccountName": "...",
 *     "virtualAccountNumber": "..."
 *   },
 *   "signature": "abc123..."
 * }
 */
@Data
@JsonIgnoreProperties(ignoreUnknown = true)
public class WebhookPayload {

    private String code;
    private String desc;
    private WebhookData data;
    private String signature;

    @Data
    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class WebhookData {
        private Long orderCode;
        private BigDecimal amount;
        private String description;
        private String accountNumber;
        private String reference;          // transaction ID
        private String transactionDateTime;
        private String currency;
        private String paymentLinkId;
        private String code;               // "00" = success
        private String desc;
        private String counterAccountBankId;
        private String counterAccountBankName;
        private String counterAccountName;
        private String counterAccountNumber;
        private String virtualAccountName;
        private String virtualAccountNumber;
    }

    // ── Convenience helpers cho service/verifier ──────────────────────────────

    public String getGatewayOrderCode() {
        return data != null && data.getOrderCode() != null
                ? String.valueOf(data.getOrderCode()) : null;
    }

    public String getTransactionId() {
        return data != null ? data.getReference() : null;
    }

    public BigDecimal getAmount() {
        return data != null ? data.getAmount() : null;
    }

    /**
     * PayOS code "00" trong data.code = thanh toán thành công.
     * Map sang internal status string.
     */
    public String getStatus() {
        if (data == null || data.getCode() == null) return "FAILED";
        return "00".equals(data.getCode()) ? "PAID" : "FAILED";
    }
}