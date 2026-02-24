<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Product</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<c:url value='/resources/css/product/product-manage.css' />">
</head>
<body>

<jsp:include page="../layer/header.jsp" />
<jsp:include page="../layer/sidebar.jsp" />

<div class="main-content">

    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2 class="fw-bold mb-0">Manage Product</h2>
    </div>

    <div class="row g-4 mb-5">
        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-title mb-2">Total Products</div>
                <div class="stat-value">${totalProducts}</div>
                <div class="small text-muted mt-1">Active: ${activeCount} | Stop: ${stopCount}</div>
            </div>
        </div>

        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-title mb-2">Categories</div>
                <div class="stat-value">${categoryCount}</div>
                <div class="small text-muted mt-1">Product Categories</div>
            </div>
        </div>

        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-title mb-2">Out of Stock</div>
                <div class="stat-value">${outOfStockCount}</div>
                <div class="small text-muted mt-1">Status: Out of Stock</div>
            </div>
        </div>

        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-title mb-2">Pending Approval</div>
                <div class="stat-value">${pendingCount}</div>
                <div class="small text-muted mt-1">Needs Approval</div>
            </div>
        </div>
    </div>

    <div class="card shadow-sm border-0">
        <div class="card-body p-4 product-list-container">

                <div class="d-flex justify-content-between align-items-center mb-4">
                    <div>
                        <h5 class="fw-bold mb-0">Products List</h5>
                        <small class="text-muted">Manage all products in system.</small>
                    </div>
                    <div>
                        <a href="<c:url value='/products/export-excel' />" class="btn btn-outline-success px-4 py-2">
                            <i class="fa-solid fa-file-excel me-2"></i>Export Excel
                        </a>
                        <a href="<c:url value='/products/add' />" class="btn btn-add px-4 py-2 d-inline-flex align-items-center text-decoration-none">
                            <i class="fa-solid fa-plus me-2"></i>Add Product
                        </a>
                    </div>
                </div>

    <div class="row g-2 mb-4 align-items-center">
        <div class="col-md-3">
            <div class="search-box">
                <i class="fa-solid fa-magnifying-glass search-icon"></i>
                <input type="text" id="jsSearchInput" class="form-control ps-5" placeholder="Find by Name or SKU...">
            </div>
        </div>

        <div class="col-md-2">
            <div class="dropdown">
                <button class="btn btn-filter w-100 text-start d-flex justify-content-between align-items-center" type="button" data-bs-toggle="dropdown" data-bs-auto-close="outside">
                    <span>Status</span>
                    <i class="fa-solid fa-chevron-down ms-1 tiny-icon"></i>
                </button>
                <div class="dropdown-menu shadow border-0 p-2" style="min-width: 200px;">
                    <c:forEach var="st" items="${statuses}">
                        <label class="dropdown-item d-flex align-items-center py-2" style="cursor: pointer;">
                            <input type="checkbox" class="filter-checkbox status-cb" value="${st.productStatusName}">
                            <span class="ms-2">${st.productStatusName}</span>
                        </label>
                    </c:forEach>
                </div>
            </div>
        </div>

        <div class="col-md-2">
            <div class="dropdown">
                <button class="btn btn-filter w-100 text-start d-flex justify-content-between align-items-center" type="button" data-bs-toggle="dropdown" data-bs-auto-close="outside">
                    <span>Category</span>
                    <i class="fa-solid fa-chevron-down ms-1 tiny-icon"></i>
                </button>
                <div class="dropdown-menu shadow border-0 p-2" style="min-width: 200px;">
                    <c:forEach var="cat" items="${categories}">
                        <label class="dropdown-item d-flex align-items-center py-2" style="cursor: pointer;">
                            <input type="checkbox" class="filter-checkbox category-cb" value="${cat.categoryName}">
                            <span class="ms-2">${cat.categoryName}</span>
                        </label>
                    </c:forEach>
                </div>
            </div>
        </div>

        <div class="col-md-2">
            <div class="dropdown">
                <button class="btn btn-filter w-100 text-start d-flex justify-content-between align-items-center" type="button" data-bs-toggle="dropdown" data-bs-auto-close="outside">
                    <span>Unit</span>
                    <i class="fa-solid fa-chevron-down ms-1 tiny-icon"></i>
                </button>
                <div class="dropdown-menu shadow border-0 p-2" style="min-width: 150px;">
                    <c:forEach var="u" items="${units}">
                        <label class="dropdown-item d-flex align-items-center py-2" style="cursor: pointer;">
                            <input type="checkbox" class="filter-checkbox unit-cb" value="${u}">
                            <span class="ms-2">${u}</span>
                        </label>
                    </c:forEach>
                </div>
            </div>
        </div>
    </div>
            <div class="table-responsive">
                <table class="table table-hover align-middle">
                    <thead>
                        <tr>
                            <th>
                                <a href="?sortField=productId&sortDir=${reverseSortDir}${not empty param.keyword ? '&keyword='.concat(param.keyword) : ''}" class="text-decoration-none text-muted">
                                    SKU <i class="fa-solid ${sortField == 'productId' ? (sortDir == 'asc' ? 'fa-sort-up' : 'fa-sort-down') : 'fa-sort'} ms-1 small"></i>
                                </a>
                            </th>
                            <th>
                                <a href="?sortField=productName&sortDir=${reverseSortDir}" class="text-decoration-none text-muted">
                                    Product Name <i class="fa-solid ${sortField == 'productName' ? (sortDir == 'asc' ? 'fa-sort-up' : 'fa-sort-down') : 'fa-sort'} ms-1 small"></i>
                                </a>
                            </th>
                            <th>Attribute</th>
                            <th>Category</th>
                            <th>Unit</th>
                            <th>
                                <a href="?sortField=price&sortDir=${reverseSortDir}" class="text-decoration-none text-muted">
                                    Unit Price <i class="fa-solid ${sortField == 'price' ? (sortDir == 'asc' ? 'fa-sort-up' : 'fa-sort-down') : 'fa-sort'} ms-1 small"></i>
                                </a>
                            </th>
                            <th>Status</th>
                            <th class="text-end"></th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="p" items="${listProducts}">
                            <tr>
                                <td class="text-muted small">${p.productId}</td>
                                <td class="product-name">
                                    <div class="d-flex align-items-center gap-3">
                                        <div class="product-img-container shadow-sm">
                                            <c:choose>
                                                <c:when test="${not empty p.imageUrl}">
                                                    <img src="${p.imageUrl}" alt="Product" class="product-img-table">
                                                </c:when>
                                                <c:otherwise>
                                                    <i class="fa-solid fa-image no-image-icon"></i>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>

                                        <div class="fw-bold">
                                            ${p.productName}
                                        </div>
                                    </div>
                                </td>
                                <td class="text-muted">${p.attribute}</td>
                                <td>
                                    <span class="badge border text-dark rounded-pill px-3 fw-normal">
                                        ${p.category.categoryName}
                                    </span>
                                </td>
                                <td>${p.unit}</td>
                                <td class="fw-bold">
                                    <fmt:formatNumber value="${p.price}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                </td>
                                <td>
                                    <c:set var="statusName" value="${p.status.productStatusName}" />
                                    <span class="badge ${statusName == 'Active' ? 'bg-success' : 'bg-secondary'}">
                                        ${statusName}
                                    </span>
                                </td>
                                <td class="text-end">
                                    <div class="dropdown">
                                        <button class="btn btn-light btn-sm rounded-circle shadow-none"
                                                type="button"
                                                data-bs-toggle="dropdown"
                                                data-bs-boundary="viewport"
                                                aria-expanded="false"
                                                style="width: 32px; height: 32px;">
                                            <i class="fa-solid fa-ellipsis-vertical"></i>
                                        </button>

                                        <ul class="dropdown-menu dropdown-menu-end shadow border-0 py-2" style="min-width: 160px; border-radius: 12px; z-index: 1060;">
                                            <li class="px-2 pb-1 text-muted small fw-bold">Action</li>
                                            <li>
                                                <button class="dropdown-item rounded-2 py-2 btn-view-detail"
                                                        type="button"
                                                        data-id="${p.productId}"
                                                        data-url="<c:url value='/products/view'/>">
                                                    <i class="fa-regular fa-eye me-2 text-primary" style="width: 18px;"></i>View
                                                </button>
                                            </li>
                                            <li>
                                                <a class="dropdown-item rounded-2 py-2" href="<c:url value='/products/update/${p.productId}'/>">
                                                    <i class="fa-regular fa-pen-to-square me-2 text-warning" style="width: 18px;"></i> Update
                                                </a>
                                            </li>
                                            <li><hr class="dropdown-divider mx-2"></li>
                                            <li>
                                                <a class="dropdown-item rounded-2 py-2 text-danger" href="<c:url value='/products/delete/${p.productId}'/>"
                                                   onclick="return confirm('Bạn có chắc chắn muốn xóa sản phẩm này?')">
                                                    <i class="fa-regular fa-trash-can me-2" style="width: 18px;"></i> Delete
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
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<div class="modal fade" id="productDetailModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content border-0 shadow">
            <div class="modal-header bg-light">
                <h5 class="modal-title fw-bold" id="modalProductName">Product Details</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body" id="modalBodyContent">
                <div class="text-center py-5">
                    <div class="spinner-border text-primary" role="status"></div>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="<c:url value='/resources/js/product/product-app.js' />"></script>

</body>
</html>