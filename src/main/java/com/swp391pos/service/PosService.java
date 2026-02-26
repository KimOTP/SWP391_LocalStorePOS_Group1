package com.swp391pos.service;

// Đổi import sang PaymentDTO
import com.swp391pos.dto.PaymentDTO.*;
import com.swp391pos.entity.Product;
import com.swp391pos.entity.PromotionDetail;
import com.swp391pos.repository.ProductRepository;
import com.swp391pos.repository.PromotionDetailRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Service
public class PosService {

    @Autowired
    private ProductRepository productRepository;
    @Autowired
    private PromotionDetailRepository promotionDetailRepository;

    public PaymentSummary calculateCheckout(List<OrderItemDTO> cartItems) {
        PaymentSummary summary = new PaymentSummary();
        List<PaymentItem> paymentItems = new ArrayList<>();

        BigDecimal totalAmount = BigDecimal.ZERO;
        BigDecimal totalDiscount = BigDecimal.ZERO;

        // Lấy orderId từ dòng đầu tiên của giỏ hàng để gán vào summary
        if (cartItems != null && !cartItems.isEmpty()) {
            summary.setOrderId(cartItems.get(0).getOrderId());
        }

        // Lấy tất cả khuyến mãi đang active hôm nay
        List<PromotionDetail> activePromos = promotionDetailRepository.findAllActivePromotionsForPos(LocalDate.now());

        for (OrderItemDTO itemDto : cartItems) {
            Product product = productRepository.findProductByProductId(itemDto.getProductId());
            if (product == null) continue;

            PaymentItem pItem = new PaymentItem();
            pItem.setProductId(product.getProductId()); // Thêm productId cho Frontend dễ xử lý
            pItem.setProductName(product.getProductName());
            pItem.setQuantity(itemDto.getQuantity());
            pItem.setOriginalPrice(product.getPrice());

            // Dùng BigDecimal.valueOf() thay cho new BigDecimal() sẽ an toàn và chuẩn Java hơn
            BigDecimal quantityBD = BigDecimal.valueOf(itemDto.getQuantity());
            BigDecimal lineOriginalTotal = product.getPrice().multiply(quantityBD);
            BigDecimal lineDiscount = BigDecimal.ZERO;

            // Tìm xem sản phẩm này có khuyến mãi nào thỏa mãn minQuantity không
            PromotionDetail appliedPromo = activePromos.stream()
                    .filter(p -> p.getProduct().getProductId().equals(product.getProductId())
                            && itemDto.getQuantity() >= p.getMinQuantity())
                    .findFirst().orElse(null);

            // Nếu có khuyến mãi -> Tính toán số tiền giảm
            if (appliedPromo != null) {
                if (appliedPromo.getDiscountType() == PromotionDetail.DiscountType.AMOUNT) {
                    // Nếu giảm thẳng tiền mặt (VD: Giảm 50k / 1 SP)
                    lineDiscount = appliedPromo.getDiscountValue().multiply(quantityBD);
                    pItem.setPromotionNote("- " + appliedPromo.getDiscountValue() + "đ/SP");
                } else {
                    // Nếu giảm phần trăm (VD: Giảm 10% trên tổng giá trị dòng)
                    BigDecimal percent = appliedPromo.getDiscountValue().divide(new BigDecimal(100));
                    lineDiscount = lineOriginalTotal.multiply(percent);
                    pItem.setPromotionNote("- " + appliedPromo.getDiscountValue() + "%");
                }
            }

            pItem.setDiscountAmount(lineDiscount);
            pItem.setFinalLineTotal(lineOriginalTotal.subtract(lineDiscount));
            paymentItems.add(pItem);

            // Cộng dồn vào tổng hóa đơn
            totalAmount = totalAmount.add(lineOriginalTotal);
            totalDiscount = totalDiscount.add(lineDiscount);
        }

        summary.setItems(paymentItems);
        summary.setTotalAmount(totalAmount);
        summary.setTotalDiscount(totalDiscount);
        summary.setFinalTotal(totalAmount.subtract(totalDiscount));

        return summary;
    }
}