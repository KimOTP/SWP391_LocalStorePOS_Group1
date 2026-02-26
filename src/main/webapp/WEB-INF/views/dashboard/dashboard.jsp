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
                    <i class="fa-solid fa-desktop"></i>
                </div>
                <div class="app-title">POS Sales</div>
            </a>
        </div>

        <c:if test="${sessionScope.role == 'MANAGER'}">
            <div class="app-wrapper">
                <i class="fa-regular fa-star star-btn" onclick="toggleFavorite(this)"></i>
                <a href="<c:url value='/products/manager/manage' />" class="app-card">
                    <div class="app-icon-wrapper bg-product">
                        <i class="fa-solid fa-box"></i>
                    </div>
                    <div class="app-title">Products</div>
                </a>
            </div>

            <div class="app-wrapper">
                <i class="fa-regular fa-star star-btn" onclick="toggleFavorite(this)"></i>
                <a href="/cus-promo/manager/customer" class="app-card">
                    <div class="app-icon-wrapper bg-customer">
                        <i class="fa-solid fa-users"></i>
                    </div>
                    <div class="app-title">Customers</div>
                </a>
            </div>

            <div class="app-wrapper">
                <i class="fa-regular fa-star star-btn" onclick="toggleFavorite(this)"></i>
                <a href="/cus-promo/manager/customer" class="app-card">
                    <div class="app-icon-wrapper bg-customer">
                        <i class="fa-solid fa-users"></i>
                    </div>
                    <div class="app-title">Customers</div>
                </a>
            </div>


            <div class="app-wrapper">
                <i class="fa-regular fa-star star-btn" onclick="toggleFavorite(this)"></i>
                <a href="/stockIn/inventory-staff/notifications" class="app-card">
                    <div class="app-icon-wrapper bg-inventory">
                        <i class="fa-solid fa-warehouse"></i>
                    </div>
                    <div class="app-title">Inventory</div>
                </a>
            </div>





            <div class="app-wrapper">
                <i class="fa-regular fa-star star-btn" onclick="toggleFavorite(this)"></i>
                <a href="#" class="app-card">
                    <div class="app-icon-wrapper bg-report">
                        <i class="fa-solid fa-chart-line"></i>
                    </div>
                    <div class="app-title">Reports</div>
                </a>
            </div>
        </c:if>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="<c:url value='/resources/js/dashboard/dashboard.js' />"></script>
</body>
</html>