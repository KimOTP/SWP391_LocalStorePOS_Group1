<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html>
<head>
    <title>POS Screen</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/pos/pos.css">
</head>
<body>

<jsp:include page="../../layer/header.jsp" />
<jsp:include page="../../layer/sidebar.jsp" />

<div class="pos-container">

    <!-- TOP BAR -->
    <div class="pos-top-bar flex-wrap gap-2">
        <c:if test="${sessionScope.account.employee.role == 'MANAGER'}">
            <button class="btn-outline" onclick="openPrintTemplate()">
                <i class="fa-solid fa-print me-1"></i> Setting print template
            </button>
            <button class="btn-outline" onclick="openBankConfig()">
                <i class="fa-solid fa-building-columns me-1"></i> Account banking configuration
            </button>
        </c:if>

        <input type="text" class="search-box" placeholder="Search for products">

        <select class="category-select" name="categoryId">
            <option value="">All categories</option>
            <c:forEach var="category" items="${categories}">
                <option value="${category.categoryId}">${category.categoryName}</option>
            </c:forEach>
        </select>
    </div>

    <!-- MAIN CONTENT -->
    <div class="pos-content flex-column flex-lg-row">

        <!-- PRODUCT LIST -->
        <div class="product-area">
            <div class="product-grid">
                <c:forEach items="${products}" var="p">
                    <div class="product-card"
                         onclick="addToCart('${p.productId}','${p.productName}','${p.price}','${p.unit}')">
                        <div class="product-img">
                            <img src="${p.imageUrl}" alt="${p.productName}"
                                 onerror="this.src='${pageContext.request.contextPath}/resources/img/no-image.jpg'"/>
                        </div>
                        <div class="product-name">${p.productName}</div>
                        <div class="product-unit">${p.unit}</div>
                        <div class="product-price"><fmt:formatNumber value="${p.price}" maxFractionDigits="0"/>đ</div>
                        <div class="add-btn">+</div>
                    </div>
                </c:forEach>
            </div>
        </div>

        <!-- CART -->
        <div class="cart-area">
            <div class="cart-header">
                <h3>Shopping cart</h3>
                <button class="btn-danger" onclick="clearCart()">Delete all</button>
            </div>

            <div id="emptyCart" class="cart-empty">
                <img src="${pageContext.request.contextPath}/resources/static/images/empty_cart.png" width="80">
                <p>The shopping cart is empty.</p>
            </div>

            <div id="cartItems" style="display:none">
                <div id="itemList"></div>
                <div class="cart-summary">
                    <div class="summary-row">
                        <span>Estimate Discount:</span>
                        <span>0đ</span>
                    </div>
                    <div class="summary-row total">
                        <span>Total:</span>
                        <span><span id="totalPrice">0</span>đ</span>
                    </div>
                </div>
                <button class="btn-pay w-100" onclick="openPayAndPrint()">
                    <i class="fa-solid fa-print me-2"></i>Pay &amp; Print
                </button>
            </div>
        </div>
    </div>
</div>

<!-- =====================================================
     MODAL: SETTING PRINT TEMPLATE
====================================================== -->
<div class="pt-overlay" id="printTemplateModal">
    <div class="pt-modal">

        <!-- HEADER -->
        <div class="pt-header">
            <div class="pt-header-title">
                <i class="fa-solid fa-print"></i>
                Setting print template
            </div>
            <button class="pt-close" onclick="closePrintTemplate()">
                <i class="fa-solid fa-xmark"></i>
            </button>
        </div>

        <!-- TABS -->
        <div class="pt-tabs">
            <button class="pt-tab active" id="tab-invoice" onclick="switchTab('invoice')">Sales invoice</button>
            <button class="pt-tab" id="tab-report" onclick="switchTab('report')">Report</button>
        </div>

        <!-- BODY: Form + Preview side by side -->
        <div class="pt-body">

            <!-- LEFT: FORM -->
            <div class="pt-form">

                <!-- INVOICE -->
                <div id="content-invoice">
                    <div class="pt-section-badge">
                        <i class="fa-solid fa-file-invoice"></i> Setting sales invoice template
                    </div>

                    <div class="pt-field-group">
                        <label class="pt-label">Paper size</label>
                        <select class="pt-select" id="inv-paper-size" onchange="updatePreview()">
                            <option value="58mm">58 mm (Thermal printer)</option>
                            <option value="80mm">80 mm (Thermal printer)</option>
                            <option value="A4">A4</option>
                        </select>
                        <i class="fa-solid fa-chevron-down pt-select-icon"></i>
                    </div>

                    <div class="pt-field-group">
                        <label class="pt-label">Font size</label>
                        <select class="pt-select" id="inv-font-size" onchange="updatePreview()">
                            <option value="10">Small – 10px</option>
                            <option value="12" selected>Medium – 12px</option>
                            <option value="14">Large – 14px</option>
                        </select>
                        <i class="fa-solid fa-chevron-down pt-select-icon"></i>
                    </div>

                    <div class="pt-field-group">
                        <label class="pt-label">Invoice Title</label>
                        <input class="pt-input" type="text" id="inv-title" value="Sales invoice" oninput="updatePreview()">
                    </div>

                    <div class="pt-field-group">
                        <label class="pt-label">Expression of gratitude</label>
                        <input class="pt-input" type="text" id="inv-thanks" value="Thank you for your purchase." oninput="updatePreview()">
                    </div>

                    <div class="pt-section-label">Company information</div>

                    <div class="pt-field-group">
                        <label class="pt-label">Company name</label>
                        <input class="pt-input" type="text" id="inv-company" value="Local store POS system" oninput="updatePreview()">
                    </div>

                    <div class="pt-field-group">
                        <label class="pt-label">Address</label>
                        <input class="pt-input" type="text" id="inv-address" value="123 Đường ABC, Hòa Lạc, thành phố Hà Nội" oninput="updatePreview()">
                    </div>

                    <div class="pt-row-2">
                        <div class="pt-field-group">
                            <label class="pt-label">Phone number</label>
                            <input class="pt-input" type="text" id="inv-phone" value="0956328396" oninput="updatePreview()">
                        </div>
                        <div class="pt-field-group">
                            <label class="pt-label">Email</label>
                            <input class="pt-input" type="text" id="inv-email" value="info@gmail.com" oninput="updatePreview()">
                        </div>
                    </div>
                </div>

                <!-- REPORT -->
                <div id="content-report" style="display:none">
                    <div class="pt-section-badge">
                        <i class="fa-solid fa-chart-bar"></i> Setting report template
                    </div>
                    <div class="pt-field-group">
                        <label class="pt-label">Paper size</label>
                        <select class="pt-select" id="rep-paper-size">
                            <option value="58mm">58 mm (Thermal printer)</option>
                            <option value="80mm">80 mm (Thermal printer)</option>
                            <option value="A4">A4</option>
                        </select>
                        <i class="fa-solid fa-chevron-down pt-select-icon"></i>
                    </div>
                </div>

            </div>

            <!-- RIGHT: PREVIEW -->
            <div class="pt-preview">
                <div class="pt-preview-label">
                    <i class="fa-regular fa-eye"></i> Preview
                </div>

                <div class="pt-paper">
                    <!-- Invoice receipt preview -->
                    <div id="preview-invoice" class="receipt">
                        <div class="r-logo">LOGO</div>
                        <div class="r-company" id="rp-company">Local store POS system</div>
                        <div class="r-addr" id="rp-address">123 Đường ABC, Hòa Lạc, Hà Nội</div>
                        <div class="r-phone" id="rp-phone">0956328396 | info@gmail.com</div>
                        <div class="r-dash">- - - - - - - - - - - - - -</div>
                        <div class="r-title" id="rp-title">SALES INVOICE</div>
                        <div class="r-date" id="rp-date"></div>
                        <div class="r-dash">- - - - - - - - - - - - - -</div>
                        <table class="r-items">
                            <tr><td>Pepsi 330ml</td><td class="text-end">2 × 10,000đ</td></tr>
                            <tr><td>Banh Mi Pate</td><td class="text-end">1 × 20,000đ</td></tr>
                            <tr><td>Coca Cola</td><td class="text-end">1 × 15,000đ</td></tr>
                        </table>
                        <div class="r-dash">- - - - - - - - - - - - - -</div>
                        <div class="r-total">
                            <span>Total</span><span>55,000đ</span>
                        </div>
                        <div class="r-dash">- - - - - - - - - - - - - -</div>
                        <div class="r-thanks" id="rp-thanks">Thank you for your purchase.</div>
                        <div class="r-barcode">||| |||||||| ||||| |||||||||</div>
                    </div>

                    <!-- Report preview -->
                    <div id="preview-report" class="receipt" style="display:none">
                        <div class="r-title" style="margin-bottom:6px;">BÁO CÁO</div>
                        <div class="r-date" id="rp-report-date"></div>
                        <div class="r-dash">- - - - - - - - - - - - - -</div>
                        <div style="font-size:9px;text-align:center;color:#94a3b8;margin-top:10px;">
                            template: report
                        </div>
                    </div>
                </div>

                <button class="pt-apply-btn" onclick="applyTemplate()">
                    <i class="fa-solid fa-check me-1"></i> Apply
                </button>
            </div>

        </div>
    </div>
</div>

<!-- =====================================================
     MODAL: BANK CONFIG
====================================================== -->
<div class="pt-overlay" id="bankConfigModal">
    <div class="pt-modal" style="max-width:420px;">
        <div class="pt-header">
            <div class="pt-header-title">
                <i class="fa-solid fa-building-columns"></i>
                Configure your bank account
            </div>
            <button class="pt-close" onclick="closeModal('bankConfigModal')">
                <i class="fa-solid fa-xmark"></i>
            </button>
        </div>
        <div class="pt-form" style="padding:20px 24px 24px;">
            <div class="pt-field-group">
                <label class="pt-label">Choose a bank</label>
                <select class="pt-select">
                    <option value="">-- Choose a bank --</option>
                    <option>Vietcombank</option>
                    <option>Techcombank</option>
                    <option>MB Bank</option>
                    <option>VPBank</option>
                    <option>BIDV</option>
                </select>
                <i class="fa-solid fa-chevron-down pt-select-icon"></i>
            </div>
            <div class="pt-field-group">
                <label class="pt-label">Account number</label>
                <input class="pt-input" type="text" placeholder="Enter account number">
            </div>
            <div class="pt-field-group">
                <label class="pt-label">Account name</label>
                <input class="pt-input" type="text" placeholder="Enter account name">
            </div>
            <div class="pt-footer">
                <button class="pt-btn-cancel" onclick="closeModal('bankConfigModal')">Cancel</button>
                <button class="pt-btn-save">
                    <i class="fa-solid fa-floppy-disk me-1"></i> Save
                </button>
            </div>
        </div>
    </div>
</div>

<!-- PRINT AREA (hidden, used for window.print()) -->
<div id="printArea" style="display:none;"></div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    window.userRole = '${sessionScope.account.employee.role}';
</script>
<script src="${pageContext.request.contextPath}/resources/js/pos/pos.js"></script>

</body>
</html>
