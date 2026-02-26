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

    <link href="${pageContext.request.contextPath}/resources/css/customer/customer1.css" rel="stylesheet">
</head>
<body>

<jsp:include page="../layer/header.jsp" />
<jsp:include page="../layer/sidebar.jsp" />

<div class="main-content">

    <c:if test="${not empty error}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="fa-solid fa-triangle-exclamation me-2"></i> ${error}
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        </c:if>

        <c:if test="${not empty success}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="fa-solid fa-check-circle me-2"></i> ${success}
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        </c:if>

    <div class="d-flex justify-content-between align-items-end mb-4">
        <div>
            <h2 class="fw-bold mb-1">Customer Management</h2>
            <span class="text-muted">Manage your customer data and loyalty points</span>
        </div>
        <div class="d-flex gap-2">
            <button class="btn btn-primary px-4 fw-medium" style="background-color: #0B4984;" onclick="openConfigModal()">
                <i class="fa-solid fa-gear me-2"></i>Config Point
            </button>
            <button class="btn btn-primary px-4 fw-medium" style="background-color: #0d6efd;" data-bs-toggle="modal" data-bs-target="#addCustomerModal">
                <i class="fa-solid fa-plus me-2"></i>Add Customer
            </button>
        </div>
    </div>

    <div class="row g-4 mb-5">
        <div class="col-md-3">
            <div class="stat-card">
            <i class="fa-solid fa-users stat-icon"></i>
                <div class="stat-title mb-2">Total Customer</div>
                <div class="stat-value text-1">${totalCustomer}</div>
                <div class="small text-muted mt-1">Active customers in system</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card">
            <i class="fa-solid fa-star stat-icon"></i>
                <div class="stat-title mb-2">Accumulated Points</div>
                <div class="stat-value text-2"><fmt:formatNumber value="${totalPoints}" /></div>
                <div class="small text-muted mt-1">Total loyalty points</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card">
            <i class="fa-solid fa-money-bill-wave stat-icon"></i>
                <div class="stat-title mb-2">Total Spending</div>
                <div class="stat-value text-3">
                    <fmt:formatNumber value="${totalSpending}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                </div>
                <div class="small text-muted mt-1">Revenue from customers</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card">
            <i class="fa-solid fa-chart-line stat-icon"></i>
                <div class="stat-title mb-2">Avg. Spending</div>
                <div class="stat-value text-4">
                    <fmt:formatNumber value="${avgSpending}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                </div>
                <div class="small text-muted mt-1">Per customer average</div>
            </div>
        </div>
    </div>

    <div class="card shadow-sm border-0">
        <div class="card-body p-4">

            <form action="/customer" method="get" id="filterForm">
                <div class="row g-3 mb-4">

                    <div class="col-md-4">
                        <div class="input-group">
                            <span class="input-group-text bg-white border-end-0">
                                <i class="fa-solid fa-magnifying-glass text-muted"></i>
                            </span>
                            <input type="text" name="keyword" value="${keyword}"
                                   class="form-control border-start-0"
                                   placeholder="Search name or phone...">
                        </div>
                    </div>

                    <div class="col-md-2">
                        <select name="minPoint" class="form-select">
                            <option value="">All score</option>
                            <option value="200"  ${minPoint == 200 ? 'selected' : ''}>>= 200 points</option>
                            <option value="500"  ${minPoint == 500 ? 'selected' : ''}>>= 500 points</option>
                            <option value="1000" ${minPoint == 1000 ? 'selected' : ''}>>= 1000 points</option>
                            <option value="2000" ${minPoint == 2000 ? 'selected' : ''}>>= 2000 points</option>
                            <option value="5000" ${minPoint == 5000 ? 'selected' : ''}>>= 5000 points</option>
                        </select>
                    </div>

                    <div class="col-md-2">
                        <select name="status" class="form-select">
                            <option value="">All status</option>
                            <option value="1" ${status == 1 ? 'selected' : ''}>Active</option>
                            <option value="0" ${status == 0 ? 'selected' : ''}>Inactive</option>
                        </select>
                    </div>

                    <div class="col-md-3 ms-auto">
                        <select name="timePeriod" class="form-select">
                            <option value="">All time</option>
                            <option value="month" ${timePeriod == 'month' ? 'selected' : ''}>This Month</option>
                            <option value="year"  ${timePeriod == 'year' ? 'selected' : ''}>This Year</option>
                            <option value="last_30_days" ${timePeriod == 'last_30_days' ? 'selected' : ''}>Last 30 Days</option>
                        </select>
                    </div>

                </div>
            </form>

            <div class="table-responsive">
                <table class="table table-hover align-middle">
                    <thead class="bg-light">
                    <tr>
                        <th class="py-3 ps-3">Code</th>
                        <th class="py-3">Customer Name</th>
                        <th class="py-3">Phone</th>
                        <th class="py-3">Points</th>
                        <th class="py-3">Spending</th>
                        <th class="py-3">Last Purchase</th>
                        <th class="py-3">Status</th>
                        <th class="py-3 text-end pe-3">Action</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach var="cust" items="${customers}">
                        <tr>
                            <td class="ps-3 fw-medium text-muted">#${cust.customerId}</td>
                            <td>
                                <div class="d-flex align-items-center">
                                    <div class="bg-light rounded-circle d-flex align-items-center justify-content-center me-2 fw-bold text-primary" style="width: 32px; height: 32px;">
                                            ${cust.fullName.charAt(0)}
                                    </div>
                                    <span class="fw-bold text-dark">${cust.fullName}</span>
                                </div>
                            </td>
                            <td class="text-1">${cust.phoneNumber}</td>
                            <td class="fw-bold text-warning">${cust.currentPoint}</td>
                            <td class="fw-bold text-3">
                                <fmt:formatNumber value="${cust.totalSpending}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                            </td>
                            <td class="text-muted">
                                    ${cust.lastTransactionDate != null ? cust.lastTransactionDate.toString().substring(0, 10) : '-'}
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${cust.status == 1}"><span class="badge-active">Active</span></c:when>
                                    <c:otherwise><span class="badge-inactive">Inactive</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td class="text-end pe-3">
                                <div class="dropdown">
                                    <button class="btn btn-sm btn-light border rounded-circle" type="button"
                                    data-bs-toggle="dropdown"
                                    data-bs-boundary="window"
                                    data-bs-popper-config='{"strategy":"fixed"}'>
                                        <i class="fa-solid fa-ellipsis"></i>
                                    </button>
                                    <ul class="dropdown-menu dropdown-menu-end border-0 shadow">
                                        <li>
                                            <a class="dropdown-item py-2" href="#"
                                               onclick="openDetailModal('${cust.customerId}', '${cust.fullName}', '${cust.phoneNumber}', '${cust.currentPoint}', '${cust.totalSpending}', '${cust.lastTransactionDate}')">
                                                <i class="fa-solid fa-circle-info text-info me-2"></i> Detail
                                            </a>
                                        </li>

                                        <li>
                                            <a class="dropdown-item py-2" href="#"
                                               onclick="openEditModal('${cust.customerId}', '${cust.fullName}', '${cust.phoneNumber}', '${cust.status}', '${cust.currentPoint}')">
                                                <i class="fa-solid fa-pen-to-square text-primary me-2"></i> Edit
                                            </a>
                                        </li>

                                        <li>
                                            <a class="dropdown-item py-2 text-danger" href="#"
                                               onclick="confirmDelete('${cust.customerId}', '${cust.fullName}')">
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

<div class="modal fade" id="addCustomerModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow">

            <div class="modal-header border-0 pb-0">
                <h5 class="modal-title fw-bold fs-4">Add customer</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>

            <form action="/customer/add" method="post">
                <div class="modal-body pt-2">

                    <div class="mb-3">
                        <label class="form-label fw-medium text-secondary">Name:</label>
                        <input type="text" class="form-control rounded-3 py-2"
                               name="fullName" placeholder="Input name..." required>
                    </div>

                    <div class="mb-3">
                        <label class="form-label fw-medium text-secondary">Phone number:</label>
                        <input type="text" class="form-control rounded-3 py-2"
                               name="phoneNumber" placeholder="Phone number..." required>
                    </div>

                    <div class="mb-4">
                        <label class="form-label fw-medium text-secondary">Status:</label>
                        <select class="form-select rounded-3 py-2" name="status">
                            <option value="1" selected>Active</option>
                            <option value="0">Inactive</option>
                        </select>
                    </div>

                    <div class="d-flex gap-2">
                        <button type="submit" class="btn text-white w-50 py-2 fw-bold rounded-3"
                                style="background-color: #2e8b57;">
                            Confirm
                        </button>

                        <button type="button" class="btn text-white w-50 py-2 fw-bold rounded-3"
                                style="background-color: #b20000;"
                                data-bs-dismiss="modal">
                            Cancel
                        </button>
                    </div>

                </div>
            </form>

        </div>
    </div>
</div>

<div class="modal fade" id="configPointModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow">

            <div class="modal-header border-0 pb-0">
                <h5 class="modal-title fw-bold fs-4">Point Configuration <i class="fa-solid fa-gear ms-2 text-muted" style="font-size: 1rem;"></i></h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>

            <form action="/customer/config/update" method="post">
                <div class="modal-body pt-2">
                    <p class="text-muted small mb-3">Set up rules for earning and redeeming loyalty points.</p>

                    <h6 class="fw-bold mb-2">Accumulate Points:</h6>
                    <div class="mb-3">
                        <label class="form-label text-secondary small mb-1">For each invoice:</label>
                        <div class="d-flex align-items-center bg-light p-2 rounded-3">
                            <input type="number" name="earningRate" id="confEarning"
                                   class="form-control fw-bold text-center border-0 py-2 shadow-sm"
                                   style="background-color: #fff9c4; width: 120px; color: #333;" required>
                            <span class="fw-bold mx-3">VNĐ &nbsp; = &nbsp; 1 Point</span>
                        </div>
                    </div>

                    <hr class="text-muted opacity-25 my-3">

                    <h6 class="fw-bold mb-2">Deduct Point & Redemption:</h6>

                    <div class="mb-3">
                        <label class="form-label text-secondary small mb-1">Each point in the account:</label>
                        <div class="d-flex align-items-center bg-light p-2 rounded-3">
                            <span class="fw-bold me-3">1 Point &nbsp; = </span>
                            <input type="number" name="redemptionValue" id="confRedemption"
                                   class="form-control fw-bold text-center border-0 py-2 shadow-sm"
                                   style="background-color: #fff9c4; width: 120px; color: #333;" required>
                            <span class="fw-bold ms-3">VNĐ</span>
                        </div>
                    </div>

                    <div class="mb-3">
                        <label class="form-label text-secondary small mb-1">Max payment percentage by points:</label>
                        <div class="d-flex align-items-center bg-light p-2 rounded-3">
                            <input type="number" name="maxRedeemPercent" id="confMaxPercent"
                                   class="form-control fw-bold text-center border-0 py-2 shadow-sm"
                                   style="background-color: #fff9c4; width: 120px; color: #333;" max="100" required>
                            <span class="fw-bold mx-3">% of Total Bill</span>
                        </div>
                    </div>

                    <div class="mb-4">
                        <label class="form-label text-secondary small mb-1">Min points required to redeem:</label>
                        <div class="d-flex align-items-center bg-light p-2 rounded-3">
                            <input type="number" name="minPointRedeem" id="confMinPoint"
                                   class="form-control fw-bold text-center border-0 py-2 shadow-sm"
                                   style="background-color: #fff9c4; width: 120px; color: #333;" required>
                            <span class="fw-bold mx-3">Points</span>
                        </div>
                    </div>

                    <div class="d-flex gap-2 pt-2">
                        <button type="submit" class="btn text-white w-50 py-2 fw-bold rounded-3"
                                style="background-color: #2e8b57;">Confirm</button>
                        <button type="button" class="btn text-white w-50 py-2 fw-bold rounded-3"
                                style="background-color: #b20000;" data-bs-dismiss="modal">Cancel</button>
                    </div>
                </div>
            </form>
        </div>
    </div>
</div>

<div class="modal fade" id="editCustomerModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow">

            <div class="modal-header border-0 pb-0">
                <h5 class="modal-title fw-bold fs-4">Edit customer <i class="fa-solid fa-right-from-bracket ms-2 text-muted" style="font-size: 1rem;"></i></h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>

            <form action="/customer/update" method="post">
                <div class="modal-body pt-2">
                    <input type="hidden" id="editId" name="customerId">

                    <div class="mb-3">
                        <label class="form-label fw-medium text-secondary">Name:</label>
                        <input type="text" class="form-control rounded-3 py-2" id="editName" name="fullName" required>
                    </div>

                    <div class="mb-3">
                        <label class="form-label fw-medium text-secondary">Phone number:</label>
                        <input type="text" class="form-control rounded-3 py-2" id="editPhone" name="phoneNumber" required>
                    </div>

                    <div class="mb-3">
                        <label class="form-label fw-medium text-secondary">Status:</label>
                        <select class="form-select rounded-3 py-2" id="editStatus" name="status">
                            <option value="1">Active</option>
                            <option value="0">Inactive</option>
                        </select>
                    </div>

                    <div class="mb-4">
                        <label class="form-label fw-medium text-secondary">Point:</label>
                        <input type="number" class="form-control rounded-3 py-2" id="editPoint" name="currentPoint">
                    </div>

                    <div class="d-flex gap-2">
                        <button type="submit" class="btn text-white w-50 py-2 fw-bold rounded-3"
                                style="background-color: #2e8b57;">Confirm</button>
                        <button type="button" class="btn text-white w-50 py-2 fw-bold rounded-3"
                                style="background-color: #b20000;" data-bs-dismiss="modal">Cancel</button>
                    </div>
                </div>
            </form>
        </div>
    </div>
</div>

<div class="modal fade" id="detailCustomerModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content border-0 shadow" style="border-radius: 15px;">

            <div class="modal-header border-0 pb-0">
                <h5 class="modal-title fw-bold fs-4">Customer detail <i class="fa-solid fa-right-from-bracket ms-2 text-muted fs-6"></i></h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>

            <div class="modal-body">
                <ul class="nav nav-pills nav-fill mb-4 p-1 rounded-pill" id="detailTab" role="tablist">
                    <li class="nav-item"><button class="nav-link active rounded-pill" data-bs-toggle="pill" data-bs-target="#personal-info">Personal information</button></li>
                    <li class="nav-item"><button class="nav-link rounded-pill" data-bs-toggle="pill" data-bs-target="#point-info">Point</button></li>
                    <li class="nav-item"><button class="nav-link rounded-pill" data-bs-toggle="pill" data-bs-target="#history-info">Transaction history</button></li>
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
                            <div class="col-md-6"><div class="p-3 rounded-3" style="background-color: #fffacd;"><div class="fw-medium mb-2"><i class="fa-solid fa-gift me-2"></i>Current point</div><div class="fw-bold fs-4" id="detailPoint">0</div></div></div>
                            <div class="col-md-6"><div class="p-3 rounded-3" style="background-color: #d1e7dd;"><div class="fw-medium mb-2"><i class="fa-solid fa-money-bill-wave me-2"></i>Total spending</div><div class="fw-bold fs-4" id="detailSpending">0 đ</div></div></div>
                            <div class="col-md-6"><div class="p-3 rounded-3" style="background-color: #e0f7fa;"><div class="fw-medium mb-2"><i class="fa-solid fa-clock-rotate-left me-2"></i>Last purchase</div><div class="fw-bold fs-4" id="detailLastDate">-</div></div></div>
                            <div class="col-md-6"><div class="p-3 rounded-3" style="background-color: #f3e5f5;"><div class="fw-medium mb-2"><i class="fa-solid fa-basket-shopping me-2"></i>Total order</div><div class="fw-bold fs-4" id="detailTotalOrder">0</div></div></div>
                        </div>
                    </div>

                    <div class="tab-pane fade" id="history-info">
                        <h6 class="mb-3 text-muted">Transaction history</h6>
                        <table class="table table-borderless">
                            <thead class="text-muted border-bottom">
                                <tr><th>OrderID</th><th>Date</th><th>Point</th><th class="text-end">Total Amount</th></tr>
                            </thead>
                            <tbody></tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

<script src="${pageContext.request.contextPath}/resources/js/customer/customer.js"></script>

</body>
</html>