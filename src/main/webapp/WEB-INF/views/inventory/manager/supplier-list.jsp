<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Supplier Management | LocalStorePOS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<c:url value='/resources/css/inventory/supplier.css'/>">
</head>
<body>

<jsp:include page="/WEB-INF/views/layer/header.jsp" />
<jsp:include page="/WEB-INF/views/layer/sidebar.jsp" />

<div class="main-content">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2 class="fw-bold mb-0">Supplier management</h2>
        <button class="btn btn-primary px-4 fw-medium" onclick="prepareAddModal()">Add supplier</button>
    </div>

    <div class="summary-container">
        <div class="stat-card">
            <div class="stat-title">Total suppliers</div>
            <div class="stat-value">${suppliers.size()}</div>
            <div class="stat-title">Total number of suppliers</div>
        </div>
        <div class="stat-card">
            <div class="stat-title">Total order value</div>
            <div class="stat-value">
                <c:set var="grandTotal" value="0" />
                <c:forEach var="s" items="${suppliers}"><c:set var="grandTotal" value="${grandTotal + s.totalValue}" /></c:forEach>
                <fmt:formatNumber value="${grandTotal}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
            </div>
            <div class="stat-title">Total value of orders of all suppliers</div>
        </div>
    </div>

    <div class="table-container">
        <div class="mb-4" style="max-width: 350px;">
            <div class="input-group">
                <span class="input-group-text bg-white border-end-0"><i class="fa-solid fa-magnifying-glass text-muted"></i></span>
                <input type="text" id="searchInput" class="form-control border-start-0" placeholder="Search suppliers...">
            </div>
        </div>

        <div class="table-responsive">
            <table class="table table-hover align-middle">
                <thead>
                <tr>
                    <th>ID</th>
                    <th>Supplier name</th>
                    <th>Address</th> <th>Email</th>
                    <th>Order value</th>
                    <th class="text-end">Action</th>
                </tr>
                </thead>
                <tbody class="supplier-table-body">
                <c:forEach var="s" items="${suppliers}">
                    <tr>
                        <td>#${s.supplierId}</td>
                        <td class="fw-bold">${s.supplierName}</td>
                        <td>${s.address}</td>
                        <td>${s.email}</td>
                        <td class="fw-bold text-primary">
                            <fmt:formatNumber value="${s.totalValue}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                        </td>
                        <td class="text-end">
                            <button class="btn btn-sm btn-light border me-1"
                                    data-id="${s.supplierId}" data-name="${s.supplierName}"
                                    data-address="${s.address}" data-email="${s.email}"
                                    onclick="openEditModal(this)">
                                <i class="fa-solid fa-pen-to-square"></i>
                            </button>
                            <button class="btn btn-sm btn-light border text-danger" onclick="confirmDelete(${s.supplierId}, '${s.supplierName}')">
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

<div class="modal fade" id="addSupplierModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <form id="addSupplierForm" action="/suppliers/add" method="post">
                <div class="modal-header"><h5>Add New Supplier</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
                <div class="modal-body p-4">
                    <div class="mb-3"><label class="form-label fw-bold">Supplier Name</label><input type="text" name="supplierName" class="form-control" required></div>
                    <div class="mb-3"><label class="form-label fw-bold">Address</label><input type="text" name="contactName" class="form-control"></div>
                    <div class="mb-3"><label class="form-label fw-bold">Email</label><input type="email" name="email" class="form-control"></div>
                </div>
                <div class="modal-footer"><button type="submit" class="btn btn-primary px-4">Add</button></div>
            </form>
        </div>
    </div>
</div>

<div class="modal fade" id="editSupplierModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <form action="/suppliers/update" method="post">
                <div class="modal-header bg-light"><h5>Update Supplier Information</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
                <div class="modal-body p-4">
                    <input type="hidden" name="supplierId" id="editSupplierId">
                    <div class="mb-3"><label class="form-label fw-bold">Supplier Name</label><input type="text" name="supplierName" id="editSupplierName" class="form-control" required></div>
                    <div class="mb-3"><label class="form-label fw-bold">Address</label><input type="text" name="contactName" id="editAddress" class="form-control"></div>
                    <div class="mb-3"><label class="form-label fw-bold">Email</label><input type="email" name="email" id="editEmail" class="form-control"></div>
                </div>
                <div class="modal-footer"><button type="submit" class="btn btn-success px-4">Save Changes</button></div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="<c:url value='/resources/js/inventory/supplier.js'/>"></script>
</body>
</html>