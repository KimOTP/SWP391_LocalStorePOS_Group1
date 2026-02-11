package com.swp391pos.controller.customer;


import com.swp391pos.entity.Customer;
import com.swp391pos.entity.PointHistory;
import com.swp391pos.service.CustomerService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.ArrayList;
import java.util.List;

@Controller
@RequestMapping("/customers")
public class CustomerController {
    @Autowired
    private CustomerService customerService;
    @GetMapping
    public String listCustomers(Model model,
                                @RequestParam(required = false) String keyword,
                                @RequestParam(required = false) Integer minPoint,
                                @RequestParam(required = false) Integer status,    // Mới thêm
                                @RequestParam(required = false) String timePeriod) { // Mới thêm

        //Gọi Service
        List<Customer> customers = customerService.getCustomers(keyword, minPoint, status, timePeriod);
        model.addAttribute("customers", customers);

        //Trả lại giá trị giữ trạng thái Selected
        model.addAttribute("keyword", keyword);
        model.addAttribute("minPoint", minPoint);
        model.addAttribute("status", status);
        model.addAttribute("timePeriod", timePeriod);

        //Chỉ số
        model.addAttribute("totalCustomer", customerService.getTotalCustomers());
        model.addAttribute("totalPoints", customerService.getTotalPoints());
        model.addAttribute("totalSpending", customerService.getTotalSpending());
        model.addAttribute("avgSpending", customerService.getAverageSpending());

        return "customer/customer-list";
    }

    @PostMapping("/add")
    public String addCustomer(@Valid @ModelAttribute Customer customer,
                              BindingResult result,
                              RedirectAttributes redirectAttributes) {

        // 1. Nếu có lỗi Validate (Ví dụ: SĐT nhập chữ, Tên để trống...)
        if (result.hasErrors()) {
            // Lấy lỗi đầu tiên ra để thông báo
            String errorMessage = result.getFieldError().getDefaultMessage();

            // Gửi thông báo lỗi về giao diện
            redirectAttributes.addFlashAttribute("error", errorMessage);

            // Quay về trang cũ
            return "redirect:/customers";
        }

        // 2. Nếu dữ liệu ngon lành -> Lưu vào DB
        customerService.saveCustomer(customer);

        // 3. Thông báo thành công
        redirectAttributes.addFlashAttribute("success", "Thêm khách hàng thành công!");

        return "redirect:/customers";
    }
    // Delete
    @GetMapping("/delete/{id}")
    public String deleteCustomer(@PathVariable("id") Long id, RedirectAttributes redirectAttributes) {
        try {
            customerService.deleteById(id);
            redirectAttributes.addFlashAttribute("success", "Đã xóa khách hàng thành công!");
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "Lỗi: Không thể xóa khách hàng này.");
        }
        return "redirect:/customers";
    }

    //Update
    @PostMapping("/update")
    public String updateCustomer(@Valid @ModelAttribute Customer customer, //Thêm @Valid
                                 BindingResult result,                     //Thêm BindingResult
                                 RedirectAttributes redirectAttributes) {

        //Kiểm tra lỗi trước khi lưu
        if (result.hasErrors()) {
            // Lấy lỗi đầu tiên ra để thông báo
            String errorMessage = result.getFieldError().getDefaultMessage();

            // Báo lỗi đỏ ra màn hình
            redirectAttributes.addFlashAttribute("error", "Cập nhật thất bại: " + errorMessage);

            // Quay về trang danh sách
            return "redirect:/customers";
        }

        //Nếu không có lỗi thì mới lưu
        try {
            // Lưu ý: customerService.saveCustomer sẽ tự xử lý việc giữ nguyên các field cũ (điểm, tổng tiền...)
            // nếu bạn code hàm save cẩn thận, hoặc JPA sẽ tự merge dựa trên ID.
            customerService.saveCustomer(customer);
            redirectAttributes.addFlashAttribute("success", "Cập nhật thông tin thành công!");
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "Có lỗi xảy ra trong quá trình lưu dữ liệu.");
        }

        return "redirect:/customers";
    }

    // API: Lấy lịch sử giao dịch (Trả về JSON)
    @GetMapping("/{id}/history")
    @ResponseBody
    public List<PointHistory> getCustomerHistory(@PathVariable Long id) {
        Customer customer = customerService.findById(id).orElse(null);
        if (customer != null) {
            return customer.getPointHistories();
        }
        return new ArrayList<>();
    }

    // API: Đếm tổng số đơn hàng của khách (Trả về số lượng)
    @GetMapping("/{id}/order-count")
    @ResponseBody
    public Integer getCustomerOrderCount(@PathVariable Long id) {
        // Tìm khách hàng
        Customer customer = customerService.findById(id).orElse(null);

        // Nếu có khách hàng và danh sách đơn không null -> Trả về kích thước list (số đơn)
        if (customer != null && customer.getOrders() != null) {
            return customer.getOrders().size();
        }

        // Nếu không có -> Trả về 0
        return 0;
    }
}
