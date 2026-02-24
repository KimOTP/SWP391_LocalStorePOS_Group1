<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <title>Sales Report</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta id="ctxMeta" name="context-path" content="${pageContext.request.contextPath}">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/reports/reports.css">
</head>
<body>

<jsp:include page="../../layer/header.jsp" />
<jsp:include page="../../layer/sidebar.jsp" />

<div class="page-content">

    <!-- ── HEADER BAR ── -->
    <div class="rpt-topbar">
        <h5 class="rpt-title">Sales report</h5>
        <div class="rpt-action-group">
            <button class="rpt-btn" onclick="refreshReport()">
                <i class="bi bi-arrow-clockwise"></i> Refresh
            </button>
            <button class="rpt-btn" onclick="exportExcel()">
                <i class="bi bi-file-earmark-excel"></i> Export excel
            </button>
        </div>
    </div>

    <!-- ── FILTER BOX ── -->
    <div class="rpt-filter-box">

        <!-- Header row: icon+label on left, Extend/Collapse button on right -->
        <div class="rpt-filter-bar">
            <span class="rpt-filter-bar-label">
                <i class="bi bi-funnel"></i> Report filter
            </span>
            <%-- THIS is the only clickable element for toggle --%>
            <button type="button" class="rpt-extend-btn" id="toggleBtn" onclick="toggleFilter()">
                Extend
            </button>
        </div>

        <!-- Collapsible body -->
        <div id="filterBody" class="rpt-filter-body" style="display: none;">

            <!-- Date input with calendar icon -->
            <div class="rpt-filter-date-row">
                <i class="bi bi-calendar3"></i>
                <input type="date" id="startDate" class="rpt-date-inp">
                <span>—</span>
                <input type="date" id="endDate" class="rpt-date-inp">
            </div>

            <!-- Cashier -->
            <div class="rpt-filter-group">
                <div class="rpt-filter-group-label">Cashier</div>
                <div class="rpt-radio-row">
                    <label class="rpt-radio-lbl">
                        <input type="radio" name="cashierFilter" value="" checked> All
                    </label>
                    <c:forEach var="emp" items="${employees}">
                        <label class="rpt-radio-lbl">
                            <input type="radio" name="cashierFilter" value="${emp.employeeId}">
                            ${emp.fullName}
                        </label>
                    </c:forEach>
                </div>
            </div>

            <!-- Payment methods -->
            <div class="rpt-filter-group">
                <div class="rpt-filter-group-label">Payment methods</div>
                <div class="rpt-radio-row">
                    <label class="rpt-radio-lbl">
                        <input type="radio" name="paymentFilter" value="" checked> All
                    </label>
                    <label class="rpt-radio-lbl">
                        <input type="radio" name="paymentFilter" value="CASH"> Payment by cash
                    </label>
                    <label class="rpt-radio-lbl">
                        <input type="radio" name="paymentFilter" value="BANKING"> Payment via banking
                    </label>
                </div>
            </div>

            <!-- Apply / Reset -->
            <div class="rpt-filter-foot">
                <button class="rpt-btn" onclick="applyFilter()">Apply</button>
                <button class="rpt-btn rpt-btn-ghost" onclick="resetFilter()">Reset</button>
            </div>

        </div>
    </div>

    <!-- ── DATE BAR ── -->
    <div class="rpt-date-bar" id="dateBar">${currentDateFormatted}</div>

    <!-- ── SUMMARY CARDS ── -->
    <div class="rpt-cards">

        <div class="rpt-card">
            <div class="rpt-card-row">
                <span class="rpt-card-lbl">Total revenue</span>
                <i class="bi bi-currency-dollar rpt-card-ico"></i>
            </div>
            <div class="rpt-card-val" id="totalRevenue">
                $<fmt:formatNumber value="${totalRevenue}" pattern="#,##0.00"/>
            </div>
            <div class="rpt-card-hint">&nbsp;</div>
        </div>

        <div class="rpt-card">
            <div class="rpt-card-row">
                <span class="rpt-card-lbl">Total order</span>
                <i class="bi bi-cart3 rpt-card-ico"></i>
            </div>
            <div class="rpt-card-val" id="totalOrders">${totalOrders}</div>
            <div class="rpt-card-hint">&nbsp;</div>
        </div>

        <div class="rpt-card">
            <div class="rpt-card-row">
                <span class="rpt-card-lbl">Average value/unit</span>
                <i class="bi bi-calculator rpt-card-ico"></i>
            </div>
            <div class="rpt-card-val" id="averageValuePerUnit">
                $<fmt:formatNumber value="${averageValuePerUnit}" pattern="#,##0.00"/>
            </div>
            <div class="rpt-card-hint">&nbsp;</div>
        </div>

        <div class="rpt-card">
            <div class="rpt-card-row">
                <span class="rpt-card-lbl">Bestselling product</span>
                <i class="bi bi-trophy rpt-card-ico"></i>
            </div>
            <div class="rpt-card-val rpt-card-val--text" id="bestSellingProduct">
                ${not empty bestSellingProduct ? bestSellingProduct : 'N/A'}
            </div>
            <div class="rpt-card-hint">&nbsp;</div>
        </div>

    </div>

    <!-- ── ORDER TABLE ── -->
    <div class="rpt-table-wrap">
        <div class="rpt-table-bar">
            <span>Order Details</span>
            <span id="orderCountBadge">${totalOrders} orders</span>
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
                    <th>Created At</th>
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
                                        <c:when test="${not empty order.employee}">${order.employee.fullName}</c:when>
                                        <c:otherwise>—</c:otherwise>
                                    </c:choose>
                                </td>
                                <td>${order.paymentMethod}</td>
                                <td>$<fmt:formatNumber value="${order.totalAmount}" pattern="#,##0.00"/></td>
                                <td>${fn:replace(fn:substring(order.createdAt, 0, 16), 'T', ' ')}</td>
                                <td>${order.orderStatus.orderStatusName}</td>
                            </tr>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <tr>
                            <td colspan="7" class="text-center text-muted py-3">
                                No orders found for the selected period.
                            </td>
                        </tr>
                    </c:otherwise>
                </c:choose>
                </tbody>
            </table>
        </div>
    </div>

</div><!-- /page-content -->

<!-- Loading indicator -->
<div class="rpt-loading d-none" id="loadingOverlay">
    <div class="spinner-border spinner-border-sm text-secondary"></div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
// ============================================================
// reports.js — inline (tránh vấn đề đường dẫn file JS ngoài)
// ============================================================
var CTX = '${pageContext.request.contextPath}';

// Set default dates on load
window.addEventListener('DOMContentLoaded', function () {
    var today = getTodayStr();
    var s = document.getElementById('startDate');
    var e = document.getElementById('endDate');
    if (s) s.value = today;
    if (e) e.value = today;
});

// ── Toggle filter ──────────────────────────────────────────
function toggleFilter() {
    var body = document.getElementById('filterBody');
    var btn  = document.getElementById('toggleBtn');
    if (!body || !btn) return;
    if (body.style.display === 'none' || body.style.display === '') {
        body.style.display = 'block';
        btn.textContent = 'Collapse';
    } else {
        body.style.display = 'none';
        btn.textContent = 'Extend';
    }
}

// ── Apply / Reset / Refresh ────────────────────────────────
function applyFilter() {
    var startDate     = document.getElementById('startDate').value;
    var endDate       = document.getElementById('endDate').value;
    var cashierEl     = document.querySelector('input[name="cashierFilter"]:checked');
    var payEl         = document.querySelector('input[name="paymentFilter"]:checked');
    var cashierId     = cashierEl ? cashierEl.value : '';
    var paymentMethod = payEl     ? payEl.value     : '';

    if (!startDate || !endDate) { alert('Please select both start and end dates.'); return; }
    if (startDate > endDate)    { alert('Start date cannot be after end date.'); return; }

    var bar = document.getElementById('dateBar');
    if (bar) bar.textContent = (startDate === endDate)
        ? toDisplay(startDate)
        : toDisplay(startDate) + ' — ' + toDisplay(endDate);

    if (cashierId) {
        doPost(CTX + '/reports/api/reports-by-cashier',
            { startDate: startDate, endDate: endDate, cashierId: cashierId });
    } else if (paymentMethod) {
        doPost(CTX + '/reports/api/reports-by-payment-method',
            { startDate: startDate, endDate: endDate, paymentMethod: paymentMethod });
    } else {
        doPost(CTX + '/reports/api/reports-by-date-range',
            { startDate: startDate, endDate: endDate });
    }
}

function resetFilter() {
    var today = getTodayStr();
    document.getElementById('startDate').value = today;
    document.getElementById('endDate').value   = today;
    document.querySelectorAll('input[name="cashierFilter"]').forEach(function(r){ r.checked = r.value === ''; });
    document.querySelectorAll('input[name="paymentFilter"]').forEach(function(r){ r.checked = r.value === ''; });
    var bar = document.getElementById('dateBar');
    if (bar) bar.textContent = toDisplay(today);
    doPost(CTX + '/reports/api/reports-by-date-range', { startDate: today, endDate: today });
}

function refreshReport() { applyFilter(); }

function exportExcel() {
    var s = document.getElementById('startDate').value;
    var e = document.getElementById('endDate').value;
    if (!s || !e) { alert('Select a date range first.'); return; }
    showLoading(true);
    fetch(CTX + '/reports/api/export-excel', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: new URLSearchParams({ startDate: s, endDate: e })
    })
    .then(function(r){ return r.json(); })
    .then(function(j){ alert(j.success ? 'Report ready!' : (j.message || 'Export failed.')); })
    .catch(function(){ alert('Network error.'); })
    .finally(function(){ showLoading(false); });
}

// ── AJAX ──────────────────────────────────────────────────
function doPost(url, params) {
    showLoading(true);
    fetch(url, {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: new URLSearchParams(params)
    })
    .then(function(r){ return r.json(); })
    .then(function(json){
        if (json.success) {
            updateSummary(json.data);
            updateTable(json.data.orders || []);
        } else {
            alert(json.message || 'Error loading report.');
        }
    })
    .catch(function(){ alert('Network error.'); })
    .finally(function(){ showLoading(false); });
}

// ── DOM updates ────────────────────────────────────────────
function updateSummary(d) {
    setEl('totalRevenue',        '$' + fmtNum(d.totalRevenue));
    setEl('totalOrders',         d.totalOrders != null ? d.totalOrders : 0);
    setEl('averageValuePerUnit', '$' + fmtNum(d.averageValuePerUnit));
    setEl('bestSellingProduct',  d.bestSellingProduct || 'N/A');
    var b = document.getElementById('orderCountBadge');
    if (b) b.textContent = (d.totalOrders != null ? d.totalOrders : 0) + ' orders';
}

function updateTable(orders) {
    var tbody = document.getElementById('orderTableBody');
    if (!tbody) return;
    if (!orders.length) {
        tbody.innerHTML = '<tr><td colspan="7" class="text-center text-muted py-3">No orders found for the selected period.</td></tr>';
        return;
    }
    tbody.innerHTML = orders.map(function(o, i){
        return '<tr>' +
            '<td>' + (i+1) + '</td>' +
            '<td>#' + o.orderId + '</td>' +
            '<td>' + (o.employee && o.employee.fullName ? o.employee.fullName : '—') + '</td>' +
            '<td>' + (o.paymentMethod || '—') + '</td>' +
            '<td>$' + fmtNum(o.totalAmount) + '</td>' +
            '<td>' + fmtDT(o.createdAt) + '</td>' +
            '<td>' + (o.orderStatus ? o.orderStatus.orderStatusName : '') + '</td>' +
            '</tr>';
    }).join('');
}

// ── Helpers ────────────────────────────────────────────────
function getTodayStr() { return new Date().toISOString().split('T')[0]; }
function toDisplay(s)  { var p=s.split('-'); return p[2]+'/'+p[1]+'/'+p[0]; }
function fmtNum(v)     { if(v==null) return '0.00'; return parseFloat(v).toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g,','); }
function fmtDT(s)      { if(!s) return '—'; return String(s).substring(0,16).replace('T',' '); }
function setEl(id, v)  { var el=document.getElementById(id); if(el) el.textContent=v; }
function showLoading(show) {
    var el = document.getElementById('loadingOverlay');
    if (!el) return;
    show ? el.classList.remove('d-none') : el.classList.add('d-none');
}
</script>
</body>
</html>
