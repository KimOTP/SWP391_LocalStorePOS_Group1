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
                <div class="stat-value">100</div>
                <div class="small text-muted mt-1">Active: 98 | Stop: 2</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-title mb-2">Categories</div>
                <div class="stat-value">3</div>
                <div class="small text-muted mt-1">Product Categories</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-title mb-2">Out of Stock</div>
                <div class="stat-value">1</div>
                <div class="small text-muted mt-1">Restock Required</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-title mb-2">Pending Approval</div>
                <div class="stat-value">1</div>
                <div class="small text-muted mt-1">Needs Approval</div>
            </div>
        </div>
    </div>

    <div class="card shadow-sm border-0">
        <div class="card-body p-4">

            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h5 class="fw-bold mb-0">Products List</h5>
                    <small class="text-muted">Manage all products in system.</small>
                </div>
                <a href="<c:url value='/products/add'/>" class="btn btn-add px-4 py-2 d-inline-flex align-items-center text-decoration-none">
                    <i class="fa-solid fa-plus me-2"></i>Add Product
                </a>
            </div>

            <div class="row g-2 mb-4">
                <div class="col-md-3">
                    <div class="input-group">
                        <input type="text" class="form-control" placeholder="Search products...">
                    </div>
                </div>
                <div class="col-md-2">
                    <select class="form-select"><option>+ Status</option></select>
                </div>
                <div class="col-md-2">
                    <select class="form-select"><option>+ Category</option></select>
                </div>
                <div class="col-md-2">
                    <select class="form-select"><option>+ Unit</option></select>
                </div>
            </div>

            <div class="table-responsive">
                <table class="table table-hover align-middle">
                    <thead>
                        <tr>
                            <th>SKU <i class="fa-solid fa-arrow-up-z-a ms-1 small text-muted"></i></th>
                            <th>Product Name <i class="fa-solid fa-arrow-up-z-a ms-1 small text-muted"></i></th>
                            <th>Attribute</th>
                            <th>Category</th>
                            <th>Unit</th>
                            <th>Unit Price <i class="fa-solid fa-arrow-up-z-a ms-1 small text-muted"></i></th>
                            <th>Status</th>
                            <th class="text-end"></th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="p" items="${listProducts}">
                            <tr>
                                <td class="text-muted small">${p.productId}</td>
                                <td class="product-name">${p.productName}</td>
                                <td class="text-muted">${p.attribute}</td>
                                <td>
                                    <span class="badge border text-dark rounded-pill px-3 fw-normal">Drink</span>
                                </td>
                                <td>${p.unit}</td>
                                <td class="fw-bold">
                                    <fmt:formatNumber value="${p.price}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${p.status == 'Active'}"><span class="badge-active">Active</span></c:when>
                                        <c:when test="${p.status == 'Out of Stock'}"><span class="badge-outstock">Out of Stock</span></c:when>
                                        <c:when test="${p.status == 'Discontinued'}"><span class="badge-discontinued">Discontinued</span></c:when>
                                        <c:otherwise><span class="badge-pending">Pending</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="text-end">
                                    <button class="btn btn-sm btn-link text-dark"><i class="fa-solid fa-ellipsis"></i></button>
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
</body>
</html>