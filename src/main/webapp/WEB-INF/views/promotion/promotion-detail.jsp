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
    <link href="${pageContext.request.contextPath}/resources/css/customer/customer1.css" rel="stylesheet">
</head>
<body>

<jsp:include page="../layer/header.jsp" />
<jsp:include page="../layer/sidebar.jsp" />

<div class="main-content">

    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <nav aria-label="breadcrumb">
                <ol class="breadcrumb mb-1">
                    <li class="breadcrumb-item"><a href="/promotion" class="text-decoration-none text-muted">Promotion Management</a></li>
                    <li class="breadcrumb-item active fw-bold text-primary" aria-current="page">Detail</li>
                </ol>
            </nav>
            <h2 class="fw-bold mb-0">Promotion Details</h2>
        </div>
        <button class="btn btn-primary px-4 py-2 fw-medium d-inline-flex align-items-center"
                style="background-color: #2563eb; border-radius: 8px;"
                data-bs-toggle="modal" data-bs-target="#addDetailModal">
            <i class="fa-solid fa-plus me-2"></i> Add Product
        </button>
    </div>

    <div class="card shadow-sm border-0 mb-4" style="border-radius: 16px;">
        <div class="card-body p-4">
            <div class="row g-4 align-items-center">
                <div class="col-md-3 border-end">
                    <div class="text-muted small mb-1">Promotion Code</div>
                    <div class="fs-5 fw-bold text-dark">#${promotion.promotionId}</div>
                </div>
                <div class="col-md-3 border-end">
                    <div class="text-muted small mb-1">Promotion Name</div>
                    <div class="fs-5 fw-bold text-primary">${promotion.promoName}</div>
                </div>
                <div class="col-md-4 border-end">
                    <div class="d-flex justify-content-between pe-4">
                        <div>
                            <div class="text-muted small mb-1">Start Date</div>
                            <div class="fw-bold text-dark">${promotion.startDate}</div>
                        </div>
                        <div>
                            <div class="text-muted small mb-1">End Date</div>
                            <div class="fw-bold text-dark">${promotion.endDate}</div>
                        </div>
                    </div>
                </div>
                <div class="col-md-2 text-center">
                    <div class="text-muted small mb-2">Status</div>
                    <c:choose>
                        <c:when test="${promotion.status == 'ACTIVE'}">
                            <span class="badge-active">Active</span>
                        </c:when>
                        <c:when test="${promotion.status == 'EXPIRED'}">
                            <span class="badge-inactive" style="color: #d97706; background: #fffbeb;">Expired</span>
                        </c:when>
                        <c:otherwise>
                            <span class="badge-inactive">Inactive</span>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </div>

    <div class="card shadow-sm border-0" style="border-radius: 16px;">
        <div class="card-body p-4">

            <div class="mb-4">
                <h5 class="fw-bold mb-1">Applied Products List</h5>
                <span class="text-muted small">Manage products and discount rules for this promotion</span>
            </div>

            <form action="/promotion/detail" method="get" id="filterForm">
                <input type="hidden" name="id" value="${promotion.promotionId}">

                <div class="row g-3 mb-4">
                    <div class="col-md-4">
                        <div class="input-group">
                            <span class="input-group-text bg-white border-end-0">
                                <i class="fa-solid fa-magnifying-glass text-muted"></i>
                            </span>
                            <input type="text" name="keyword" value="${keyword}"
                                   class="form-control border-start-0"
                                   placeholder="Search for details...">
                        </div>
                    </div>
                    <div class="col-md-3">
                        <select name="productName" class="form-select" onchange="document.getElementById('filterForm').submit()">
                            <option value="">Filter by product</option>
                            <c:forEach var="pName" items="${productNamesList}">
                                <option value="${pName}" ${productName == pName ? 'selected' : ''}>${pName}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <select name="discountType" class="form-select" onchange="document.getElementById('filterForm').submit()">
                            <option value="">Discount Type</option>
                            <option value="PERCENT" ${discountType == 'PERCENT' ? 'selected' : ''}>% (Percent)</option>
                            <option value="AMOUNT" ${discountType == 'AMOUNT' ? 'selected' : ''}>VND (Money)</option>
                        </select>
                    </div>
                </div>
            </form>

            <div class="table-responsive">
                <table class="table table-hover align-middle">
                    <thead class="bg-light">
                    <tr>
                        <th class="py-3 ps-3">Rule ID</th>
                        <th class="py-3">Product Name</th>
                        <th class="py-3">Min. Quantity</th>
                        <th class="py-3">Discount Value</th>
                        <th class="py-3">Type</th>
                        <th class="py-3 text-end pe-3">Action</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach var="detail" items="${details}">
                        <tr>
                            <td class="ps-3 fw-medium text-muted">#${detail.promoDetailId}</td>
                            <td class="fw-bold text-dark">${detail.product.productName}</td>
                            <td class="text-muted">Buy >= <span class="fw-bold text-dark">${detail.minQuantity}</span></td>

                            <td class="fw-bold text-danger">
                                <c:choose>
                                    <c:when test="${detail.discountType == 'AMOUNT'}">
                                        <fmt:formatNumber value="${detail.discountValue}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                    </c:when>
                                    <c:otherwise>
                                        ${detail.discountValue} %
                                    </c:otherwise>
                                </c:choose>
                            </td>

                            <td>
                                <span class="badge bg-light text-dark border">${detail.discountType == 'AMOUNT' ? 'VND' : 'PERCENT'}</span>
                            </td>

                            <td class="text-end pe-3">
                                <div class="dropdown">
                                    <button class="btn btn-sm btn-light border-0 rounded-circle" type="button"
                                            data-bs-toggle="dropdown"
                                            data-bs-boundary="window"
                                            data-bs-popper-config='{"strategy":"fixed"}'>
                                        <i class="fa-solid fa-ellipsis fs-5"></i>
                                    </button>

                                    <ul class="dropdown-menu dropdown-menu-end border-0 shadow">
                                        <li>
                                            <a class="dropdown-item py-2" href="#"
                                               onclick="openEditDetailModal('${detail.promoDetailId}', '${detail.product.productId}', '${detail.minQuantity}', '${detail.discountValue}', '${detail.discountType}')">
                                                <i class="fa-solid fa-pen-to-square text-primary me-2"></i> Edit Rule
                                            </a>
                                        </li>
                                        <li><hr class="dropdown-divider"></li>
                                        <li>
                                            <a class="dropdown-item py-2 text-danger"
                                               href="/promotion/detail/delete?detailId=${detail.promoDetailId}&promotionId=${promotion.promotionId}"
                                               onclick="return confirm('Bạn có chắc chắn muốn xóa sản phẩm này khỏi đợt khuyến mãi?')">
                                                <i class="fa-solid fa-trash me-2"></i> Delete
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

<div class="modal fade" id="addDetailModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow" style="border-radius: 16px;">
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
                        <button type="submit" class="btn text-white w-50 py-2 fw-bold" style="background-color: #2563eb; border-radius: 8px;">Confirm</button>
                        <button type="button" class="btn btn-light w-50 py-2 fw-bold border" style="border-radius: 8px;" data-bs-dismiss="modal">Cancel</button>
                    </div>
                </div>
            </form>
        </div>
    </div>
</div>

<div class="modal fade" id="editDetailModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow" style="border-radius: 16px;">
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
                        <button type="submit" class="btn text-white w-50 py-2 fw-bold" style="background-color: #2563eb; border-radius: 8px;">Save Changes</button>
                        <button type="button" class="btn btn-light w-50 py-2 fw-bold border" style="border-radius: 8px;" data-bs-dismiss="modal">Cancel</button>
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