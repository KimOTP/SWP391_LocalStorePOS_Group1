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

        // 1. CỨU CSS: Cho phép các file tĩnh và trang login đi qua luôn
        if (uri.contains("/static/") || uri.contains("/auth/") || uri.contains("/css/") || uri.contains("/js/")) {
            filterChain.doFilter(request, response);
            return;
        }

        // 2. Kiểm tra đăng nhập
        if (role == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return;
        }

        // 3. Phân quyền chi tiết dựa trên thư mục
        if ("CASHIER".equalsIgnoreCase(role)) {
            // Chặn nếu truy cập vào bất kỳ folder nào chứa chữ "manager" hoặc "admin"
            if (uri.contains("/manager/") || uri.contains("/admin/")) {
                response.sendRedirect(request.getContextPath() + "/dashboard");
                return;
            }

            // Cashier chỉ được vào các folder "cashier", "dashboard", "layer" hoặc "common"
            // Bạn có thể thêm các folder khác vào đây nếu cần
            boolean isAllowed = uri.contains("/pos")
                    || uri.contains("/dashboard")
                    || uri.contains("/layer");

            if (!isAllowed) {
                // Ví dụ: Cashier vào /product/ (không thuộc 3 cái trên) sẽ bị đẩy về dashboard
                response.sendRedirect(request.getContextPath() + "/dashboard");
                return;
            }
        }

        // Manager mặc định được đi tiếp vì không bị chặn bởi logic if trên
        filterChain.doFilter(request, response);
    }
}