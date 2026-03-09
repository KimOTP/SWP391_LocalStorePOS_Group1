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
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2 class="fw-bold mb-0">Manage Combo</h2>
    </div>

    <div class="row g-4 mb-4">
        <div class="col-md-4">
            <div class="stat-card">
                <i class="fa-solid fa-layer-group stat-icon"></i>
                <div class="stat-title">Total Combos</div>
                <div class="stat-value text-total">${totalCombos}</div>
                <div class="small text-muted mt-2">Active Packages</div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="stat-card">
                <i class="fa-solid fa-check-double stat-icon"></i>
                <div class="stat-title">Active</div>
                <div class="stat-value text-category" style="color: #16a34a !important;">${activeCount}</div>
                <div class="small text-muted mt-2">Ready to Sell</div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="stat-card">
                <i class="fa-solid fa-clock-rotate-left stat-icon"></i>
                <div class="stat-title">Pending Approval</div>
                <div class="stat-value text-pending">${pendingCount}</div>
                <div class="small text-muted mt-2">Waiting for Review</div>
            </div>
        </div>
    </div>

    <div class="card shadow-sm border-0">
        <div class="card-body p-4 product-list-container">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h5 class="fw-bold mb-0">Combo List</h5>
                    <small class="text-muted">Manage product bundles and special offers.</small>
                </div>
                <div>
                    <a href="<c:url value='/combos/export-excel' />" class="btn btn-outline-success px-4 py-2 me-2">
                        <i class="fa-solid fa-file-excel me-2"></i>Export
                    </a>
                    <a href="<c:url value='/combos/add' />" class="btn btn-add px-4 py-2 text-decoration-none">
                        <i class="fa-solid fa-plus me-2"></i>Add Combo
                    </a>
                </div>
            </div>

            <div class="row g-2 mb-4 align-items-center">
                <div class="col-md-4">
                    <div class="search-box">
                        <i class="fa-solid fa-magnifying-glass search-icon"></i>
                        <input type="text" id="comboSearchInput" class="form-control ps-5" placeholder="Find by Combo Name or ID...">
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="dropdown">
                        <button class="btn btn-filter w-100 text-start d-flex justify-content-between align-items-center" type="button" data-bs-toggle="dropdown">
                            <span>Status</span>
                            <i class="fa-solid fa-chevron-down ms-1 tiny-icon"></i>
                        </button>
                        <div class="dropdown-menu shadow border-0 p-2">
                            <label class="dropdown-item d-flex align-items-center py-2">
                                <input type="checkbox" class="filter-checkbox status-cb" value="ACTIVE">
                                <span class="ms-2">Active</span>
                            </label>
                            <label class="dropdown-item d-flex align-items-center py-2">
                                <input type="checkbox" class="filter-checkbox status-cb" value="DISCONTINUED">
                                <span class="ms-2">Discontinued</span>
                            </label>
                            <label class="dropdown-item d-flex align-items-center py-2">
                                <input type="checkbox" class="filter-checkbox status-cb" value="PENDING_APPROVAL">
                                <span class="ms-2">Pending Approval</span>
                            </label>
                        </div>
                    </div>
                </div>
            </div>

            <div class="table-responsive">
                <table class="table table-hover align-middle">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Combo Name</th>
                            <th>Included Products</th>
                            <th>Total Price</th>
                            <th>Status</th>
                            <th class="text-end">Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="c" items="${listCombos}">
                            <tr>
                                <td class="text-sku small">${c.comboId}</td>
                                <td class="product-name">
                                                <div class="d-flex align-items-center gap-3">
                                                    <div class="product-img-container shadow-sm" style="width: 45px; height: 45px; overflow: hidden; border-radius: 8px; background: #f8f9fa; display: flex; align-items: center; justify-content: center;">
                                                        <c:choose>
                                                            <c:when test="${not empty c.imageUrl}">
                                                                <img src="${c.imageUrl}" alt="Combo" class="product-img-table" style="width: 100%; height: 100%; object-fit: cover;">
                                                            </c:when>
                                                            <c:otherwise>
                                                                <i class="fa-solid fa-layer-group text-muted" style="font-size: 1.2rem;"></i>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                    <div class="fw-bold text-dark">
                                                        ${c.comboName}
                                                    </div>
                                                </div>
                                            </td>
                                <td>
                                    <div class="small text-muted">
                                        <c:forEach var="detail" items="${c.comboDetails}" varStatus="status">
                                            ${detail.product.productName} (x${detail.quantity})${not status.last ? ', ' : ''}
                                        </c:forEach>
                                    </div>
                                </td>
                                <td class="price">
                                    <fmt:formatNumber value="${c.totalPrice}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                </td>
                                <td>
                                    <span class="status-badge status-text
                                        <c:choose>
                                            <c:when test="${c.statusCombo == 'ACTIVE'}">status-active</c:when>
                                            <c:when test="${c.statusCombo == 'PENDING_APPROVAL'}">status-pending</c:when>
                                            <c:otherwise>status-discontinued</c:otherwise>
                                        </c:choose>"
                                        data-status="${c.statusCombo}"> ${c.statusCombo == 'ACTIVE' ? 'Active' :
                                          c.statusCombo == 'PENDING_APPROVAL' ? 'Pending Approval' : 'Discontinued'}
                                    </span>
                                </td>
                                <td class="text-end">
                                    <div class="dropdown">
                                        <button class="btn btn-action-more" type="button" data-bs-toggle="dropdown" aria-expanded="false"
                                                style="background: #f8f9fa; border: 1px solid #eee; border-radius: 50%; width: 32px; height: 32px; padding: 0;">
                                            <i class="fa-solid fa-ellipsis-vertical"></i>
                                        </button>
                                        <ul class="dropdown-menu dropdown-menu-end shadow border-0 py-2">
                                            <li>
                                                <button class="dropdown-item btn-view-combo" data-id="${c.comboId}">
                                                    <i class="fa-regular fa-eye me-2 text-primary"></i>View
                                                </button>
                                            </li>
                                            <li>
                                                <a class="dropdown-item" href="<c:url value='/combos/update/${c.comboId}'/>">
                                                    <i class="fa-regular fa-pen-to-square me-2 text-warning"></i>Update
                                                </a>
                                            </li>
                                            <li><hr class="dropdown-divider"></li>
                                            <li>
                                                <a class="dropdown-item text-danger btn-delete-combo" href="javascript:void(0)"
                                                   onclick="confirmDelete('${c.comboId}', '<c:url value='/combos/delete/${c.comboId}'/>')">
                                                    <i class="fa-regular fa-trash-can me-2"></i>Delete
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