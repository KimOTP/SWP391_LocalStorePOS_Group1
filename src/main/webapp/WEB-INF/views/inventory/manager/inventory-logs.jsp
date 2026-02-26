<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Inventory Logs & Reports | LocalStorePOS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="<c:url value='/resources/css/inventory/inventory-logs.css'/>">
</head>
<body>
<jsp:include page="../../layer/header.jsp" />
<jsp:include page="../../layer/sidebar.jsp" />

<div class="main-content">
    <h2 class="fw-bold mb-4">Inventory Logs & Reports</h2>

    <div class="row g-4 mb-4">
        <div class="col-md-3">
            <div class="stat-card">
                <i class="fa-solid fa-layer-group stat-icon"></i>
                <div class="stat-title">Total Records</div>
                <div class="stat-value">${totalCount}</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card">
                <i class="fa-solid fa-arrow-down-long stat-icon"></i>
                <div class="stat-title">Stock-In</div>
                <div class="stat-value">${countSI}</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card">
                <i class="fa-solid fa-arrow-up-long stat-icon"></i>
                <div class="stat-title">Stock-Out</div>
                <div class="stat-value">${countSO}</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card">
                <i class="fa-solid fa-clipboard-check stat-icon"></i>
                <div class="stat-title">Audit Sessions</div>
                <div class="stat-value">${countAU}</div>
            </div>
        </div>
    </div>

    <div class="card shadow-sm border-0 mb-4">
        <div class="card-body p-4">
            <div class="row g-3 align-items-end">
                <div class="col-md-2">
                    <label class="small fw-bold text-muted text-uppercase mb-2">Date</label>
                    <div class="search-box">
                        <i class="fa-solid fa-calendar-day search-icon"></i>
                        <input type="date" id="dateFilter" class="form-control">
                    </div>
                </div>
                <div class="col-md-3">
                    <label class="small fw-bold text-muted text-uppercase mb-2">Staff Member</label>
                    <select id="staffFilter" class="form-select btn-filter">
                        <option value="ALL">All Staff</option>
                    </select>
                </div>
                <div class="col-md-2">
                    <label class="small fw-bold text-muted text-uppercase mb-2">Type</label>
                    <select id="typeFilter" class="form-select btn-filter">
                        <option value="ALL">All Types</option>
                        <option value="Stock-in">Stock-in</option>
                        <option value="Stock-out">Stock-out</option>
                        <option value="Audit">Audit</option>
                    </select>
                </div>
                <div class="col-md-3">
                    <label class="small fw-bold text-muted text-uppercase mb-2">Status</label>
                    <select id="statusFilter" class="form-select btn-filter">
                        <option value="ALL">All Status</option>
                        <option value="COMPLETED">Completed</option>
                        <option value="REJECTED">Rejected</option>
                        <option value="PENDING">Pending</option>
                    </select>
                </div>
                <div class="col-md-2">
                    <button class="btn btn-light w-100 fw-bold border" onclick="resetFilters()" style="height: 40px;">
                        <i class="fa-solid fa-rotate-left me-2"></i>Reset
                    </button>
                </div>
            </div>
        </div>
    </div>

    <div class="table-section shadow-sm border-0">
        <div class="table-responsive">
            <table class="table table-hover align-middle">
                <thead>
                <tr>
                    <th class="text-center" style="width: 60px;">#</th>
                    <th>Log ID</th>
                    <th>Type</th>
                    <th>Staff</th>
                    <th>Time</th>
                    <th class="text-center">Status</th>
                    <th class="text-end">Action</th>
                </tr>
                </thead>
                <tbody>
                <c:forEach items="${logList}" var="item" varStatus="loop">
                    <fmt:parseDate value="${item.time}" pattern="yyyy-MM-dd'T'HH:mm" var="parsedRowDate" />

                    <c:set var="statusKey" value="${item.statusId == 4 ? 'COMPLETED' : (item.statusId == 3 ? 'REJECTED' : 'PENDING')}" />

                    <tr class="request-row"
                        data-date="<fmt:formatDate value='${parsedRowDate}' pattern='yyyy-MM-dd' />"
                        data-staff="${item.staff}"
                        data-type="${item.type}"
                        data-status="${statusKey}">

                        <td class="text-center text-muted small">${loop.index + 1}</td>
                        <td><span class="log-id">#${item.prefix}${item.id}</span></td>
                        <td><span class="badge border text-dark fw-normal px-3">${item.type}</span></td>
                        <td class="staff-cell">${item.staff}</td>
                        <td class="text-muted small">
                            <fmt:formatDate value="${parsedRowDate}" pattern="dd/MM/yyyy HH:mm" />
                        </td>
                        <td class="text-center">
                            <c:choose>
                                <c:when test="${statusKey == 'COMPLETED'}"><span class="status-badge status-active">Completed</span></c:when>
                                <c:when test="${statusKey == 'REJECTED'}"><span class="status-badge status-outstock">Rejected</span></c:when>
                                <c:otherwise><span class="status-badge status-pending">Pending</span></c:otherwise>
                            </c:choose>
                        </td>
                        <td class="text-end">
                            <c:url var="detailLink" value="${item.type == 'Stock-in' ? '/stockIn/details' : (item.type == 'Stock-out' ? '/stockOut/details' : '/audit/details')}" />
                            <a href="${detailLink}?id=${item.id}" class="action-link">View Detailed</a>
                        </td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
        </div>
    </div>
</div>

<script src="<c:url value='/resources/js/inventory/inventory-logs.js'/>"></script>
</body>
</html>