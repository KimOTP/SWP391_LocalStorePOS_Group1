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
    <link href="${pageContext.request.contextPath}/resources/css/customer/customer.css" rel="stylesheet">
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
            <button class="btn btn-primary px-4 fw-medium" style="background-color: #0d6efd;">
                <i class="fa-solid fa-plus me-2"></i>Add promotion
            </button>
        </div>
    </div>

    <div class="row g-4 mb-5">
        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-title mb-2">Total promotion</div>
                <div class="stat-value">${totalPromotions}</div>
                <div class="small text-muted mt-1">Promotions in the system</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-title mb-2">Active</div>
                <div class="stat-value text-success">${activeCount}</div>
                <div class="small text-muted mt-1">Currently running system-wide</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-title mb-2">Inactive</div>
                <div class="stat-value text-secondary">${inactiveCount}</div>
                <div class="small text-muted mt-1">Temporarily suspended</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-title mb-2">Promotion is about to end</div>
                <div class="stat-value text-warning">${expiredCount}</div> <div class="small text-muted mt-1">About to expire across system</div>
            </div>
        </div>
    </div>

    <div class="card shadow-sm border-0">
        <div class="card-body p-4">

            <div class="mb-4">
                <h5 class="fw-bold">Promotion list</h5>
                <span class="text-muted small">Search and filter by criteria</span>
            </div>

            <form action="/promotions" method="get" id="filterForm">
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

                            <td class="fw-bold text-dark">${promo.promoName}</td>

                            <td class="text-muted">
                                ${promo.startDate.toString().substring(0, 10)}
                            </td>
                            <td class="text-muted">
                                ${promo.endDate.toString().substring(0, 10)}
                            </td>

                            <td>
                                <c:choose>
                                    <c:when test="${promo.status == 'ACTIVE'}">
                                        <span class="badge rounded-pill bg-success px-3 py-2">Active</span>
                                    </c:when>
                                    <c:when test="${promo.status == 'EXPIRED'}">
                                        <span class="badge rounded-pill bg-warning text-dark px-3 py-2">Expired</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge rounded-pill bg-secondary px-3 py-2">Inactive</span>
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
                                        <li><a class="dropdown-item py-2" href="#"><i class="fa-solid fa-eye text-warning me-2"></i> View details</a></li>
                                        <li><a class="dropdown-item py-2" href="#"><i class="fa-solid fa-pause text-secondary me-2"></i> Inactive</a></li>
                                        <li><hr class="dropdown-divider"></li>
                                        <li><a class="dropdown-item py-2 text-danger" href="#"><i class="fa-solid fa-trash me-2"></i> Delete</a></li>
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

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

<script src="${pageContext.request.contextPath}/resources/js/customer/customer.js"></script>

</body>
</html>