<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Customer Management</title>
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
            <h2 class="fw-bold mb-0">Customer Management</h2>
            <small class="text-muted">Manage customer data and loyalty points</small>
        </div>
        <div class="d-flex gap-2">
            <button class="btn-add" style="background-color:#0B4984 !important;" onclick="openConfigModal()">
                <i class="fa-solid fa-gear"></i> Config Point
            </button>
            <button class="btn-add" data-bs-toggle="modal" data-bs-target="#addCustomerModal">
                <i class="fa-solid fa-plus"></i> Add Customer
            </button>
        </div>
    </div>

    <%-- Stat Cards --%>
    <div class="row g-4">
        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-card-header">
                    <div class="stat-card-info">
                        <div class="stat-title">Total Customers</div>
                        <div class="stat-value text-1">${totalCustomer}</div>
                    </div>
                    <div class="stat-card-icon stat-icon-blue"><i class="fa-solid fa-users"></i></div>
                </div>
                <div class="stat-sub">Active customers in system</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-card-header">
                    <div class="stat-card-info">
                        <div class="stat-title">Accumulated Points</div>
                        <div class="stat-value text-2"><fmt:formatNumber value="${totalPoints}" /></div>
                    </div>
                    <div class="stat-card-icon stat-icon-yellow"><i class="fa-solid fa-star"></i></div>
                </div>
                <div class="stat-sub">Total loyalty points</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-card-header">
                    <div class="stat-card-info">
                        <div class="stat-title">Total Spending</div>
                        <div class="stat-value text-4">
                            <fmt:formatNumber value="${totalSpending}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                        </div>
                    </div>
                    <div class="stat-card-icon stat-icon-green"><i class="fa-solid fa-money-bill-wave"></i></div>
                </div>
                <div class="stat-sub">Revenue from customers</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-card-header">
                    <div class="stat-card-info">
                        <div class="stat-title">Avg. Spending</div>
                        <div class="stat-value text-3">
                            <fmt:formatNumber value="${avgSpending}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                        </div>
                    </div>
                    <div class="stat-card-icon stat-icon-cyan"><i class="fa-solid fa-chart-line"></i></div>
                </div>
                <div class="stat-sub">Per customer average</div>
            </div>
        </div>
    </div>

    <%-- Filter Bar --%>
    <form action="/customer" method="get" id="filterForm">
        <div class="filter-bar">
            <div class="search-box-standalone">
                <i class="fa-solid fa-magnifying-glass search-icon"></i>
                <input type="text" name="keyword" value="${keyword}"
                       class="form-control" placeholder="Search name or phone...">
            </div>

            <div class="filter-actions">
                <%-- Points filter --%>
                <div class="dropdown">
                    <button class="btn-filter" type="button" data-bs-toggle="dropdown" data-bs-auto-close="outside">
                        <span>${empty minPoint ? 'All Points' : '>= '.concat(minPoint).concat(' pts')}</span>
                        <i class="fa-solid fa-chevron-down"></i>
                    </button>
                    <div class="dropdown-menu shadow border-0 p-2">
                        <c:forEach var="pt" items="200,500,1000,2000,5000"><%-- label only --%></c:forEach>
                        <label class="dropdown-item" style="cursor:pointer;gap:10px;"><input type="radio" name="minPoint" value="" ${empty minPoint ? 'checked':''} onchange="filterForm.submit()"> All Points</label>
                        <label class="dropdown-item" style="cursor:pointer;gap:10px;"><input type="radio" name="minPoint" value="200"  ${minPoint==200  ?'checked':''} onchange="filterForm.submit()"> &ge; 200 pts</label>
                        <label class="dropdown-item" style="cursor:pointer;gap:10px;"><input type="radio" name="minPoint" value="500"  ${minPoint==500  ?'checked':''} onchange="filterForm.submit()"> &ge; 500 pts</label>
                        <label class="dropdown-item" style="cursor:pointer;gap:10px;"><input type="radio" name="minPoint" value="1000" ${minPoint==1000 ?'checked':''} onchange="filterForm.submit()"> &ge; 1000 pts</label>
                        <label class="dropdown-item" style="cursor:pointer;gap:10px;"><input type="radio" name="minPoint" value="2000" ${minPoint==2000 ?'checked':''} onchange="filterForm.submit()"> &ge; 2000 pts</label>
                        <label class="dropdown-item" style="cursor:pointer;gap:10px;"><input type="radio" name="minPoint" value="5000" ${minPoint==5000 ?'checked':''} onchange="filterForm.submit()"> &ge; 5000 pts</label>
                    </div>
                </div>

                <%-- Status filter --%>
                <div class="dropdown">
                    <button class="btn-filter" type="button" data-bs-toggle="dropdown" data-bs-auto-close="outside">
                        <span>${empty status ? 'All Status' : (status == 1 ? 'Active' : 'Inactive')}</span>
                        <i class="fa-solid fa-chevron-down"></i>
                    </button>
                    <div class="dropdown-menu shadow border-0 p-2">
                        <label class="dropdown-item" style="cursor:pointer;gap:10px;"><input type="radio" name="status" value=""  ${empty status ?'checked':''} onchange="filterForm.submit()"> All Status</label>
                        <label class="dropdown-item" style="cursor:pointer;gap:10px;"><input type="radio" name="status" value="1" ${status==1 ?'checked':''} onchange="filterForm.submit()"> Active</label>
                        <label class="dropdown-item" style="cursor:pointer;gap:10px;"><input type="radio" name="status" value="0" ${status==0 ?'checked':''} onchange="filterForm.submit()"> Inactive</label>
                    </div>
                </div>

                <%-- Time filter --%>
                <div class="dropdown">
                    <button class="btn-filter" type="button" data-bs-toggle="dropdown" data-bs-auto-close="outside">
                        <span>${empty timePeriod ? 'All Time' : timePeriod}</span>
                        <i class="fa-solid fa-chevron-down"></i>
                    </button>
                    <div class="dropdown-menu shadow border-0 p-2">
                        <label class="dropdown-item" style="cursor:pointer;gap:10px;"><input type="radio" name="timePeriod" value=""            ${empty timePeriod ?'checked':''} onchange="filterForm.submit()"> All Time</label>
                        <label class="dropdown-item" style="cursor:pointer;gap:10px;"><input type="radio" name="timePeriod" value="month"        ${timePeriod=='month' ?'checked':''} onchange="filterForm.submit()"> This Month</label>
                        <label class="dropdown-item" style="cursor:pointer;gap:10px;"><input type="radio" name="timePeriod" value="year"         ${timePeriod=='year' ?'checked':''} onchange="filterForm.submit()"> This Year</label>
                        <label class="dropdown-item" style="cursor:pointer;gap:10px;"><input type="radio" name="timePeriod" value="last_30_days" ${timePeriod=='last_30_days' ?'checked':''} onchange="filterForm.submit()"> Last 30 Days</label>
                    </div>
                </div>

                <button type="submit" class="btn-add">
                    <i class="fa-solid fa-magnifying-glass"></i> Search
                </button>
            </div>
        </div>
    </form>

    <%-- Customer Table --%>
    <div class="data-table-card">
        <div class="table-responsive">
            <table class="table table-hover align-middle">
                <thead>
                    <tr class="thead-row">
                        <th class="th-cell">Code</th>
                        <th class="th-cell">Customer Name</th>
                        <th class="th-cell">Phone</th>
                        <th class="th-cell">Points</th>
                        <th class="th-cell">Spending</th>
                        <th class="th-cell">Last Purchase</th>
                        <th class="th-cell">Status</th>
                        <th class="th-cell text-end">Actions</th>
                    </tr>
                </thead>
                <tbody>
                <c:forEach var="cust" items="${customers}">
                    <tr>
                        <td class="td-cell fw-medium text-muted" style="font-family:monospace;font-size:0.82rem;">#${cust.customerId}</td>
                        <td class="td-cell">
                            <div class="d-flex align-items-center gap-3">
                                <div class="d-flex align-items-center justify-content-center rounded-circle fw-bold text-white"
                                     style="width:36px;height:36px;background-color:#2563eb;font-size:0.9rem;flex-shrink:0;">
                                    ${cust.fullName.charAt(0)}
                                </div>
                                <span class="fw-bold text-dark">${cust.fullName}</span>
                            </div>
                        </td>
                        <td class="td-cell text-muted">${cust.phoneNumber}</td>
                        <td class="td-cell fw-bold text-2">${cust.currentPoint}</td>
                        <td class="td-cell fw-bold text-4">
                            <fmt:formatNumber value="${cust.totalSpending}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                        </td>
                        <td class="td-cell text-muted">
                            ${cust.lastTransactionDate != null ? cust.lastTransactionDate.toString().substring(0, 10) : '-'}
                        </td>
                        <td class="td-cell">
                            <c:choose>
                                <c:when test="${cust.status == 1}"><span class="badge-active">Active</span></c:when>
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
                                        <a class="dropdown-item" href="#"
                                           onclick="openDetailModal('${cust.customerId}','${cust.fullName}','${cust.phoneNumber}','${cust.currentPoint}','${cust.totalSpending}','${cust.lastTransactionDate}')">
                                            <i class="fa-solid fa-circle-info text-info"></i> Detail
                                        </a>
                                    </li>
                                    <li>
                                        <a class="dropdown-item" href="#"
                                           onclick="openEditModal('${cust.customerId}','${cust.fullName}','${cust.phoneNumber}','${cust.status}','${cust.currentPoint}')">
                                            <i class="fa-solid fa-pen-to-square text-primary"></i> Edit
                                        </a>
                                    </li>
                                    <li><hr class="dropdown-divider mx-2"></li>
                                    <li>
                                        <a class="dropdown-item text-danger" href="#"
                                           onclick="confirmDelete('/customer/delete/${cust.customerId}','customer: ${cust.fullName}')">
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

<%-- Add Customer --%>
<div class="modal fade" id="addCustomerModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow" style="border-radius:16px;">
            <div class="modal-header border-0 pb-0 mt-2 mx-2">
                <h5 class="modal-title fw-bold fs-4">Add Customer</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form action="/customer/add" method="post">
                <div class="modal-body pt-3 px-4">
                    <div class="mb-3">
                        <label class="form-label fw-bold text-muted small">Name:</label>
                        <input type="text" class="form-control py-2" name="fullName" placeholder="Enter name..." required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-bold text-muted small">Phone Number:</label>
                        <input type="text" class="form-control py-2" name="phoneNumber" placeholder="Phone number..." required>
                    </div>
                    <div class="mb-4">
                        <label class="form-label fw-bold text-muted small">Status:</label>
                        <select class="form-select py-2" name="status">
                            <option value="1" selected>Active</option>
                            <option value="0">Inactive</option>
                        </select>
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

<%-- Edit Customer --%>
<div class="modal fade" id="editCustomerModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow" style="border-radius:16px;">
            <div class="modal-header border-0 pb-0 mt-2 mx-2">
                <h5 class="modal-title fw-bold fs-4">Edit Customer</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form action="/customer/update" method="post">
                <div class="modal-body pt-3 px-4">
                    <input type="hidden" id="editId" name="customerId">
                    <div class="mb-3">
                        <label class="form-label fw-bold text-muted small">Name:</label>
                        <input type="text" class="form-control py-2" id="editName" name="fullName" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-bold text-muted small">Phone Number:</label>
                        <input type="text" class="form-control py-2" id="editPhone" name="phoneNumber" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-bold text-muted small">Status:</label>
                        <select class="form-select py-2" id="editStatus" name="status">
                            <option value="1">Active</option>
                            <option value="0">Inactive</option>
                        </select>
                    </div>
                    <div class="mb-4">
                        <label class="form-label fw-bold text-muted small">Points:</label>
                        <input type="number" class="form-control py-2" id="editPoint" name="currentPoint">
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

<%-- Config Point --%>
<div class="modal fade" id="configPointModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow" style="border-radius:16px;">
            <div class="modal-header border-0 pb-0 mt-2 mx-2">
                <h5 class="modal-title fw-bold fs-4">Point Configuration <i class="fa-solid fa-gear ms-2 text-muted" style="font-size:1rem;"></i></h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form action="/customer/config/update" method="post">
                <div class="modal-body pt-3 px-4">
                    <p class="text-muted small mb-3">Set up rules for earning and redeeming loyalty points.</p>
                    <h6 class="fw-bold mb-2">Accumulate Points:</h6>
                    <div class="mb-3">
                        <label class="form-label text-muted small">For each invoice:</label>
                        <div class="d-flex align-items-center bg-light p-2 rounded-3">
                            <input type="number" name="earningRate" id="confEarning"
                                   class="form-control fw-bold text-center border-0 py-2 shadow-sm"
                                   style="background-color:#fff9c4;width:120px;" required>
                            <span class="fw-bold mx-3">VNĐ = 1 Point</span>
                        </div>
                    </div>
                    <hr class="opacity-25 my-3">
                    <h6 class="fw-bold mb-2">Deduct Point & Redemption:</h6>
                    <div class="mb-3">
                        <label class="form-label text-muted small">Each point equals:</label>
                        <div class="d-flex align-items-center bg-light p-2 rounded-3">
                            <span class="fw-bold me-3">1 Point =</span>
                            <input type="number" name="redemptionValue" id="confRedemption"
                                   class="form-control fw-bold text-center border-0 py-2 shadow-sm"
                                   style="background-color:#fff9c4;width:120px;" required>
                            <span class="fw-bold ms-3">VNĐ</span>
                        </div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label text-muted small">Max payment percentage by points:</label>
                        <div class="d-flex align-items-center bg-light p-2 rounded-3">
                            <input type="number" name="maxRedeemPercent" id="confMaxPercent"
                                   class="form-control fw-bold text-center border-0 py-2 shadow-sm"
                                   style="background-color:#fff9c4;width:120px;" max="100" required>
                            <span class="fw-bold mx-3">% of Total Bill</span>
                        </div>
                    </div>
                    <div class="mb-4">
                        <label class="form-label text-muted small">Min points required to redeem:</label>
                        <div class="d-flex align-items-center bg-light p-2 rounded-3">
                            <input type="number" name="minPointRedeem" id="confMinPoint"
                                   class="form-control fw-bold text-center border-0 py-2 shadow-sm"
                                   style="background-color:#fff9c4;width:120px;" required>
                            <span class="fw-bold mx-3">Points</span>
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

<%-- Customer Detail --%>
<div class="modal fade" id="detailCustomerModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content border-0 shadow" style="border-radius:16px;">
            <div class="modal-header border-0 pb-0 mt-2 mx-2">
                <h5 class="modal-title fw-bold fs-4">Customer Detail</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body px-4 pb-4">
                <ul class="nav nav-pills nav-fill mb-4 p-1 rounded-pill" id="detailTab" role="tablist">
                    <li class="nav-item"><button class="nav-link active rounded-pill" data-bs-toggle="pill" data-bs-target="#personal-info">Personal Information</button></li>
                    <li class="nav-item"><button class="nav-link rounded-pill" data-bs-toggle="pill" data-bs-target="#point-info">Points</button></li>
                    <li class="nav-item"><button class="nav-link rounded-pill" data-bs-toggle="pill" data-bs-target="#history-info">Transaction History</button></li>
                </ul>
                <div class="tab-content">
                    <div class="tab-pane fade show active" id="personal-info">
                        <div class="d-flex align-items-start mb-4">
                            <i class="fa-solid fa-user fs-1 me-3 text-secondary"></i>
                            <div>
                                <div class="text-muted small">Code: <span class="fw-bold text-dark" id="detailCode"></span></div>
                                <div class="fw-bold fs-5" id="detailName"></div>
                            </div>
                        </div>
                        <div class="d-flex align-items-center mb-4">
                            <i class="fa-solid fa-phone fs-4 me-3 ms-1 text-secondary"></i>
                            <div><div class="text-muted small">Phone number:</div><div class="fw-bold fs-5" id="detailPhone"></div></div>
                        </div>
                    </div>
                    <div class="tab-pane fade" id="point-info">
                        <div class="row g-3">
                            <div class="col-md-6"><div class="p-3 rounded-3" style="background-color:#fffacd;"><div class="fw-medium mb-2"><i class="fa-solid fa-gift me-2"></i>Current Points</div><div class="fw-bold fs-4" id="detailPoint">0</div></div></div>
                            <div class="col-md-6"><div class="p-3 rounded-3" style="background-color:#d1e7dd;"><div class="fw-medium mb-2"><i class="fa-solid fa-money-bill-wave me-2"></i>Total Spending</div><div class="fw-bold fs-4" id="detailSpending">0 đ</div></div></div>
                            <div class="col-md-6"><div class="p-3 rounded-3" style="background-color:#e0f7fa;"><div class="fw-medium mb-2"><i class="fa-solid fa-clock-rotate-left me-2"></i>Last Purchase</div><div class="fw-bold fs-4" id="detailLastDate">-</div></div></div>
                            <div class="col-md-6"><div class="p-3 rounded-3" style="background-color:#f3e5f5;"><div class="fw-medium mb-2"><i class="fa-solid fa-basket-shopping me-2"></i>Total Orders</div><div class="fw-bold fs-4" id="detailTotalOrder">0</div></div></div>
                        </div>
                    </div>
                    <div class="tab-pane fade" id="history-info">
                        <h6 class="mb-3 text-muted">Transaction History</h6>
                        <table class="table table-borderless">
                            <thead class="text-muted border-bottom">
                                <tr><th>Order ID</th><th>Date</th><th>Points</th><th class="text-end">Total Amount</th></tr>
                            </thead>
                            <tbody></tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<input type="hidden" id="serverSuccessMsg" value="${success}">
<input type="hidden" id="serverErrorMsg" value="${error}">
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/resources/js/customer/customer.js"></script>

</body>
</html>
