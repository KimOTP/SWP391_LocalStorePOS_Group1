package com.swp391pos.controller.customer; // Hoặc package tương ứng của bạn

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.swp391pos.dto.CheckoutDTO.*;
import com.swp391pos.service.PosService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;

@Controller
@RequestMapping("/pos")
public class PosCheckoutController {

    @Autowired
    private PosService posService;

    // Khi ấn nút Pay ở màn POS, form sẽ POST vào đây
    @PostMapping("/payment") // Đợi Việt Anh chốt đường dẫn khi ấn nút Pay
    public String processToPayment(@RequestParam("cartDataJson") String cartDataJson, Model model) {
        try {
            // Chuyển chuỗi JSON từ JS thành List<CartRequest> của Java
            ObjectMapper mapper = new ObjectMapper();
            List<CartRequest> cartItems = mapper.readValue(cartDataJson, new TypeReference<List<CartRequest>>(){});
            // Gọi Service tính tiền
            PaymentSummary summary = posService.calculateCheckout(cartItems);
            // Đẩy dữ liệu ra màn Payment
            model.addAttribute("summary", summary);
        } catch (Exception e) {
            e.printStackTrace();
            return "redirect:/pos?error=InvalidCart"; // Quay lại nếu lỗi
        }
        return "pos/payment-screen"; // Trỏ đến file JSP của màn Payment // VAnh chưa làm màn payment
    }
}