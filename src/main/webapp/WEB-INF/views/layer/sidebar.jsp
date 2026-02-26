<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<style>
    :root {
        --sb-bg: #ffffff;
        --sb-collapsed: 80px;
        --sb-expanded: 260px;
        --sb-blue: #2563eb;
        --sb-text: #64748b;
        --sb-hover: #f8fafc;
        /* Đồng bộ font chữ với các hệ thống POS hiện đại */
        --sb-font: 'Inter', 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
    }

    #sidebar {
        width: var(--sb-collapsed);
        height: calc(100vh - 70px);
        position: fixed;
        top: 70px;
        left: 0;
        background: var(--sb-bg);
        border-right: 1px solid #edf2f7;
        transition: width 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        z-index: 1000;
        overflow-y: auto;
        overflow-x: hidden;
        font-family: var(--sb-font);
    }

    #sidebar.expanded {
        width: var(--sb-expanded);
        box-shadow: 10px 0 30px rgba(0, 0, 0, 0.05);
    }

    /* Header & Toggle Area */
    .sidebar-header {
        height: 60px;
        display: flex;
        align-items: center;
        justify-content: center;
        cursor: pointer;
        color: var(--sb-blue);
        border-bottom: 1px solid #f8fafc;
    }

    #sidebar.expanded .sidebar-header {
        justify-content: space-between;
        padding: 0 28px;
    }

    /* Đảm bảo transition mượt mà cho icon */
    .toggle-icon {
        font-size: 1.1rem;
        transition: transform 0.3s ease;
    }

    #sidebar.expanded .toggle-icon {
        transform: rotate(180deg);
    }

    /* FIX: Khi sidebar đóng, ép tất cả các nội dung bên trong collapse phải ẩn đi */
    #sidebar:not(.expanded) .collapse {
        display: none !important;
    }

    /* FIX: Ẩn các mũi tên xuống khi thu nhỏ để icon chính được căn giữa */
    #sidebar:not(.expanded) .sb-arrow {
        display: none !important;
    }

    /* Sidebar Links (Cấp 1) */
    .sidebar-link {
        display: flex;
        align-items: center;
        justify-content: center;
        height: 50px;
        color: var(--sb-text);
        text-decoration: none !important;
        margin: 4px 12px;
        border-radius: 12px;
        transition: all 0.2s;
    }

    #sidebar.expanded .sidebar-link {
        justify-content: flex-start;
        padding: 0 16px;
    }

    .sidebar-link i:first-child {
        font-size: 1.2rem;
        min-width: 24px;
        text-align: center;
    }

    .sidebar-link:hover {
        background: var(--sb-hover);
        color: var(--sb-blue);
    }

    .sidebar-link.active {
        background: #eff6ff;
        color: var(--sb-blue);
        font-weight: 600;
    }

    /* KHÓA CLICK: Chỉ Dashboard được bấm khi thu nhỏ */
    #sidebar:not(.expanded) .sidebar-link:not(.allow-collapsed),
    #sidebar:not(.expanded) .nav-group {
        pointer-events: none;
        cursor: default;
    }

    /* Submenu (Cấp 2) */
    .submenu-list {
        padding: 2px 0 8px 0;
    }

    .submenu-item {
        display: flex;
        align-items: center;
        padding: 10px 16px 10px 48px;
        color: var(--sb-text);
        text-decoration: none !important;
        font-size: 0.88rem;
        border-radius: 10px;
        margin: 2px 12px;
        transition: all 0.2s;
    }

    .submenu-item i {
        font-size: 1rem;
        width: 20px;
        margin-right: 10px;
    }

    .submenu-item.active {
        background: var(--sb-blue);
        color: #fff !important;
        font-weight: 500;
    }

    .submenu-item:hover:not(.active) {
        background: var(--sb-hover);
        color: var(--sb-blue);
    }

    /* Visibility Controls */
    .sb-text, .sb-arrow, .header-label {
        display: none;
        opacity: 0;
        white-space: nowrap;
    }

    #sidebar.expanded .sb-text,
    #sidebar.expanded .sb-arrow,
    #sidebar.expanded .header-label {
        display: inline-block;
        opacity: 1;
        margin-left: 12px;
    }

    .sb-arrow {
        margin-left: auto;
        font-size: 9px;
    }

    #sidebar::-webkit-scrollbar { width: 4px; }
    #sidebar::-webkit-scrollbar-thumb { background: #e2e8f0; border-radius: 10px; }
</style>

<div id="sidebar">
    <div class="sidebar-header" id="toggleBtn">
        <span class="header-label fw-bold" style="font-size: 14px; letter-spacing: 0.5px;">NAVIGATION</span>
        <i class="fa-solid fa-chevron-right toggle-icon"></i>
    </div>

    <a href="/dashboard" class="sidebar-link allow-collapsed ${pageContext.request.requestURI.endsWith('dashboard') ? 'active' : ''}">
        <i class="fa-solid fa-house-chimney"></i>
        <span class="sb-text">Dashboard</span>
    </a>

    <c:set var="isPosOpen" value="${pageContext.request.requestURI.contains('/pos') || pageContext.request.requestURI.contains('/receipts')}" />
    <div class="nav-group">
        <a href="#posSub" data-bs-toggle="collapse" class="sidebar-link ${isPosOpen ? 'active' : ''}">
            <i class="fa-solid fa-cart-shopping"></i>
            <span class="sb-text">POS & Sales</span>
            <i class="fa-solid fa-chevron-down sb-arrow"></i> </a>
        <div class="collapse ${isPosOpen ? 'show' : ''}" id="posSub">
            <div class="submenu-list">
                <a href="/pos" class="submenu-item ${pageContext.request.requestURI.endsWith('/pos') ? 'active' : ''}">
                    <i class="fa-solid fa-cash-register"></i>
                    <span>POS Terminal</span>
                </a>
                <a href="/pos/receipts" class="submenu-item ${pageContext.request.requestURI.contains('/receipts') ? 'active' : ''}">
                    <i class="fa-solid fa-file-invoice"></i>
                    <span>Manage Receipt</span>
                </a>
            </div>
        </div>
    </div>


    <c:set var="isMenuOpen" value="${pageContext.request.requestURI.contains('/products')}" />
    <div class="nav-group">
        <a href="#menuSub" data-bs-toggle="collapse" class="sidebar-link ${isMenuOpen ? 'active' : ''}">
            <i class="fa-solid fa-utensils"></i>
            <span class="sb-text">Menu & Products</span>
            <i class="fa-solid fa-chevron-down sb-arrow"></i>
        </a>
        <div class="collapse ${isMenuOpen ? 'show' : ''}" id="menuSub">
            <div class="submenu-list">
                <a href="/products/manage" class="submenu-item ${pageContext.request.requestURI.contains('/manage') ? 'active' : ''}">
                    <i class="fa-solid fa-layer-group"></i>
                    <span>Product List</span>
                </a>
            </div>
        </div>
    </div>

    <c:set var="isCrmOpen" value="${pageContext.request.requestURI.contains('/cus-promo')}" />
    <div class="nav-group">
        <a href="#crmSub" data-bs-toggle="collapse" class="sidebar-link ${isCrmOpen ? 'active' : ''}">
            <i class="fa-solid fa-users-gear"></i>
            <span class="sb-text">CRM & Promo</span>
            <i class="fa-solid fa-chevron-down sb-arrow"></i>
        </a>
        <div class="collapse ${isCrmOpen ? 'show' : ''}" id="crmSub">
            <div class="submenu-list">
                <a href="/customer" class="submenu-item ${pageContext.request.requestURI.contains('/customer') ? 'active' : ''}">
                    <i class="fa-solid fa-user-tag"></i>
                    <span>Customers</span>
                </a>
                <a href="/promotion" class="submenu-item ${pageContext.request.requestURI.contains('/promotion') ? 'active' : ''}">
                    <i class="fa-solid fa-ticket"></i>
                    <span>Promotions</span>
                </a>
            </div>
        </div>
    </div>

    <c:set var="isInvOpen" value="${pageContext.request.requestURI.contains('/stockIn') or pageContext.request.requestURI.contains('/suppliers') or pageContext.request.requestURI.contains('/inventory')}" />
    <div class="nav-group">
        <a href="#invSub" data-bs-toggle="collapse" class="sidebar-link ${isInvOpen ? 'active' : ''}">
            <i class="fa-solid fa-boxes-stacked"></i>
            <span class="sb-text">Inventory</span>
            <i class="fa-solid fa-chevron-down sb-arrow"></i>
        </a>
        <div class="collapse ${isInvOpen ? 'show' : ''}" id="invSub">
            <div class="submenu-list">
                <a href="/stockIn/notifications" class="submenu-item">
                    <i class="fa-solid fa-bell"></i><span>Notifications</span>
                </a>
                <a href="/stockIn/view" class="submenu-item">
                    <i class="fa-solid fa-file-circle-plus"></i><span>Request Order</span>
                </a>
                <a href="/suppliers" class="submenu-item">
                    <i class="fa-solid fa-truck-ramp-box"></i><span>Supplier List</span>
                </a>
                <a href="/inventory/approval/queue" class="submenu-item">
                    <i class="fa-solid fa-clipboard-check"></i><span>Approval Queue</span>
                </a>
            </div>
        </div>
    </div>

    <a href="/reports" class="sidebar-link">
        <i class="fa-solid fa-chart-column"></i>
        <span class="sb-text">Reports</span>
    </a>
</div>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        const sidebar = document.getElementById('sidebar');
        const toggleBtn = document.getElementById('toggleBtn');

        // Toggle Expand/Collapse on Click
        toggleBtn.addEventListener('click', function() {
            sidebar.classList.toggle('expanded');
        });

        // Auto-close submenus when collapsing for clean UI
        sidebar.addEventListener('transitionend', function() {
            if (!sidebar.classList.contains('expanded')) {
                const openCollapses = sidebar.querySelectorAll('.collapse.show');
                openCollapses.forEach(c => {
                    const bCollapse = bootstrap.Collapse.getInstance(c);
                    if (bCollapse) bCollapse.hide();
                });
            }
        });
    });
</script>