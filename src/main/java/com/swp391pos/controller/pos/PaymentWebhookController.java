package com.swp391pos.controller.pos;

import com.swp391pos.dto.WebhookPayload;
import com.swp391pos.service.PaymentService;
import com.swp391pos.utility.PayOSVerifier;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/**
 * Webhook controller - chi lam 1 viec: cap nhat payment.
 */
@RestController
@RequestMapping("/api/payment")
public class PaymentWebhookController {

    private final PaymentService paymentService;
    private final PayOSVerifier payOSVerifier;

    public PaymentWebhookController(PaymentService paymentService, PayOSVerifier payOSVerifier) {
        this.paymentService = paymentService;
        this.payOSVerifier = payOSVerifier;
    }

    @PostMapping("/webhook")
    public ResponseEntity<?> handleWebhook(@RequestBody WebhookPayload payload) {

        // [FIX] Verify chu ky truoc khi xu ly - bat buoc ve bao mat
        if (!payOSVerifier.verify(payload)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }

        paymentService.handleWebhook(payload);
        return ResponseEntity.ok().build();
    }
}
