package com.swp391pos.controller.customer; // Hoặc package tương ứng của bạn

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.swp391pos.dto.PaymentDTO.*;
import com.swp391pos.entity.Order;
import com.swp391pos.entity.OrderItem;
import com.swp391pos.service.OrderItemService;
import com.swp391pos.service.OrderService;
import com.swp391pos.service.PosService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;
import java.util.stream.Collectors;

@Controller
@RequestMapping("/pos")
public class PosCheckoutController {

    @Autowired
    private PosService posService;
    @Autowired
    private OrderService orderService;
    @Autowired
    private OrderItemService orderItemService;
    // Bỏ vào một Controller bất kỳ (ví dụ PosController.java)

//    @GetMapping("/payment")
//    public String showPaymentScreen(@RequestParam("orderId") Long orderId, Model model) {
//        // 1. Tìm Order trong Database
//        Order order = orderService.findById(orderId);
//
//        // 2. Lấy danh sách OrderItem của Order đó
//        List<OrderItem> items = orderItemService.findByOrder(order);
//
//        // 3. Map OrderItem sang dạng OrderItemDTO để nhét vào hàm calculateCheckout
//        List<OrderItemDTO> cartItems = items.stream().map(oi -> {
//            OrderItemDTO dto = new OrderItemDTO();
//            dto.setOrderId(order.getOrderId());
//            dto.setProductId(oi.getProduct().getProductId());
//            dto.setQuantity(oi.getQuantity());
//            return dto;
//        }).collect(Collectors.toList());
//
//        // 4. Gọi Service tính tiền Khuyến mãi (mà chúng ta vừa làm)
//        PaymentSummary summary = posService.calculateCheckout(cartItems);
//
//        // 5. Đẩy dữ liệu ra màn hình Payment
//        model.addAttribute("order", order);
//        model.addAttribute("summary", summary);
//
//        // Đường dẫn tới file JSP (chờ VAnh chốt thư mục)
//        return "pos/cashier/payment";
//    }
}