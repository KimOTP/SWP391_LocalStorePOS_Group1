<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html>
<head>
    <title>POS Screen</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="<c:url value='/resources/css/pos/pos.css' />">
</head>
<body>

<jsp:include page="../layer/header.jsp" />

<jsp:include page="../layer/sidebar.jsp" />

<div class="pos-container">

    <!-- TOP BAR -->
    <div class="pos-top-bar flex-wrap gap-2">
        <c:if test="${sessionScope.currentUser.role eq 'MANAGER'}">
            <button class="btn-outline" onclick="openPrintTemplate()">Setting print template</button>
            <button class="btn-outline" onclick="openBankConfig()">Account banking configuration</button>
        </c:if>

        <input type="text" class="search-box" placeholder="Search for products">
        <select class="category-select">
            <option>All categories</option>
        </select>
    </div>

    <!-- MAIN CONTENT -->
    <div class="pos-content flex-column flex-lg-row">

        <!-- PRODUCT LIST -->
        <div class="product-area">
            <div class="product-grid">
                <c:forEach items="${products}" var="p">
                    <div class="product-card"
                         onclick="addToCart('${p.id}','${p.name}',${p.price})">
                        <div class="product-img"></div>
                        <div class="product-name">${p.name}</div>
                        <div class="product-price">$${p.price}</div>
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
                <img src="<c:url value='/resources/img/cart.png' />" width="80">
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

<!-- ================= JS ================= -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    const userRole = '${sessionScope.currentUser.role}';
    let cart = [];

    function addToCart(id, name, price) {
        let item = cart.find(i => i.id === id);
        if (item) item.qty++;
        else cart.push({id, name, price, qty: 1});
        renderCart();
    }

    function renderCart() {
        const list = document.getElementById("itemList");
        const empty = document.getElementById("emptyCart");
        const items = document.getElementById("cartItems");

        list.innerHTML = "";
        let total = 0;

        cart.forEach(i => {
            total += i.price * i.qty;
            list.innerHTML += `
                <div class="cart-item">
                    <span>${i.name}</span>
                    <span>${i.qty} x $${i.price}</span>
                </div>`;
        });

        document.getElementById("totalPrice").innerText = total;

        empty.style.display = cart.length === 0 ? "block" : "none";
        items.style.display = cart.length === 0 ? "none" : "block";
    }

    function clearCart() {
        cart = [];
        renderCart();
    }

    function openPrintTemplate() {
        if (userRole !== 'MANAGER') return alert('Permission denied');
        document.getElementById('printTemplateModal').style.display = 'flex';
    }

    function openBankConfig() {
        if (userRole !== 'MANAGER') return alert('Permission denied');
        document.getElementById('bankConfigModal').style.display = 'flex';
    }

    function closeModal(id) {
        document.getElementById(id).style.display = 'none';
    }
</script>

</body>
</html>
