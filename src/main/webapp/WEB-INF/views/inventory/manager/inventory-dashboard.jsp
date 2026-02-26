<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Approval Queue | LocalStorePOS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<c:url value='/resources/css/inventory/inventory-dashboard.css'/>">
</head>
<body>

<jsp:include page="../../layer/header.jsp" />
<jsp:include page="../../layer/sidebar.jsp" />

<div class="main-content">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2 class="fw-bold mb-0">Inventory Management</h2>
        <a href="<c:url value='/stockIn/notifications'/>" class="btn btn-light border px-3">
            Stock-in Notifications
        </a>
    </div>

    <div class="row g-4 mb-4">
        <div class="col-md-3">
            <div class="stat-card">
                <i class="fa-solid fa-file-import stat-icon"></i>
                <div class="stat-title">Total Inventory Receipt</div>
                <div class="stat-value text-total">
                    <fmt:formatNumber value="${stats.totalReceipt}" pattern="#,### đ"/>
                </div>
                <div class="small text-muted mt-2">Tổng giá trị hàng nhập</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card">
                <i class="fa-solid fa-file-export stat-icon"></i>
                <div class="stat-title">Total Stock-out Receipt</div>
                <div class="stat-value text-category">
                    <fmt:formatNumber value="${stats.totalStockOut}" pattern="#,### đ"/>
                </div>
                <div class="small text-muted mt-2">Tổng giá trị hàng xuất</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card">
                <i class="fa-solid fa-warehouse stat-icon"></i>
                <div class="stat-title">Inventory Receipt</div>
                <div class="stat-value text-total" style="color: #1e293b;">
                    <fmt:formatNumber value="${stats.inventoryValue}" pattern="#,### đ"/>
                </div>
                <div class="small text-muted mt-2">Giá trị hàng tồn kho</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card">
                <i class="fa-solid fa-bell-slash stat-icon"></i>
                <div class="stat-title">Number of stock alerts</div>
                <div class="stat-value text-outstock">${stats.alertCount}</div>
                <div class="small text-muted mt-2">Dưới mức tối thiểu</div>
            </div>
        </div>
    </div>

    <div class="product-list-container">
        <div class="mb-4">
            <h5 class="fw-bold mb-1">Inventory List</h5>
            <small class="text-muted">Manage the quantity of products in the system.</small>
        </div>

        <div class="row g-2 mb-4">
            <div class="col-md-4">
                <div class="search-box">
                    <i class="fa-solid fa-magnifying-glass search-icon"></i>
                    <input type="text" id="inventorySearch" class="form-control" placeholder="Search product...">
                </div>
            </div>
            <div class="col-md-2">
                <select class="form-select btn-filter" id="statusFilter">
                    <option value="">Status</option>
                    <option value="Enough">Enough</option>
                    <option value="Warning">Warning</option>
                </select>
            </div>
        </div>

        <div class="table-responsive">
            <table class="table table-hover align-middle">
                <thead>
                <tr>
                    <th class="small text-muted">SKU <i class="fa-solid fa-sort ms-1"></i></th>
                    <th class="small text-muted">Product Name <i class="fa-solid fa-sort ms-1"></i></th>
                    <th class="small text-muted">Inventory</th>
                    <th class="small text-muted">Min</th>
                    <th class="small text-muted">Cost price</th>
                    <th class="small text-muted">Total Inventory Value</th>
                    <th class="small text-muted">Stock Status</th>
                    <th class="small text-muted">Action</th>
                </tr>
                </thead>
                <tbody>
                <c:forEach items="${inventoryList}" var="i">
                    <c:set var="isLow" value="${i.currentQuantity <= i.minThreshold}" />
                    <tr>
                        <td class="text-sku small">${i.product.productId}</td>
                        <td class="fw-bold">${i.product.productName}</td>
                        <td class="fw-bold">${i.currentQuantity}</td>
                        <td>
                                <span class="badge bg-light text-dark border px-3 rounded-pill">
                                        ${i.minThreshold}
                                </span>
                        </td>
                        <td><fmt:formatNumber value="${i.product.price}" pattern="#,### đ"/></td>
                        <td class="fw-bold">
                            <fmt:formatNumber value="${i.currentQuantity * i.product.price}" pattern="#,### đ"/>
                        </td>
                        <td>
                                <span class="status-badge ${isLow ? 'status-outstock' : 'status-active'}">
                                        ${isLow ? 'Warning' : 'Enough'}
                                </span>
                        </td>
                        <td class="text-end pe-3">
                            <div class="dropdown">
                                <button class="btn btn-light btn-sm rounded-circle shadow-none" type="button" data-bs-toggle="dropdown">
                                    <i class="fa-solid fa-ellipsis-vertical"></i>
                                </button>
                                <ul class="dropdown-menu dropdown-menu-end shadow border-0 py-2">
                                    <li>
                                        <a class="dropdown-item py-2" href="<c:url value='/stockOut/add?productId=${i.product.productId}'/>">
                                            <i class="fa-solid fa-file-export me-2 text-primary"></i> Add Stock-out
                                        </a>
                                    </li>
                                    <li>
                                        <a class="dropdown-item py-2" href="javascript:void(0)" onclick="editMinStock('${i.product.productId}', ${i.minThreshold})">
                                            <i class="fa-solid fa-pen-to-square me-2 text-warning"></i> Edit Min Threshold
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

<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script src="<c:url value='/resources/js/inventory/inventory-dashboard.js'/>"></script>
</body>
</html>