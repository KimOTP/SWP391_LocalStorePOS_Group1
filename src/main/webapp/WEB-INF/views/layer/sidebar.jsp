<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<div id="sidebar" class="sidebar bg-white border-end">
    <div class="d-flex flex-column h-100">

        <div class="sidebar-item toggle-btn" id="sidebarToggle">
            <i class="fa-solid fa-chevron-right" id="toggleIcon"></i>
            <span class="ms-3 sidebar-text fw-bold">Collapse</span>
        </div>

        <a href="/" class="sidebar-item text-decoration-none" title="Home">
            <i class="fa-solid fa-house"></i>
            <span class="ms-3 sidebar-text">Home</span>
        </a>

        <a href="/pos" class="sidebar-item text-decoration-none" title="POS">
            <i class="fa-solid fa-cart-shopping"></i>
            <span class="ms-3 sidebar-text">POS & Sales</span>
        </a>

        <a href="/products/manage" class="sidebar-item text-decoration-none" title="Products">
            <i class="fa-solid fa-store"></i>
            <span class="ms-3 sidebar-text">Menu & Products</span>
        </a>

        <c:set var="isCrmActive" value="${pageContext.request.requestURI.contains('/customers') or pageContext.request.requestURI.contains('/promotions')}" />

        <div class="nav-item">
            <a href="#crmSubmenu" data-bs-toggle="collapse"
               class="sidebar-item text-decoration-none d-flex align-items-center justify-content-between ${isCrmActive ? 'active' : ''}"
               aria-expanded="${isCrmActive}">
                <div class="d-flex align-items-center">
                    <i class="fa-solid fa-user-group"></i> <span class="ms-3 sidebar-text">CRM & Promo</span>
                </div>
                <i class="fa-solid fa-chevron-down ms-auto sidebar-text small-arrow"></i>
            </a>

            <div class="collapse ${isCrmActive ? 'show' : ''}" id="crmSubmenu" style="background-color: #f9f9f9;">
                <ul class="btn-toggle-nav list-unstyled fw-normal pb-1 small m-0">

                    <li>
                        <a href="/customers" class="sidebar-item text-decoration-none ps-5 d-flex align-items-center ${pageContext.request.requestURI.contains('/customers') ? 'text-primary fw-bold' : ''}" style="height: 45px;">
                            <i class="fa-regular fa-user me-2 sidebar-text" style="font-size: 14px;"></i>
                            <span class="sidebar-text">Customer</span>
                        </a>
                    </li>

                    <li>
                        <a href="/promotions" class="sidebar-item text-decoration-none ps-5 d-flex align-items-center ${pageContext.request.requestURI.contains('/promotions') ? 'text-primary fw-bold' : ''}" style="height: 45px;">
                            <i class="fa-solid fa-tags me-2 sidebar-text" style="font-size: 14px;"></i>
                            <span class="sidebar-text">Promotion</span>
                        </a>
                    </li>

                </ul>
            </div>
        </div>
        <c:set var="isInventoryActive" value="${pageContext.request.requestURI.contains('/stockIn')
                                      or pageContext.request.requestURI.contains('/suppliers')
                                      or pageContext.request.requestURI.contains('/inventory/admin')}" />

        <div class="nav-item">
            <a href="#inventorySubmenu" data-bs-toggle="collapse"
               class="sidebar-item text-decoration-none d-flex align-items-center justify-content-between ${isInventoryActive ? 'active' : ''}"
               aria-expanded="${isInventoryActive}">
                <div class="d-flex align-items-center">
                    <i class="fa-solid fa-building"></i>
                    <span class="ms-3 sidebar-text">Inventory</span>
                </div>
                <i class="fa-solid fa-chevron-down ms-auto sidebar-text small-arrow"></i>
            </a>

            <div class="collapse ${isInventoryActive ? 'show' : ''}" id="inventorySubmenu" style="background-color: #f9f9f9;">
                <ul class="btn-toggle-nav list-unstyled fw-normal pb-1 small m-0">

                    <li>
                        <a href="/stockIn/inventory-staff/notifications" class="sidebar-item text-decoration-none ps-5 d-flex align-items-center ${pageContext.request.requestURI.contains('/notifications') ? 'text-primary fw-bold' : ''}" style="height: 45px;">
                            <i class="fa-solid fa-bell me-2 sidebar-text" style="font-size: 14px;"></i>
                            <span class="sidebar-text">Notifications</span>
                        </a>
                    </li>

                    <li>
                        <a href="/stockIn/admin/view" class="sidebar-item text-decoration-none ps-5 d-flex align-items-center ${pageContext.request.requestURI.contains('/stockIn/admin') ? 'text-primary fw-bold' : ''}" style="height: 45px;">
                            <i class="fa-solid fa-file-invoice me-2 sidebar-text" style="font-size: 14px;"></i>
                            <span class="sidebar-text">Request Order</span>
                        </a>
                    </li>

                    <li>
                        <a href="/suppliers" class="sidebar-item text-decoration-none ps-5 d-flex align-items-center ${pageContext.request.requestURI.contains('/suppliers') ? 'text-primary fw-bold' : ''}" style="height: 45px;">
                            <i class="fa-solid fa-truck-field me-2 sidebar-text" style="font-size: 14px;"></i>
                            <span class="sidebar-text">Supplier List</span>
                        </a>
                    </li>

                    <li>
                        <a href="/inventory/admin/approval/queue" class="sidebar-item text-decoration-none ps-5 d-flex align-items-center ${pageContext.request.requestURI.contains('/inventory/admin/queue') ? 'text-primary fw-bold' : ''}" style="height: 45px;">
                            <i class="fa-solid fa-check-to-slot me-2 sidebar-text" style="font-size: 14px;"></i>
                            <span class="sidebar-text">Approval Queue</span>
                        </a>
                    </li>

                </ul>
            </div>
        </div>

        <a href="/reports" class="sidebar-item text-decoration-none" title="Reports">
            <i class="fa-solid fa-clipboard-list"></i>
            <span class="ms-3 sidebar-text">Reports</span>
        </a>
    </div>
</div>

<style>
    /* CSS Sidebar cơ bản */
    .sidebar {
        width: 80px;
        height: calc(100vh - 70px);
        position: fixed;
        top: 70px;
        left: 0;
        transition: width 0.3s ease;
        z-index: 1000;
        overflow-x: hidden;
        white-space: nowrap;
        box-shadow: 2px 0 5px rgba(0,0,0,0.05);
    }

    .sidebar.expanded { width: 250px; }

    .sidebar-item {
        padding: 15px 25px;
        font-size: 18px;
        color: #555;
        cursor: pointer;
        display: flex;
        align-items: center;
        transition: all 0.2s;
    }

    .sidebar-item:hover, .sidebar-item.active {
        color: #0d6efd;
    }

    /* Hiệu ứng thanh xanh bên trái khi active (chỉ áp dụng cho item cấp 1) */
    .nav-item > .sidebar-item.active {
        background-color: #f0f2f5;
        border-left: 4px solid #0d6efd;
    }

    /* Ẩn hiện text khi thu/phóng */
    .sidebar-text {
        opacity: 0;
        transition: opacity 0.2s;
        visibility: hidden;
        display: none; /* Ẩn hẳn để không vỡ layout khi thu nhỏ */
    }

    .sidebar.expanded .sidebar-text {
        opacity: 1;
        visibility: visible;
        display: inline-block;
    }

    .sidebar.expanded #toggleIcon { transform: rotate(180deg); }

    /* Mũi tên nhỏ của dropdown */
    .small-arrow { font-size: 12px; transition: transform 0.2s; }
    .sidebar-item[aria-expanded="true"] .small-arrow { transform: rotate(180deg); }

</style>

<script>
    const sidebar = document.getElementById('sidebar');
    const toggleBtn = document.getElementById('sidebarToggle');

    // Hover vào mũi tên -> Mở rộng sidebar
    toggleBtn.addEventListener('mouseenter', () => {
        sidebar.classList.add('expanded');
    });

    // Rời chuột khỏi sidebar -> Thu nhỏ
    sidebar.addEventListener('mouseleave', () => {
        // Chỉ thu nhỏ nếu người dùng không click giữ cố định (logic mở rộng tùy bạn)
        sidebar.classList.remove('expanded');

        // Tùy chọn: Khi thu nhỏ thì đóng luôn submenu cho gọn
        // var collapseElementList = [].slice.call(document.querySelectorAll('.collapse'))
        // var collapseList = collapseElementList.map(function (collapseEl) {
        //   return new bootstrap.Collapse(collapseEl, { toggle: false }).hide()
        // })
    });
</script>