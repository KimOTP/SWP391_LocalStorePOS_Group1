package com.swp391pos.utility;

import com.swp391pos.dto.WebhookPayload;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.util.HexFormat;

/**
 * [FIX] PayOSVerifier phai duoc goi trong PaymentWebhookController
 * truoc khi xu ly bat ky payload nao.
 * Webhook chua verify chu ky = lo hong bao mat nghiem trong.
 */
@Component
public class PayOSVerifier {

    @Value("${payos.checksum-key:placeholder}")
    private String checksumKey;

    /**
     * Verify chu ky HMAC-SHA256 cua webhook payload tu PayOS.
     * @return true neu chu ky hop le, false neu bi giả mạo
     */
    public boolean verify(WebhookPayload payload) {
        if (payload.getSignature() == null) return false;

        try {
            // Tao chuoi data theo dung format PayOS yeu cau
            String data = "amount=" + payload.getAmount()
                    + "&code=" + payload.getStatus()
                    + "&id=" + payload.getGatewayOrderCode()
                    + "&orderCode=" + payload.getGatewayOrderCode();

            String computed = hmacSHA256(data, checksumKey);
            return computed.equalsIgnoreCase(payload.getSignature());
        } catch (Exception e) {
            return false;
        }
    }

    private String hmacSHA256(String data, String key) throws Exception {
        Mac mac = Mac.getInstance("HmacSHA256");
        mac.init(new SecretKeySpec(key.getBytes(StandardCharsets.UTF_8), "HmacSHA256"));
        byte[] hash = mac.doFinal(data.getBytes(StandardCharsets.UTF_8));
        return HexFormat.of().formatHex(hash);
    }
}
