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

    public PaymentSummary calculatePromotion(List<OrderItemDTO> cartItems) {
        PaymentSummary summary = new PaymentSummary();
        List<PaymentItem> paymentItems = new ArrayList<>();

        BigDecimal totalDiscount = BigDecimal.ZERO;

        if (cartItems != null && !cartItems.isEmpty()) {
            summary.setOrderId(cartItems.get(0).getOrderId());
        }
        //lấy toàn bộ các quy tắc giảm giá đang có hiệu lực tính đến hôm nay
        List<PromotionDetail> activePromos = promotionDetailRepository.findAllActivePromotionsForPos(LocalDate.now());

        for (OrderItemDTO itemDto : cartItems) {
            Product product = productRepository.findProductByProductId(itemDto.getProductId());
            if (product == null) continue;

            PaymentItem pItem = new PaymentItem();
            pItem.setProductId(product.getProductId());
            pItem.setProductName(product.getProductName());
            pItem.setQuantity(itemDto.getQuantity());
            pItem.setOriginalPrice(product.getPrice());

            BigDecimal quantityBD = BigDecimal.valueOf(itemDto.getQuantity());
            BigDecimal lineOriginalTotal = product.getPrice().multiply(quantityBD);
            BigDecimal lineDiscount = BigDecimal.ZERO;

            PromotionDetail appliedPromo = activePromos.stream()
                    .filter(p -> p.getProduct().getProductId().equals(product.getProductId())
                            && itemDto.getQuantity() >= p.getMinQuantity())
                    .findFirst().orElse(null);

            if (appliedPromo != null) {
                if (appliedPromo.getDiscountType() == PromotionDetail.DiscountType.AMOUNT) {
                    lineDiscount = appliedPromo.getDiscountValue().multiply(quantityBD);
                    pItem.setPromotionNote("- " + appliedPromo.getDiscountValue() + "đ/SP");
                } else {
                    BigDecimal percent = appliedPromo.getDiscountValue().divide(new BigDecimal(100));
                    lineDiscount = lineOriginalTotal.multiply(percent);
                    pItem.setPromotionNote("- " + appliedPromo.getDiscountValue() + "%");
                }
            }

            pItem.setDiscountAmount(lineDiscount);
            pItem.setFinalLineTotal(lineOriginalTotal.subtract(lineDiscount));
            paymentItems.add(pItem);

            totalDiscount = totalDiscount.add(lineDiscount);
        }

        summary.setItems(paymentItems);
        summary.setTotalDiscount(totalDiscount);

        return summary;
    }
}