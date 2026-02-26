<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%-- Bootstrap + Font Awesome --%>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet">

<style>
    /* --- UI Profile Dropdown - Refined & Small Style --- */
    .user-dropdown {
        min-width: 260px !important;
        border-radius: 12px !important;
        padding: 0 !important;
        border: 1px solid #edf2f7 !important;
        box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08) !important;
        overflow: hidden !important;
    }

    /* Container cho Avatar */
    .user-avatar-container {
        width: 50px !important;
        height: 50px !important;
        flex-shrink: 0;
        border-radius: 50% !important;
        overflow: hidden;
        border: 1px solid #eee;
    }

    .user-avatar-img {
        width: 100%;
        height: 100%;
        object-fit: cover;
    }

    /* Ép cỡ chữ nhỏ lại cho phần Header */
    .user-details .user-name {
        font-size: 14px !important;
        font-weight: 600 !important;
        color: #1e293b;
        line-height: 1.2;
        margin-bottom: 2px;
    }

    .user-details .user-email {
        font-size: 13px !important;
        color: #94a3b8;
        font-weight: 400 !important;
        margin-bottom: 6px;
        display: block;
    }

    /* Badge bo tròn kiểu Pill (Viên thuốc) */
    .user-badge-pill {
        font-size: 10px !important;
        padding: 2px 10px !important;
        border-radius: 50px !important; /* Bo tròn hoàn toàn */
        font-weight: 500 !important;
        display: inline-block;
        border: 1px solid transparent;
        text-transform: capitalize;
    }


    .role-pill {
        background-color: #ffffff !important;
        border-color: #e2e8f0 !important;
        color: #64748b !important;
    }
    .status-pill {
            background-color: #eff6ff !important;
            border-color: #dbeafe !important;
            color: #3b82f6 !important;
    }

    /* Trạng thái Active - Xanh dương nhạt */
    .status-active-header {
        background-color: #ecfdf5 !important;
        border-color: #dbeafe !important;
        color: #3b82f6 !important;
    }

    /* Trạng thái Inactive - Đỏ nhạt */
    .status-inactive-header {
        background-color: #fef2f2 !important;
        border-color: #fee2e2 !important;
        color: #ef4444 !important;
    }

    /* Đảm bảo icon cũng nhỏ gọn */
    .user-badge-pill i {
        font-size: 9px !important;
    }

    .dept-pill {
        background-color: #eff6ff !important;
        border-color: #dbeafe !important;
        color: #3b82f6 !important;
    }

    /* Menu Items nhỏ gọn và thanh thoát */
    .user-dropdown .dropdown-item {
        font-size: 12px !important;
        padding: 10px 16px !important;
        color: #475569 !important;
        font-weight: 400 !important;
        display: flex;
        align-items: center;
        transition: all 0.2s;
    }

    .user-dropdown .dropdown-item i {
        width: 20px;
        font-size: 14px;
        color: #94a3b8;
        margin-right: 8px;
    }

    .user-dropdown .dropdown-item:hover {
        background-color: #f8fafc !important;
        color: #2563eb !important;
    }

    .user-dropdown .dropdown-item:hover i {
        color: #2563eb !important;
    }

    .user-dropdown .dropdown-item.text-danger:hover {
        background-color: #fef2f2 !important;
        color: #dc2626 !important;
    }

    .dropdown-divider {
        margin: 0 !important;
        border-top: 1px solid #f1f5f9 !important;
        opacity: 1 !important;
    }
</style>

<nav class="navbar navbar-expand-lg navbar-light bg-white border-bottom fixed-top" style="height: 70px;">
    <div class="container-fluid px-4">
        <a class="navbar-brand p-0 me-3" href="${pageContext.request.contextPath}/dashboard">
            <img src="${pageContext.request.contextPath}/resources/static/images/pos-logo.png"
                 alt="POS System Logo"
                 style="height: 50px; width: auto; object-fit: contain;">
        </a>

        <div class="d-flex flex-column align-items-end mx-auto me-4">
            <span id="realtime-clock" class="fw-bold fs-5 text-primary">00:00:00</span>
            <span id="realtime-date" class="small text-muted">Loading date...</span>
        </div>

        <div class="dropdown">
            <button class="btn btn-light d-flex align-items-center gap-2 border-0 bg-transparent" type="button" data-bs-toggle="dropdown">
                <div class="text-end" style="line-height: 1.2;">
                    <span class="d-block fw-bold small text-dark">${account.username}</span>
                    <span class="d-block text-muted" style="font-size: 11px;">${account.employee.role}</span>
                </div>
                <div class="bg-primary rounded-circle text-white d-flex align-items-center justify-content-center" style="width: 35px; height: 35px;">
                    <i class="fa-solid fa-user"></i>
                </div>
            </button>
            <ul class="dropdown-menu dropdown-menu-end user-dropdown">
                <li class="px-3 py-3">
                    <div class="d-flex align-items-center gap-3">
                        <div class="user-avatar-container">
                            <img src="https://ui-avatars.com/api/?name=${account.username}&background=f1f5f9&color=64748b" alt="Avatar" class="user-avatar-img">
                        </div>
                        <div class="user-details">
                            <div class="user-name">${account.username}</div>
                            <div class="user-email text-muted">${account.employee.email}</div>
                            <div class="d-flex gap-1 mt-1">
                                <span class="user-badge-pill role-pill">
                                    <i class="fa-solid ${account.employee.role == 'MANAGER' ? 'fa-user-tie' : 'fa-cash-register'}"></i>
                                    ${account.employee.role}
                                </span>
                                <span class="user-badge-pill status-pill ${account.employee.status ? 'status-active-header' : 'status-inactive-header'}">
                                    <i class="fa-solid ${account.employee.status ? 'fa-circle-check' : 'fa-circle-xmark'}"></i>
                                    ${account.employee.status ? 'Active' : 'Inactive'}
                                </span>
                            </div>
                        </div>
                    </div>
                </li>

                <li><hr class="dropdown-divider"></li>

                <li>
                    <a class="dropdown-item"
                       href="${account.employee.role == 'MANAGER' ? '/hr/manager/manager_profile' : '/hr/cashier/cashier_profile'}">
                        <i class="fa-regular fa-address-card"></i>Profile
                    </a>
                </li>
                <li>
                    <a class="dropdown-item text-danger" href="${pageContext.request.contextPath}/auth/logout">
                        <i class="fa-solid fa-arrow-right-from-bracket"></i>Logout
                    </a>
                </li>
            </ul>
        </div>
    </div>
</nav>

<script>
    function updateClock() {
        const now = new Date();
        const timeString = now.toLocaleTimeString('vi-VN', { hour12: false });
        const options = { weekday: 'long', year: 'numeric', month: '2-digit', day: '2-digit' };
        const dateString = now.toLocaleDateString('en-US', options);

        document.getElementById('realtime-clock').textContent = timeString;
        document.getElementById('realtime-date').textContent = dateString;
    }
    setInterval(updateClock, 1000);
    updateClock();
</script>