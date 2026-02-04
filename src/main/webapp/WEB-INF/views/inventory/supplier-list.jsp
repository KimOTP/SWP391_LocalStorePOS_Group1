<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Supplier Management</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<c:url value='/resources/css/supplier.css'/>">
</head>
<body>

<jsp:include page="../layer/header.jsp" />
<jsp:include page="../layer/sidebar.jsp" />

<div class="main-content">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2 class="fw-bold">Supplier management</h2>
        <button class="btn btn-primary px-4 fw-medium" data-bs-toggle="modal" data-bs-target="#addSupplierModal">
            Add supplier
        </button>
    </div>

    <div class="summary-container">
        <div class="stat-card">
            <div class="stat-title">Total suppliers</div>
            <div class="stat-value">${suppliers.size()}</div>
            <div class="stat-desc">Total number of suppliers</div>
        </div>

        <div class="stat-card">
            <div class="stat-title">Total order value</div>
            <div class="stat-value">
                <c:set var="grandTotal" value="0" />
                <c:forEach var="s" items="${suppliers}">
                    <c:set var="grandTotal" value="${grandTotal + s.totalOrdersValue}" />
                </c:forEach>
                <fmt:formatNumber value="${grandTotal}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
            </div>
            <div class="stat-desc">Total value of orders</div>
        </div>
    </div>

    <div class="table-container shadow-sm border-0">
        <div class="d-flex justify-content-between align-items-center mb-3">
            <div>
                <h5 class="fw-bold mb-0">Supplier list</h5>
                <span class="text-muted small">Manage supplier details</span>
            </div>
            <div class="text-muted small">Results: ${suppliers.size()} suppliers</div>
        </div>

        <div class="mb-3" style="max-width: 300px;">
            <input type="text" id="searchInput" class="form-control form-control-sm" placeholder="Search suppliers...">
        </div>

        <div class="table-responsive">
            <table class="table table-hover align-middle">
                <thead>
                <tr>
                    <th class="text-muted">Supplier ID</th>
                    <th>Supplier name</th>
                    <th>Email</th>
                    <th>Phone number</th>
                    <th>Total orders value</th>
                    <th class="text-center">Action</th>
                </tr>
                </thead>
                <tbody>
                <c:forEach var="s" items="${suppliers}">
                    <tr>
                        <td class="fw-bold text-muted">${s.supplierId < 10 ? '0' : ''}${s.supplierId}</td>
                        <td class="fw-bold">${s.supplierName}</td>
                        <td>${s.email}</td>
                        <td>${s.phoneNumber}</td>
                        <td class="fw-bold">
                            <fmt:formatNumber value="${s.totalOrdersValue}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                        </td>
                        <td class="text-center">
                            <button class="btn btn-sm btn-light border me-1" onclick="openEditModal(this)"
                                    data-id="${s.supplierId}"
                                    data-name="${s.supplierName}"
                                    data-phone="${s.phoneNumber}"
                                    data-email="${s.email}">
                                <i class="fa-solid fa-pen-to-square"></i>
                            </button>
                            <button class="btn btn-sm btn-light border text-danger">
                                <i class="fa-solid fa-trash"></i>
                            </button>
                        </td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="<c:url value='/resources/js/supplier.js'/>"></script>
</body>
</html>