<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
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
        <h2 class="fw-bold mb-0">Supplier Management</h2>
    </div>

    <div class="row g-4 mb-4">
        <div class="col-md-3">
            <div class="stat-card">
                <i class="fa-solid fa-truck-field stat-icon"></i>
                <div class="stat-title">Total Suppliers</div>
                <div class="stat-value text-total">${suppliers.size()}</div>
                <div class="small text-muted mt-2">Active partners</div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="stat-card">
                <i class="fa-solid fa-wallet stat-icon"></i>
                <div class="stat-title">Total Order Value</div>
                <div class="stat-value text-category">
                    <c:set var="grandTotal" value="0" />
                    <c:forEach var="s" items="${suppliers}"><c:set var="grandTotal" value="${grandTotal + s.totalValue}" /></c:forEach>
                    <fmt:formatNumber value="${grandTotal}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                </div>
                <div class="small text-muted mt-2">Combined across all suppliers</div>
            </div>
        </div>
    </div>

    <div class="card shadow-sm border-0">
        <div class="card-body p-4 product-list-container">

            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h5 class="fw-bold mb-0">Suppliers List</h5>
                    <small class="text-muted">Manage your supply chain partners.</small>
                </div>
                <button class="btn btn-add px-4" onclick="prepareAddModal()">
                    <i class="fa-solid fa-plus me-2"></i>Add Supplier
                </button>
            </div>

            <div class="row g-2 mb-4 align-items-center">
                <div class="col-md-4">
                    <div class="search-box">
                        <i class="fa-solid fa-magnifying-glass search-icon"></i>
                        <input type="text" id="searchInput" class="form-control" placeholder="Search suppliers...">
                    </div>
                </div>
            </div>

            <div class="table-responsive">
                <table class="table table-hover align-middle">
                    <thead>
                    <tr>
                        <th>ID</th>
                        <th>Supplier Name</th>
                        <th>Address</th>
                        <th>Email</th>
                        <th>Order Value</th>
                        <th class="text-end">Action</th>
                    </tr>
                    </thead>
                    <tbody class="supplier-table-body">
                    <c:forEach var="s" items="${suppliers}">
                        <tr>
                            <td class="text-sku">#${s.supplierId}</td>
                            <td class="fw-bold">${s.supplierName}</td>
                            <td class="text-muted">${s.address}</td>
                            <td>${s.email}</td>
                            <td class="fw-bold text-dark">
                                <fmt:formatNumber value="${s.totalValue}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                            </td>
                            <td class="text-end">
                                <div class="dropdown">
                                    <button class="btn btn-light btn-sm rounded-circle shadow-none" type="button" data-bs-toggle="dropdown">
                                        <i class="fa-solid fa-ellipsis-vertical"></i>
                                    </button>
                                    <ul class="dropdown-menu dropdown-menu-end shadow border-0 py-2" style="border-radius: 12px;">
                                        <li>
                                            <button class="dropdown-item py-2"
                                                    data-id="${s.supplierId}" data-name="${s.supplierName}"
                                                    data-address="${s.address}" data-email="${s.email}"
                                                    onclick="openEditModal(this)">
                                                <i class="fa-regular fa-pen-to-square me-2 text-warning"></i> Edit
                                            </button>
                                        </li>
                                        <li><hr class="dropdown-divider"></li>
                                        <li>
                                            <button class="dropdown-item py-2 text-danger" onclick="confirmDelete(${s.supplierId}, '${s.supplierName}')">
                                                <i class="fa-regular fa-trash-can me-2"></i> Delete
                                            </button>
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

<div class="modal fade" id="addSupplierModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow">
            <form id="addSupplierForm" action="/suppliers/add" method="post">
                <div class="modal-header bg-light"><h5 class="fw-bold mb-0">Add New Supplier</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
                <div class="modal-body p-4">
                    <div class="mb-3"><label class="form-label small fw-bold text-muted">SUPPLIER NAME</label><input type="text" name="supplierName" class="form-control" required></div>
                    <div class="mb-3"><label class="form-label small fw-bold text-muted">ADDRESS</label><input type="text" name="contactName" class="form-control"></div>
                    <div class="mb-3"><label class="form-label small fw-bold text-muted">EMAIL</label><input type="email" name="email" class="form-control"></div>
                </div>
                <div class="modal-footer border-0"><button type="submit" class="btn btn-add px-4">Create Supplier</button></div>
            </form>
        </div>
    </div>
</div>

<div class="modal fade" id="editSupplierModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow">
            <form action="/suppliers/update" method="post">
                <div class="modal-header bg-light"><h5 class="fw-bold mb-0">Update Information</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
                <div class="modal-body p-4">
                    <input type="hidden" name="supplierId" id="editSupplierId">
                    <div class="mb-3"><label class="form-label small fw-bold text-muted">SUPPLIER NAME</label><input type="text" name="supplierName" id="editSupplierName" class="form-control" required></div>
                    <div class="mb-3"><label class="form-label small fw-bold text-muted">ADDRESS</label><input type="text" name="contactName" id="editAddress" class="form-control"></div>
                    <div class="mb-3"><label class="form-label small fw-bold text-muted">EMAIL</label><input type="email" name="email" id="editEmail" class="form-control"></div>
                </div>
                <div class="modal-footer border-0"><button type="submit" class="btn btn-add px-4">Save Changes</button></div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="<c:url value='/resources/js/inventory/supplier.js'/>"></script>
</body>
</html>