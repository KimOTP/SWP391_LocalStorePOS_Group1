package com.swp391pos.dto;

import lombok.Data;

import java.math.BigDecimal;
import java.util.List;

public class PaymentDTO {
    // 1. Class hứng dữ liệu thô (Thay thế CartRequest cũ)
    @Data
    public static class OrderItemDTO {
        private Integer orderItemId;
        private Long orderId;
        private String productId;
        private String productName;
        private String unit;
        private Integer quantity;
        private BigDecimal unitPrice;
        private BigDecimal lineTotal;
    }

    // 2. Class hiển thị chi tiết từng món ĐÃ TÍNH KHUYẾN MÃI (Bên màn Payment)
    @Data
    public static class PaymentItem {
        private String productId; // Thêm productId để nhỡ frontend cần dùng
        private String productName;
        private Integer quantity;
        private BigDecimal originalPrice; // Giá gốc 1 SP
        private BigDecimal discountAmount; // Số tiền được giảm (Tổng)
        private BigDecimal finalLineTotal; // Tổng tiền sau giảm của dòng này
        private String promotionNote; // Ghi chú: "Giảm 10%", "Giảm 20k", v.v.
    }

    // 3. Class chứa tổng hợp hóa đơn ĐÃ TÍNH KHUYẾN MÃI (Góc trái dưới màn Payment)
    @Data
    public static class PaymentSummary {
        private Long orderId; // Thêm mã hóa đơn
        private List<PaymentItem> items;
        private BigDecimal totalAmount;    // Tổng tiền gốc
        private BigDecimal totalDiscount;  // Tổng tiền giảm từ Promotion
        private BigDecimal finalTotal;     // Tổng phải thanh toán (Total)
    }
}
