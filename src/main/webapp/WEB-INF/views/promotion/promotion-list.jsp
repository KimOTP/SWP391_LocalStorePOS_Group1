<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Promotion Management</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/resources/css/customer/customer1.css" rel="stylesheet">
</head>
<body>

<jsp:include page="../layer/header.jsp" />
<jsp:include page="../layer/sidebar.jsp" />

<div class="main-content">

    <div class="d-flex justify-content-between align-items-end mb-4">
        <div>
            <h2 class="fw-bold mb-1">Promotion Management</h2>
            <span class="text-muted">Manage your marketing campaigns and deals</span>
        </div>
        <div>
            <button class="btn btn-primary px-4 fw-medium" style="background-color: #0d6efd;"
                data-bs-toggle="modal" data-bs-target="#addPromotionModal">
                    <i class="fa-solid fa-plus me-2"></i>Add promotion
            </button>
        </div>
    </div>

    <div class="row g-4 mb-5">
        <div class="col-md-3">
            <div class="stat-card">
            <i class="fa-solid fa-tags stat-icon"></i>
                <div class="stat-title mb-2">Total promotion</div>
                <div class="stat-value text-5">${totalPromotions}</div>
                <div class="small text-muted mt-1">Promotions in the system</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card">
            <i class="fa-solid fa-circle-check stat-icon"></i>
                <div class="stat-title mb-2">Active</div>
                <div class="stat-value text-6">${activeCount}</div>
                <div class="small text-muted mt-1">Currently running system-wide</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card">
            <i class="fa-solid fa-circle-pause stat-icon"></i>
                <div class="stat-title mb-2">Inactive</div>
                <div class="stat-value text-7">${inactiveCount}</div>
                <div class="small text-muted mt-1">Temporarily suspended</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card">
            <i class="fa-solid fa-hourglass-half stat-icon"></i>
                <div class="stat-title mb-2">Promotion Expired</div>
                <div class="stat-value text-8">${expiredCount}</div> <div class="small text-muted mt-1">Expired across system</div>
            </div>
        </div>
    </div>

    <div class="card shadow-sm border-0">
        <div class="card-body p-4">

            <div class="mb-4">
                <h5 class="fw-bold">Promotion list</h5>
                <span class="text-muted small">Search and filter by criteria</span>
            </div>

            <form action="/promotion" method="get" id="filterForm">
                <div class="row g-3 mb-4">

                    <div class="col-md-4">
                        <div class="input-group">
                            <span class="input-group-text bg-white border-end-0">
                                <i class="fa-solid fa-magnifying-glass text-muted"></i>
                            </span>
                            <input type="text" name="keyword" value="${keyword}"
                                   class="form-control border-start-0"
                                   placeholder="Search name or ID...">
                        </div>
                    </div>

                    <div class="col-md-2">
                        <select name="status" class="form-select" onchange="document.getElementById('filterForm').submit()">
                            <option value="">All status</option>
                            <option value="ACTIVE" ${status == 'ACTIVE' ? 'selected' : ''}>Active</option>
                            <option value="INACTIVE" ${status == 'INACTIVE' ? 'selected' : ''}>Inactive</option>
                            <option value="EXPIRED" ${status == 'EXPIRED' ? 'selected' : ''}>Expired</option>
                        </select>
                    </div>

                    <div class="col-md-3">
                        <div class="input-group">
                            <span class="input-group-text bg-white border-end-0 text-muted small">From</span>
                            <input type="date" name="fromDate" value="${fromDate}"
                                   class="form-control border-start-0 text-muted"
                                   onchange="document.getElementById('filterForm').submit()">
                        </div>
                    </div>

                    <div class="col-md-3">
                        <div class="input-group">
                            <span class="input-group-text bg-white border-end-0 text-muted small">To</span>
                            <input type="date" name="toDate" value="${toDate}"
                                   class="form-control border-start-0 text-muted"
                                   onchange="document.getElementById('filterForm').submit()">
                        </div>
                    </div>

                </div>
            </form>

            <div class="table-responsive">
                <table class="table table-hover align-middle">
                    <thead class="bg-light">
                    <tr>
                        <th class="py-3 ps-3">Promotion code <i class="fa-solid fa-sort ms-1 text-muted small"></i></th>
                        <th class="py-3">Promotion name <i class="fa-solid fa-sort ms-1 text-muted small"></i></th>
                        <th class="py-3">Start date</th>
                        <th class="py-3">End date</th>
                        <th class="py-3">Status</th>
                        <th class="py-3 text-end pe-3">Operation</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach var="promo" items="${promotions}">
                        <tr>
                            <td class="ps-3 fw-medium text-muted">${promo.promotionId}</td>

                            <td class="fw-bold text-5">${promo.promoName}</td>

                            <td class="text-muted">
                                ${promo.startDate.toString().substring(0, 10)}
                            </td>
                            <td class="text-muted">
                                ${promo.endDate.toString().substring(0, 10)}
                            </td>

                            <td>
                                <c:choose>
                                    <c:when test="${promo.status == 'ACTIVE'}">
                                        <span class="badge rounded-pill badge-active px-3 py-2">Active</span>
                                    </c:when>
                                    <c:when test="${promo.status == 'EXPIRED'}">
                                        <span class="badge rounded-pill badge-expired px-3 py-2">Expired</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge rounded-pill badge-inactive px-3 py-2">Inactive</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>

                            <td class="text-end pe-3">
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
                                                   onclick="openEditPromotionModal('${promo.promotionId}', '${promo.promoName}', '${promo.status}', '${promo.startDate}', '${promo.endDate}')">
                                                    <i class="fa-solid fa-pen-to-square text-primary me-2"></i> Edit
                                             </a>
                                        </li>
                                        <li><a class="dropdown-item py-2" href="/promotion/detail?id=${promo.promotionId}"><i class="fa-solid fa-eye text-warning me-2"></i> View details</a></li>
                                        <li>
                                                <c:choose>
                                                    <%-- Nếu đang ACTIVE -> Inactive để tắt --%>
                                                    <c:when test="${promo.status == 'ACTIVE'}">
                                                        <a class="dropdown-item py-2"
                                                           href="/promotion/status?id=${promo.promotionId}&status=INACTIVE"
                                                           onclick="return confirm('Are you sure you want to pause this promotion?')">
                                                            <i class="fa-solid fa-pause text-secondary me-2"></i> Inactive
                                                        </a>
                                                    </c:when>

                                                    <%-- Nếu đang INACTIVE -> Hiện nút Active--%>
                                                    <c:when test="${promo.status == 'INACTIVE'}">
                                                        <a class="dropdown-item py-2"
                                                           href="/promotion/status?id=${promo.promotionId}&status=ACTIVE"
                                                           onclick="return confirm('Are you sure you want to activate this promotion?')">
                                                            <i class="fa-solid fa-play text-success me-2"></i> Active
                                                        </a>
                                                    </c:when>
                                                </c:choose>
                                            </li>
                                        <li><hr class="dropdown-divider"></li>
                                        <li>
                                             <a class="dropdown-item py-2 text-danger" href="/promotion/delete?id=${promo.promotionId}"
                                                   onclick="return confirm('Are you sure you want to delete this promotion?')">
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

<div class="modal fade" id="addPromotionModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-lg"> <div class="modal-content border-0 shadow">

            <div class="modal-header border-0 pb-0">
                <h5 class="modal-title fw-bold fs-3">Add promotion <i class="fa-solid fa-right-from-bracket ms-2 text-muted" style="font-size: 1rem;"></i></h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>

            <form action="/promotion/add" method="post" onsubmit="return validatePromotionForm(this)">
                <div class="modal-body pt-3">
                    <div class="row g-4"> <div class="col-md-6">
                            <label class="form-label fw-bold fs-5">Name:</label>
                            <input type="text" name="promoName" class="form-control rounded-pill py-2 px-3" placeholder="Nhập tên" required>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label fw-bold fs-5">Status:</label>
                            <select name="status" class="form-select rounded-pill py-2 px-3">
                                <option value="ACTIVE">Active</option>
                                <option value="INACTIVE">Inactive</option>
                            </select>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label fw-bold fs-5">Start date:</label>
                            <input type="date" name="startDate" class="form-control rounded-pill py-2 px-3" required>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label fw-bold fs-5">End date:</label>
                            <input type="date" name="endDate" class="form-control rounded-pill py-2 px-3" required>
                        </div>
                    </div>

                    <div class="d-flex gap-3 mt-5">
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

<div class="modal fade" id="editPromotionModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content border-0 shadow">

            <div class="modal-header border-0 pb-0">
                <h5 class="modal-title fw-bold fs-3">Edit promotion <i class="fa-solid fa-pen ms-2 text-muted" style="font-size: 1rem;"></i></h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>

            <form action="/promotion/update" method="post" onsubmit="return validatePromotionForm(this)">
                <div class="modal-body pt-3">
                    <input type="hidden" id="editPromoId" name="promotionId">

                    <div class="row g-4">
                        <div class="col-md-6">
                            <label class="form-label fw-bold fs-5">Name:</label>
                            <input type="text" id="editPromoName" name="promoName" class="form-control rounded-pill py-2 px-3" required>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label fw-bold fs-5">Status:</label>
                            <select id="editStatus" name="status" class="form-select rounded-pill py-2 px-3">
                                <option value="ACTIVE">Active</option>
                                <option value="INACTIVE">Inactive</option>
                                <option value="EXPIRED">Expired</option>
                            </select>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label fw-bold fs-5">Start date:</label>
                            <input type="date" id="editStartDate" name="startDate" class="form-control rounded-pill py-2 px-3" required>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label fw-bold fs-5">End date:</label>
                            <input type="date" id="editEndDate" name="endDate" class="form-control rounded-pill py-2 px-3" required>
                        </div>
                    </div>

                    <div class="d-flex gap-3 mt-5">
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

<input type="hidden" id="serverSuccessMsg" value="${success}">
<input type="hidden" id="serverErrorMsg" value="${error}">
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/resources/js/customer/customer.js"></script>

</body>
</html>