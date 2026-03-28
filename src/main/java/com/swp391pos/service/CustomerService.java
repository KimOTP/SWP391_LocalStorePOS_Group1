package com.swp391pos.service;


import com.swp391pos.entity.Customer;
import com.swp391pos.entity.Order;
import com.swp391pos.entity.PointHistory;
import com.swp391pos.repository.CustomerRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Service
public class CustomerService {
    @Autowired private CustomerRepository customerRepository;
    @Autowired private OrderService orderService;
    @Autowired private PointHistoryService pointHistoryService;
    @Autowired private SystemSettingService systemSettingService;


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
                    customer.setTotalSpending(oldCustomer.getTotalSpending());
                    customer.setLastTransactionDate(oldCustomer.getLastTransactionDate());
                    customer.setCreatedAt(oldCustomer.getCreatedAt());
            }
        } else {
            // Đây là Thêm mới (ID null) -> Gán mặc định

            if (customer.getCurrentPoint() == null) customer.setCurrentPoint(0);
            if (customer.getTotalSpending() == null) customer.setTotalSpending(BigDecimal.ZERO);
            if (customer.getStatus() == null) customer.setStatus(1);
        }

        customerRepository.save(customer);
    }

    public Optional<Customer> findByPhoneNumber(String phone) {
        return customerRepository.findByPhoneNumber(phone);
    }

    public Customer saveQuick(String phoneNumber, String fullName) {
        Customer c = new Customer();
        c.setPhoneNumber(phoneNumber);
        c.setFullName(fullName);
        c.setCurrentPoint(0);
        c.setTotalSpending(BigDecimal.ZERO);
        c.setStatus(1);
        c.setCreatedAt(LocalDateTime.now());
        return customerRepository.save(c);
    }

    public void deleteById(Long id) {

        customerRepository.deleteById(id);
    }
    public Customer findById(Long id) {
        return customerRepository.findByCustomerId(id);
    }


    @Transactional
    public void updateCustomerAfterPayment(Long orderId, Long customerId, double totalPaid, int pointsUsed) {
        if (customerId == null) return;

        Customer customer = this.findById(customerId);
        Order order = orderService.findById(orderId);

        if (customer != null && order != null) {

            if (pointsUsed > 0) {
                customer.setCurrentPoint(customer.getCurrentPoint() - pointsUsed);

                PointHistory useHistory = new PointHistory();
                useHistory.setCustomer(customer);
                useHistory.setOrder(order);
                useHistory.setPointAmount(-pointsUsed);
                useHistory.setActionType(PointHistory.ActionType.USE);
                useHistory.setCreatedAt(LocalDateTime.now());
                pointHistoryService.save(useHistory);
            }

            Map<String, String> config = systemSettingService.getAllSettings();
            double earningRate = Double.parseDouble(config.getOrDefault("POINT_EARNING_RATE", "0"));

            if (earningRate > 0) {
                int earnedPoints = (int) (totalPaid / earningRate);
                customer.setCurrentPoint(customer.getCurrentPoint() + earnedPoints);

                PointHistory earnHistory = new PointHistory();
                earnHistory.setCustomer(customer);
                earnHistory.setOrder(order);
                earnHistory.setPointAmount(earnedPoints);
                earnHistory.setActionType(PointHistory.ActionType.EARN);
                earnHistory.setCreatedAt(LocalDateTime.now());
                pointHistoryService.save(earnHistory);
            }

            BigDecimal currentSpending = customer.getTotalSpending() != null ? customer.getTotalSpending() : BigDecimal.ZERO;
            customer.setTotalSpending(currentSpending.add(BigDecimal.valueOf(totalPaid)));
            customer.setLastTransactionDate(LocalDateTime.now());

            saveCustomer(customer);
        }
    }
}