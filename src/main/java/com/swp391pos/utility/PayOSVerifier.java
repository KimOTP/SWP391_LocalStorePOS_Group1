package com.swp391pos.utility;

import com.swp391pos.dto.WebhookPayload;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.util.HexFormat;

/**
 * Verify HMAC-SHA256 signature từ PayOS webhook.
 *
 * PayOS tạo signature bằng cách sort các field trong data theo alphabet,
 * nối thành chuỗi key=value&key=value rồi HMAC-SHA256 với checksumKey.
 *
 * Các field PayOS dùng để tạo signature (theo tài liệu chính thức):
 * amount, canceledAt, cancellationReason, code, createdAt, description,
 * expiredAt, id, orderCode, paymentLinkId, status, transactions
 *
 * Tuy nhiên với webhook event (payment success), PayOS dùng các field:
 * amount, code, desc, orderCode, reference (sorted alphabetically)
 */
@Component
public class PayOSVerifier {

    @Value("${payos.checksum-key}")
    private String checksumKey;

    /**
     * Verify webhook signature từ PayOS.
     * PayOS ký trên toàn bộ data object, sort key alphabetically.
     */
    public boolean verify(WebhookPayload payload) {
        if (payload == null || payload.getSignature() == null || payload.getData() == null) {
            return false;
        }
        try {
            String dataString = buildDataString(payload);
            String computed   = hmacSHA256(dataString, checksumKey);
            return computed.equalsIgnoreCase(payload.getSignature());
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * Build chuỗi data theo đúng format PayOS yêu cầu:
     * Sort theo alphabet, nối key=value&key=value
     * (chỉ include các field có giá trị non-null)
     */
    private String buildDataString(WebhookPayload payload) {
        WebhookPayload.WebhookData d = payload.getData();

        // PayOS sort theo alphabet: accountNumber, amount, description, orderCode, reference, transactionDateTime
        StringBuilder sb = new StringBuilder();

        appendIfNotNull(sb, "accountNumber",  d.getAccountNumber());
        appendIfNotNull(sb, "amount",          d.getAmount() != null ? d.getAmount().toPlainString() : null);
        appendIfNotNull(sb, "description",     d.getDescription());
        appendIfNotNull(sb, "orderCode",       d.getOrderCode() != null ? String.valueOf(d.getOrderCode()) : null);
        appendIfNotNull(sb, "reference",       d.getReference());
        appendIfNotNull(sb, "transactionDateTime", d.getTransactionDateTime());

        // Xoá dấu & cuối nếu có
        String result = sb.toString();
        if (result.endsWith("&")) {
            result = result.substring(0, result.length() - 1);
        }
        return result;
    }

    private void appendIfNotNull(StringBuilder sb, String key, String value) {
        if (value != null && !value.isEmpty()) {
            sb.append(key).append("=").append(value).append("&");
        }
    }

    private String hmacSHA256(String data, String key) throws Exception {
        Mac mac = Mac.getInstance("HmacSHA256");
        mac.init(new SecretKeySpec(key.getBytes(StandardCharsets.UTF_8), "HmacSHA256"));
        byte[] hash = mac.doFinal(data.getBytes(StandardCharsets.UTF_8));
        return HexFormat.of().formatHex(hash);
    }
}