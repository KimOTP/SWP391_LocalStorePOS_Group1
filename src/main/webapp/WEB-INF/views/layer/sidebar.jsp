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
        /* KHÔNG có transition ở đây — sẽ được thêm bằng JS sau khi load */
        z-index: 1000;
        overflow-y: auto;
        overflow-x: hidden;
        font-family: var(--sb-font);
    }

    /* Transition CHỈ được bật sau khi JS thêm class .ready */
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
        /* Transition của icon cũng chỉ bật sau khi ready */
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
        transition: transform 0.3s;
    }

    .sidebar-link[aria-expanded="true"] .sb-arrow {
        transform: rotate(180deg);
    }

    /* ẨN submenu khi sidebar collapsed */
    #sidebar:not(.expanded) .submenu-list {
        display: none;
    }

    #sidebar::-webkit-scrollbar { width: 4px; }
    #sidebar::-webkit-scrollbar-thumb { background: #e2e8f0; border-radius: 10px; }
</style>

<c:set var="currUri" value="${pageContext.request.requestURI}" />

<%-- Tính toán group nào đang active --%>
<c:set var="isPosOpen"  value="${currUri.contains('/pos') || currUri.contains('/receipts')}" />
<c:set var="isMenuOpen" value="${currUri.contains('/products') || currUri.contains('/combos')}" />
<c:set var="isCrmOpen"  value="${currUri.contains('/customer') || currUri.contains('/promotion')}" />
<c:set var="isInvOpen"  value="${currUri.contains('/inventory') || currUri.contains('/stockIn') || currUri.contains('/stockOut') || currUri.contains('/audit') || currUri.contains('/suppliers') || currUri.contains('/approval') || currUri.contains('/log')}" />

<div id="sidebar">
    <div class="sidebar-header" id="toggleBtn">
        <span class="header-label fw-bold" style="font-size: 14px; letter-spacing: 0.5px;">NAVIGATION</span>
        <i class="fa-solid fa-chevron-right toggle-icon"></i>
    </div>

    <%-- Dashboard --%>
    <a href="<c:url value='/dashboard'/>" class="sidebar-link ${currUri.contains('/dashboard') ? 'active' : ''}">
        <i class="fa-solid fa-house-chimney"></i>
        <span class="sb-text">Dashboard</span>
    </a>

    <%-- POS & Sales --%>
    <div class="nav-group">
        <a href="javascript:void(0)" data-bs-toggle="collapse" data-bs-target="#posSub"
           class="sidebar-link ${isPosOpen ? 'active' : ''}"
           aria-expanded="${isPosOpen}">
            <i class="fa-solid fa-cart-shopping"></i>
            <span class="sb-text">POS &amp; Sales</span>
            <i class="fa-solid fa-chevron-down sb-arrow"></i>
        </a>
        <div class="collapse ${isPosOpen ? 'show' : ''}" id="posSub">
            <div class="submenu-list">
                <a href="<c:url value='/pos'/>"
                   class="submenu-item ${currUri.endsWith('/pos') ? 'active' : ''}">
                    <i class="fa-solid fa-cash-register"></i>
                    <span>POS Terminal</span>
                </a>
                <a href="<c:url value='/pos/receipts'/>"
                   class="submenu-item ${currUri.contains('/receipts') ? 'active' : ''}">
                    <i class="fa-solid fa-file-invoice"></i>
                    <span>Manage Receipt</span>
                </a>
            </div>
        </div>
    </div>

    <%-- Menu & Products --%>
    <div class="nav-group">
        <a href="javascript:void(0)" data-bs-toggle="collapse" data-bs-target="#menuSub"
           class="sidebar-link ${isMenuOpen ? 'active' : ''}"
           aria-expanded="${isMenuOpen}">
            <i class="fa-solid fa-utensils"></i>
            <span class="sb-text">Menu &amp; Products</span>
            <i class="fa-solid fa-chevron-down sb-arrow"></i>
        </a>
        <div class="collapse ${isMenuOpen ? 'show' : ''}" id="menuSub">
            <div class="submenu-list">
                <a href="<c:url value='/products/manage'/>"
                   class="submenu-item ${currUri.contains('/products/manage') ? 'active' : ''}">
                    <i class="fa-solid fa-layer-group"></i>
                    <span>Product</span>
                </a>
                <a href="<c:url value='/combos/manage'/>"
                   class="submenu-item ${currUri.contains('/combos/manage') ? 'active' : ''}">
                    <i class="fa-solid fa-cubes"></i>
                    <span>Combo</span>
                </a>
            </div>
        </div>
    </div>

    <%-- CRM & Promo --%>
    <div class="nav-group">
        <a href="javascript:void(0)" data-bs-toggle="collapse" data-bs-target="#crmSub"
           class="sidebar-link ${isCrmOpen ? 'active' : ''}"
           aria-expanded="${isCrmOpen}">
            <i class="fa-solid fa-users-gear"></i>
            <span class="sb-text">CRM &amp; Promo</span>
            <i class="fa-solid fa-chevron-down sb-arrow"></i>
        </a>
        <div class="collapse ${isCrmOpen ? 'show' : ''}" id="crmSub">
            <div class="submenu-list">
                <a href="<c:url value='/customer'/>"
                   class="submenu-item ${currUri.contains('/customer') ? 'active' : ''}">
                    <i class="fa-solid fa-user-tag"></i>
                    <span>Customers</span>
                </a>
                <a href="<c:url value='/promotion'/>"
                   class="submenu-item ${currUri.contains('/promotion') ? 'active' : ''}">
                    <i class="fa-solid fa-ticket"></i>
                    <span>Promotions</span>
                </a>
            </div>
        </div>
    </div>

    <%-- Inventory --%>
    <div class="nav-group">
        <a href="javascript:void(0)" data-bs-toggle="collapse" data-bs-target="#invSub"
           class="sidebar-link ${isInvOpen ? 'active' : ''}"
           aria-expanded="${isInvOpen}">
            <i class="fa-solid fa-boxes-stacked"></i>
            <span class="sb-text">Inventory</span>
            <i class="fa-solid fa-chevron-down sb-arrow"></i>
        </a>
        <div class="collapse ${isInvOpen ? 'show' : ''}" id="invSub">
            <div class="submenu-list">
                <a href="<c:url value='/inventory/dashboard'/>"
                   class="submenu-item ${currUri.contains('/inventory/dashboard') ? 'active' : ''}">
                    <i class="fa-solid fa-house-chimney"></i><span>Inventory Dashboard</span>
                </a>
                <a href="<c:url value='/stockIn/notifications'/>"
                   class="submenu-item ${currUri.contains('/notifications') ? 'active' : ''}">
                    <i class="fa-solid fa-bell"></i><span>Notifications</span>
                </a>
                <a href="<c:url value='/stockIn/add'/>"
                   class="submenu-item ${currUri.contains('/stockIn/add') ? 'active' : ''}">
                    <i class="fa-solid fa-file-circle-plus"></i><span>Stock-in Request</span>
                </a>
                <a href="<c:url value='/stockOut/add'/>"
                   class="submenu-item ${currUri.contains('/stockOut/add') ? 'active' : ''}">
                    <i class="fa-solid fa-file-circle-minus"></i><span>Stock-out Request</span>
                </a>
                <a href="<c:url value='/audit/add'/>"
                   class="submenu-item ${currUri.contains('/audit') ? 'active' : ''}">
                    <i class="fa-solid fa-clipboard-list"></i><span>Audit Session</span>
                </a>
                <a href="<c:url value='/suppliers'/>"
                   class="submenu-item ${currUri.contains('/suppliers') ? 'active' : ''}">
                    <i class="fa-solid fa-truck-ramp-box"></i><span>Supplier List</span>
                </a>
                <a href="<c:url value='/inventory/approval/queue'/>"
                   class="submenu-item ${currUri.contains('/approval') ? 'active' : ''}">
                    <i class="fa-solid fa-clipboard-check"></i><span>Approval Queue</span>
                </a>
                <a href="<c:url value='/inventory/log/show'/>"
                   class="submenu-item ${currUri.contains('/log') ? 'active' : ''}">
                    <i class="fa-solid fa-clock-rotate-left"></i><span>Inventory Logs</span>
                </a>
            </div>
        </div>
    </div>

    <%-- Reports --%>
    <a href="<c:url value='/reports'/>"
       class="sidebar-link ${currUri.contains('/reports') ? 'active' : ''}">
        <i class="fa-solid fa-chart-column"></i>
        <span class="sb-text">Reports</span>
    </a>
</div>

<!--
    CRITICAL: Script này phải chạy NGAY SAU KHI sidebar render,
    TRƯỚC KHI Bootstrap bundle được load ở cuối body.
    Mục đích: xóa data-bs-toggle để Bootstrap không scan và reset
    các .collapse.show mà server đã render sẵn.
-->
<script>
(function() {
    document.querySelectorAll('.sidebar-link[data-bs-toggle="collapse"]').forEach(function(el) {
        el.removeAttribute('data-bs-toggle');
        el.removeAttribute('data-bs-target');
    });
})();
</script>

<script>
(function () {
    // ── BƯỚC 1: Khôi phục expanded/collapsed NGAY LẬP TỨC trước khi render
    var sidebar = document.getElementById('sidebar');
    if (localStorage.getItem('sidebarExpanded') === 'true') {
        sidebar.classList.add('expanded');
    }

    document.addEventListener('DOMContentLoaded', function () {
        var toggleBtn = document.getElementById('toggleBtn');

        // ── BƯỚC 2: Bật transition sau khi DOM đã ổn định
        //    (data-bs-toggle đã được xóa bởi inline script trước Bootstrap load)
        requestAnimationFrame(function () {
            requestAnimationFrame(function () {
                sidebar.classList.add('ready');
            });
        });

        // ── BƯỚC 4: Toggle sidebar expand/collapse
        toggleBtn.addEventListener('click', function () {
            sidebar.classList.toggle('expanded');
            localStorage.setItem('sidebarExpanded', sidebar.classList.contains('expanded'));
        });

        // ── BƯỚC 5: Tự xử lý toggle submenu bằng JS thuần
        //    Gán listener trực tiếp lên trigger (sidebar-link), không phải nav-group
        //    để tránh bắt nhầm click bubble từ submenu-item bên trong
        document.querySelectorAll('.nav-group').forEach(function (group) {
            var trigger = group.querySelector('.sidebar-link');
            var collapseEl = group.querySelector('.collapse');
            if (!trigger || !collapseEl) return;

            trigger.addEventListener('click', function (e) {
                // Chỉ xử lý khi click đúng vào trigger hoặc các element con trực tiếp
                // Bỏ qua nếu click từ submenu-item bubble lên
                if (e.target.closest('.submenu-item')) return;

                e.preventDefault();
                var isShown = collapseEl.classList.contains('show');
                if (isShown) {
                    collapseEl.classList.remove('show');
                    trigger.setAttribute('aria-expanded', 'false');
                } else {
                    collapseEl.classList.add('show');
                    trigger.setAttribute('aria-expanded', 'true');
                }
            });
        });
    });
})();
</script>
