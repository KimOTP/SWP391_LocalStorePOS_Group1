package com.swp391pos.service;

import com.swp391pos.dto.CheckoutDTO.*;
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

    public PaymentSummary calculateCheckout(List<CartRequest> cartItems) {
        PaymentSummary summary = new PaymentSummary();
        List<PaymentItem> paymentItems = new ArrayList<>();

        BigDecimal totalAmount = BigDecimal.ZERO;
        BigDecimal totalDiscount = BigDecimal.ZERO;

        // Lấy tất cả khuyến mãi đang active hôm nay (Bạn có thể dùng hàm đã tạo ở bài trước)
        List<PromotionDetail> activePromos = promotionDetailRepository.findAllActivePromotionsForPos(LocalDate.now());

        for (CartRequest cartReq : cartItems) {
            Product product = productRepository.findProductByProductId(cartReq.getProductId());
            if (product == null) continue;

            PaymentItem pItem = new PaymentItem();
            pItem.setProductName(product.getProductName());
            pItem.setQuantity(cartReq.getQuantity());
            // Giả sử entity Product của bạn có trường getPrice()
            pItem.setOriginalPrice(product.getPrice());

            BigDecimal lineOriginalTotal = product.getPrice().multiply(new BigDecimal(cartReq.getQuantity()));
            BigDecimal lineDiscount = BigDecimal.ZERO;

            // Tìm xem sản phẩm này có khuyến mãi nào thỏa mãn minQuantity không
            PromotionDetail appliedPromo = activePromos.stream()
                    .filter(p -> p.getProduct().getProductId().equals(product.getProductId())
                            && cartReq.getQuantity() >= p.getMinQuantity())
                    .findFirst().orElse(null);

            // Nếu có khuyến mãi -> Tính toán số tiền giảm
            if (appliedPromo != null) {
                if (appliedPromo.getDiscountType() == PromotionDetail.DiscountType.AMOUNT) {
                    // Nếu giảm thẳng tiền mặt (VD: Giảm 50k / 1 SP)
                    lineDiscount = appliedPromo.getDiscountValue().multiply(new BigDecimal(cartReq.getQuantity()));
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