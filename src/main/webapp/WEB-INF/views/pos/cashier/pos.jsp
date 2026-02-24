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
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

    <div class="pos-top-bar flex-wrap gap-2">
        <c:if test="${sessionScope.currentUser.role eq 'MANAGER'}">
            <button class="btn-outline" onclick="openPrintTemplate()">Setting print template</button>
            <button class="btn-outline" onclick="openBankConfig()">Account banking configuration</button>
        </c:if>

        <input type="text" class="search-box" placeholder="Search for products">

        <select class="category-select" name="categoryId">
            <option value="">All categories</option>

            <c:forEach var="category" items="${categories}">
                <option value="${category.categoryId}">
                    ${category.categoryName}
                </option>
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
                         onclick="addToCart('${p.productId}','${p.productName}','${p.price}')">
                        <div class="product-img"></div>
                        <div class="product-name">${p.productName}</div>
                        <div class="product-price">$<fmt:formatNumber value="${p.price}" maxFractionDigits="0"/></div>
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

            <!-- EMPTY -->
            <div id="emptyCart" class="cart-empty">
                <img src="${pageContext.request.contextPath}/resources/static/images/empty_cart.png" width="80">
                <p>The shopping cart is empty.</p>
            </div>

            <!-- ITEMS -->
            <div id="cartItems" style="display:none">
                <div id="itemList"></div>

                <div class="cart-summary">
                    <div>Estimate Discount: $0</div>
                    <div class="total">
                        Total: $<span id="totalPrice">0</span>
                    </div>
                </div>

                <button class="btn-pay w-100">Pay</button>
            </div>
        </div>
    </div>
</div>

<!-- ================= MODALS ================= -->

<!-- PRINT TEMPLATE -->
<div class="modal" id="printTemplateModal">
    <div class="modal-content large">

        <!-- HEADER -->
        <div class="modal-header">
            <h3>Setting print template</h3>
            <span class="close" onclick="closeModal('printTemplateModal')">×</span>
        </div>

        <!-- TAB -->
        <div class="tab-header">
            <button class="tab active">Sales invoice</button>
            <button class="tab">Report</button>
        </div>

        <!-- BODY -->
        <div class="print-template-body flex-column flex-md-row">

            <!-- LEFT FORM -->
            <div class="template-form">

                <label>Paper size</label>
                <select>
                    <option>58 mm (Thermal printer)</option>
                </select>

                <label>Font size</label>
                <select>
                    <option>Medium</option>
                </select>

                <label>Invoice title</label>
                <input type="text" value="Sales invoice">

                <label>Expression of gratitude</label>
                <input type="text" value="Thank you for your purchase">

                <div class="section-title">Company information</div>

                <label>Company name</label>
                <input type="text" value="Local Store POS system">

                <label>Address</label>
                <input type="text" value="Hồ Chí Minh, Việt Nam">

                <div class="row-2 flex-column flex-sm-row">
                    <div class="flex-fill">
                        <label>Phone number</label>
                        <input type="text" value="0966666666">
                    </div>
                    <div class="flex-fill">
                        <label>Email</label>
                        <input type="text" value="info@gmail.com">
                    </div>
                </div>

            </div>

            <!-- RIGHT PREVIEW -->
            <div class="template-preview">
                <div class="preview-header">
                    <span>👁 Preview</span>
                </div>

                <div class="preview-paper">
                    <img src="/resources/img/receipt-demo.png" alt="Receipt preview">
                </div>

                <button class="btn-apply w-100">Apply</button>
            </div>

        </div>
    </div>
</div>


<!-- BANK CONFIG -->
<div class="modal" id="bankConfigModal">
    <div class="modal-content small">
        <div class="modal-header">
            <h3>Configure your bank account</h3>
            <span class="close" onclick="closeModal('bankConfigModal')">×</span>
        </div>

        <label>Choose a bank</label>
        <select>
            <option>Choose a bank</option>
        </select>

        <label>Account number</label>
        <input type="text">

        <label>Account name</label>
        <input type="text">

        <div class="modal-footer">
            <button onclick="closeModal('bankConfigModal')">Cancel</button>
            <button class="btn-save">Save</button>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
  <script>
      window.userRole = '${sessionScope.currentUser.role}';
  </script>
<script src="${pageContext.request.contextPath}/resources/js/pos/pos.js"></script>

</body>
</html>
