<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Stock-in Request | GOAL POS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="<c:url value='/resources/css/inventory/stock-in-request.css'/>">
</head>
<body>
<jsp:include page="../../layer/header.jsp" />
<jsp:include page="../../layer/sidebar.jsp" />

<input type="hidden" id="serverMessage" value="${message}">
<input type="hidden" id="serverStatus" value="${status}">

<div class="main-content">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h2 class="fw-bold mb-0">Create Stock-in Request</h2>
            <small class="text-muted">Create a new import transaction</small>
        </div>
        <a href="/inventory/dashboard" class="btn btn-cancel px-4 d-inline-flex align-items-center text-decoration-none">
            <i class="fa-solid fa-arrow-left me-2"></i>Back
        </a>
    </div>

    <div class="card shadow-sm border-0 mb-4" style="border-radius: 16px; background: #ffffff;">
        <div class="card-body p-4">
            <div class="d-flex justify-content-between align-items-center mb-4 pb-3 border-bottom">
                <h5 class="fw-bold mb-0 text-dark">
                    <i class="fa-solid fa-file-import me-2" style="color: #2563eb;"></i>Import Transaction
                </h5>
                <span class="status-badge status-pending">
                    <i class="fa-solid fa-spinner fa-spin me-1"></i> In Progress
                </span>
            </div>

            <div class="row g-4 align-items-end">
                <div class="col-md-4">
                    <label class="info-label">Transaction Type</label>
                    <div class="info-value p-2 px-3 bg-light rounded-3 fw-bold text-primary border" style="height: 42px;">
                        Stock-in (New Import)
                    </div>
                </div>
                <div class="col-md-4">
                    <label class="info-label">Supplier <span class="text-danger">*</span></label>
                    <select id="supplierSelect" class="form-select custom-select">
                        <option value="">-- Choose a Supplier --</option>
                        <c:forEach items="${suppliers}" var="s">
                            <option value="${s.supplierId}">${s.supplierName}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="col-md-4">
                    <label class="info-label">Current Date</label>
                    <div class="info-value p-2 px-3 bg-light rounded-3 border text-muted" style="height: 42px;">
                        <i class="fa-regular fa-calendar me-2"></i>
                        <jsp:useBean id="now" class="java.util.Date" />
                        <fmt:formatDate value="${now}" pattern="dd/MM/yyyy" />
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="d-flex justify-content-between align-items-center mb-3 mt-2">
        <h5 class="fw-bold mb-0 text-dark">Products to Restock</h5>
        <button class="btn btn-add px-4" data-bs-toggle="modal" data-bs-target="#productPickerModal">
            <i class="fa-solid fa-plus me-2"></i>Add Product
        </button>
    </div>

    <div class="product-table-card mb-4">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0" id="stockInTable">
                <thead>
                <tr class="thead-row">
                    <th class="th-cell" style="width: 140px;">SKU</th>
                    <th class="th-cell">Product Information</th>
                    <th class="th-cell text-center" style="width: 140px;">Quantity</th>
                    <th class="th-cell text-center" style="width: 180px;">Unit Cost (VND)</th>
                    <th class="th-cell text-end" style="width: 180px;">Subtotal</th>
                    <th class="th-cell text-center" style="width: 60px;">Action</th>
                </tr>
                </thead>
                <tbody id="stockInBody">
                </tbody>
            </table>
        </div>

        <div id="emptyState" class="text-center py-5">
            <i class="fa-solid fa-box-open d-block mb-3" style="font-size: 2.5rem; color: #cbd5e1;"></i>
            <span class="fw-medium text-muted">No products added yet. Use "Add Product" to start.</span>
        </div>
    </div>

    <div class="summary-box p-4 mb-4">
        <div class="row align-items-center">
            <div class="col-sm-6">
                <span class="badge bg-white text-primary border border-primary px-3 py-2" style="font-size: 0.85rem; border-radius: 8px;" id="itemCount">0 Items</span>
            </div>
            <div class="col-sm-6 text-end">
                <span class="info-label d-block mb-1">Total Estimated Amount</span>
                <h3 class="fw-bold text-primary mb-0" id="grandTotal">0 VND</h3>
            </div>
        </div>
    </div>

    <div class="d-flex justify-content-end gap-3 mb-5">
        <button class="btn btn-cancel px-5" onclick="location.reload()">Discard</button>
        <button class="btn btn-add px-5" onclick="submitStockIn()">
            <i class="fa-solid fa-check-to-slot me-2"></i>Submit Request
        </button>
    </div>
</div>

<div class="modal fade" id="productPickerModal" tabindex="-1">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content border-0 shadow-lg">
            <div class="modal-header bg-light pb-3 border-0">
                <h5 class="modal-title fw-bold"><i class="fa-solid fa-list-check me-2 text-primary"></i>Select Products</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body p-4 pt-2">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <div class="search-box-standalone flex-grow-1 me-3">
                        <i class="fa-solid fa-magnifying-glass search-icon"></i>
                        <input type="text" id="modalSearch" class="form-control" placeholder="Search by name or SKU...">
                    </div>
                    <button class="btn btn-warning fw-bold px-3 py-2 d-inline-flex align-items-center" onclick="autoSelectLowStock()" style="border-radius: 10px; font-size: 0.85rem;">
                        <i class="fa-solid fa-bolt me-2"></i> Auto-fill Low Stock
                    </button>
                </div>

                <div class="table-responsive product-table-card" style="max-height: 400px; overflow-y: auto;">
                    <table class="table table-hover align-middle mb-0" id="modalTable">
                        <thead class="sticky-top">
                        <tr class="thead-row">
                            <th class="th-cell text-center" style="width: 50px;">
                                <input type="checkbox" id="selectAllCheckbox" class="form-check-input" onclick="toggleAll(this)">
                            </th>
                            <th class="th-cell">Product Details</th>
                            <th class="th-cell text-center">Stock / Min</th>
                            <th class="th-cell text-center">Action</th>
                        </tr>
                        </thead>
                        <tbody id="modalProductList">
                        </tbody>
                    </table>
                </div>
            </div>
            <div class="modal-footer border-0 p-4 pt-0">
                <button class="btn btn-add w-100" onclick="processSelectedProducts()">
                    <i class="fa-solid fa-check-double me-2"></i>Add Selected Products
                </button>
            </div>
        </div>
    </div>
</div>

<form id="submitForm" action="<c:url value='/stockIn/stock-in'/>" method="POST">
    <input type="hidden" name="supplierId" id="formSupplierId">
    <input type="hidden" name="itemsJson" id="formItems">
    <c:if test="${_csrf != null}">
        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
    </c:if>
</form>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script src="<c:url value='/resources/js/inventory/stock-in-request.js'/>"></script>
</body>
</html>