<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Receipt</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/pos/pos.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/pos/receipt.css">
</head>
<body>

<%-- Sidebar & Header include --%>
<jsp:include page="../../layer/header.jsp" />
<jsp:include page="../../layer/sidebar.jsp" />

<div class="receipt-container">

    <!-- ======================================================
         PAGE HEADER
         ====================================================== -->
    <div class="page-header">
        <h1 class="page-title">
            <i class="fa-regular fa-file-lines"></i>
            Manage receipt
        </h1>
        <div class="header-actions">
            <button class="btn-action" onclick="loadReceipts()">
                <i class="fa-solid fa-rotate-right"></i>
                Refresh
            </button>
            <button class="btn-action btn-excel" onclick="exportExcel()">
                <i class="fa-solid fa-file-arrow-up"></i>
                Export excel
            </button>
        </div>
    </div>

    <!-- ======================================================
         STAT CARDS
         ====================================================== -->
    <div class="stats-row">

        <div class="stat-card">
            <div class="stat-body">
                <div class="stat-label">Total bill</div>
                <div class="stat-value">${totalBill}</div>
                <div class="stat-desc">Total number of invoices in the system</div>
            </div>
            <div class="stat-icon blue"><i class="fa-regular fa-file-lines"></i></div>
        </div>

        <div class="stat-card">
            <div class="stat-body">
                <div class="stat-label">Revenue</div>
                <div class="stat-value">
                    <%-- totalRevenue is BigDecimal --%>
                    <fmt:formatNumber value="${totalRevenue}" type="number" maxFractionDigits="0"/>
                    <span class="currency">₫</span>
                </div>
                <div class="stat-desc">Total revenue paid</div>
            </div>
            <div class="stat-icon green"><i class="fa-solid fa-dollar-sign"></i></div>
        </div>

        <div class="stat-card">
            <div class="stat-body">
                <div class="stat-label">Pending</div>
                <div class="stat-value">${pending}</div>
                <div class="stat-desc">Invoice awaiting confirmation</div>
            </div>
            <div class="stat-icon orange"><i class="fa-regular fa-clock"></i></div>
        </div>

        <div class="stat-card">
            <div class="stat-body">
                <div class="stat-label">Completed bill</div>
                <div class="stat-value">${completed}</div>
                <div class="stat-desc">The invoice has been paid.</div>
            </div>
            <div class="stat-icon teal"><i class="fa-solid fa-circle-check"></i></div>
        </div>

        <div class="stat-card">
            <div class="stat-body">
                <div class="stat-label">Cancelled</div>
                <div class="stat-value">${cancelled}</div>
                <div class="stat-desc">The invoice has been canceled.</div>
            </div>
            <div class="stat-icon red"><i class="fa-solid fa-circle-xmark"></i></div>
        </div>

        <div class="stat-card">
            <div class="stat-body">
                <div class="stat-label">Today</div>
                <div class="stat-value">${today}</div>
                <div class="stat-desc">Total number of invoices today</div>
            </div>
            <div class="stat-icon purple"><i class="fa-regular fa-file-lines"></i></div>
        </div>

    </div>

    <!-- ======================================================
         FILTER SECTION
         ====================================================== -->
    <div class="filter-section">
        <div class="filter-title">
            <i class="fa-solid fa-filter"></i>
            Filter
        </div>
        <div class="filter-controls">
            <div class="search-wrap">
                <i class="fa-solid fa-magnifying-glass"></i>
                <input type="text" class="search-input" id="searchInput"
                       placeholder="Search for receipt" oninput="filterTable()">
            </div>

            <%-- Custom dropdown Payment giống pos.css --%>
            <div class="pos-dropdown" id="paymentDropdown">
                <div class="pos-dropdown-selected" onclick="toggleDropdown('paymentDropdown')">
                    <span id="paymentDropdownLabel">All payment methods</span>
                    <div class="pos-dropdown-arrow"></div>
                </div>
                <div class="pos-dropdown-menu">
                    <div class="pos-dropdown-item" onclick="selectPayment('', 'All payment methods')">All payment methods</div>
                    <div class="pos-dropdown-item" onclick="selectPayment('CASH', 'Cashing')">Cashing</div>
                    <div class="pos-dropdown-item" onclick="selectPayment('BANKING', 'Banking')">Banking</div>
                    <div class="pos-dropdown-item" onclick="selectPayment('QR', 'QR')">QR</div>
                </div>
            </div>
            <input type="hidden" id="paymentFilter" value="">

            <div class="date-range-wrap">
                <button class="date-range-btn" id="dateRangeBtn" onclick="toggleDatePicker(event)">
                    <i class="fa-regular fa-calendar-days"></i>
                    <span id="dateRangeLabel">Select a time range</span>
                </button>
                <div class="date-picker-popup" id="datePickerPopup">
                    <label>From date</label>
                    <input type="date" id="dateFrom">
                    <label>To date</label>
                    <input type="date" id="dateTo">
                    <div class="date-picker-actions">
                        <button class="btn-clear" onclick="clearDateFilter()">Clear</button>
                        <button class="btn-apply" onclick="applyDateFilter()">Apply</button>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- ======================================================
         RECEIPT TABLE
         ====================================================== -->
    <div class="table-card">
        <table class="receipt-table">
            <thead>
                <tr>
                    <th class="td-check">
                        <input type="checkbox" class="row-checkbox" id="checkAll"
                               onchange="toggleAll(this)">
                    </th>
                    <th>Invoice code</th>
                    <th>Creation date</th>
                    <th>Customer</th>
                    <th>Cashier</th>
                    <th>Total amount</th>
                    <th>Payment method</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody id="receiptTableBody">

                <c:forEach var="r" items="${receipts}">
                <%-- r is a Map with keys: receiptNumber, createdAt, customerName,
                     cashierName, totalAmount, paymentMethod, orderStatus, statusLabel --%>
                <tr data-code="${r.receiptNumber}"
                    data-status="${r.orderStatus}"
                    data-payment="${r.paymentMethod}"
                    data-customer="${r.customerName}"
                    data-cashier="${r.cashierName}">

                    <td class="td-check">
                        <input type="checkbox" class="row-checkbox">
                    </td>

                    <%-- Invoice code --%>
                    <td><span class="invoice-code">${r.receiptNumber}</span></td>

                    <%-- Creation date – already formatted String from Service --%>
                    <td>${not empty r.createdAt ? r.createdAt : '—'}</td>

                    <%-- Customer (nullable) --%>
                    <td>${not empty r.customerName ? r.customerName : 'Guest'}</td>

                    <%-- Cashier --%>
                    <td>${not empty r.cashierName ? r.cashierName : '—'}</td>

                    <%-- Total amount (BigDecimal) --%>
                    <td>
                        <c:choose>
                            <c:when test="${r.totalAmount != null}">
                                <fmt:formatNumber value="${r.totalAmount}"
                                                 type="number" maxFractionDigits="0"/> ₫
                            </c:when>
                            <c:otherwise>—</c:otherwise>
                        </c:choose>
                    </td>

                    <%-- Payment method --%>
                    <td>
                        <c:choose>
                            <c:when test="${r.paymentMethod == 'CASH'}">
                                <span class="payment-badge cash">
                                    <i class="fa-solid fa-coins"></i> Cashing
                                </span>
                            </c:when>
                            <c:when test="${r.paymentMethod == 'BANKING'}">
                                <span class="payment-badge banking">
                                    <i class="fa-solid fa-building-columns"></i> Banking
                                </span>
                            </c:when>
                            <c:when test="${r.paymentMethod == 'QR'}">
                                <span class="payment-badge qr">
                                    <i class="fa-solid fa-qrcode"></i> QR
                                </span>
                            </c:when>
                            <c:otherwise>
                                <span class="payment-badge cash">
                                    ${not empty r.paymentMethod ? r.paymentMethod : '—'}
                                </span>
                            </c:otherwise>
                        </c:choose>
                    </td>

                    <%-- Action --%>
                    <td>
                        <div class="action-wrap">
                            <button class="btn-dots" onclick="toggleMenu(this)"
                                    title="Actions">•••</button>
                            <div class="action-menu">
                                <div class="action-menu-item"
                                     onclick="viewDetail('${r.receiptNumber}')">
                                    <i class="fa-regular fa-eye"></i> See the detailed
                                </div>
                                <div class="action-menu-item"
                                     onclick="printReceipt('${r.receiptNumber}')">
                                    <i class="fa-solid fa-print"></i> Print receipt
                                </div>
                            </div>
                        </div>
                    </td>

                </tr>
                </c:forEach>

                <%-- Empty state --%>
                <c:if test="${empty receipts}">
                <tr>
                    <td colspan="8"
                        style="text-align:center; color:#94a3b8; padding:40px 16px;">
                        <i class="fa-regular fa-file-lines"
                           style="font-size:2rem; display:block; margin-bottom:8px;"></i>
                        No receipts found.
                    </td>
                </tr>
                </c:if>

            </tbody>
        </table>
    </div>

</div><!-- /.receipt-container -->

<!-- ======================================================
     INVOICE DETAIL MODAL
     ====================================================== -->
<div class="modal-overlay" id="detailModal" onclick="closeModalOnBg(event)">
    <div class="modal-box">

        <div class="modal-header">
            <h2 class="modal-title" id="modalTitle">Invoice details</h2>
            <button class="modal-close" onclick="closeModal()">
                <i class="fa-solid fa-xmark"></i>
            </button>
        </div>

        <div class="modal-body">

            <!-- Receipt info + Customer info -->
            <div class="modal-grid">

                <div class="info-card">
                    <div class="info-card-title">Receipt information</div>
                    <div class="info-row">
                        <span class="info-key">Invoice code:</span>
                        <span class="info-val" id="detailCode">—</span>
                    </div>
                    <div class="info-row">
                        <span class="info-key">Creation date:</span>
                        <span class="info-val" id="detailDate">—</span>
                    </div>
                    <div class="info-row">
                        <span class="info-key">State:</span>
                        <span class="info-val status-paid" id="detailStatus">—</span>
                    </div>
                    <div class="info-row">
                        <span class="info-key">Cashier:</span>
                        <span class="info-val" id="detailCashier">—</span>
                    </div>
                </div>

                <div class="info-card">
                    <div class="info-card-title">Customer information</div>
                    <div class="info-row">
                        <span class="info-key">Customer:</span>
                        <span class="info-val" id="detailCustomer">—</span>
                    </div>
                    <div class="info-row">
                        <span class="info-key">Payment method:</span>
                        <span class="info-val" id="detailPayment">—</span>
                    </div>
                </div>

            </div>

            <!-- Order details table -->
            <p class="modal-section-title">Order details</p>
            <div class="detail-table-wrap">
            <table class="detail-table">
                <thead>
                    <tr>
                        <th>Product name</th>
                        <th>Unit of measurement</th>
                        <th>Unit price</th>
                        <th>Total amount</th>
                        <th>Product quantity</th>
                    </tr>
                </thead>
                <tbody id="detailItems">
                    <tr>
                        <td colspan="5"
                            style="text-align:center; color:#94a3b8; padding:16px;">
                            No items
                        </td>
                    </tr>
                </tbody>
            </table>
            </div>

            <!-- Payment summary -->
            <div class="summary-box">
                <div class="summary-box-title">Payment summary</div>
                <div class="summary-row">
                    <span>Total amount of goods:</span>
                    <span id="detailSubtotal">—</span>
                </div>
                <div class="summary-row">
                    <span>Total discount of goods:</span>
                    <span id="detailDiscount">—</span>
                </div>
            </div>

            <!-- Total amount -->
            <div class="total-box">
                <div class="total-box-title">Total amount</div>
                <div class="summary-row">
                    <span>Customer payment:</span>
                    <span id="detailPaid">—</span>
                </div>
                <div class="summary-row">
                    <span>Change:</span>
                    <span id="detailChange">—</span>
                </div>
            </div>

        </div><!-- /.modal-body -->
    </div><!-- /.modal-box -->
</div><!-- /.modal-overlay -->

<script src="${pageContext.request.contextPath}/resources/js/pos/receipt.js"></script>
</body>
</html>
