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
    <link rel="stylesheet" href="<c:url value='/resources/css/inventory/audit-session.css'/>">
</head>
<body>
<jsp:include page="../../layer/header.jsp" />
<jsp:include page="../../layer/sidebar.jsp" />

<input type="hidden" id="serverMessage" value="${message}">
<input type="hidden" id="serverStatus" value="${status}">

<div class="main-content">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h2 class="fw-bold mb-0">Inventory Audit</h2>
            <small class="text-muted">Perform routine stock checks</small>
        </div>
        <button class="btn btn-add px-4 py-2 d-inline-flex align-items-center" onclick="openMultiProductModal()">
            <i class="fa-solid fa-plus me-2"></i>Add Products
        </button>
    </div>

    <div class="row g-4 mb-4">
        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-card-header">
                    <div class="stat-card-info">
                        <div class="stat-title">Items in List</div>
                        <div class="stat-value text-dark" id="stat-total">0</div>
                    </div>
                    <div class="stat-card-icon stat-icon-total">
                        <i class="fa-solid fa-clipboard-list"></i>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-card-header">
                    <div class="stat-card-info">
                        <div class="stat-title">Discrepancy Found</div>
                        <div class="stat-value text-danger" id="stat-diff">0</div>
                    </div>
                    <div class="stat-card-icon stat-icon-stockout">
                        <i class="fa-solid fa-triangle-exclamation"></i>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-md-6">
            <div class="stat-card progress-card">
                <div class="d-flex justify-content-between align-items-center mb-2">
                    <div class="stat-title text-white">Audit Progress</div>
                    <span class="fs-4 fw-bold text-white" id="stat-progress">0%</span>
                </div>
                <div class="progress" style="height: 10px; background: rgba(255,255,255,0.2); border-radius: 8px;">
                    <div id="progress-bar" class="progress-bar bg-white" style="width: 0%; border-radius: 8px;"></div>
                </div>
            </div>
        </div>
    </div>

    <div class="card shadow-sm border-0 mb-4" style="border-radius: 16px; background: #ffffff;">
        <div class="card-body p-4">
            <div class="d-flex justify-content-between align-items-center mb-4 pb-3 border-bottom">
                <h5 class="fw-bold mb-0 text-dark">
                    <i class="fa-solid fa-clipboard-check me-2" style="color: #2563eb;"></i>Audit Session Information
                </h5>
                <span class="status-badge" style="background: #fee2e2; color: #dc2626; border: 1px solid #fecaca;">
                    <i class="fa-solid fa-spinner fa-spin me-1"></i> In Progress
                </span>
            </div>

            <div class="row g-4 align-items-center">
                <div class="col-md-3">
                    <label class="info-label">Audit Staff</label>
                    <div class="info-value">
                        <i class="fa-solid fa-user-tie me-2 text-primary"></i>${loggedInAccount.employee.fullName}
                    </div>
                </div>
                <div class="col-md-6">
                    <label class="info-label">Current Date</label>
                    <div class="info-value">
                        <i class="fa-regular fa-calendar me-2 text-primary"></i>
                        <jsp:useBean id="now" class="java.util.Date" />
                        <fmt:formatDate value="${now}" pattern="dd/MM/yyyy" />
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="product-table-card mb-4">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0" id="auditTable">
                <thead>
                <tr class="thead-row">
                    <th class="th-cell text-center" style="width: 60px;">#</th>
                    <th class="th-cell">Product Name</th>
                    <th class="th-cell text-center">Expected Qty</th>
                    <th class="th-cell text-center">Actual Count</th>
                    <th class="th-cell text-center">Difference</th>
                    <th class="th-cell">Reason / Note</th>
                    <th class="th-cell text-center">Action</th>
                </tr>
                </thead>
                <tbody>
                <tr id="emptyRow">
                    <td colspan="7" class="text-center py-5 text-muted">
                        <i class="fa-solid fa-clipboard-list d-block mb-3" style="font-size: 2.5rem; color: #cbd5e1;"></i>
                        <span class="fw-medium">No items added. Click "Add Products" to start auditing.</span>
                    </td>
                </tr>
                </tbody>
            </table>
        </div>
    </div>

    <div class="d-flex justify-content-end gap-3 mt-2 mb-5">
        <button class="btn btn-cancel" onclick="location.reload()">
            <i class="fa-solid fa-rotate-left me-2"></i>Reset
        </button>
        <button class="btn btn-add" onclick="submitAudit()">
            <i class="fa-solid fa-check-double me-2"></i>Confirm Audit
        </button>
    </div>
</div>

<div class="modal fade" id="productPickerModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content border-0 shadow-lg">
            <div class="modal-header bg-light">
                <h5 class="fw-bold mb-0"><i class="fa-solid fa-list-check me-2 text-primary"></i>Quick Selection</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body p-4">
                <div class="mb-4">
                    <div class="search-box-standalone w-100">
                        <i class="fa-solid fa-magnifying-glass search-icon"></i>
                        <input type="text" id="modalSearch" class="form-control"
                               placeholder="Search product..." onkeyup="filterModalProducts()">
                    </div>
                </div>
                <div class="table-responsive product-table-card" style="max-height: 400px; overflow-y: auto;">
                    <table class="table table-hover align-middle mb-0" id="modalTable">
                        <thead class="sticky-top">
                        <tr class="thead-row">
                            <th class="th-cell text-center" style="width: 50px;">
                                <input type="checkbox" id="selectAllCheckbox" class="form-check-input" onclick="toggleAll(this)">
                            </th>
                            <th class="th-cell">Product Details</th>
                            <th class="th-cell">SKU</th>
                            <th class="th-cell text-end pe-4">In Stock</th>
                        </tr>
                        </thead>
                        <tbody></tbody>
                    </table>
                </div>
            </div>
            <div class="modal-footer border-0 p-4 pt-0">
                <button class="btn btn-add w-100" onclick="addSelectedItems()">
                    <i class="fa-solid fa-check-double me-2"></i>Add Selected to Audit
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