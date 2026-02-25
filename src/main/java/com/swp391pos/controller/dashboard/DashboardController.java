package com.swp391pos.controller.dashboard;

import com.swp391pos.repository.ProductRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

@Controller
public class DashboardController {

    @Autowired
    private ProductRepository productRepository;

    // Giả sử bạn có OrderRepository để đếm đơn hàng
    // @Autowired
    // private OrderRepository orderRepository;

    @GetMapping("/dashboard")
    public String showDashboard(Model model) {
        // 1. Lấy dữ liệu thống kê nhanh
        long totalProducts = productRepository.count();

        // Giả sử lấy số đơn hàng hôm nay (Ví dụ demo là 0)
        long ordersToday = 0;

        // 2. Truyền dữ liệu ra View
        model.addAttribute("totalProducts", totalProducts);
        model.addAttribute("ordersToday", ordersToday);

        // 3. Truyền thông tin ngày tháng hiện tại (như trong ảnh mẫu của bạn)
        LocalDate now = LocalDate.now();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("EEEE, MM/dd/yyyy");
        model.addAttribute("currentDate", now.format(formatter));

        // 4. Trả về file dashboard.jsp
        return "dashboard/dashboard"; // Đảm bảo file nằm đúng thư mục /WEB-INF/views/dashboard.jsp
    }
}
