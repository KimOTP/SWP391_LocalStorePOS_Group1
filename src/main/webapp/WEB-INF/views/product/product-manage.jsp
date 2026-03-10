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
    <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</head>
<body>

<jsp:include page="../layer/header.jsp" />
<jsp:include page="../layer/sidebar.jsp" />

<div class="main-content">

    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h2 class="fw-bold mb-0">Manage Products</h2>
            <small class="text-muted">Product List</small>
        </div>
        <div class="d-flex gap-2">
            <a href="<c:url value='/products/export-excel' />" class="btn btn-outline-success px-4 py-2">
                <i class="fa-solid fa-download me-2"></i>Export
            </a>
            <a href="<c:url value='/products/add' />" class="btn btn-add px-4 py-2 d-inline-flex align-items-center text-decoration-none">
                <i class="fa-solid fa-plus me-2"></i>Add Product
            </a>
        </div>
    </div>

    <div class="row g-4">
            <!-- Total Products -->
            <div class="col-md-3">
                <div class="stat-card">
                    <div class="stat-card-header">

                        <div class="stat-card-info">
                            <div class="stat-title">Total Products</div>
                            <div class="stat-value text-total">${totalProducts}</div>
                        </div>
                        <div class="stat-card-icon stat-icon-total">
                                                    <i class="fa-solid fa-box"></i>
                                                </div>
                    </div>
                    <div class="stat-sub">Active: ${activeCount} | Stop: ${stopCount}</div>
                </div>
            </div>

            <!-- Categories -->
            <div class="col-md-3">
                <div class="stat-card">
                    <div class="stat-card-header">

                        <div class="stat-card-info">
                            <div class="stat-title">Categories</div>
                            <div class="stat-value text-category">${categoryCount}</div>
                        </div>
                        <div class="stat-card-icon stat-icon-category">
                                                    <i class="fa-solid fa-list-ul"></i>
                                                </div>
                    </div>
                    <div class="stat-sub">Product Categories</div>
                </div>
            </div>

            <!-- Out of Stock -->
            <div class="col-md-3">
                <div class="stat-card">
                    <div class="stat-card-header">

                        <div class="stat-card-info">
                            <div class="stat-title">Out of Stock</div>
                            <div class="stat-value text-outstock">${outOfStockCount}</div>
                        </div>
                        <div class="stat-card-icon stat-icon-outstock">
                                                    <i class="fa-solid fa-triangle-exclamation"></i>
                                                </div>
                    </div>
                    <div class="stat-sub">Need to Restock</div>
                </div>
            </div>

            <!-- Pending Approval -->
            <div class="col-md-3">
                <div class="stat-card">
                    <div class="stat-card-header">
                    <div class="stat-card-info">
                       <div class="stat-title">Pending Approval</div>
                         <div class="stat-value text-pending">${pendingCount}</div>
                         </div>
                        <div class="stat-card-icon stat-icon-pending">
                            <i class="fa-solid fa-clock-rotate-left"></i>
                        </div>
                    </div>
                    <div class="stat-sub">Needs Approval</div>
                </div>
            </div>
        </div>


    <%-- Filter Bar --%>
    <div class="filter-bar mb-3">
        <div class="search-box-standalone">
            <i class="fa-solid fa-magnifying-glass search-icon"></i>
            <input type="text" id="jsSearchInput" class="form-control" placeholder="Search by name, SKU, or category...">
        </div>

        <div class="filter-actions">
            <div class="dropdown">
                <button class="btn btn-filter" type="button" data-bs-toggle="dropdown" data-bs-auto-close="outside">
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

            <div class="dropdown">
                <button class="btn btn-filter" type="button" data-bs-toggle="dropdown" data-bs-auto-close="outside">
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

            <div class="dropdown">
                <button class="btn btn-filter" type="button" data-bs-toggle="dropdown" data-bs-auto-close="outside">
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

    <%-- Product Table - Card riêng --%>
    <div class="product-table-card">
        <div class="table-responsive">
            <table class="table table-hover align-middle">
                <thead>
                    <tr class="thead-row">
                        <th class="th-cell">
                            <a href="?sortField=productId&sortDir=${reverseSortDir}${not empty param.keyword ? '&keyword='.concat(param.keyword) : ''}" class="text-decoration-none th-link">
                                SKU <i class="fa-solid ${sortField == 'productId' ? (sortDir == 'asc' ? 'fa-sort-up' : 'fa-sort-down') : 'fa-sort'} ms-1 small"></i>
                            </a>
                        </th>
                        <th class="th-cell">
                            <a href="?sortField=productName&sortDir=${reverseSortDir}" class="text-decoration-none th-link">
                                Product Name <i class="fa-solid ${sortField == 'productName' ? (sortDir == 'asc' ? 'fa-sort-up' : 'fa-sort-down') : 'fa-sort'} ms-1 small"></i>
                            </a>
                        </th>
                        <th class="th-cell">Attribute</th>
                        <th class="th-cell">Category</th>
                        <th class="th-cell">Unit</th>
                        <th class="th-cell">
                            <a href="?sortField=price&sortDir=${reverseSortDir}" class="text-decoration-none th-link">
                                Unit Price <i class="fa-solid ${sortField == 'price' ? (sortDir == 'asc' ? 'fa-sort-up' : 'fa-sort-down') : 'fa-sort'} ms-1 small"></i>
                            </a>
                        </th>
                        <th class="th-cell">Status</th>
                        <th class="th-cell text-end">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="p" items="${listProducts}">
                        <tr>
                            <td class="td-cell text-sku small">${p.productId}</td>
                            <td class="td-cell product-name">
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
                            <td class="td-cell text-muted">${p.attribute}</td>
                            <td class="td-cell">
                                <span class="badge border text-dark rounded-pill px-3 fw-normal">
                                    ${p.category.categoryName}
                                </span>
                            </td>
                            <td class="td-cell">${p.unit}</td>
                            <td class="td-cell price">
                                <fmt:formatNumber value="${p.price}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                            </td>
                            <td class="td-cell">
                                <c:set var="statusName" value="${p.status.productStatusName}" />
                                <span class="status-badge
                                    ${statusName == 'Active' ? 'status-active' : ''}
                                    ${statusName == 'Out of Stock' ? 'status-outstock' : ''}
                                    ${statusName == 'Discontinued' ? 'status-discontinued' : ''}
                                    ${statusName == 'Pending Approval' ? 'status-pending' : ''}">
                                    ${statusName}
                                </span>
                            </td>
                            <td class="td-cell text-end">
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
                                            <a class="dropdown-item rounded-2 py-2 text-danger btn-delete-confirm"
                                               href="javascript:void(0)"
                                               data-url="<c:url value='/products/delete/${p.productId}'/>">
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