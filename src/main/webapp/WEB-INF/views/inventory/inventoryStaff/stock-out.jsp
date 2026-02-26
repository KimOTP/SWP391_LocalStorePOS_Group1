<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Add Stock-out | LocalStorePOS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<c:url value='/resources/css/inventory/stock-out.css'/>">
</head>
<body>
<jsp:include page="../../layer/header.jsp" />
<jsp:include page="../../layer/sidebar.jsp" />

<input type="hidden" id="serverMessage" value="${message}">
<input type="hidden" id="serverStatus" value="${status}">

<div class="main-content">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2 class="fw-bold mb-0">Add Stock-out</h2>
        <button class="btn-confirm" onclick="showProductSearchModal()">
            <i class="fa-solid fa-plus me-2"></i>Add Product
        </button>
    </div>

    <div class="info-card mb-4">
        <div class="d-flex justify-content-between align-items-start mb-4">
            <h5 class="fw-bold mb-0 text-secondary">Export Transaction</h5>
            <span class="status-badge">
                <i class="fa-solid fa-spinner fa-spin me-1"></i> In Progress
            </span>
        </div>

        <div class="row g-4">
            <div class="col-md-3">
                <label class="info-label">Staff in Charge</label>
                <div class="info-value">
                    <i class="fa-solid fa-user-tie me-1 text-muted"></i> ${loggedInAccount.employee.fullName}
                </div>
            </div>
            <div class="col-md-3">
                <label class="info-label">Current Date</label>
                <div class="info-value">
                    <i class="fa-regular fa-calendar me-1 text-muted"></i>
                    <jsp:useBean id="now" class="java.util.Date" />
                    <fmt:formatDate value="${now}" pattern="dd/MM/yyyy" />
                </div>
            </div>
            <div class="col-md-6">
                <label class="info-label">General Reason/Note</label>
                <input type="text" id="generalNote" class="form-control border-0 bg-light rounded-3"
                       placeholder="Enter general reason for export..." style="font-size: 0.9rem;">
            </div>
        </div>
    </div>

    <div class="table-section shadow-sm">
        <div class="table-responsive">
            <table class="table table-hover align-middle" id="stockOutTable">
                <thead>
                <tr>
                    <th style="width: 60px;" class="text-center">#</th>
                    <th>SKU</th>
                    <th>Product Name</th>
                    <th>Unit</th>
                    <th class="text-center">Current Stock</th>
                    <th class="text-center">Export Qty</th>
                    <th>Reason</th>
                    <th class="text-center">Action</th>
                </tr>
                </thead>
                <tbody>
                <tr id="emptyRow">
                    <td colspan="8" class="text-center py-5 text-muted small">
                        <i class="fa-solid fa-box-open d-block mb-2 fs-3"></i>
                        No products added. Click "Add Product" to start.
                    </td>
                </tr>
                </tbody>
            </table>
        </div>
    </div>

    <div class="d-flex justify-content-end gap-3 mt-4">
        <button class="btn-cancel" onclick="location.reload()">
            <i class="fa-solid fa-rotate-left me-2"></i>Reset
        </button>
        <button class="btn-confirm" onclick="submitStockOut()">
            <i class="fa-solid fa-check-to-slot me-2"></i>Confirm Export
        </button>
    </div>
</div>

<div class="modal fade" id="productModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content border-0 shadow-lg" style="border-radius: 16px;">
            <div class="modal-header border-0 pb-0">
                <h5 class="fw-bold">Select Product to Export</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <div class="mb-4">
                    <div class="input-group">
                        <span class="input-group-text bg-light border-0"><i class="fa-solid fa-magnifying-glass"></i></span>
                        <input type="text" id="productSearchInput" class="form-control border-0 bg-light"
                               placeholder="Search product name or SKU..." onkeyup="liveSearch()">
                    </div>
                </div>
                <div class="table-responsive" style="max-height: 400px;">
                    <table class="table table-hover align-middle" id="searchResultTable">
                        <thead class="sticky-top bg-white">
                        <tr>
                            <th>Product Details</th>
                            <th>SKU</th>
                            <th class="text-center">In Stock</th>
                            <th class="text-center">Action</th>
                        </tr>
                        </thead>
                        <tbody></tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<form id="submitForm" action="<c:url value='/stockOut/submit'/>" method="POST">
    <input type="hidden" name="generalNote" id="formNote">
    <input type="hidden" name="itemsJson" id="formItems">
</form>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script src="<c:url value='/resources/js/inventory/stock-out.js'/>"></script>
</body>
</html>