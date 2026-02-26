package com.swp391pos.configuration.web;

import org.springframework.web.filter.OncePerRequestFilter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

public class RoleAuthorizationFilter extends OncePerRequestFilter {

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {

        String uri = request.getRequestURI();
        HttpSession session = request.getSession(false);
        String role = (session != null) ? (String) session.getAttribute("role") : null;

        // 1. LOẠI BỎ CÁC REQUEST TÀI NGUYÊN (Sửa lỗi hiện thông báo do load ảnh/icon thất bại)
        if (uri.contains("/static/") || uri.contains("/auth/") || uri.contains("/css/") ||
                uri.contains("/js/") || uri.contains("/resources/") || uri.endsWith(".png") ||
                uri.endsWith(".jpg") || uri.endsWith(".svg") || uri.endsWith(".ico")) {
            filterChain.doFilter(request, response);
            return;
        }

        // 2. KIỂM TRA ĐĂNG NHẬP
        if (role == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return;
        }

        // 3. PHÂN QUYỀN CHO CASHIER
        if ("CASHIER".equalsIgnoreCase(role)) {
            // Chặn folder quản lý
            if (uri.contains("/manager/") || uri.contains("/admin/")) {
                handleAccessDenied(request, response, "Access Denied !");
                return;
            }

            // Danh sách trắng cho Cashier
            boolean isAllowed = uri.contains("/pos")
                    || uri.contains("/dashboard")
                    || uri.contains("/layer")
                    || uri.contains("/cashier/")
                    || uri.contains("/common/")
                    || uri.contains("/hr/cashier_profile")
                    || uri.contains("/hr/change_information")
                    || uri.contains("/hr/attendance_record")
                    || uri.contains("/hr/shift_change_history")
                    || uri.contains("/shift/change_shift")
                    || uri.contains("/shift/work_schedule")
                    || uri.contains("/hr/update_information")
                    || uri.contains("/hr/change_password");

            if (!isAllowed) {
                handleAccessDenied(request, response, "Access Denied !");
                return;
            }
        } else if ("INVENTORY STAFF".equalsIgnoreCase(role)) {
            if (uri.contains("/manager/") || uri.contains("/admin/")) {
                handleAccessDenied(request, response, "Access Denied !");
                return;
            }
            boolean isAllowed = uri.contains("/dashboard")
                    || uri.contains("/layer")
                    ||uri.contains("/stockIn/add")
                    || uri.contains("/stockIn/details")
                    || uri.contains("/hr/cashier_profile")
                    || uri.contains("/stockOut/add")
                    || uri.contains("/stockOut/details")
                    || uri.contains("/audit/add")
                    || uri.contains("/audit/details")
                    || uri.contains("/stockIn/notifications");

            if (!isAllowed) {
                handleAccessDenied(request, response, "Access Denied !");
                return;
            }
        }


        // 4. BƯỚC QUAN TRỌNG NHẤT: Xóa lỗi nếu truy cập hợp lệ (Manager luôn vào đây)
        if (session != null && session.getAttribute("accessError") != null) {
            session.removeAttribute("accessError");
        }

        filterChain.doFilter(request, response);
    }

    private void handleAccessDenied(HttpServletRequest request, HttpServletResponse response, String message) throws IOException {
        HttpSession session = request.getSession();
        session.setAttribute("accessError", message);
        response.sendRedirect(request.getContextPath() + "/dashboard?authError=1");
    }
}