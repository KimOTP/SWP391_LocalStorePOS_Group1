<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>GOAL POS - Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<c:url value='/resources/css/dashboard/dashboard.css' />">
</head>
<body>

<jsp:include page="../layer/header.jsp" />
<jsp:include page="../layer/sidebar.jsp" />

<div class="main-content">
    <%-- Header Section --%>
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h2 class="fw-bold mb-1">Dashboard</h2>
            <p class="text-muted small">Welcome back, <span class="text-primary fw-semibold">${role}</span></p>
        </div>

        <div class="d-flex gap-2 align-items-center">
            <div class="search-wrapper">
                <i class="fa-solid fa-magnifying-glass search-icon"></i>
                <input type="text" class="form-control search-input" placeholder="Search...">
            </div>
            <div class="view-toggle-group">
                <button class="btn btn-view active" id="gridBtn" onclick="switchView('grid')">
                    <i class="fa-solid fa-grip"></i>
                </button>
                <button class="btn btn-view" id="listBtn" onclick="switchView('list')">
                    <i class="fa-solid fa-list"></i>
                </button>
            </div>
        </div>
    </div>

    <%-- Single Stat Card Section --%>
        <div class="row mb-4">
            <div class="col-md-3">
                <div class="stat-card">
                    <div class="d-flex justify-content-between">
                        <span class="stat-label">Today's Orders</span>
                        <i class="fa-solid fa-cart-shopping text-primary"></i>
                    </div>
                    <h2 class="stat-value">5</h2>
                    <span class="stat-sub">Completed: 4 | Pending: 1</span>
                </div>
            </div>
        </div>

    <%-- Favorite Section (Hiển thị ngay trên Available App) --%>
    <div id="favorite-container" style="display: none;" class="mb-4">
        <h6 class="fw-bold mb-3 text-warning text-uppercase small" style="letter-spacing: 1px;">
            <i class="fa-solid fa-star me-2"></i>Favorites
        </h6>
        <div class="app-grid" id="favorite-grid">
            </div>
        <hr class="my-4" style="border-top: 1.5px dashed #e2e8f0;">
    </div>

    <%-- Available Services --%>
    <h6 class="fw-bold mb-3 text-primary text-uppercase small" style="letter-spacing: 1px;">
        <i class="fa-solid fa-bolt me-2"></i>Available Services
    </h6>

    <div class="app-grid" id="main-app-grid">
        <div class="app-wrapper">
            <i class="fa-regular fa-star star-btn" onclick="toggleFavorite(this)"></i>
            <a href="<c:url value='/pos' />" class="app-card">
                <div class="app-icon-wrapper bg-pos">
                    <i class="fa-solid fa-cash-register"></i>
                </div>
                <div class="app-title">POS Sales</div>
                <div class="app-desc">Checkout & Billing</div>
            </a>
        </div>

        <c:if test="${sessionScope.role == 'MANAGER'}">
            <div class="app-wrapper">
                <i class="fa-regular fa-star star-btn" onclick="toggleFavorite(this)"></i>
                <a href="<c:url value='/products/manager/manage' />" class="app-card">
                    <div class="app-icon-wrapper bg-product">
                        <i class="fa-solid fa-boxes-stacked"></i>
                    </div>
                    <div class="app-title">Products</div>
                    <div class="app-desc">Items & Pricing</div>
                </a>
            </div>

            <div class="app-wrapper">
                <i class="fa-regular fa-star star-btn" onclick="toggleFavorite(this)"></i>
                <a href="/customer" class="app-card">
                    <div class="app-icon-wrapper bg-customer">
                        <i class="fa-solid fa-user-group"></i>
                    </div>
                    <div class="app-title">Customers</div>
                    <div class="app-desc">Member Management</div>
                </a>
            </div>

            <div class="app-wrapper">
                <i class="fa-regular fa-star star-btn" onclick="toggleFavorite(this)"></i>
                <a href="/promotion" class="app-card">
                    <div class="app-icon-wrapper bg-warning text-white">
                        <i class="fa-solid fa-tags"></i>
                    </div>
                    <div class="app-title">Promotions</div>
                    <div class="app-desc">Discounts & Offers</div>
                </a>
            </div>

            <div class="app-wrapper">
                <i class="fa-regular fa-star star-btn" onclick="toggleFavorite(this)"></i>
                <a href="/stockIn/inventory-staff/notifications" class="app-card">
                    <div class="app-icon-wrapper bg-inventory">
                        <i class="fa-solid fa-warehouse"></i>
                    </div>
                    <div class="app-title">Inventory</div>
                    <div class="app-desc">Stock Control</div>
                </a>
            </div>

            <div class="app-wrapper">
                <i class="fa-regular fa-star star-btn" onclick="toggleFavorite(this)"></i>
                <a href="#" class="app-card">
                    <div class="app-icon-wrapper bg-info text-white">
                        <i class="fa-solid fa-file-invoice"></i>
                    </div>
                    <div class="app-title">Request Order</div>
                    <div class="app-desc">Purchase Requests</div>
                </a>
            </div>

            <div class="app-wrapper">
                <i class="fa-regular fa-star star-btn" onclick="toggleFavorite(this)"></i>
                <a href="#" class="app-card">
                    <div class="app-icon-wrapper bg-secondary text-white">
                        <i class="fa-solid fa-truck-field"></i>
                    </div>
                    <div class="app-title">Supplier</div>
                    <div class="app-desc">Vendor Partners</div>
                </a>
            </div>

            <div class="app-wrapper">
                <i class="fa-regular fa-star star-btn" onclick="toggleFavorite(this)"></i>
                <a href="#" class="app-card">
                    <div class="app-icon-wrapper bg-danger text-white">
                        <i class="fa-solid fa-clipboard-check"></i>
                    </div>
                    <div class="app-title">Approval Queue</div>
                    <div class="app-desc">Pending Tasks</div>
                </a>
            </div>

            <div class="app-wrapper">
                <i class="fa-regular fa-star star-btn" onclick="toggleFavorite(this)"></i>
                <a href="/hr/manager_profile" class="app-card">
                    <div class="app-icon-wrapper bg-dark text-white">
                        <i class="fa-solid fa-user-gear"></i>
                    </div>
                    <div class="app-title">Manage Employee</div>
                    <div class="app-desc">HR Settings</div>
                </a>
            </div>

            <div class="app-wrapper">
                <i class="fa-regular fa-star star-btn" onclick="toggleFavorite(this)"></i>
                <a href="/hr/employee_list" class="app-card">
                    <div class="app-icon-wrapper bg-primary text-white">
                        <i class="fa-solid fa-address-book"></i>
                    </div>
                    <div class="app-title">Employee List</div>
                    <div class="app-desc">Staff Directory</div>
                </a>
            </div>

            <div class="app-wrapper">
                <i class="fa-regular fa-star star-btn" onclick="toggleFavorite(this)"></i>
                <a href="/shift/shift_change_req" class="app-card">
                    <div class="app-icon-wrapper bg-warning text-white">
                        <i class="fa-solid fa-calendar-day"></i> </div>
                    <div class="app-info-container"> <div class="app-title">Shift Change</div>
                        <div class="app-desc">Schedule Adjustments</div>
                    </div>
                </a>
            </div>

            <div class="app-wrapper">
                <i class="fa-regular fa-star star-btn" onclick="toggleFavorite(this)"></i>
                <a href="/shift/attendance" class="app-card">
                    <div class="app-icon-wrapper bg-success text-white">
                        <i class="fa-solid fa-user-clock"></i>
                    </div>
                    <div class="app-title">Attendance</div>
                    <div class="app-desc">Time Tracking</div>
                </a>
            </div>

            <div class="app-wrapper">
                <i class="fa-regular fa-star star-btn" onclick="toggleFavorite(this)"></i>
                <a href="/reports" class="app-card">
                    <div class="app-icon-wrapper bg-report">
                        <i class="fa-solid fa-chart-pie"></i>
                    </div>
                    <div class="app-title">Reports</div>
                    <div class="app-desc">Analytics & Data</div>
                </a>
            </div>
        </c:if>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="<c:url value='/resources/js/dashboard/dashboard.js' />"></script>
</body>
</html>