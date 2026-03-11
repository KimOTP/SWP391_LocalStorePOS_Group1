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
            <h2 class="fw-bold mb-0">Promotion Management</h2>
            <small class="text-muted">Manage your marketing campaigns and deals</small>
        </div>
        <button class="btn-add" data-bs-toggle="modal" data-bs-target="#addPromotionModal">
            <i class="fa-solid fa-plus"></i> Add Promotion
        </button>
    </div>

    <%-- Stat Cards --%>
    <div class="row g-4">
        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-card-header">
                    <div class="stat-card-info">
                        <div class="stat-title">Total Promotions</div>
                        <div class="stat-value text-1">${totalPromotions}</div>
                    </div>
                    <div class="stat-card-icon stat-icon-blue"><i class="fa-solid fa-tags"></i></div>
                </div>
                <div class="stat-sub">Promotions in the system</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-card-header">
                    <div class="stat-card-info">
                        <div class="stat-title">Active</div>
                        <div class="stat-value text-6">${activeCount}</div>
                    </div>
                    <div class="stat-card-icon stat-icon-green"><i class="fa-solid fa-circle-check"></i></div>
                </div>
                <div class="stat-sub">Currently running system-wide</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-card-header">
                    <div class="stat-card-info">
                        <div class="stat-title">Inactive</div>
                        <div class="stat-value text-7">${inactiveCount}</div>
                    </div>
                    <div class="stat-card-icon stat-icon-red"><i class="fa-solid fa-circle-pause"></i></div>
                </div>
                <div class="stat-sub">Temporarily suspended</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-card-header">
                    <div class="stat-card-info">
                        <div class="stat-title">Expired</div>
                        <div class="stat-value text-8">${expiredCount}</div>
                    </div>
                    <div class="stat-card-icon stat-icon-orange"><i class="fa-solid fa-hourglass-half"></i></div>
                </div>
                <div class="stat-sub">Expired across system</div>
            </div>
        </div>
    </div>

    <%-- Filter Bar --%>
    <form action="/promotion" method="get" id="filterForm">
        <div class="filter-bar">
            <div class="search-box-standalone">
                <i class="fa-solid fa-magnifying-glass search-icon"></i>
                <input type="text" name="keyword" value="${keyword}"
                       class="form-control" placeholder="Search name or ID...">
            </div>

            <div class="filter-actions">
                <%-- Status filter --%>
                <div class="dropdown">
                    <button class="btn-filter" type="button" data-bs-toggle="dropdown" data-bs-auto-close="outside">
                        <span>${empty status ? 'All Status' : status}</span>
                        <i class="fa-solid fa-chevron-down"></i>
                    </button>
                    <div class="dropdown-menu shadow border-0 p-2">
                        <label class="dropdown-item" style="cursor:pointer;gap:10px;"><input type="radio" name="status" value=""         ${empty status ?'checked':''} onchange="filterForm.submit()"> All Status</label>
                        <label class="dropdown-item" style="cursor:pointer;gap:10px;"><input type="radio" name="status" value="ACTIVE"   ${status=='ACTIVE'   ?'checked':''} onchange="filterForm.submit()"> Active</label>
                        <label class="dropdown-item" style="cursor:pointer;gap:10px;"><input type="radio" name="status" value="INACTIVE" ${status=='INACTIVE' ?'checked':''} onchange="filterForm.submit()"> Inactive</label>
                        <label class="dropdown-item" style="cursor:pointer;gap:10px;"><input type="radio" name="status" value="EXPIRED"  ${status=='EXPIRED'  ?'checked':''} onchange="filterForm.submit()"> Expired</label>
                    </div>
                </div>

                <%-- Date range --%>
                <div class="d-flex align-items-center gap-2">
                    <div class="search-box-standalone" style="width:auto;">
                        <span class="search-icon" style="font-size:0.75rem;white-space:nowrap;">From</span>
                        <input type="date" name="fromDate" value="${fromDate}"
                               class="form-control" style="min-width:130px;"
                               onchange="filterForm.submit()">
                    </div>
                    <div class="search-box-standalone" style="width:auto;">
                        <span class="search-icon" style="font-size:0.75rem;white-space:nowrap;">To</span>
                        <input type="date" name="toDate" value="${toDate}"
                               class="form-control" style="min-width:130px;"
                               onchange="filterForm.submit()">
                    </div>
                </div>

                <button type="submit" class="btn-add">
                    <i class="fa-solid fa-magnifying-glass"></i> Search
                </button>
            </div>
        </div>
    </form>

    <%-- Promotion Table --%>
    <div class="data-table-card">
        <div class="table-responsive">
            <table class="table table-hover align-middle">
                <thead>
                    <tr class="thead-row">
                        <th class="th-cell">Promo Code <i class="fa-solid fa-sort ms-1"></i></th>
                        <th class="th-cell">Promotion Name <i class="fa-solid fa-sort ms-1"></i></th>
                        <th class="th-cell">Start Date</th>
                        <th class="th-cell">End Date</th>
                        <th class="th-cell">Status</th>
                        <th class="th-cell text-end">Actions</th>
                    </tr>
                </thead>
                <tbody>
                <c:forEach var="promo" items="${promotions}">
                    <tr>
                        <td class="td-cell fw-medium text-muted" style="font-family:monospace;font-size:0.82rem;">#${promo.promotionId}</td>
                        <td class="td-cell fw-bold text-1">${promo.promoName}</td>
                        <td class="td-cell text-muted">${promo.startDate.toString().substring(0, 10)}</td>
                        <td class="td-cell text-muted">${promo.endDate.toString().substring(0, 10)}</td>
                        <td class="td-cell">
                            <c:choose>
                                <c:when test="${promo.status == 'ACTIVE'}"><span class="badge-active">Active</span></c:when>
                                <c:when test="${promo.status == 'EXPIRED'}"><span class="badge-expired">Expired</span></c:when>
                                <c:otherwise><span class="badge-inactive">Inactive</span></c:otherwise>
                            </c:choose>
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
                                        <a class="dropdown-item" href="/promotion/detail?id=${promo.promotionId}">
                                            <i class="fa-solid fa-eye text-warning"></i> View Details
                                        </a>
                                    </li>
                                    <li>
                                        <a class="dropdown-item" href="#"
                                           onclick="openEditPromotionModal('${promo.promotionId}','${promo.promoName}','${promo.status}','${promo.startDate}','${promo.endDate}')">
                                            <i class="fa-solid fa-pen-to-square text-primary"></i> Edit
                                        </a>
                                    </li>
                                    <li>
                                        <c:choose>
                                            <c:when test="${promo.status == 'ACTIVE'}">
                                                <a class="dropdown-item" href="/promotion/status?id=${promo.promotionId}&status=INACTIVE"
                                                   onclick="return confirm('Pause this promotion?')">
                                                    <i class="fa-solid fa-pause text-secondary"></i> Set Inactive
                                                </a>
                                            </c:when>
                                            <c:when test="${promo.status == 'INACTIVE'}">
                                                <a class="dropdown-item" href="/promotion/status?id=${promo.promotionId}&status=ACTIVE"
                                                   onclick="return confirm('Activate this promotion?')">
                                                    <i class="fa-solid fa-play text-success"></i> Set Active
                                                </a>
                                            </c:when>
                                        </c:choose>
                                    </li>
                                    <li><hr class="dropdown-divider mx-2"></li>
                                    <li>
                                        <a class="dropdown-item text-danger" href="#"
                                           onclick="confirmDelete('/promotion/delete?id=${promo.promotionId}','this promotion')">
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

<%-- Add Promotion --%>
<div class="modal fade" id="addPromotionModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content border-0 shadow" style="border-radius:16px;">
            <div class="modal-header border-0 pb-0 mt-2 mx-2">
                <h5 class="modal-title fw-bold fs-4">Add Promotion</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form action="/promotion/add" method="post" onsubmit="return validatePromotionForm(this)">
                <div class="modal-body pt-3 px-4">
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label fw-bold text-muted small">Name:</label>
                            <input type="text" name="promoName" class="form-control py-2" placeholder="Enter promotion name..." required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-bold text-muted small">Status:</label>
                            <select name="status" class="form-select py-2">
                                <option value="ACTIVE">Active</option>
                                <option value="INACTIVE">Inactive</option>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-bold text-muted small">Start Date:</label>
                            <input type="date" name="startDate" class="form-control py-2" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-bold text-muted small">End Date:</label>
                            <input type="date" name="endDate" class="form-control py-2" required>
                        </div>
                    </div>
                    <div class="d-flex gap-2 mt-4 mb-2">
                        <button type="submit" class="btn text-white w-50 py-2 fw-bold" style="background-color:#2563eb;border-radius:8px;">Confirm</button>
                        <button type="button" class="btn btn-light w-50 py-2 fw-bold border" style="border-radius:8px;" data-bs-dismiss="modal">Cancel</button>
                    </div>
                </div>
            </form>
        </div>
    </div>
</div>

<%-- Edit Promotion --%>
<div class="modal fade" id="editPromotionModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content border-0 shadow" style="border-radius:16px;">
            <div class="modal-header border-0 pb-0 mt-2 mx-2">
                <h5 class="modal-title fw-bold fs-4">Edit Promotion</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form action="/promotion/update" method="post" onsubmit="return validatePromotionForm(this)">
                <div class="modal-body pt-3 px-4">
                    <input type="hidden" id="editPromoId" name="promotionId">
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label fw-bold text-muted small">Name:</label>
                            <input type="text" id="editPromoName" name="promoName" class="form-control py-2" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-bold text-muted small">Status:</label>
                            <select id="editStatus" name="status" class="form-select py-2">
                                <option value="ACTIVE">Active</option>
                                <option value="INACTIVE">Inactive</option>
                                <option value="EXPIRED">Expired</option>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-bold text-muted small">Start Date:</label>
                            <input type="date" id="editStartDate" name="startDate" class="form-control py-2" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-bold text-muted small">End Date:</label>
                            <input type="date" id="editEndDate" name="endDate" class="form-control py-2" required>
                        </div>
                    </div>
                    <div class="d-flex gap-2 mt-4 mb-2">
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
