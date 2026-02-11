package com.swp391pos.service;


import com.swp391pos.entity.Customer;
import com.swp391pos.repository.CustomerRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class CustomerService {
    @Autowired
    private CustomerRepository customerRepository;
    public List<Customer> getAllCustomer() {
        return customerRepository.findAll();
    }
    //các hàm thống kê ở màn customer-management
    public long getTotalCustomers() {
        return customerRepository.count();
    }
    public Long getTotalPoints() {
        Long points = customerRepository.sumTotalPoints();
        return (points != null) ? points : 0L;
    }
    public BigDecimal getTotalSpending() {
        BigDecimal total = customerRepository.sumTotalSpending();
        return (total != null) ? total : BigDecimal.ZERO;
    }
    public BigDecimal getAverageSpending() {
        long count = getTotalCustomers();
        BigDecimal total = getTotalSpending();
        if(count == 0) return BigDecimal.ZERO;
        return total.divide(BigDecimal.valueOf(count), 0, RoundingMode.HALF_UP);
    }
    public List<Customer> getCustomers(String keyword, Integer minPoint, Integer status, String timePeriod) {

        LocalDateTime startDate = null;

        // Logic quy đổi Time Period thành Ngày bắt đầu
        if (timePeriod != null && !timePeriod.isEmpty()) {
            LocalDate today = LocalDate.now();
            switch (timePeriod) {
                case "month": // Tháng này
                    // Lấy ngày mùng 1 của tháng hiện tại, lúc 00:00:00
                    startDate = today.withDayOfMonth(1).atStartOfDay();
                    break;
                case "year": // Năm nay
                    // Lấy ngày 1/1 của năm hiện tại
                    startDate = today.withDayOfYear(1).atStartOfDay();
                    break;
                case "last_30_days": // 30 ngày gần đây
                    startDate = today.minusDays(30).atStartOfDay();
                    break;
                default:
                    startDate = null; // Chọn "All time"
            }
        }

        // Gọi Repository với đủ 4 tham số
        return customerRepository.searchFullFilter(keyword, minPoint, status, startDate);
    }

    public void saveCustomer(Customer customer) {
        // Nếu ID tồn tại -> Đây là Update -> Cần lấy dữ liệu cũ để giữ lại Điểm và Tổng tiền (nếu form không gửi lên)
        if (customer.getCustomerId() != null) {
            Customer oldCustomer = customerRepository.findById(customer.getCustomerId()).orElse(null);
            if (oldCustomer != null) {
                // Nếu form edit không gửi điểm (null), thì giữ nguyên điểm cũ
                if (customer.getCurrentPoint() == null) {
                    customer.setCurrentPoint(oldCustomer.getCurrentPoint());
                }
                // Nếu form edit không gửi tổng tiền (null), thì giữ nguyên tiền cũ
                if (customer.getTotalSpending() == null) {
                    customer.setTotalSpending(oldCustomer.getTotalSpending());
                }
                // Giữ nguyên ngày tạo, v.v...
            }
        } else {
            // Đây là Thêm mới (ID null) -> Gán mặc định
            if (customer.getCurrentPoint() == null) customer.setCurrentPoint(0);
            if (customer.getTotalSpending() == null) customer.setTotalSpending(BigDecimal.ZERO);
            if (customer.getStatus() == null) customer.setStatus(1);
        }

        customerRepository.save(customer);
    }

    public void deleteById(Long id) {
        customerRepository.deleteById(id);
    }
    public Optional<Customer> findById(Long id) {
        return customerRepository.findById(id);
    }
}
