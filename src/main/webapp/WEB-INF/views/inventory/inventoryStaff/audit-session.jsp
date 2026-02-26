<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Inventory Audit | LocalStorePOS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<c:url value='/resources/css/inventory/stock-out.css'/>">
    <style>
        .diff-positive { color: #10b981 !important; font-weight: 700; }
        .diff-negative { color: #ef4444 !important; font-weight: 700; }
        .progress-card { background-color: #2563eb !important; color: white !important; }
        .progress-card .info-label { color: rgba(255,255,255,0.8); }
    </style>
</head>
<body>
<jsp:include page="../../layer/header.jsp" />
<jsp:include page="../../layer/sidebar.jsp" />

<input type="hidden" id="serverMessage" value="${message}">
<input type="hidden" id="serverStatus" value="${status}">

<div class="main-content">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2 class="fw-bold mb-0">Inventory Audit</h2>
        <button class="btn-confirm" onclick="openMultiProductModal()">
            <i class="fa-solid fa-plus me-2"></i>Add Products
        </button>
    </div>

    <div class="row g-3 mb-4">
        <div class="col-md-3">
            <div class="info-card h-100">
                <label class="info-label">Items in List</label>
                <div class="info-value fs-3" id="stat-total">0</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="info-card h-100">
                <label class="info-label">Discrepancy Found</label>
                <div class="info-value fs-3 text-danger" id="stat-diff">0</div>
            </div>
        </div>
        <div class="col-md-6">
            <div class="info-card progress-card h-100">
                <div class="d-flex justify-content-between align-items-center">
                    <label class="info-label text-white">Audit Progress</label>
                    <span class="fw-bold" id="stat-progress">0%</span>
                </div>
                <div class="progress mt-2" style="height: 8px; background: rgba(255,255,255,0.2);">
                    <div id="progress-bar" class="progress-bar bg-white" style="width: 0%"></div>
                </div>
            </div>
        </div>
    </div>

    <div class="info-card mb-4">
        <div class="d-flex justify-content-between align-items-start mb-4">
            <h5 class="fw-bold mb-0 text-secondary">Audit Session Information</h5>
            <span class="status-badge" style="background: #fee2e2; color: #dc2626; border-color: #fecaca;">
                <i class="fa-solid fa-clipboard-check me-1"></i> In Progress
            </span>
        </div>

        <div class="row g-4">
            <div class="col-md-3">
                <label class="info-label">Audit Staff</label>
                <div class="info-value">
                    <i class="fa-solid fa-user-tie me-1 text-muted"></i> ${loggedInAccount.employee.fullName}
                </div>
            </div>
            <div class="col-md-6">
                <label class="info-label">Current Date</label>
                <div class="info-value">
                    <i class="fa-regular fa-calendar me-1 text-muted"></i>
                    <jsp:useBean id="now" class="java.util.Date" />
                    <fmt:formatDate value="${now}" pattern="dd/MM/yyyy" />
                </div>
            </div>
        </div>
    </div>

    <div class="table-section shadow-sm">
        <div class="table-responsive">
            <table class="table table-hover align-middle" id="auditTable">
                <thead>
                <tr>
                    <th style="width: 60px;" class="text-center">#</th>
                    <th>Product Name</th>
                    <th class="text-center">Expected Qty</th>
                    <th class="text-center">Actual Count</th>
                    <th class="text-center">Difference</th>
                    <th>Reason / Note</th>
                    <th class="text-center">Action</th>
                </tr>
                </thead>
                <tbody>
                <tr id="emptyRow">
                    <td colspan="7" class="text-center py-5 text-muted small">
                        <i class="fa-solid fa-clipboard-list d-block mb-2 fs-3"></i>
                        No items added. Click "Add Products" to start auditing.
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
        <button class="btn-confirm" onclick="submitAudit()">
            <i class="fa-solid fa-check-double me-2"></i>Confirm Audit
        </button>
    </div>
</div>

<div class="modal fade" id="productPickerModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content border-0 shadow-lg" style="border-radius: 16px;">
            <div class="modal-header border-0 pb-0">
                <h5 class="fw-bold"><i class="fa-solid fa-list-check me-2 text-primary"></i>Quick Selection</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <div class="mb-4">
                    <div class="input-group">
                        <span class="input-group-text bg-light border-0"><i class="fa-solid fa-magnifying-glass"></i></span>
                        <input type="text" id="modalSearch" class="form-control border-0 bg-light"
                               placeholder="Search product..." onkeyup="filterModalProducts()">
                    </div>
                </div>
                <div class="table-responsive" style="max-height: 400px;">
                    <table class="table table-hover align-middle" id="modalTable">
                        <thead class="sticky-top bg-white">
                        <tr>
                            <th style="width: 50px;" class="ps-3">
                                <input type="checkbox" id="selectAllCheckbox" class="form-check-input" onclick="toggleAll(this)">
                            </th>
                            <th>Product Details</th>
                            <th>SKU</th>
                            <th class="text-end pe-3">In Stock</th>
                        </tr>
                        </thead>
                        <tbody></tbody>
                    </table>
                </div>
            </div>
            <div class="modal-footer border-0 p-4">
                <button class="btn-confirm w-100" onclick="addSelectedItems()">
                    Add Selected to Audit
                </button>
            </div>
        </div>
    </div>
</div>

<form id="auditForm" action="<c:url value='/audit/submit'/>" method="POST">
    <input type="hidden" name="auditDataJson" id="auditDataJson">
</form>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script src="<c:url value='/resources/js/inventory/audit-session.js'/>"></script>
</body>
</html>