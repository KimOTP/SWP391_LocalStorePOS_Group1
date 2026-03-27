<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html>
<head>
    <title>Payment</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/pos/payment.css">
    <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</head>
<body>

<jsp:include page="../../layer/header.jsp" />
<jsp:include page="../../layer/sidebar.jsp" />

<div class="pay-container">

    <!-- PAGE HEADER -->
    <div class="pay-page-header">
        <div class="pay-page-title">
            <a href="${pageContext.request.contextPath}/pos" class="pay-back-btn">
                <i class="fa-solid fa-arrow-left"></i>
            </a>
            <div>
                <h2>Payment</h2>
                <span class="pay-invoice-meta">
                    Invoice number: <strong>${order.orderId}</strong>
                    &nbsp;|&nbsp; Employee: <strong>${sessionScope.account.employee.fullName}</strong>
                </span>
            </div>
        </div>

    </div>

    <!-- MAIN GRID: 3 columns -->
    <div class="pay-grid">

        <!-- ── COL 1: ORDER DETAILS ── -->
        <div class="pay-card">
            <div class="pay-card-header">
                <i class="fa-solid fa-receipt"></i> Order details
            </div>
            <div class="pay-card-body order-items-area">
                <table class="order-table">
                    <thead>
                        <tr>
                            <th>Product</th>
                            <th class="text-end">Total amount</th>
                        </tr>
                    </thead>
                    <tbody id="orderItemsBody">
                        <%-- Order items được load từ session JSON bởi JS bên dưới --%>
                    </tbody>
                </table>

                <%-- ── DISCOUNT SECTION (from summary) ── --%>
                <c:if test="${not empty summary and not empty summary.items}">
                    <%-- Kiểm tra có ít nhất 1 item có discount --%>
                    <c:set var="hasAnyDiscount" value="false"/>
                    <c:forEach var="item" items="${summary.items}">
                        <c:if test="${item.discountAmount != null and item.discountAmount.doubleValue() > 0}">
                            <c:set var="hasAnyDiscount" value="true"/>
                        </c:if>
                    </c:forEach>

                    <c:if test="${hasAnyDiscount}">
                    <div class="promo-section" id="promoSection">
                        <div class="promo-section-header">
                            <i class="fa-solid fa-tag"></i> Promotions applied
                        </div>
                        <table class="promo-table">
                            <tbody>
                                <c:forEach var="item" items="${summary.items}">
                                    <c:if test="${item.discountAmount != null and item.discountAmount.doubleValue() > 0}">
                                        <tr class="promo-row">
                                            <td class="promo-product">
                                                <span class="promo-product-name"><c:out value="${item.productName}"/></span>
                                                <c:if test="${not empty item.promotionNote}">
                                                    <%-- Phân loại badge: % màu cam, tiền cố định màu xanh lá --%>
                                                    <c:choose>
                                                        <c:when test="${fn:contains(item.promotionNote, '%')}">
                                                            <span class="promo-badge promo-badge--percent"><c:out value="${item.promotionNote}"/></span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="promo-badge promo-badge--amount"><c:out value="${item.promotionNote}"/></span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </c:if>
                                            </td>
                                            <td class="promo-discount text-end">
                                                −<fmt:formatNumber value="${item.discountAmount}" maxFractionDigits="0"/>đ
                                            </td>
                                        </tr>
                                    </c:if>
                                </c:forEach>
                            </tbody>
                        </table>
                        <c:if test="${summary.totalDiscount != null and summary.totalDiscount.doubleValue() > 0}">
                            <div class="promo-total-row">
                                <span>Total promotion discount:</span>
                                <span class="promo-total-val">
                                    −<fmt:formatNumber value="${summary.totalDiscount}" maxFractionDigits="0"/>đ
                                </span>
                            </div>
                        </c:if>
                    </div>
                    </c:if>
                </c:if>
            </div>

            <!-- Totals -->
            <div class="pay-totals">
                <div class="pay-total-row">
                    <span>Total amount:</span>
                    <span class="amount-val" id="subtotalVal">
                        <fmt:formatNumber value="${order.totalAmount}" maxFractionDigits="0"/>đ
                    </span>
                </div>
                <div class="pay-total-row discount">
                    <span>Discounts:</span>
                    <span class="discount-val" id="discountVal">−0đ</span>
                </div>
                <div class="pay-total-row grand-total">
                    <span>Total:</span>
                    <span class="grand-val" id="grandTotalVal">
                        <fmt:formatNumber value="${order.totalAmount}" maxFractionDigits="0"/>đ
                    </span>
                </div>
            </div>
        </div>

        <!-- ── COL 2: PAYMENT INFO ── -->
        <div class="pay-card">
            <div class="pay-card-header">
                <i class="fa-solid fa-money-bill-wave"></i> Payment information
            </div>
            <div class="pay-card-body">

                <!-- Payment method -->
                <div class="pay-field-group">
                    <label class="pay-label">Payment methods:</label>
                    <div class="pay-radio-group">
                        <label class="pay-radio" id="lbl-cash">
                            <input type="radio" name="payMethod" value="cash" checked onchange="onPayMethodChange(this)">
                            <span class="radio-custom"></span>
                            <span>Payment by cash</span>
                        </label>
                        <label class="pay-radio" id="lbl-bank">
                            <input type="radio" name="payMethod" value="bank" onchange="onPayMethodChange(this)">
                            <span class="radio-custom"></span>
                            <span>Payment via banking</span>
                        </label>
                    </div>
                </div>

                <!-- Customer payment (cash) -->
                <div id="cashSection">
                    <div class="pay-field-group">
                        <label class="pay-label">Customer payment (VND):</label>
                        <input type="text" class="pay-input" id="customerPaid"
                               placeholder="0"
                               oninput="calcChange(this.value)">
                    </div>
                    <div class="pay-field-group">
                        <label class="pay-label">Change (VND):</label>
                        <input type="text" class="pay-input pay-input-readonly" id="changeAmount"
                               readonly value="0">
                    </div>
                </div>

                <!-- Customer info -->
                <div class="pay-section-label">Customer information</div>

                <!-- Phone input -->
                <div class="pay-field-group">
                    <label class="pay-label">Customer's phone number:</label>
                    <div class="pay-input-icon-wrap">
                        <i class="fa-solid fa-magnifying-glass pay-input-icon" id="phoneIcon"></i>
                        <input type="text" class="pay-input pay-input-search" id="customerPhone"
                               placeholder="0925558666" maxlength="10"
                               oninput="lookupCustomer(this.value)">
                        <!-- Spinner while looking up -->
                        <span class="phone-spinner" id="phoneSpinner" style="display:none">
                            <i class="fa-solid fa-spinner fa-spin"></i>
                        </span>
                    </div>
                </div>

                <%-- ── STATE A: chưa nhập / đang gõ ── --%>
                <div id="custStateIdle" class="cust-state">
                    <p class="cust-hint"><i class="fa-solid fa-circle-info"></i> Enter phone number to look up customer</p>
                </div>

                <%-- ── STATE B: đã tìm thấy khách hàng ── --%>
                <div id="custStateFound" class="cust-state" style="display:none">
                    <div class="cust-found-card">
                        <div class="cust-found-avatar" id="custAvatar">K</div>
                        <div class="cust-found-info">
                            <div class="cust-found-name" id="custFoundName">–</div>
                            <div class="cust-found-meta">
                                <span id="custFoundPhone">–</span>
                                <span class="cust-point-badge">
                                    <i class="fa-solid fa-star"></i>
                                    <span id="custFoundPoints">0</span> pts
                                </span>
                            </div>
                        </div>
                        <button class="cust-clear-btn" onclick="clearCustomer()" title="Remove customer">
                            <i class="fa-solid fa-xmark"></i>
                        </button>
                    </div>

                    <div class="pay-field-group" style="margin-top:10px">
                        <label class="pay-label">Customer name:</label>
                        <input type="text" class="pay-input pay-input-readonly" id="customerName"
                               readonly placeholder="–">
                    </div>

                    <%-- Thông tin điểm + quy đổi --%>
                    <div class="cust-point-summary">
                        <div class="cust-point-summary-row">
                            <span class="cust-point-summary-label">
                                <i class="fa-solid fa-star"></i> Available points
                            </span>
                            <span class="cust-point-summary-val" id="custPointDisplay">0 pts</span>
                        </div>
                        <div class="cust-point-summary-row">
                            <span class="cust-point-summary-label">
                                <i class="fa-solid fa-arrow-right-arrow-left"></i> Max redeemable
                            </span>
                            <span class="cust-point-summary-val text-blue" id="custMaxRedeemDisplay">0 pts</span>
                        </div>
                        <div class="cust-point-summary-divider"></div>
                        <div class="cust-point-config-hint" id="custPointConfigHint">
                            <%-- filled by JS --%>
                        </div>
                    </div>

                    <div class="pay-field-group">
                        <label class="pay-label">Use loyalty points:</label>
                        <div class="pay-loyalty-row">
                            <input type="number" class="pay-input" id="usePoints"
                                   placeholder="0" min="0"
                                   oninput="applyLoyaltyPoints(this.value)">
                            <span class="pay-loyalty-avail" id="loyaltyAvail">= 0đ</span>
                        </div>
                        <div class="cust-point-warn" id="custPointWarn" style="display:none"></div>
                    </div>
                </div>

                <%-- ── STATE C: không tìm thấy → hiện nút Add ── --%>
                <div id="custStateNotFound" class="cust-state" style="display:none">
                    <div class="cust-not-found-box">
                        <i class="fa-solid fa-user-slash cust-nf-icon"></i>
                        <p class="cust-nf-msg">No customer found with this phone number.</p>
                        <button class="cust-add-btn" onclick="openAddCustomer()">
                            <i class="fa-solid fa-user-plus"></i> Add new customer
                        </button>
                    </div>
                </div>

                <%-- ── INLINE ADD FORM (hidden by default) ── --%>
                <div id="custAddForm" class="cust-state cust-add-form-wrap" style="display:none">
                    <div class="cust-add-form-header">
                        <i class="fa-solid fa-user-plus"></i> New customer
                    </div>
                    <div class="pay-field-group">
                        <label class="pay-label">Full name <span class="req">*</span></label>
                        <input type="text" class="pay-input" id="newCustName"
                               placeholder="Nguyen Van A">
                    </div>
                    <div class="pay-field-group">
                        <label class="pay-label">Phone number</label>
                        <input type="text" class="pay-input pay-input-readonly" id="newCustPhone"
                               readonly>
                    </div>
                    <div class="cust-add-form-actions">
                        <button class="cust-cancel-add-btn" onclick="cancelAddCustomer()">
                            <i class="fa-solid fa-xmark"></i> Cancel
                        </button>
                        <button class="cust-save-btn" onclick="saveNewCustomer()">
                            <i class="fa-solid fa-floppy-disk"></i> Save
                        </button>
                    </div>
                </div>

                <!-- Hidden field giữ customerId để gửi lên server -->
                <input type="hidden" id="customerId" value="">

                <div class="pay-field-group">
                    <label class="pay-label">Note:</label>
                    <textarea class="pay-textarea" id="orderNote"
                              placeholder="Enter a note..."></textarea>
                </div>

            </div>

            <!-- Action buttons -->
            <div class="pay-actions">
                <button class="pay-btn-cancel" onclick="cancelOrder()">
                    <i class="fa-solid fa-xmark me-1"></i> Cancel order
                </button>
                <button class="pay-btn-pay" onclick="confirmPayment()">
                    <i class="fa-solid fa-check me-1"></i> Pay
                </button>
            </div>
        </div>

        <!-- ── COL 3: QR CODE ── -->
        <div class="pay-card pay-card-qr">
            <div class="pay-card-header">
                <i class="fa-solid fa-qrcode"></i> QR code for payment
            </div>
            <div class="pay-card-body qr-body">

                <!-- STATE: idle -->
                <div id="qrStateIdle" class="qr-state">
                    <div class="qr-idle-wrap">
                        <div class="qr-idle-icon">
                            <i class="fa-solid fa-credit-card"></i>
                        </div>
                        <p class="qr-idle-title">Banking payment</p>
                        <p class="qr-idle-desc">Select <strong>Payment via banking</strong><br>then press <strong>Pay</strong> to generate QR</p>
                    </div>
                </div>

                <!-- STATE: loading -->
                <div id="qrStateLoading" class="qr-state" style="display:none">
                    <div class="qr-loading-wrap">
                        <div class="qr-loading-ring">
                            <svg viewBox="0 0 44 44" class="qr-spinner-svg">
                                <circle cx="22" cy="22" r="18" fill="none" stroke-width="3"/>
                            </svg>
                            <i class="fa-solid fa-qrcode qr-loading-icon"></i>
                        </div>
                        <p class="qr-loading-title">Generating QR code...</p>
                        <p class="qr-loading-desc">Connecting to PayOS</p>
                    </div>
                </div>

                <!-- STATE: ready — PayOS checkout iframe -->
                <div id="qrStateReady" class="qr-state" style="display:none">
                    <span id="qrAmount" style="display:none">0đ</span>
                    <div class="qr-iframe-wrap">
                        <iframe id="qrIframe"
                                src=""
                                frameborder="0"
                                scrolling="no"
                                allowtransparency="true"
                                class="qr-iframe">
                        </iframe>
                    </div>
                    <div id="qrStatusBadge" class="qr-status-badge" style="display:none"></div>
                </div>

            </div>
        </div>

    </div><!-- /pay-grid -->
</div><!-- /pay-container -->

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
window.PAGE_DATA = {
    orderId     : '${order.orderId}',
    totalAmount : parseFloat('${order.totalAmount}') || 0,
    contextPath : '${pageContext.request.contextPath}',

    summary : {
        totalDiscount : parseFloat('${summary.totalDiscount}') || 0,
        items : [
            <c:forEach var="item" items="${summary.items}" varStatus="loop">
            {
                productId     : '${item.productId}',
                productName   : '${item.productName}',
                quantity      : ${item.quantity},
                originalPrice : parseFloat('${item.originalPrice}')  || 0,
                discountAmount: parseFloat('${item.discountAmount}') || 0,
                finalLineTotal: parseFloat('${item.finalLineTotal}') || 0,
                promotionNote : '${item.promotionNote}'
            }<c:if test="${!loop.last}">,</c:if>
            </c:forEach>
        ]
    },

    bank : {
        bankName  : '${sessionScope.posBankConfig.bankName}',
        accNumber : '${sessionScope.posBankConfig.accountNumber}',
        accName   : '${sessionScope.posBankConfig.accountName}'
    },

    pointConfig : {
        earningRate     : parseFloat('${pointConfig["POINT_EARNING_RATE"]}')     || 10000,
        redemptionValue : parseFloat('${pointConfig["POINT_REDEMPTION_VALUE"]}') || 1000,
        maxRedeemPercent: parseFloat('${pointConfig["MAX_REDEEM_PERCENT"]}')     || 30,
        minPointToRedeem: parseFloat('${pointConfig["MIN_POINT_TO_REDEEM"]}')    || 100
    }
};

// Backward-compat aliases (payment.js vẫn đọc các window.xxx cũ)
window.orderId      = PAGE_DATA.orderId;
window.totalAmount  = PAGE_DATA.totalAmount;
window.contextPath  = PAGE_DATA.contextPath;
window.summaryData  = PAGE_DATA.summary;
window.bankSettings = PAGE_DATA.bank;
window.pointConfig  = PAGE_DATA.pointConfig;

// Fallback bankSettings từ cookie nếu session bị mất (logout/login) ──
(function () {
    const b = window.bankSettings || {};
    const sessionEmpty = !b.bankName && !b.accNumber && !b.accName;

    function getCookie(name) {
        const match = document.cookie.match('(?:^|;)\\s*' + name + '=([^;]*)');
        return match ? decodeURIComponent(match[1]) : null;
    }

    if (sessionEmpty) {
        // Đọc từ cookie pos_bank_config
        const raw = getCookie('pos_bank_config');
        if (raw) {
            try {
                const saved = JSON.parse(raw);
                window.bankSettings = saved;
                PAGE_DATA.bank = saved;
            } catch(e) {}
        }
    } else {
        // Session có config → ghi đè cookie để luôn mới nhất
        const val = encodeURIComponent(JSON.stringify({
            bankName  : b.bankName  || '',
            accNumber : b.accNumber || '',
            accName   : b.accName   || ''
        }));
        // Max-Age 30 ngày
        document.cookie = 'pos_bank_config=' + val + '; path=/; max-age=2592000; SameSite=Lax';
    }
})();
</script>
<script src="${pageContext.request.contextPath}/resources/js/pos/payment.js"></script>

</body>
</html>
