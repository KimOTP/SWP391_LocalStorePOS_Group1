<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Revenue Report</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <%-- Context path for JS --%>
    <meta id="ctxMeta" name="context-path" content="${pageContext.request.contextPath}">

    <%-- Bootstrap CSS --%>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <%-- Bootstrap Icons --%>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">

    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/reports/reports.css">
</head>
<body>

<%-- Sidebar & Header include --%>
<jsp:include page="../../layer/header.jsp" />
<jsp:include page="../../layer/sidebar.jsp" />

<div class="page-content">

    <%-- ── HEADER BAR ── --%>
    <div class="rpt-topbar">
        <h5 class="rpt-title">Revenue Report</h5>
        <div class="rpt-action-group">
            <button class="rpt-btn" onclick="refreshReport()">
                <i class="bi bi-arrow-clockwise"></i> Refresh
            </button>
            <button class="btn-outline-success" onclick="exportExcel()">
                <i class="bi bi-file-earmark-excel"></i> Export Excel
            </button>
        </div>
    </div>

    <%-- ── FILTER BOX ── --%>
    <div class="rpt-filter-box">

        <div class="rpt-filter-bar">
            <span class="rpt-filter-bar-label">
                <i class="bi bi-funnel"></i> Report Filters
            </span>
            <button type="button" class="rpt-extend-btn" id="filterToggleBtn" onclick="toggleFilter()">
                <i class="bi bi-chevron-down rpt-filter-chevron" id="filterChevron"></i>
                <span id="filterToggleLabel">Expand</span>
            </button>
        </div>

        <div id="filterBody" class="rpt-filter-body" style="display: none;">

            <div class="row g-4">
                <%-- Date range --%>
                <div class="col-md-12">
                    <div class="rpt-filter-group mb-0">
                        <div class="rpt-filter-group-label"><i class="bi bi-calendar-range me-1"></i> Time Period</div>
                        <div class="rpt-filter-date-row mb-0">
                            <label class="mb-0 me-2 fw-medium">From</label>
                            <input type="date" id="startDate" class="rpt-date-inp">
                            <span class="mx-2 text-muted">—</span>
                            <label class="mb-0 me-2 fw-medium">To</label>
                            <input type="date" id="endDate" class="rpt-date-inp">
                        </div>
                    </div>
                </div>

                <%-- Cashier filter --%>
                <div class="col-md-6">
                    <div class="rpt-filter-group mb-0">
                        <div class="rpt-filter-group-label"><i class="bi bi-person-badge me-1"></i> Cashier</div>
                        <div class="rpt-radio-row">
                            <label class="rpt-radio-lbl">
                                <input type="radio" name="cashierFilter" value="" checked>
                                <span class="ms-1">All Staff</span>
                            </label>
                            <c:forEach var="emp" items="${cashiers}">
                                <label class="rpt-radio-lbl">
                                    <input type="radio" name="cashierFilter" value="${emp.employeeId}">
                                    <span class="ms-1">${fn:escapeXml(emp.fullName)}</span>
                                </label>
                            </c:forEach>
                        </div>
                    </div>
                </div>

                <%-- Payment method --%>
                <div class="col-md-6">
                    <div class="rpt-filter-group mb-0">
                        <div class="rpt-filter-group-label"><i class="bi bi-credit-card me-1"></i> Payment Method</div>
                        <div class="rpt-radio-row">
                            <label class="rpt-radio-lbl">
                                <input type="radio" name="paymentFilter" value="" checked>
                                <span class="ms-1">All Methods</span>
                            </label>
                            <label class="rpt-radio-lbl">
                                <input type="radio" name="paymentFilter" value="CASH">
                                <i class="bi bi-cash text-success"></i> <span class="ms-1">Cash</span>
                            </label>
                            <label class="rpt-radio-lbl">
                                <input type="radio" name="paymentFilter" value="BANKING">
                                <i class="bi bi-bank text-primary"></i> <span class="ms-1">Bank Transfer</span>
                            </label>
                        </div>
                    </div>
                </div>
            </div>

            <%-- Apply / Reset buttons --%>
            <div class="rpt-filter-foot">
                <button class="rpt-btn rpt-btn-primary" onclick="applyFilter()">
                    <i class="bi bi-funnel-fill"></i> Apply Filter
                </button>
                <button class="rpt-btn rpt-btn-ghost" onclick="resetFilter()">
                    <i class="bi bi-arrow-counterclockwise"></i> Reset
                </button>
            </div>

        </div>
    </div>

    <%-- ── DATE BAR ── --%>
    <div class="rpt-date-bar" id="dateBar">${currentDateFormatted}</div>
    <%-- ── SUMMARY CARDS ── --%>
    <div class="rpt-cards">

        <div class="rpt-card">
            <div class="rpt-card-row">
                <span class="rpt-card-lbl">Total Sales</span>
                <i class="bi bi-cash-stack rpt-card-ico text-success"></i>
            </div>
            <div class="rpt-card-val" id="totalSales">
                <fmt:formatNumber value="${totalSales}" pattern="#,##0"/> ₫
            </div>
            <div class="rpt-card-hint">&nbsp;</div>
        </div>

        <div class="rpt-card">
            <div class="rpt-card-row">
                <span class="rpt-card-lbl">Total Order</span>
                <i class="bi bi-receipt rpt-card-ico text-warning"></i>
            </div>
            <div class="rpt-card-val" id="totalOrders">
                ${totalOrders}
            </div>
            <div class="rpt-card-hint">&nbsp;</div>
        </div>

        <div class="rpt-card">
            <div class="rpt-card-row">
                <span class="rpt-card-lbl">Avg. Value / Unit</span>
                <i class="bi bi-calculator rpt-card-ico text-info"></i>
            </div>
            <div class="rpt-card-val" id="averageValuePerUnit">
                <fmt:formatNumber value="${averageValuePerUnit}" pattern="#,##0"/> ₫
            </div>
            <div class="rpt-card-hint">&nbsp;</div>
        </div>

        <div class="rpt-card">
            <div class="rpt-card-row">
                <span class="rpt-card-lbl">Best-Selling Product</span>
                <i class="bi bi-trophy rpt-card-ico" style="color: #eab308;"></i>
            </div>
            <div class="rpt-card-val rpt-card-val--text" id="bestSellingProduct">
                ${not empty bestSellingProduct ? fn:escapeXml(bestSellingProduct) : 'N/A'}
            </div>
            <div class="rpt-card-hint">&nbsp;</div>
        </div>

    </div>

    <%-- ── ORDER TABLE ── --%>
    <div class="rpt-table-wrap">
        <div class="rpt-table-bar">
            <span><i class="bi bi-list-ul me-1"></i>Order Details</span>
        </div>
        <div class="table-responsive">
            <table class="table table-sm table-hover rpt-table mb-0">
                <thead>
                <tr>
                    <th>#</th>
                    <th>Order ID</th>
                    <th>Cashier</th>
                    <th>Payment</th>
                    <th>Amount</th>
                    <th>Date & Time</th>
                    <th>Status</th>
                </tr>
                </thead>
                <tbody id="orderTableBody">
                <c:choose>
                    <c:when test="${not empty report.orders}">
                        <c:forEach var="order" items="${report.orders}" varStatus="s">
                            <tr>
                                <td>${s.index + 1}</td>
                                <td>#${order.orderId}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${not empty order.employee}">${fn:escapeXml(order.employee.fullName)}</c:when>
                                        <c:otherwise>—</c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${empty order.paymentMethod}">—</c:when>
                                        <c:when test="${order.paymentMethod.name() == 'CASH'}">Cash</c:when>
                                        <c:when test="${order.paymentMethod.name() == 'BANKING'}">Bank Transfer</c:when>
                                        <c:otherwise>${order.paymentMethod}</c:otherwise>
                                    </c:choose>
                                </td>
                                <td><fmt:formatNumber value="${order.totalAmount}" pattern="#,##0"/> ₫</td>
                                <td>${fn:replace(fn:substring(order.createdAt, 0, 16), 'T', ' ')}</td>
                                <td>
                                    <c:set var="sName" value="${order.orderStatus.orderStatusName}"/>
                                    <c:choose>
                                        <c:when test="${sName == 'PAID'}">
                                            <span style="display:inline-block;padding:2px 10px;border-radius:20px;font-size:0.75rem;font-weight:600;color:#16a34a;background:#f0fdf4;border:1px solid #86efac">Paid</span>
                                        </c:when>
                                        <c:when test="${sName == 'CANCELLED'}">
                                            <span style="display:inline-block;padding:2px 10px;border-radius:20px;font-size:0.75rem;font-weight:600;color:#dc2626;background:#fef2f2;border:1px solid #fca5a5">Cancelled</span>
                                        </c:when>
                                        <c:when test="${sName == 'PENDING_PAYMENT'}">
                                            <span style="display:inline-block;padding:2px 10px;border-radius:20px;font-size:0.75rem;font-weight:600;color:#d97706;background:#fffbeb;border:1px solid #fcd34d">Pending Payment</span>
                                        </c:when>
                                        <c:when test="${sName == 'DRAFT'}">
                                            <span style="display:inline-block;padding:2px 10px;border-radius:20px;font-size:0.75rem;font-weight:600;color:#6b7280;background:#f9fafb;border:1px solid #d1d5db">Draft</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span style="display:inline-block;padding:2px 10px;border-radius:20px;font-size:0.75rem;font-weight:600;color:#6b7280;background:#f9fafb;border:1px solid #d1d5db">${sName}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <tr>
                            <td colspan="7" class="text-center text-muted py-4">
                                <i class="bi bi-inbox me-1"></i>No orders found for the selected date.
                            </td>
                        </tr>
                    </c:otherwise>
                </c:choose>
                </tbody>
            </table>
        </div>
    </div>

</div><%-- /page-content --%>

<%-- Loading overlay --%>
<div class="rpt-loading d-none" id="loadingOverlay">
    <div class="spinner-border spinner-border-sm text-secondary me-1"></div>
    <span>Loading...</span>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/resources/js/report/reports.js"></script>
</body>
</html>
