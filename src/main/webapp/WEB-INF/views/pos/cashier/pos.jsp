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

    <!-- TOP BAR: Buttons + Search + Category + Price Dropdown -->
    <div class="pos-top-bar">
        <c:if test="${sessionScope.account.employee.role == 'MANAGER'}">
            <button class="btn-outline" onclick="openPrintTemplate()">
                <i class="fa-solid fa-print"></i> Setting print template
            </button>
            <button class="btn-outline" onclick="openBankConfig()">
                <i class="fa-solid fa-building-columns"></i> Account banking configuration
            </button>
        </c:if>

        <input type="text" class="search-box" id="mainSearchBox" placeholder="Search products / SKU-PROD-# / SKU-COM-# / F1">

        <!-- Category Dropdown -->
        <div class="pos-dropdown" id="categoryDropdown">
            <div class="pos-dropdown-selected" onclick="toggleCategoryDropdown()">
                <span id="selectedCategoryText">Select category</span>
                <span class="pos-dropdown-arrow"></span>
            </div>
            <div class="pos-dropdown-menu" id="categoryMenu">
                <div class="pos-dropdown-item" onclick="selectCategory('', 'Select category')">
                    All categories
                </div>
                <c:forEach var="c" items="${categories}">
                    <div class="pos-dropdown-item"
                         onclick="selectCategory('${c.categoryId}', '${c.categoryName}')">
                        ${c.categoryName}
                    </div>
                </c:forEach>
            </div>
        </div>

        <!-- Price Range Dropdown -->
        <div class="pos-dropdown price-dropdown" id="priceDropdown">
            <div class="pos-dropdown-selected" onclick="togglePriceDropdown()">
                <i class="fa-solid fa-tag" style="color:var(--sb-blue);font-size:0.8rem;"></i>
                <span id="selectedPriceText">All prices</span>
                <span class="pos-dropdown-arrow"></span>
            </div>
            <div class="pos-dropdown-menu price-dropdown-menu" id="priceMenu">
                <div class="pos-dropdown-item" onclick="selectPriceRange(0, 0, 'All prices')">
                    All prices
                </div>
                <!-- Options populated dynamically by JS -->
            </div>
        </div>
    </div>

    <!-- MAIN CONTENT: products scroll, cart fixed height -->
    <div class="pos-content">

        <!-- PRODUCT LIST (scrollable) -->
        <div class="product-area">

            <%-- ── COMBO SECTION ── --%>
            <c:if test="${not empty combos}">
                <div class="product-section-label">
                    <i class="fa-solid fa-layer-group"></i> Combo
                </div>
                <div class="product-grid combo-grid" id="comboGrid">
                    <c:forEach items="${combos}" var="combo">
                        <div class="product-card combo-card"
                             data-price="${combo.totalPrice}"
                             data-id="COMBO_${combo.comboId}"
                             data-sku="SKU-COM-${combo.comboId}"
                             onclick="addToCart('COMBO_${combo.comboId}','${combo.comboName}','${combo.totalPrice}','combo')">
                            <div class="product-img">
                                <img src="${combo.imageUrl}" alt="${combo.comboName}"
                                     onerror="this.src='${pageContext.request.contextPath}/resources/img/no-image.jpg'"/>
                            </div>
                            <div class="product-name">${combo.comboName}</div>
                            <div class="product-unit">combo</div>
                            <div class="product-price"><fmt:formatNumber value="${combo.totalPrice}" maxFractionDigits="0"/>đ</div>
                            <div class="add-btn">+</div>
                        </div>
                    </c:forEach>
                </div>
                <div class="product-section-divider"></div>
            </c:if>

            <%-- ── PRODUCT SECTION ── --%>
            <c:if test="${not empty combos}">
                <div class="product-section-label">
                    <i class="fa-solid fa-box-open"></i> Product
                </div>
            </c:if>
            <div class="product-grid" id="productGrid">
                <c:forEach items="${products}" var="p">
                    <div class="product-card"
                         data-price="${p.price}"
                         data-id="${p.productId}"
                         data-sku="SKU-PROD-${p.productId}"
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

        <!-- CART (fixed height, items scroll internally) -->
        <div class="cart-area">

            <!-- HEADER (fixed) -->
            <div class="cart-header">
                <div class="cart-title-wrap">
                    <i class="fa-solid fa-cart-shopping cart-icon"></i>
                    <h3>Shopping cart</h3>
                    <span class="cart-count-badge" id="cartCountBadge" style="display:none">0</span>
                </div>
                <button class="btn-danger" onclick="clearCart()">
                    <i class="fa-solid fa-trash-can me-1"></i>Delete all
                </button>
            </div>

            <!-- EMPTY STATE -->
            <div id="emptyCart" class="cart-empty">
                <div class="cart-empty-icon"><i class="fa-solid fa-cart-shopping"></i></div>
                <p>The shopping cart is empty.</p>
            </div>

            <!-- ITEMS (scrollable zone) -->
            <div id="cartItems" class="cart-items-wrap" style="display:none">
                <div id="itemList" class="cart-item-list"></div>
            </div>

            <!-- FOOTER (fixed): total + pay button -->
            <div class="cart-footer" id="cartFooter" style="display:none">
                <div class="summary-row total">
                    <span>Total:</span>
                    <span class="total-amount"><span id="totalPrice">0</span>đ</span>
                </div>
                <button class="btn-pay" onclick="goToPayment()">
                    <i class="fa-solid fa-credit-card me-2"></i>PAY
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
        <div class="pt-header">
            <div class="pt-header-title">
                <i class="fa-solid fa-print"></i> Setting print template
            </div>
            <button class="pt-close" onclick="closePrintTemplate()">
                <i class="fa-solid fa-xmark"></i>
            </button>
        </div>
        <div class="pt-tabs">
            <button class="pt-tab active" id="tab-invoice">Sales invoice</button>
        </div>
        <div class="pt-body">
            <div class="pt-form">
                <div id="content-invoice">
                    <div class="pt-section-badge"><i class="fa-solid fa-file-invoice"></i> Setting sales invoice template</div>
                    <div class="pt-field-group">
                        <label class="pt-label">Paper size</label>
                        <div class="pt-dd" id="dd-paper-size">
                            <div class="pt-dd-selected" onclick="togglePtDd('dd-paper-size')">
                                <span class="pt-dd-label" id="dd-paper-size-label">58 mm (Thermal printer)</span>
                                <span class="pt-dd-arrow"></span>
                            </div>
                            <div class="pt-dd-menu">
                                <div class="pt-dd-item" onclick="selectPtDd('dd-paper-size','58mm','58 mm (Thermal printer)')">58 mm (Thermal printer)</div>
                                <div class="pt-dd-item" onclick="selectPtDd('dd-paper-size','80mm','80 mm (Thermal printer)')">80 mm (Thermal printer)</div>
                                <div class="pt-dd-item" onclick="selectPtDd('dd-paper-size','A4','A4')">A4</div>
                            </div>
                        </div>
                        <input type="hidden" id="inv-paper-size" value="58mm">
                    </div>
                    <div class="pt-field-group">
                        <label class="pt-label">Font size</label>
                        <div class="pt-dd" id="dd-font-size">
                            <div class="pt-dd-selected" onclick="togglePtDd('dd-font-size')">
                                <span class="pt-dd-label" id="dd-font-size-label">Medium – 12px</span>
                                <span class="pt-dd-arrow"></span>
                            </div>
                            <div class="pt-dd-menu">
                                <div class="pt-dd-item" onclick="selectPtDd('dd-font-size','10','Small – 10px')">Small – 10px</div>
                                <div class="pt-dd-item" onclick="selectPtDd('dd-font-size','12','Medium – 12px')">Medium – 12px</div>
                                <div class="pt-dd-item" onclick="selectPtDd('dd-font-size','14','Large – 14px')">Large – 14px</div>
                            </div>
                        </div>
                        <input type="hidden" id="inv-font-size" value="12">
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
            </div>
            <div class="pt-preview">
                <div class="pt-preview-label"><i class="fa-regular fa-eye"></i> Preview</div>
                <div class="pt-paper">
                    <div id="preview-invoice" class="receipt">
                        <div class="r-logo">LOGO</div>
                        <div class="r-company" id="rp-company">Local store POS system</div>
                        <div class="r-addr"    id="rp-address">123 Đường ABC, Hòa Lạc, Hà Nội</div>
                        <div class="r-phone"   id="rp-phone">0956328396 | info@gmail.com</div>
                        <div class="r-dash">- - - - - - - - - - - - - -</div>
                        <div class="r-title"   id="rp-title">SALES INVOICE</div>
                        <div class="r-date"    id="rp-date"></div>
                        <div class="r-dash">- - - - - - - - - - - - - -</div>
                        <table class="r-items">
                            <tr><td>Pepsi 330ml</td><td class="text-end">2×10,000đ</td></tr>
                            <tr><td>Banh Mi Pate</td><td class="text-end">1×20,000đ</td></tr>
                            <tr><td>Coca Cola</td><td class="text-end">1×15,000đ</td></tr>
                        </table>
                        <div class="r-dash">- - - - - - - - - - - - - -</div>
                        <div class="r-total"><span>Total</span><span>55,000đ</span></div>
                        <div class="r-dash">- - - - - - - - - - - - - -</div>
                        <div class="r-thanks" id="rp-thanks">Thank you for your purchase.</div>
                        <div class="r-barcode">||| |||||||| ||||| |||||||||</div>
                    </div>
                </div>
                <button class="pt-apply-btn" onclick="applyTemplate()">
                    <i class="fa-solid fa-check me-1"></i> Apply
                </button>
            </div>
        </div>
    </div>
</div>

<!-- MODAL: BANK CONFIG -->
<div class="pt-overlay" id="bankConfigModal">
    <div class="pt-modal" style="max-width:440px;">
        <div class="pt-header">
            <div class="pt-header-title"><i class="fa-solid fa-building-columns"></i> Configure your bank account</div>
            <button class="pt-close" onclick="closeModal('bankConfigModal')"><i class="fa-solid fa-xmark"></i></button>
        </div>
        <div class="pt-form" style="padding:20px 24px 24px;">
            <div class="pt-field-group">
                <label class="pt-label">Choose a bank</label>
                <!-- Custom bank dropdown -->
                <div class="bank-dropdown" id="bankDropdown">
                    <div class="bank-dropdown-selected" onclick="toggleBankDropdown()">
                        <div class="bank-selected-content" id="bankSelectedContent">
                            <span class="bank-placeholder">-- Choose a bank --</span>
                        </div>
                        <span class="pos-dropdown-arrow"></span>
                    </div>
                    <div class="bank-dropdown-menu" id="bankDropdownMenu">
                        <div class="bank-search-wrap">
                            <input class="bank-search-input" id="bankSearchInput"
                                   type="text" placeholder="Tìm kiếm ngân hàng..."
                                   oninput="filterBanks(this.value)" onclick="event.stopPropagation()">
                        </div>
                        <div class="bank-list" id="bankList">
                            <!-- Populated by JS -->
                        </div>
                    </div>
                </div>
                <input type="hidden" id="selectedBankCode" value="">
            </div>
            <div class="pt-field-group">
                <label class="pt-label">Account number</label>
                <input class="pt-input" type="text" id="bankAccountNumber" placeholder="Enter account number">
            </div>
            <div class="pt-field-group">
                <label class="pt-label">Account name</label>
                <input class="pt-input" type="text" id="bankAccountName" placeholder="Enter account name">
            </div>
            <div class="pt-footer">
                <button class="pt-btn-cancel" onclick="closeModal('bankConfigModal')">Cancel</button>
                <button class="pt-btn-save" onclick="saveBankConfig()"><i class="fa-solid fa-floppy-disk me-1"></i> Save</button>
            </div>
        </div>
    </div>
</div>

<div id="printArea" style="display:none;"></div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    window.userRole = '${sessionScope.account.employee.role}';
    window.contextPath = '${pageContext.request.contextPath}';
</script>
<script src="${pageContext.request.contextPath}/resources/js/pos/pos.js"></script>
</body>
</html>
