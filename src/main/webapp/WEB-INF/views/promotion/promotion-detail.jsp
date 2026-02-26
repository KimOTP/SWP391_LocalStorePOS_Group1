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
        <h2 class="fw-bold mb-0">Promotion Detail</h2>
        <button class="btn btn-primary px-3 py-2 fw-medium border-0"
                style="background-color: #3b82f6; border-radius: 8px;"
                data-bs-toggle="modal" data-bs-target="#addDetailModal">
            <i class="fa-solid fa-plus"></i>
        </button>
    </div>

    <div class="card border-0 mb-5" style="background-color: #e5e7eb; border-radius: 12px;">
        <div class="card-body p-4">
            <div class="row mb-3">
                <div class="col-md-12 d-flex align-items-center">
                    <span class="fs-5 text-dark me-2">Promotion code:</span>
                    <span class="fs-5 text-dark">${promotion.promotionId}</span>
                </div>
            </div>

            <div class="row mb-4">
                <div class="col-md-12 d-flex align-items-center">
                    <span class="fs-5 text-dark me-2">Promotion name:</span>
                    <span class="fs-5 fw-bold text-dark">${promotion.promoName}</span>
                </div>
            </div>

            <div class="row">
                <div class="col-md-3">
                    <div class="text-dark mb-1">Start date :</div>
                    <div class="fs-5 text-dark">${promotion.startDate}</div>
                </div>
                <div class="col-md-3">
                    <div class="text-dark mb-1">End date:</div>
                    <div class="fs-5 text-dark">${promotion.endDate}</div>
                </div>
                <div class="col-md-3">
                    <div class="text-dark mb-2">Status :</div>
                    <c:choose>
                        <c:when test="${promotion.status == 'ACTIVE'}">
                            <span class="badge rounded-pill bg-success px-4 py-2">Active</span>
                        </c:when>
                        <c:when test="${promotion.status == 'EXPIRED'}">
                            <span class="badge rounded-pill bg-warning text-dark px-4 py-2">Expired</span>
                        </c:when>
                        <c:otherwise>
                            <span class="badge rounded-pill bg-secondary px-4 py-2">Inactive</span>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </div>

    <div class="mb-3">
        <h6 class="fw-bold mb-1 fs-5">Promotion detail list</h6>
        <span class="text-muted small">Search and filter by criteria</span>
    </div>

    <form action="/promotion/detail" method="get" id="filterForm">
        <input type="hidden" name="id" value="${promotion.promotionId}">

        <div class="row g-3 mb-4">
            <div class="col-md-3">
                <input type="text" name="keyword" value="${keyword}"
                       class="form-control py-2 rounded-3 border-0"
                       placeholder="Search for Deals..." style="background-color: #f3f4f6;">
            </div>
            <div class="col-md-3">
                <select name="productName" class="form-select py-2 rounded-3" onchange="document.getElementById('filterForm').submit()">
                    <option value="">Filter by product</option>
                    <c:forEach var="pName" items="${productNamesList}">
                        <option value="${pName}" ${productName == pName ? 'selected' : ''}>${pName}</option>
                    </c:forEach>
                </select>
            </div>
            <div class="col-md-3">
                <select name="discountType" class="form-select py-2 rounded-3" onchange="document.getElementById('filterForm').submit()">
                    <option value="">% Or Money</option>
                    <option value="PERCENT" ${discountType == 'PERCENT' ? 'selected' : ''}>%</option>
                    <option value="AMOUNT" ${discountType == 'AMOUNT' ? 'selected' : ''}>VND</option>
                </select>
            </div>
        </div>
    </form>

    <div class="table-responsive">
        <table class="table table-borderless align-middle text-center">
            <thead class="border-bottom">
            <tr>
                <th class="py-3 text-start ps-3 fw-bold">Detailed code <i class="fa-solid fa-sort ms-1 text-muted small"></i></th>
                <th class="py-3 text-start fw-bold">Products</th>
                <th class="py-3 fw-bold">Minimum quantity</th>
                <th class="py-3 fw-bold">DiscountValue</th>
                <th class="py-3 fw-bold">Discount Type</th>
                <th class="py-3 text-end pe-3 fw-bold">Operation</th>
            </tr>
            </thead>
            <tbody>
            <c:forEach var="detail" items="${details}">
                <tr>
                    <td class="text-start ps-3 py-3 text-muted">${detail.promoDetailId}</td>

                    <td class="text-start py-3 text-dark">${detail.product.productName}</td>

                    <td class="py-3 text-dark">${detail.minQuantity}</td>

                    <td class="py-3 text-dark">
                        <fmt:formatNumber value="${detail.discountValue}" maxFractionDigits="0"/>
                    </td>

                    <td class="py-3 text-dark">
                        ${detail.discountType == 'AMOUNT' ? 'VND' : '%'}
                    </td>

                    <td class="text-end pe-3 py-3">
                        <div class="dropdown">
                            <button class="btn btn-sm btn-light border-0" type="button"
                                    data-bs-toggle="dropdown"
                                    data-bs-boundary="window"
                                    data-bs-popper-config='{"strategy":"fixed"}'>
                                <i class="fa-solid fa-ellipsis fs-5"></i>
                            </button>

                            <ul class="dropdown-menu dropdown-menu-end border-0 shadow">
                                <li>
                                     <a class="dropdown-item py-2" href="#"
                                           onclick="openEditDetailModal('${detail.promoDetailId}', '${detail.product.productId}', '${detail.minQuantity}', '${detail.discountValue}', '${detail.discountType}')">
                                            <i class="fa-solid fa-pen text-warning me-2"></i> Edit
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
<div class="modal fade" id="addDetailModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow">

            <div class="modal-header border-0 pb-0">
                <h5 class="modal-title fw-bold fs-4">Add Promotion Detail <i class="fa-solid fa-tags ms-2 text-muted" style="font-size: 1rem;"></i></h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>

            <form action="/promotion/detail/add" method="post">
                <div class="modal-body pt-3">
                    <input type="hidden" name="promotionId" value="${promotion.promotionId}">

                    <div class="mb-3">
                        <label class="form-label fw-bold">Product:</label>
                        <select name="productId" class="form-select rounded-pill py-2 px-3" required>
                            <option value="">-- Choose a product --</option>
                            <c:forEach var="prod" items="${allProducts}">
                                <option value="${prod.productId}">${prod.productName}</option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="mb-3">
                        <label class="form-label fw-bold">Minimum Quantity:</label>
                        <input type="number" name="minQuantity" class="form-control rounded-pill py-2 px-3" value="1" min="1" required>
                    </div>

                    <div class="row g-3 mb-4">
                        <div class="col-md-6">
                            <label class="form-label fw-bold">Discount Type:</label>
                            <select name="discountType" class="form-select rounded-pill py-2 px-3" required>
                                <option value="AMOUNT">VND (Money)</option>
                                <option value="PERCENT">% (Percentage)</option>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-bold">Discount Value:</label>
                            <input type="number" name="discountValue" class="form-control rounded-pill py-2 px-3" required>
                        </div>
                    </div>

                    <div class="d-flex gap-3 mt-4">
                        <button type="submit" class="btn text-white w-50 py-2 fw-bold rounded-3 fs-5"
                                style="background-color: #34a853;">Confirm</button>
                        <button type="button" class="btn text-white w-50 py-2 fw-bold rounded-3 fs-5"
                                style="background-color: #b20000;" data-bs-dismiss="modal">Cancel</button>
                    </div>
                </div>
            </form>
        </div>
    </div>
</div>

<div class="modal fade" id="editDetailModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow">

            <div class="modal-header border-0 pb-0">
                <h5 class="modal-title fw-bold fs-4">Edit Promotion Detail <i class="fa-solid fa-pen ms-2 text-muted" style="font-size: 1rem;"></i></h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>

            <form action="/promotion/detail/update" method="post">
                <div class="modal-body pt-3">
                    <input type="hidden" name="promoDetailId" id="editPromoDetailId">
                    <input type="hidden" name="promotionId" value="${promotion.promotionId}">

                    <div class="mb-3">
                        <label class="form-label fw-bold">Product:</label>
                        <select name="productId" id="editProductId" class="form-select rounded-pill py-2 px-3" required>
                            <option value="">-- Choose a product --</option>
                            <c:forEach var="prod" items="${allProducts}">
                                <option value="${prod.productId}">${prod.productName}</option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="mb-3">
                        <label class="form-label fw-bold">Minimum Quantity:</label>
                        <input type="number" name="minQuantity" id="editMinQuantity" class="form-control rounded-pill py-2 px-3" min="1" required>
                    </div>

                    <div class="row g-3 mb-4">
                        <div class="col-md-6">
                            <label class="form-label fw-bold">Discount Type:</label>
                            <select name="discountType" id="editDiscountType" class="form-select rounded-pill py-2 px-3" required>
                                <option value="AMOUNT">VND (Money)</option>
                                <option value="PERCENT">% (Percentage)</option>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-bold">Discount Value:</label>
                            <input type="number" name="discountValue" id="editDiscountValue" class="form-control rounded-pill py-2 px-3" required>
                        </div>
                    </div>

                    <div class="d-flex gap-3 mt-4">
                        <button type="submit" class="btn text-white w-50 py-2 fw-bold rounded-3 fs-5" style="background-color: #34a853;">Save Changes</button>
                        <button type="button" class="btn text-white w-50 py-2 fw-bold rounded-3 fs-5" style="background-color: #b20000;" data-bs-dismiss="modal">Cancel</button>
                    </div>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/resources/js/customer/customer.js"></script>

</body>
</html>