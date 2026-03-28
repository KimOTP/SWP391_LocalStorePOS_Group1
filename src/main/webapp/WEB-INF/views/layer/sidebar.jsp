<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<style>
    :root {
        --sb-bg: #ffffff;
        --sb-collapsed: 80px;
        --sb-expanded: 260px;
        --sb-blue: #2563eb;
        --sb-text: #64748b;
        --sb-hover: #f8fafc;
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
        z-index: 1000;
        overflow-y: auto;
        overflow-x: hidden;
        font-family: var(--sb-font);
    }

    #sidebar.ready {
        transition: width 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    }

    #sidebar.expanded {
        width: var(--sb-expanded);
        box-shadow: 10px 0 30px rgba(0, 0, 0, 0.05);
    }

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

    .toggle-icon {
        font-size: 1.1rem;
    }

    #sidebar.ready .toggle-icon {
        transition: transform 0.3s ease;
    }

    #sidebar.expanded .toggle-icon {
        transform: rotate(180deg);
    }

    /* Sidebar Links (Level 1) */
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
        cursor: pointer;
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

    /* Parent active — chỉ đổi màu chữ + bold, KHÔNG có nền */
    .sidebar-link.active {
        color: var(--sb-blue);
        font-weight: 700;
        background: transparent;
    }

    /* Submenu (Level 2) */
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
        border-left: 3px solid transparent;
    }

    .submenu-item i {
        font-size: 1rem;
        width: 20px;
        margin-right: 10px;
    }

    /* Submenu active — nền xanh nhạt + đường kẻ xanh bên trái */
    .submenu-item.active {
        background: #eff6ff;
        color: var(--sb-blue) !important;
        font-weight: 600;
        border-left: 3px solid var(--sb-blue);
        padding-left: 45px !important;
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
        transition: transform 0.3s;
    }

    .sidebar-link[aria-expanded="true"] .sb-arrow {
        transform: rotate(180deg);
    }

    /* Dùng sb-collapse thay vì Bootstrap collapse để tránh Bootstrap can thiệp */
    .sb-collapse {
        display: none;
    }

    .sb-collapse.sb-show {
        display: block;
    }

    /* ẨN submenu khi sidebar collapsed */
    #sidebar:not(.expanded) .submenu-list {
        display: none;
    }

    #sidebar::-webkit-scrollbar { width: 4px; }
    #sidebar::-webkit-scrollbar-thumb { background: #e2e8f0; border-radius: 10px; }
</style>

<c:set var="currUri" value="${requestScope['jakarta.servlet.forward.request_uri']}" />

<%-- Tính toán group nào đang active --%>
<c:set var="isPosOpen"  value="${fn:contains(currUri, '/pos') || fn:contains(currUri, '/receipts')}" />
<c:set var="isMenuOpen" value="${fn:contains(currUri, '/products') || fn:contains(currUri, '/combos')}" />
<c:set var="isCrmOpen"  value="${fn:contains(currUri, '/customer') || fn:contains(currUri, '/promotion')}" />
<c:set var="isInvOpen"  value="${fn:contains(currUri, '/inventory') || fn:contains(currUri, '/stockIn') || fn:contains(currUri, '/stockOut') || fn:contains(currUri, '/audit') || fn:contains(currUri, '/suppliers') || fn:contains(currUri, '/approval') || fn:contains(currUri, '/log')}" />

<%-- Đọc cookie để render class expanded ngay từ server — tránh flash transition --%>
<div id="sidebar" class="${cookie['sidebarExpanded'].value == 'true' ? 'expanded' : ''}">
    <div class="sidebar-header" id="toggleBtn">
        <span class="header-label fw-bold" style="font-size: 14px; letter-spacing: 0.5px;">NAVIGATION</span>
        <i class="fa-solid fa-chevron-right toggle-icon"></i>
    </div>

    <%-- Dashboard --%>
    <a href="<c:url value='/dashboard'/>"
       class="sidebar-link ${fn:contains(currUri, '/dashboard') ? 'active' : ''}">
        <i class="fa-solid fa-house-chimney"></i>
        <span class="sb-text">Dashboard</span>
    </a>

    <%-- POS & Sales --%>
    <div class="nav-group">
        <a href="javascript:void(0)"
           class="sidebar-link"
           aria-expanded="${isPosOpen}">
            <i class="fa-solid fa-cart-shopping"></i>
            <span class="sb-text">POS &amp; Sales</span>
            <i class="fa-solid fa-chevron-down sb-arrow"></i>
        </a>
        <div class="sb-collapse ${isPosOpen ? 'sb-show' : ''}" id="posSub">
            <div class="submenu-list">
                <a href="<c:url value='/pos'/>"
                   class="submenu-item ${fn:endsWith(currUri, '/pos') ? 'active' : ''}">
                    <i class="fa-solid fa-cash-register"></i>
                    <span>POS Terminal</span>
                </a>
                <a href="<c:url value='/pos/receipts'/>"
                   class="submenu-item ${fn:contains(currUri, '/receipts') ? 'active' : ''}">
                    <i class="fa-solid fa-file-invoice"></i>
                    <span>Manage Receipt</span>
                </a>
            </div>
        </div>
    </div>

    <%-- Menu & Products --%>
    <div class="nav-group">
        <a href="javascript:void(0)"
           class="sidebar-link"
           aria-expanded="${isMenuOpen}">
            <i class="fa-solid fa-utensils"></i>
            <span class="sb-text">Menu &amp; Products</span>
            <i class="fa-solid fa-chevron-down sb-arrow"></i>
        </a>
        <div class="sb-collapse ${isMenuOpen ? 'sb-show' : ''}" id="menuSub">
            <div class="submenu-list">
                <a href="<c:url value='/products/manage'/>"
                   class="submenu-item ${fn:contains(currUri, '/products/manage') ? 'active' : ''}">
                    <i class="fa-solid fa-layer-group"></i>
                    <span>Product</span>
                </a>
                <a href="<c:url value='/combos/manage'/>"
                   class="submenu-item ${fn:contains(currUri, '/combos/manage') ? 'active' : ''}">
                    <i class="fa-solid fa-cubes"></i>
                    <span>Combo</span>
                </a>
            </div>
        </div>
    </div>

    <%-- CRM & Promo --%>
    <div class="nav-group">
        <a href="javascript:void(0)"
           class="sidebar-link"
           aria-expanded="${isCrmOpen}">
            <i class="fa-solid fa-users-gear"></i>
            <span class="sb-text">CRM &amp; Promo</span>
            <i class="fa-solid fa-chevron-down sb-arrow"></i>
        </a>
        <div class="sb-collapse ${isCrmOpen ? 'sb-show' : ''}" id="crmSub">
            <div class="submenu-list">
                <a href="<c:url value='/customer'/>"
                   class="submenu-item ${fn:contains(currUri, '/customer') ? 'active' : ''}">
                    <i class="fa-solid fa-user-tag"></i>
                    <span>Customers</span>
                </a>
                <a href="<c:url value='/promotion'/>"
                   class="submenu-item ${fn:contains(currUri, '/promotion') ? 'active' : ''}">
                    <i class="fa-solid fa-ticket"></i>
                    <span>Promotions</span>
                </a>
            </div>
        </div>
    </div>

    <%-- Inventory --%>
    <div class="nav-group">
        <a href="javascript:void(0)"
           class="sidebar-link"
           aria-expanded="${isInvOpen}">
            <i class="fa-solid fa-boxes-stacked"></i>
            <span class="sb-text">Inventory</span>
            <i class="fa-solid fa-chevron-down sb-arrow"></i>
        </a>
        <div class="sb-collapse ${isInvOpen ? 'sb-show' : ''}" id="invSub">
            <div class="submenu-list">
                <a href="<c:url value='/inventory/dashboard'/>"
                   class="submenu-item ${fn:contains(currUri, '/inventory/dashboard') ? 'active' : ''}">
                    <i class="fa-solid fa-house-chimney"></i><span>Inventory Dashboard</span>
                </a>
                <a href="<c:url value='/stockIn/notifications'/>"
                   class="submenu-item ${fn:contains(currUri, '/notifications') ? 'active' : ''}">
                    <i class="fa-solid fa-bell"></i><span>Notifications</span>
                </a>
                <a href="<c:url value='/stockIn/add'/>"
                   class="submenu-item ${fn:contains(currUri, '/stockIn/add') ? 'active' : ''}">
                    <i class="fa-solid fa-file-circle-plus"></i><span>Stock-in Request</span>
                </a>
                <a href="<c:url value='/stockOut/add'/>"
                   class="submenu-item ${fn:contains(currUri, '/stockOut/add') ? 'active' : ''}">
                    <i class="fa-solid fa-file-circle-minus"></i><span>Stock-out Request</span>
                </a>
                <a href="<c:url value='/audit/add'/>"
                   class="submenu-item ${fn:contains(currUri, '/audit') ? 'active' : ''}">
                    <i class="fa-solid fa-clipboard-list"></i><span>Audit Session</span>
                </a>
                <a href="<c:url value='/suppliers'/>"
                   class="submenu-item ${fn:contains(currUri, '/suppliers') ? 'active' : ''}">
                    <i class="fa-solid fa-truck-ramp-box"></i><span>Supplier List</span>
                </a>
                <a href="<c:url value='/inventory/approval/queue'/>"
                   class="submenu-item ${fn:contains(currUri, '/approval') ? 'active' : ''}">
                    <i class="fa-solid fa-clipboard-check"></i><span>Approval Queue</span>
                </a>
                <a href="<c:url value='/inventory/log/show'/>"
                   class="submenu-item ${fn:contains(currUri, '/log') ? 'active' : ''}">
                    <i class="fa-solid fa-clock-rotate-left"></i><span>Inventory Logs</span>
                </a>
            </div>
        </div>
    </div>

    <%-- Reports --%>
    <a href="<c:url value='/reports'/>"
       class="sidebar-link ${fn:contains(currUri, '/reports') ? 'active' : ''}">
        <i class="fa-solid fa-chart-column"></i>
        <span class="sb-text">Reports</span>
    </a>
</div>

<script>
(function () {
    var sidebar = document.getElementById('sidebar');

    document.addEventListener('DOMContentLoaded', function () {
        var toggleBtn = document.getElementById('toggleBtn');

        // Bật transition sau khi DOM ổn định — tránh flash khi load
        requestAnimationFrame(function () {
            requestAnimationFrame(function () {
                sidebar.classList.add('ready');
            });
        });

        // Toggle sidebar expand/collapse — lưu vào cookie để server đọc được
        toggleBtn.addEventListener('click', function () {
            sidebar.classList.toggle('expanded');
            var isExpanded = sidebar.classList.contains('expanded');
            document.cookie = 'sidebarExpanded=' + isExpanded + ';path=/;max-age=31536000';
        });

        // Xử lý toggle submenu
        document.querySelectorAll('.nav-group').forEach(function (group) {
            var trigger = group.querySelector('.sidebar-link');
            var collapseEl = group.querySelector('.sb-collapse');
            if (!trigger || !collapseEl) return;

            // Highlight parent nếu có submenu-item active bên trong
            if (collapseEl.querySelector('.submenu-item.active')) {
                trigger.classList.add('active');
            }

            trigger.addEventListener('click', function (e) {
                // Nếu click xuất phát từ bên trong sb-collapse thì bỏ qua
                if (collapseEl.contains(e.target)) return;
                e.preventDefault();

                // Toggle submenu hiện tại, KHÔNG ảnh hưởng submenu khác
                var isShown = collapseEl.classList.contains('sb-show');
                if (isShown) {
                    collapseEl.classList.remove('sb-show');
                    trigger.setAttribute('aria-expanded', 'false');
                } else {
                    collapseEl.classList.add('sb-show');
                    trigger.setAttribute('aria-expanded', 'true');
                }
            });
        });
    });
})();
</script>
