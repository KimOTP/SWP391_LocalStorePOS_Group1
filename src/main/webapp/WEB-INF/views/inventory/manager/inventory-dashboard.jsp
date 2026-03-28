<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Approval Queue | LocalStorePOS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <link rel="stylesheet" href="<c:url value='/resources/css/inventory/inventory-dashboard.css'/>">
</head>
<body>

<jsp:include page="../../layer/header.jsp" />
<jsp:include page="../../layer/sidebar.jsp" />

<div class="main-content">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h2 class="fw-bold mb-0">Inventory Management</h2>
            <small class="text-muted">Stock monitoring and alerts</small>
        </div>
        <div class="d-flex gap-2">
            <a href="<c:url value='/stockIn/notifications'/>" class="btn btn-outline-primary px-4 py-2 border-2 fw-bold" style="border-radius: 10px;">
                <i class="fa-solid fa-bell me-2"></i>Notifications
            </a>
        </div>
    </div>

    <div class="row g-4 mb-4">
        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-card-header">
                    <div class="stat-card-info">
                        <div class="stat-title">Total Stock-In</div>
                        <div class="stat-value text-total"><fmt:formatNumber value="${stats.totalReceipt}" pattern="#,### VND"/></div>
                    </div>
                    <div class="stat-card-icon stat-icon-import"><i class="fa-solid fa-file-import"></i></div>
                </div>
                <div class="stat-sub text-muted small">Total value of stock-in product</div>
            </div>
        </div>

        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-card-header">
                    <div class="stat-card-info">
                        <div class="stat-title">Total Stock-Out</div>
                        <div class="stat-value text-category"><fmt:formatNumber value="${stats.totalStockOut}" pattern="#,### VND"/></div>
                    </div>
                    <div class="stat-card-icon stat-icon-export"><i class="fa-solid fa-file-export"></i></div>
                </div>
                <div class="stat-sub text-muted small">Total value of stock-out product</div>
            </div>
        </div>

        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-card-header">
                    <div class="stat-card-info">
                        <div class="stat-title">Inventory Value</div>
                        <div class="stat-value"><fmt:formatNumber value="${stats.inventoryValue}" pattern="#,### VND"/></div>
                    </div>
                    <div class="stat-card-icon stat-icon-value"><i class="fa-solid fa-warehouse"></i></div>
                </div>
                <div class="stat-sub text-muted small">Products value remaining</div>
            </div>
        </div>

        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-card-header">
                    <div class="stat-card-info">
                        <div class="stat-title">Stock Alerts</div>
                        <div class="stat-value text-outstock">${stats.alertCount}</div>
                    </div>
                    <div class="stat-card-icon stat-icon-alert"><i class="fa-solid fa-triangle-exclamation"></i></div>
                </div>
                <div class="stat-sub text-muted small">Products under min threshold</div>
            </div>
        </div>
    </div>

    <div class="filter-bar mb-3">
        <div class="search-box-standalone">
            <i class="fa-solid fa-magnifying-glass text-muted me-2"></i>
            <input type="text" id="inventorySearch" placeholder="Search product by name or SKU...">
        </div>
        <div class="dropdown filter-dropdown">
            <button class="btn btn-filter" type="button" data-bs-toggle="dropdown" aria-expanded="false" id="statusFilterValue">
                <span>All Status</span>
                <i class="fa-solid fa-chevron-down tiny-icon"></i>
            </button>
            <ul class="dropdown-menu shadow border-0">
                <li><a class="dropdown-item" href="javascript:void(0)" onclick="updateFilter('', 'All Status')">All Status</a></li>
                <li><a class="dropdown-item" href="javascript:void(0)" onclick="updateFilter('Enough', 'Enough')">Enough</a></li>
                <li><a class="dropdown-item" href="javascript:void(0)" onclick="updateFilter('Warning', 'Warning')">Warning</a></li>
            </ul>
        </div>
    </div>

    <div class="inventory-table-card mb-5">
        <div class="table-responsive" style="overflow-y: visible;"> <table class="table table-hover align-middle mb-0">
            <thead>
            <tr class="thead-row">
                <th class="th-cell text-center" style="width: 120px;">SKU</th>
                <th class="th-cell">Product Name</th>
                <th class="th-cell text-center" style="width: 140px;">In Stock</th>
                <th class="th-cell text-center" style="width: 140px;">Min Stock</th>

                <c:if test="${sessionScope.role == 'MANAGER'}">
                    <th class="th-cell text-center" style="width: 140px;">Input Price</th>
                    <th class="th-cell text-end" style="width: 180px;">Total Value</th>
                </c:if>

                <th class="th-cell text-center" style="width: 140px;">Status</th>
                <th class="th-cell text-center" style="width: 80px;">Actions</th>
            </tr>
            </thead>
            <tbody>
            <c:forEach items="${inventoryList}" var="i">
                <c:set var="isLow" value="${i.currentQuantity < i.minThreshold}" />
                <tr>
                    <td class="td-cell align-middle text-center">
                        <div class="d-flex align-items-center justify-content-center h-100">
                            <span class="text-sku">#${i.product.productId}</span>
                        </div>
                    </td>
                    <td class="td-cell align-middle fw-bold text-dark">${i.product.productName}</td>
                    <td class="td-cell align-middle text-center fw-bold text-primary fs-6">
                            ${i.currentQuantity}
                    </td>
                    <td class="td-cell align-middle text-center">
    <span class="badge border text-dark px-3 py-2 fw-normal bg-light">
            ${i.minThreshold}
    </span>
                    </td>

                    <c:if test="${sessionScope.role == 'MANAGER'}">

                        <td class="td-cell align-middle text-center">
                            <fmt:formatNumber value="${i.product.price}" pattern="#,##0 VND"/>
                        </td>

                        <td class="td-cell align-middle text-end fw-bold text-success">
                            <fmt:formatNumber value="${i.currentQuantity * i.product.price}" pattern="#,##0 VND"/>
                        </td>
                    </c:if>
                    <td class="td-cell align-middle text-center">
                            <span class="status-badge ${isLow ? 'status-outstock' : 'status-active'}">
                                    ${isLow ? 'Warning' : 'Enough'}
                            </span>
                    </td>
                    <td class="td-cell align-middle text-center">
                        <div class="dropdown">
                            <button class="btn btn-light btn-sm rounded-circle shadow-sm border" type="button" data-bs-toggle="dropdown" style="width: 34px; height: 34px;">
                                <i class="fa-solid fa-ellipsis-vertical text-secondary"></i>
                            </button>
                            <ul class="dropdown-menu dropdown-menu-end shadow border-0 py-2" style="border-radius: 12px;">
                                <li>
                                    <a class="dropdown-item py-2 fw-medium" href="<c:url value='/stockOut/add?productId=${i.product.productId}'/>">
                                        <i class="fa-solid fa-file-export me-2 text-primary" style="width: 18px;"></i>Stock-out
                                    </a>
                                </li>
                                <li>
                                    <a class="dropdown-item py-2 fw-medium" href="javascript:void(0)" onclick="editMinStock('${i.product.productId}', '${i.product.productName.replace('\'', '\\\'')}', ${i.minThreshold})">
                                        <i class="fa-solid fa-pen-to-square me-2 text-warning" style="width: 18px;"></i>Edit Min
                                    </a>
                                </li>
                            </ul>
                        </div>
                    </td>
                </tr>
            </c:forEach>
            </tbody>
        </table>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="<c:url value='/resources/js/inventory/inventory-dashboard.js'/>"></script>
</body>
</html>