<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<nav class="navbar navbar-expand-lg navbar-light bg-white border-bottom fixed-top" style="height: 70px;">
    <div class="container-fluid px-4">

        <a class="navbar-brand p-0 me-3" href="${pageContext.request.contextPath}/">
            <img src="${pageContext.request.contextPath}/resources/static/images/pos-logo.png"
                 alt="POS System Logo"
                 style="height: 50px; width: auto; object-fit: contain;">
        </a>

        <div class="d-flex flex-column align-items-end mx-auto me-4">
            <span id="realtime-clock" class="fw-bold fs-5 text-primary">00:00:00</span>
            <span id="realtime-date" class="small text-muted">Thứ ..., .../.../....</span>
        </div>

        <div class="dropdown">
            <button class="btn btn-light d-flex align-items-center gap-2 border-0" type="button" data-bs-toggle="dropdown">
                <div class="text-end" style="line-height: 1.2;">
                    <span class="d-block fw-bold small">${account.username}</span>
                    <span class="d-block text-muted" style="font-size: 11px;">${account.employee.role}</span>
                </div>
                <div class="bg-secondary rounded-circle text-white d-flex align-items-center justify-content-center" style="width: 35px; height: 35px;">
                    <i class="fa-solid fa-user"></i>
                </div>
            </button>
            <ul class="dropdown-menu dropdown-menu-end">
                <li>
                    <a class="dropdown-item"
                       href="${employee.role == 'MANAGER'
                            ? pageContext.request.contextPath.concat('/hr/manager/manager_profile')
                            : pageContext.request.contextPath.concat('/hr/cashier/cashier_profile')}">
                        Profile
                    </a>
                </li>
                <li><a class="dropdown-item" href="#">Settings</a></li>
                <li><hr class="dropdown-divider"></li>
                <li><a class="dropdown-item text-danger" href="${pageContext.request.contextPath}/auth/logout">← Logout</a></li>
            </ul>
        </div>
    </div>
</nav>

<script>
    // Script chạy đồng hồ thời gian thực
    function updateClock() {
        const now = new Date();

        // Format giờ: 14:05:30
        const timeString = now.toLocaleTimeString('vi-VN', { hour12: false });

        // Format ngày: Thứ Tư, 04/02/2026
        const options = { weekday: 'long', year: 'numeric', month: '2-digit', day: '2-digit' };
        // Sử dụng 'en-US' để hiển thị tiếng Anh
        const dateString = now.toLocaleDateString('en-US', options);

        document.getElementById('realtime-clock').textContent = timeString;
        document.getElementById('realtime-date').textContent = dateString;
    }

    setInterval(updateClock, 1000); // Cập nhật mỗi giây
    updateClock(); // Chạy ngay khi load trang
</script>