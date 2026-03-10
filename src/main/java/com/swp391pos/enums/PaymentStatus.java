package com.swp391pos.enums;

/**
 * Trang thai cua Payment.
 * Dung enum de dam bao compile-time safety, tranh typo.
 */
public enum PaymentStatus {
    PENDING,
    PAID,
    FAILED,
    CANCELLED,
    EXPIRED,  // [Blind spot #5] them EXPIRED cho timeout
    EXTRA
}
