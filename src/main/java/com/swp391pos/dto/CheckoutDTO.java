package com.swp391pos.dto;

import lombok.Data;

import java.math.BigDecimal;
import java.util.List;

public class CheckoutDTO {
    // Class hứng dữ liệu từ Javascript gửi lên (Giỏ hàng)
    @Data
    public static class CartRequest {
        private String productId;
        private Integer quantity;
    }

    // Class hiển thị chi tiết từng món bên màn Payment
    @Data
    public static class PaymentItem {
        private String productName;
        private Integer quantity;
        private BigDecimal originalPrice; // Giá gốc 1 SP
        private BigDecimal discountAmount; // Số tiền được giảm (Tổng)
        private BigDecimal finalLineTotal; // Tổng tiền sau giảm của dòng này
        private String promotionNote; // Ghi chú: "Giảm 10%", v.v.
    }

    // Class chứa tổng hợp hóa đơn hiển thị ở góc trái dưới màn Payment
    @Data
    public static class PaymentSummary {
        private List<PaymentItem> items;
        private BigDecimal totalAmount;    // Tổng tiền gốc
        private BigDecimal totalDiscount;  // Tổng tiền giảm
        private BigDecimal finalTotal;     // Tổng phải thanh toán (Total)
    }
}
