<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Combo</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<c:url value='/resources/css/combo/combo-manage.css' />">
    <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</head>
<body>

<jsp:include page="../layer/header.jsp" />
<jsp:include page="../layer/sidebar.jsp" />

<div class="main-content">

    <%-- Header: Title + Buttons --%>
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h2 class="fw-bold mb-0">Manage Combos</h2>
            <small class="text-muted">Combo List</small>
        </div>
        <div class="d-flex gap-2">
            <a href="<c:url value='/combos/export-excel' />" class="btn btn-outline-success px-4 py-2">
                <i class="fa-solid fa-download me-2"></i>Export
            </a>
            <a href="<c:url value='/combos/add' />" class="btn btn-add px-4 py-2 d-inline-flex align-items-center text-decoration-none">
                <i class="fa-solid fa-plus me-2"></i>Add Combo
            </a>
        </div>
    </div>

    <%-- Stat Cards --%>
    <div class="row g-4">
        <!-- Total Combos -->
        <div class="col-md-4">
            <div class="stat-card">
                <div class="stat-card-header">
                    <div class="stat-card-info">
                        <div class="stat-title">Total Combos</div>
                        <div class="stat-value text-combo-total">${totalCombos}</div>
                    </div>
                    <div class="stat-card-icon stat-icon-combo-total">
                        <i class="fa-solid fa-layer-group"></i>
                    </div>
                </div>
                <div class="stat-sub">Active Packages</div>
            </div>
        </div>

        <!-- Active -->
        <div class="col-md-4">
            <div class="stat-card">
                <div class="stat-card-header">
                    <div class="stat-card-info">
                        <div class="stat-title">Active</div>
                        <div class="stat-value text-combo-active">${activeCount}</div>
                    </div>
                    <div class="stat-card-icon stat-icon-combo-active">
                        <i class="fa-solid fa-check-double"></i>
                    </div>
                </div>
                <div class="stat-sub">Ready to Sell</div>
            </div>
        </div>

        <!-- Pending Approval -->
        <div class="col-md-4">
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
                <div class="stat-sub">Waiting for Review</div>
            </div>
        </div>
    </div>

    <%-- Filter Bar --%>
    <div class="filter-bar mb-3">
        <div class="search-box-standalone">
            <i class="fa-solid fa-magnifying-glass search-icon"></i>
            <input type="text" id="comboSearchInput" class="form-control" placeholder="Search by Combo Name or ID...">
        </div>

        <div class="filter-actions">
            <div class="dropdown">
                <button class="btn btn-filter" type="button" data-bs-toggle="dropdown" data-bs-auto-close="outside">
                    <span>Status</span>
                    <i class="fa-solid fa-chevron-down ms-1 tiny-icon"></i>
                </button>
                <div class="dropdown-menu shadow border-0 p-2" style="min-width: 200px;">
                    <label class="dropdown-item d-flex align-items-center py-2" style="cursor: pointer;">
                        <input type="checkbox" class="filter-checkbox status-cb" value="ACTIVE">
                        <span class="ms-2">Active</span>
                    </label>
                    <label class="dropdown-item d-flex align-items-center py-2" style="cursor: pointer;">
                        <input type="checkbox" class="filter-checkbox status-cb" value="DISCONTINUED">
                        <span class="ms-2">Discontinued</span>
                    </label>
                    <label class="dropdown-item d-flex align-items-center py-2" style="cursor: pointer;">
                        <input type="checkbox" class="filter-checkbox status-cb" value="PENDING_APPROVAL">
                        <span class="ms-2">Pending Approval</span>
                    </label>
                </div>
            </div>
        </div>
    </div>

    <%-- Combo Table --%>
    <div class="product-table-card">
        <div class="table-responsive">
            <table class="table table-hover align-middle">
                <thead>
                    <tr class="thead-row">
                        <th class="th-cell">ID</th>
                        <th class="th-cell">Combo Name</th>
                        <th class="th-cell">Included Products</th>
                        <th class="th-cell">Total Price</th>
                        <th class="th-cell">Status</th>
                        <th class="th-cell text-end">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="c" items="${listCombos}">
                        <tr>
                            <td class="td-cell text-sku small">${c.comboId}</td>
                            <td class="td-cell product-name">
                                <div class="d-flex align-items-center gap-3">
                                    <div class="product-img-container shadow-sm">
                                        <c:choose>
                                            <c:when test="${not empty c.imageUrl}">
                                                <img src="${c.imageUrl}" alt="Combo" class="product-img-table">
                                            </c:when>
                                            <c:otherwise>
                                                <i class="fa-solid fa-layer-group no-image-icon"></i>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                    <div class="fw-bold">${c.comboName}</div>
                                </div>
                            </td>
                            <td class="td-cell">
                                <div class="combo-products-list">
                                    <c:forEach var="detail" items="${c.comboDetails}" varStatus="status">
                                        ${detail.product.productName} (x${detail.quantity})${not status.last ? ', ' : ''}
                                    </c:forEach>
                                </div>
                            </td>
                            <td class="td-cell price">
                                <fmt:formatNumber value="${c.totalPrice}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                            </td>
                            <td class="td-cell">
                                <span class="status-badge status-text
                                    <c:choose>
                                        <c:when test="${c.statusCombo == 'ACTIVE'}">status-active</c:when>
                                        <c:when test="${c.statusCombo == 'PENDING_APPROVAL'}">status-pending</c:when>
                                        <c:otherwise>status-discontinued</c:otherwise>
                                    </c:choose>"
                                    data-status="${c.statusCombo}">
                                    ${c.statusCombo == 'ACTIVE' ? 'Active' :
                                      c.statusCombo == 'PENDING_APPROVAL' ? 'Pending Approval' : 'Discontinued'}
                                </span>
                            </td>
                            <td class="td-cell text-end">
                                <div class="dropdown">
                                    <button class="btn btn-light btn-sm rounded-circle shadow-none"
                                            type="button"
                                            data-bs-toggle="dropdown"
                                            aria-expanded="false"
                                            style="width: 32px; height: 32px;">
                                        <i class="fa-solid fa-ellipsis-vertical"></i>
                                    </button>
                                    <ul class="dropdown-menu dropdown-menu-end shadow border-0 py-2" style="min-width: 160px; border-radius: 12px; z-index: 9999;">
                                        <li class="px-2 pb-1 text-muted small fw-bold">Action</li>
                                        <li>
                                            <button class="dropdown-item rounded-2 py-2 btn-view-combo" type="button" data-id="${c.comboId}">
                                                <i class="fa-regular fa-eye me-2 text-primary" style="width: 18px;"></i>View
                                            </button>
                                        </li>
                                        <li>
                                            <a class="dropdown-item rounded-2 py-2" href="<c:url value='/combos/update/${c.comboId}'/>">
                                                <i class="fa-regular fa-pen-to-square me-2 text-warning" style="width: 18px;"></i>Update
                                            </a>
                                        </li>
                                        <li><hr class="dropdown-divider mx-2"></li>
                                        <li>
                                            <a class="dropdown-item rounded-2 py-2 text-danger btn-delete-combo"
                                               href="javascript:void(0)"
                                               onclick="confirmDelete('${c.comboId}', '<c:url value='/combos/delete/${c.comboId}'/>')">
                                                <i class="fa-regular fa-trash-can me-2" style="width: 18px;"></i>Delete
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

<div class="modal fade" id="comboDetailModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content border-0 shadow">
            <div class="modal-header bg-light">
                <h5 class="modal-title fw-bold">Combo Package Details</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body" id="comboModalBody">
                </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="<c:url value='/resources/js/combo/combo-app.js' />"></script>
</body>
</html>