package com.swp391pos.controller.customer;


import com.swp391pos.entity.Account;
import com.swp391pos.entity.Customer;
import com.swp391pos.entity.Employee;
import com.swp391pos.entity.PointHistory;
import com.swp391pos.service.CustomerService;
import com.swp391pos.service.SystemSettingService;
import jakarta.servlet.http.HttpSession;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Controller
@RequestMapping("/customer")
public class CustomerController {
    @Autowired
    private CustomerService customerService;
    @Autowired
    private SystemSettingService systemSettingService;
    @GetMapping
    public String listCustomers(Model model,
                                @RequestParam(required = false) String keyword,
                                @RequestParam(required = false) Integer minPoint,
                                @RequestParam(required = false) Integer status,      // Mới thêm
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

        // Nếu có lỗi Validate (Ví dụ: SĐT nhập chữ, Tên để trống...)
        if (result.hasErrors()) {
            // Lấy lỗi đầu tiên ra để thông báo
            String errorMessage = result.getFieldError().getDefaultMessage();
            // Gửi thông báo lỗi về giao diện
            redirectAttributes.addFlashAttribute("errorMessage", errorMessage);
            // Quay về trang cũ
            return "redirect:/customer";
        }

        // Kiểm tra trùng số điện thoại
        Optional<Customer> existingCustomer = customerService.findByPhoneNumber(customer.getPhoneNumber());
        if (existingCustomer.isPresent()) {
            redirectAttributes.addFlashAttribute("errorMessage", "Error: This phone number already exists in the system!");
            return "redirect:/customer";
        }

        // Nếu dữ liệu valid -> Lưu vào DB
        customerService.saveCustomer(customer);
        // Thông báo thành công
        redirectAttributes.addFlashAttribute("notification", "Successfully added a customer!");
        return "redirect:/customer";
    }
    // Delete
    @GetMapping("/delete/{id}")
    public String deleteCustomer(@PathVariable("id") Long id, RedirectAttributes redirectAttributes) {
        try {
            customerService.deleteById(id); // Dữ liệu nào không có lquan bên bảng khác thì xóa được
            redirectAttributes.addFlashAttribute("notification", "Customer successfully deleted!");
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("errorMessage", "Error: Cannot delete this customer.");
        }
        return "redirect:/customer";
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
            // Báo lỗi
            redirectAttributes.addFlashAttribute("errorMessage", "Update failed: " + errorMessage);
            return "redirect:/customer";
        }

        // Kiểm tra trùng số điện thoại khi update
        Optional<Customer> existingCustomer = customerService.findByPhoneNumber(customer.getPhoneNumber());
        // Nếu tìm thấy SĐT này, VÀ SĐT này thuộc về một ID khác với ID đang được cập nhật -> Báo lỗi
        if (existingCustomer.isPresent() && !existingCustomer.get().getCustomerId().equals(customer.getCustomerId())) {
            redirectAttributes.addFlashAttribute("errorMessage", "Update failed: This phone number is already used by another customer!");
            return "redirect:/customer";
        }
        //Nếu không có lỗi thì mới lưu
        try {
            //SaveCustomer sẽ xử lý việc giữ nguyên các field cũ
            customerService.saveCustomer(customer);
            redirectAttributes.addFlashAttribute("notification", "Information updated successfully.!");
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("errorMessage", "An error occurred during the data saving process.");
        }

        return "redirect:/customer";
    }

    // API: Lấy lịch sử giao dịch (Trả về JSON)
    @GetMapping("/{id}/history")
    @ResponseBody
    public List<PointHistory> getCustomerHistory(@PathVariable Long id) {
        // Lấy ra entity
        Customer customer = customerService.findById(id);
        if (customer != null) {
            //Lấy table point history
            return customer.getPointHistories();
        }
        return new ArrayList<>();
    }

    // API: Đếm tổng số đơn hàng của khách (Trả về số lượng)
    @GetMapping("/{id}/order-count")
    @ResponseBody
    public Integer getCustomerOrderCount(@PathVariable Long id) {
        // Tìm khách hàng
        Customer customer = customerService.findById(id);

        // Nếu có khách hàng và danh sách đơn không null -> Trả về kích thước list (số đơn)
        if (customer != null && customer.getOrders() != null) {
            return customer.getOrders().size();
        }

        // Nếu không có -> Trả về 0
        return 0;
    }

    // API: Lấy cấu hình (JSON)
    @GetMapping("/config")
    @ResponseBody
    public Map<String, String> getPointConfig() {
        return systemSettingService.getAllSettings();
    }

    // API: Lưu cấu hình (Form POST)
    @PostMapping("/config/update")
    public String updatePointConfig(
            @RequestParam("earningRate") String earningRate,
            @RequestParam("redemptionValue") String redemptionValue,
            @RequestParam("maxRedeemPercent") String maxRedeemPercent,
            @RequestParam("minPointRedeem") String minPointRedeem,
            HttpSession session,
            RedirectAttributes redirectAttributes) {

        try {
            //  Lấy Account từ Session
            Account loggedInAccount = (Account) session.getAttribute("account");
            Employee updater = (loggedInAccount != null) ? loggedInAccount.getEmployee() : null;
            // Update 4 trường vào DB
            systemSettingService.updateSetting("POINT_EARNING_RATE", earningRate, updater);
            systemSettingService.updateSetting("POINT_REDEMPTION_VALUE", redemptionValue, updater);
            systemSettingService.updateSetting("MAX_REDEEM_PERCENT", maxRedeemPercent, updater);
            systemSettingService.updateSetting("MIN_POINT_TO_REDEEM", minPointRedeem, updater);

            redirectAttributes.addFlashAttribute("notification", "The point configuration has been successfully updated.!");
        } catch (Exception e) {
            e.printStackTrace();
            //redirectAttributes.addFlashAttribute("errorMessage", "Configuration update error.");
            redirectAttributes.addFlashAttribute("errorMessage", e.getMessage());
        }

        return "redirect:/customer";
    }
}
