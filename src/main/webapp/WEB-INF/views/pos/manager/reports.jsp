<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Báo cáo doanh thu</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <%-- Context path cho JS --%>
    <meta id="ctxMeta" name="context-path" content="${pageContext.request.contextPath}">

    <%-- Bootstrap CSS --%>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <%-- Bootstrap Icons — đảm bảo icon hiển thị trong cả reports và sidebar --%>
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
        <h5 class="rpt-title">Báo cáo doanh thu</h5>
        <div class="rpt-action-group">
            <button class="rpt-btn" onclick="refreshReport()">
                <i class="bi bi-arrow-clockwise"></i> Làm mới
            </button>
            <button class="rpt-btn rpt-btn-excel" onclick="exportExcel()">
                <i class="bi bi-file-earmark-excel"></i> Xuất Excel
            </button>
        </div>
    </div>

    <%-- ── FILTER BOX ── --%>
    <div class="rpt-filter-box">

        <div class="rpt-filter-bar">
            <span class="rpt-filter-bar-label">
                <i class="bi bi-funnel"></i> Bộ lọc báo cáo
            </span>
            <button type="button" class="rpt-extend-btn" id="toggleBtn" onclick="toggleFilter()">
                Mở rộng
            </button>
        </div>

        <div id="filterBody" class="rpt-filter-body" style="display: none;">

            <%-- Khoảng ngày --%>
            <div class="rpt-filter-date-row">
                <i class="bi bi-calendar3"></i>
                <label class="rpt-filter-group-label mb-0 me-1">Từ:</label>
                <input type="date" id="startDate" class="rpt-date-inp">
                <span class="mx-1">—</span>
                <label class="rpt-filter-group-label mb-0 me-1">Đến:</label>
                <input type="date" id="endDate" class="rpt-date-inp">
            </div>

            <%-- Cashier filter — CHỈ hiển thị nhân viên có role CASHIER --%>
            <div class="rpt-filter-group">
                <div class="rpt-filter-group-label">Thu ngân</div>
                <div class="rpt-radio-row">
                    <label class="rpt-radio-lbl">
                        <input type="radio" name="cashierFilter" value="" checked> Tất cả
                    </label>
                    <c:forEach var="emp" items="${cashiers}">
                        <label class="rpt-radio-lbl">
                            <input type="radio" name="cashierFilter" value="${emp.employeeId}">
                            ${fn:escapeXml(emp.fullName)}
                        </label>
                    </c:forEach>
                </div>
            </div>

            <%-- Phương thức thanh toán --%>
            <div class="rpt-filter-group">
                <div class="rpt-filter-group-label">Phương thức thanh toán</div>
                <div class="rpt-radio-row">
                    <label class="rpt-radio-lbl">
                        <input type="radio" name="paymentFilter" value="" checked> Tất cả
                    </label>
                    <label class="rpt-radio-lbl">
                        <input type="radio" name="paymentFilter" value="CASH"> Tiền mặt
                    </label>
                    <label class="rpt-radio-lbl">
                        <input type="radio" name="paymentFilter" value="BANKING"> Chuyển khoản
                    </label>
                </div>
            </div>

            <%-- Nút Apply / Reset --%>
            <div class="rpt-filter-foot">
                <button class="rpt-btn" onclick="applyFilter()">
                    <i class="bi bi-check2"></i> Áp dụng
                </button>
                <button class="rpt-btn rpt-btn-ghost" onclick="resetFilter()">
                    <i class="bi bi-x-circle"></i> Đặt lại
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
                <span class="rpt-card-lbl">Tổng doanh thu</span>
                <i class="bi bi-cash-coin rpt-card-ico"></i>
            </div>
            <div class="rpt-card-val" id="totalRevenue">
                <fmt:formatNumber value="${totalRevenue}" pattern="#,##0"/> ₫
            </div>
            <div class="rpt-card-hint">&nbsp;</div>
        </div>

        <div class="rpt-card">
            <div class="rpt-card-row">
                <span class="rpt-card-lbl">Tổng đơn hàng</span>
                <i class="bi bi-cart3 rpt-card-ico"></i>
            </div>
            <div class="rpt-card-val" id="totalOrders">${totalOrders}</div>
            <div class="rpt-card-hint">&nbsp;</div>
        </div>

        <div class="rpt-card">
            <div class="rpt-card-row">
                <span class="rpt-card-lbl">Giá trị TB / đơn vị</span>
                <i class="bi bi-calculator rpt-card-ico"></i>
            </div>
            <div class="rpt-card-val" id="averageValuePerUnit">
                <fmt:formatNumber value="${averageValuePerUnit}" pattern="#,##0"/> ₫
            </div>
            <div class="rpt-card-hint">&nbsp;</div>
        </div>

        <div class="rpt-card">
            <div class="rpt-card-row">
                <span class="rpt-card-lbl">Sản phẩm bán chạy</span>
                <i class="bi bi-trophy rpt-card-ico"></i>
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
            <span><i class="bi bi-list-ul me-1"></i>Chi tiết đơn hàng</span>
            <span id="orderCountBadge">${totalOrders} đơn hàng</span>
        </div>
        <div class="table-responsive">
            <table class="table table-sm table-hover rpt-table mb-0">
                <thead>
                <tr>
                    <th>#</th>
                    <th>Mã đơn</th>
                    <th>Thu ngân</th>
                    <th>Thanh toán</th>
                    <th>Thành tiền</th>
                    <th>Thời gian</th>
                    <th>Trạng thái</th>
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
                                        <c:when test="${order.paymentMethod == 'CASH'}">Tiền mặt</c:when>
                                        <c:when test="${order.paymentMethod == 'BANKING'}">Chuyển khoản</c:when>
                                        <c:otherwise>${order.paymentMethod}</c:otherwise>
                                    </c:choose>
                                </td>
                                <td><fmt:formatNumber value="${order.totalAmount}" pattern="#,##0"/> ₫</td>
                                <td>${fn:replace(fn:substring(order.createdAt, 0, 16), 'T', ' ')}</td>
                                <td>
                                    <span class="rpt-status-badge">${order.orderStatus.orderStatusName}</span>
                                </td>
                            </tr>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <tr>
                            <td colspan="7" class="text-center text-muted py-4">
                                <i class="bi bi-inbox me-1"></i>Không có đơn hàng trong ngày đã chọn.
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
    <span>Đang tải...</span>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<%-- JS tách riêng --%>
<script src="${pageContext.request.contextPath}/resources/js/report/reports.js"></script>
</body>
</html>
