<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Promotion Detail</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/resources/css/customer/customer.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</head>
<body>

<jsp:include page="../layer/header.jsp" />
<jsp:include page="../layer/sidebar.jsp" />

<div class="main-content">

    <%-- Page Header --%>
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <nav aria-label="breadcrumb">
                <ol class="breadcrumb mb-1">
                    <li class="breadcrumb-item">
                        <a href="/promotion" class="text-decoration-none text-muted">Promotion Management</a>
                    </li>
                    <li class="breadcrumb-item active fw-bold text-primary" aria-current="page">Detail</li>
                </ol>
            </nav>
            <h2 class="fw-bold mb-0">Promotion Details</h2>
            <small class="text-muted">View and manage products in this promotion</small>
        </div>
        <div class="d-flex gap-2">
            <input type="file" id="excelFile" accept=".xlsx" style="display:none;"
                   onchange="uploadExcel(${promotion.promotionId})">
            <button type="button" class="btn-success-outline"
                    onclick="document.getElementById('excelFile').click()">
                <i class="fa-solid fa-file-excel"></i> Import Excel
            </button>
            <button class="btn-add" data-bs-toggle="modal" data-bs-target="#addDetailModal">
                <i class="fa-solid fa-plus"></i> Add Product
            </button>
        </div>
    </div>

    <%-- Promotion Info Card --%>
    <div class="info-card">
        <div class="row g-4 align-items-center">
            <div class="col-md-3 border-end">
                <div class="stat-title mb-1">Promotion Code</div>
                <div class="fs-5 fw-bold text-dark">#${promotion.promotionId}</div>
            </div>
            <div class="col-md-3 border-end">
                <div class="stat-title mb-1">Promotion Name</div>
                <div class="fs-5 fw-bold text-1">${promotion.promoName}</div>
            </div>
            <div class="col-md-4 border-end">
                <div class="d-flex justify-content-between pe-4">
                    <div>
                        <div class="stat-title mb-1">Start Date</div>
                        <div class="fw-bold text-dark">${promotion.startDate}</div>
                    </div>
                    <div>
                        <div class="stat-title mb-1">End Date</div>
                        <div class="fw-bold text-dark">${promotion.endDate}</div>
                    </div>
                </div>
            </div>
            <div class="col-md-2 text-center">
                <div class="stat-title mb-2">Status</div>
                <c:choose>
                    <c:when test="${promotion.status == 'ACTIVE'}"><span class="badge-active">Active</span></c:when>
                    <c:when test="${promotion.status == 'EXPIRED'}"><span class="badge-expired">Expired</span></c:when>
                    <c:otherwise><span class="badge-inactive">Inactive</span></c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>

    <%-- Filter Bar --%>
    <form action="/promotion/detail" method="get" id="filterForm">
        <input type="hidden" name="id" value="${promotion.promotionId}">
        <div class="filter-bar">
            <div class="search-box-standalone">
                <i class="fa-solid fa-magnifying-glass search-icon"></i>
                <input type="text" name="keyword" value="${keyword}"
                       class="form-control" placeholder="Search for details...">
            </div>

            <div class="filter-actions">
                <%-- Product filter --%>
                <div class="dropdown">
                    <button class="btn-filter" type="button" data-bs-toggle="dropdown" data-bs-auto-close="outside">
                        <span>${empty productName ? 'All Products' : productName}</span>
                        <i class="fa-solid fa-chevron-down"></i>
                    </button>
                    <div class="dropdown-menu shadow border-0 p-2" style="max-height:240px;overflow-y:auto;">
                        <label class="dropdown-item" style="cursor:pointer;gap:10px;">
                            <input type="radio" name="productName" value="" ${empty productName ?'checked':''} onchange="filterForm.submit()"> All Products
                        </label>
                        <c:forEach var="pName" items="${productNamesList}">
                            <label class="dropdown-item" style="cursor:pointer;gap:10px;">
                                <input type="radio" name="productName" value="${pName}" ${productName == pName ?'checked':''} onchange="filterForm.submit()"> ${pName}
                            </label>
                        </c:forEach>
                    </div>
                </div>

                <%-- Discount type filter --%>
                <div class="dropdown">
                    <button class="btn-filter" type="button" data-bs-toggle="dropdown" data-bs-auto-close="outside">
                        <span>${empty discountType ? 'Discount Type' : discountType}</span>
                        <i class="fa-solid fa-chevron-down"></i>
                    </button>
                    <div class="dropdown-menu shadow border-0 p-2">
                        <label class="dropdown-item" style="cursor:pointer;gap:10px;"><input type="radio" name="discountType" value=""        ${empty discountType ?'checked':''} onchange="filterForm.submit()"> All Types</label>
                        <label class="dropdown-item" style="cursor:pointer;gap:10px;"><input type="radio" name="discountType" value="PERCENT" ${discountType=='PERCENT' ?'checked':''} onchange="filterForm.submit()"> % Percent</label>
                        <label class="dropdown-item" style="cursor:pointer;gap:10px;"><input type="radio" name="discountType" value="AMOUNT"  ${discountType=='AMOUNT'  ?'checked':''} onchange="filterForm.submit()"> VND Money</label>
                    </div>
                </div>

                <button type="submit" class="btn-add">
                    <i class="fa-solid fa-magnifying-glass"></i> Search
                </button>
            </div>
        </div>
    </form>

    <%-- Detail Table --%>
    <div class="data-table-card">
        <div class="table-responsive">
            <table class="table table-hover align-middle">
                <thead>
                    <tr class="thead-row">
                        <th class="th-cell">Rule ID</th>
                        <th class="th-cell">Product Name</th>
                        <th class="th-cell">Min. Quantity</th>
                        <th class="th-cell">Discount Value</th>
                        <th class="th-cell">Type</th>
                        <th class="th-cell text-end">Actions</th>
                    </tr>
                </thead>
                <tbody>
                <c:forEach var="detail" items="${details}">
                    <tr>
                        <td class="td-cell fw-medium text-muted" style="font-family:monospace;font-size:0.82rem;">#${detail.promoDetailId}</td>
                        <td class="td-cell fw-bold text-dark">${detail.product.productName}</td>
                        <td class="td-cell text-muted">
                            Buy &ge; <span class="fw-bold text-dark">${detail.minQuantity}</span>
                        </td>
                        <td class="td-cell fw-bold text-7">
                            <c:choose>
                                <c:when test="${detail.discountType == 'AMOUNT'}">
                                    <fmt:formatNumber value="${detail.discountValue}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                </c:when>
                                <c:otherwise>${detail.discountValue} %</c:otherwise>
                            </c:choose>
                        </td>
                        <td class="td-cell">
                            <span class="badge bg-light text-dark border" style="border-radius:6px;">
                                ${detail.discountType == 'AMOUNT' ? 'VND' : 'PERCENT'}
                            </span>
                        </td>
                        <td class="td-cell text-end">
                            <div class="dropdown">
                                <button class="btn btn-light btn-sm rounded-circle shadow-none"
                                        type="button" data-bs-toggle="dropdown"
                                        data-bs-boundary="viewport" aria-expanded="false"
                                        style="width:32px;height:32px;">
                                    <i class="fa-solid fa-ellipsis-vertical"></i>
                                </button>
                                <ul class="dropdown-menu dropdown-menu-end shadow border-0 py-1">
                                    <li>
                                        <a class="dropdown-item" href="#"
                                           onclick="openEditDetailModal('${detail.promoDetailId}','${detail.product.productId}','${detail.minQuantity}','${detail.discountValue}','${detail.discountType}')">
                                            <i class="fa-solid fa-pen-to-square text-primary"></i> Edit Rule
                                        </a>
                                    </li>
                                    <li><hr class="dropdown-divider mx-2"></li>
                                    <li>
                                        <a class="dropdown-item text-danger" href="#"
                                           onclick="confirmDelete('/promotion/detail/delete?detailId=${detail.promoDetailId}&promotionId=${promotion.promotionId}','this product from the promotion')">
                                            <i class="fa-solid fa-trash"></i> Delete
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

<%-- ===== MODALS ===== --%>

<%-- Add Detail --%>
<div class="modal fade" id="addDetailModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow" style="border-radius:16px;">
            <div class="modal-header border-0 pb-0 mt-2 mx-2">
                <h5 class="modal-title fw-bold fs-4">Add Promotion Rule</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form action="/promotion/detail/add" method="post">
                <div class="modal-body pt-3 px-4">
                    <input type="hidden" name="promotionId" value="${promotion.promotionId}">
                    <div class="mb-3">
                        <label class="form-label fw-bold text-muted small">Select Product:</label>
                        <select name="productId" class="form-select py-2" required>
                            <option value="">-- Choose a product --</option>
                            <c:forEach var="prod" items="${allProducts}">
                                <option value="${prod.productId}">${prod.productName}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-bold text-muted small">Minimum Quantity Required:</label>
                        <input type="number" name="minQuantity" class="form-control py-2" value="1" min="1" required>
                    </div>
                    <div class="row g-3 mb-4">
                        <div class="col-md-6">
                            <label class="form-label fw-bold text-muted small">Discount Type:</label>
                            <select name="discountType" class="form-select py-2" required>
                                <option value="AMOUNT">VND (Money)</option>
                                <option value="PERCENT">% (Percentage)</option>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-bold text-muted small">Discount Value:</label>
                            <input type="number" name="discountValue" class="form-control py-2" required>
                        </div>
                    </div>
                    <div class="d-flex gap-2 mb-2">
                        <button type="submit" class="btn text-white w-50 py-2 fw-bold" style="background-color:#2563eb;border-radius:8px;">Confirm</button>
                        <button type="button" class="btn btn-light w-50 py-2 fw-bold border" style="border-radius:8px;" data-bs-dismiss="modal">Cancel</button>
                    </div>
                </div>
            </form>
        </div>
    </div>
</div>

<%-- Edit Detail --%>
<div class="modal fade" id="editDetailModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow" style="border-radius:16px;">
            <div class="modal-header border-0 pb-0 mt-2 mx-2">
                <h5 class="modal-title fw-bold fs-4">Edit Promotion Rule</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form action="/promotion/detail/update" method="post">
                <div class="modal-body pt-3 px-4">
                    <input type="hidden" name="promoDetailId" id="editPromoDetailId">
                    <input type="hidden" name="promotionId" value="${promotion.promotionId}">
                    <div class="mb-3">
                        <label class="form-label fw-bold text-muted small">Select Product:</label>
                        <select name="productId" id="editProductId" class="form-select py-2" required>
                            <option value="">-- Choose a product --</option>
                            <c:forEach var="prod" items="${allProducts}">
                                <option value="${prod.productId}">${prod.productName}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-bold text-muted small">Minimum Quantity Required:</label>
                        <input type="number" name="minQuantity" id="editMinQuantity" class="form-control py-2" min="1" required>
                    </div>
                    <div class="row g-3 mb-4">
                        <div class="col-md-6">
                            <label class="form-label fw-bold text-muted small">Discount Type:</label>
                            <select name="discountType" id="editDiscountType" class="form-select py-2" required>
                                <option value="AMOUNT">VND (Money)</option>
                                <option value="PERCENT">% (Percentage)</option>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-bold text-muted small">Discount Value:</label>
                            <input type="number" name="discountValue" id="editDiscountValue" class="form-control py-2" required>
                        </div>
                    </div>
                    <div class="d-flex gap-2 mb-2">
                        <button type="submit" class="btn text-white w-50 py-2 fw-bold" style="background-color:#2563eb;border-radius:8px;">Save Changes</button>
                        <button type="button" class="btn btn-light w-50 py-2 fw-bold border" style="border-radius:8px;" data-bs-dismiss="modal">Cancel</button>
                    </div>
                </div>
            </form>
        </div>
    </div>
</div>

<input type="hidden" id="serverSuccessMsg" value="${success}">
<input type="hidden" id="serverErrorMsg" value="${error}">
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/resources/js/customer/customer.js"></script>

</body>
</html>
