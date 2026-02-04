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

    <style>
        body { background-color: #f8f9fa; font-family: 'Segoe UI', sans-serif; }

        /* Layout Adjustment */
        .main-content {
            margin-top: 70px; /* Né Header */
            margin-left: 80px; /* Né Sidebar (khi thu gọn) */
            padding: 30px;
            transition: margin-left 0.3s;
        }

        /* Stats Card Style */
        .stat-card { background-color: #e9ecef; border: none; border-radius: 12px; padding: 20px; height: 100%; transition: transform 0.2s; }
        .stat-card:hover { transform: translateY(-5px); box-shadow: 0 4px 15px rgba(0,0,0,0.1); }
        .stat-value { font-size: 1.8rem; font-weight: bold; color: #212529; }
        .stat-title { font-size: 0.9rem; font-weight: 600; color: #495057; }

        /* Table Style */
        .badge-active { background-color: #198754; color: white; padding: 5px 12px; border-radius: 20px; font-size: 0.8rem; }
        .badge-inactive { background-color: #ffc107; color: #000; padding: 5px 12px; border-radius: 20px; font-size: 0.8rem; }
    </style>
</head>
<body>

<jsp:include page="../layer/header.jsp" />

<jsp:include page="../layer/sidebar.jsp" />

<div class="main-content">

    <div class="d-flex justify-content-between align-items-end mb-4">
        <div>
            <h2 class="fw-bold mb-1">Customer Management</h2>
            <span class="text-muted">Manage your customer data and loyalty points</span>
        </div>
        <div class="d-flex gap-2">
            <button class="btn btn-primary px-4 fw-medium" style="background-color: #0d6efd;" data-bs-toggle="modal" data-bs-target="#configPointModal">
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
                <div class="stat-title mb-2">Total Customer</div>
                <div class="stat-value">${totalCustomer}</div>
                <div class="small text-muted mt-1">Active customers in system</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-title mb-2">Accumulated Points</div>
                <div class="stat-value"><fmt:formatNumber value="${totalPoints}" /></div>
                <div class="small text-muted mt-1">Total loyalty points</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-title mb-2">Total Spending</div>
                <div class="stat-value">
                    <fmt:formatNumber value="${totalSpending}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                </div>
                <div class="small text-muted mt-1">Revenue from customers</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-title mb-2">Avg. Spending</div>
                <div class="stat-value">
                    <fmt:formatNumber value="${avgSpending}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                </div>
                <div class="small text-muted mt-1">Per customer average</div>
            </div>
        </div>
    </div>

    <div class="card shadow-sm border-0">
        <div class="card-body p-4">

            <div class="row g-3 mb-4">
                <div class="col-md-4">
                    <form action="/customers" method="get">
                        <div class="input-group">
                <span class="input-group-text bg-white border-end-0">
                    <i class="fa-solid fa-magnifying-glass text-muted"></i>
                </span>

                            <input type="text"
                                   name="keyword"
                                   value="${keyword}"
                                   class="form-control border-start-0"
                                   placeholder="Search name or phone..."
                                   onchange="this.form.submit()"> </div>
                    </form>
                </div>
                <div class="col-md-2">
                    <select class="form-select">
                        <option>Filter by Score</option>
                    </select>
                </div>
                <div class="col-md-2">
                    <select class="form-select">
                        <option>Status: All</option>
                    </select>
                </div>
                <div class="col-md-3 ms-auto">
                    <select class="form-select">
                        <option>Time: This Month</option>
                    </select>
                </div>
            </div>

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
                            <td>${cust.phoneNumber}</td>
                            <td class="fw-bold text-warning">${cust.currentPoint}</td>
                            <td class="fw-bold">
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
                                <button class="btn btn-sm btn-light border"><i class="fa-solid fa-ellipsis"></i></button>
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
    <div class="modal-dialog modal-dialog-centered modal-lg"> <div class="modal-content">
        <div class="modal-header">
            <h5 class="modal-title fw-bold">Add New Customer</h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
        </div>
        <div class="modal-body">
            <div class="text-center py-5 text-muted">
                <i class="fa-solid fa-person-digging fs-1 mb-3"></i>
                <p>Giao diện nhập thông tin khách hàng sẽ ở đây.</p>
                <p class="small">(Chức năng đang được xây dựng...)</p>
            </div>
        </div>
        <div class="modal-footer">
            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
            <button type="button" class="btn btn-primary">Save Customer</button>
        </div>
    </div>
    </div>
</div>

<div class="modal fade" id="configPointModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title fw-bold">Point Configuration</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <div class="alert alert-info">
                    Cấu hình quy đổi điểm thưởng.
                </div>
                <div class="mb-3">
                    <label class="form-label">Tỷ lệ quy đổi (VND sang Điểm)</label>
                    <input type="text" class="form-control" value="10,000 VND = 1 Point" disabled>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                <button type="button" class="btn btn-primary">Update Config</button>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>