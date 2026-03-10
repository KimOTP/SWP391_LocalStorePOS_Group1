<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Create New Combo</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<c:url value='/resources/css/combo/combo-add.css' />">
</head>
<body>

    <jsp:include page="../layer/header.jsp" />
    <jsp:include page="../layer/sidebar.jsp" />

    <div class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2 class="fw-bold mb-0">Create New Combo</h2>
            <a href="<c:url value='/combos/manage' />" class="btn btn-light border fw-bold px-3">
                <i class="fa-solid fa-arrow-left me-2"></i>Back to List
            </a>
        </div>

        <div class="card border-0 shadow-sm" style="border-radius: 15px;">
            <form id="comboForm" action="${pageContext.request.contextPath}/combos/add" method="POST" enctype="multipart/form-data">
                <div class="card-body p-5">
                    <div class="row g-5">
                        <%-- Cột 1: Combo Info & Product Selection --%>
                        <div class="col-md-4 border-end">
                            <div class="mb-4">
                                <label class="form-label text-muted fw-bold small">Combo ID</label>
                                <input type="text" name="comboId" class="form-control input-custom" placeholder="CB-XXXX" readonly>
                            </div>
                            <div class="mb-4">
                                <label class="form-label text-muted fw-bold small">Combo Name</label>
                                <input type="text" name="comboName" class="form-control input-custom" placeholder="e.g. Family Pack" required>
                            </div>

                           <div class="mb-3">
                               <label class="form-label text-muted fw-bold small">Add Products to Combo</label>
                               <div class="dropdown custom-select-wrapper">
                                   <button class="btn input-custom dropdown-toggle w-100 text-start d-flex justify-content-between align-items-center"
                                           type="button" data-bs-toggle="dropdown" id="dropdownProductBtn">
                                       <span class="text-muted">Select product to add...</span>
                                       <i class="fa-solid fa-chevron-down ms-1 tiny-icon"></i>
                                   </button>

                                   <div class="dropdown-menu w-100 shadow border-0 p-2 custom-dropdown-menu">
                                       <div class="px-2 pb-2 border-bottom mb-2">
                                           <div class="input-group input-group-sm">
                                               <span class="input-group-text bg-transparent border-end-0">
                                                   <i class="fa-solid fa-magnifying-glass text-muted"></i>
                                               </span>
                                               <input type="text" class="form-control border-start-0 ps-0 shadow-none"
                                                      id="productSearchInside" placeholder="Search product name..."
                                                      onclick="event.stopPropagation()"> </div>
                                       </div>

                                       <ul class="list-unstyled mb-0 scrollable-menu" id="productListItems" style="max-height: 250px; overflow-y: auto;">
                                           <c:forEach var="p" items="${products}">
                                               <li class="product-item-li">
                                                   <a class="dropdown-item d-flex justify-content-between align-items-center py-2 rounded-2"
                                                      href="javascript:void(0)"
                                                      onclick="addProductToCombo('${p.productId}', '${p.productName}', ${p.price})">
                                                       <div class="d-flex flex-column">
                                                           <span class="fw-bold text-dark small p-name">${p.productName}</span>
                                                           <span class="text-muted" style="font-size: 11px;">SKU: ${p.productId}</span>
                                                       </div>
                                                       <span class="text-primary fw-bold small">${p.price}đ</span>
                                                   </a>
                                               </li>
                                           </c:forEach>
                                           <li id="noProductFound" class="text-center py-3 text-muted small d-none">
                                               No products found
                                           </li>
                                       </ul>
                                   </div>
                               </div>
                           </div>

                            <%-- List Sản phẩm đã chọn có Scroll --%>
                            <div class="selected-products-wrapper mt-3">
                                <div id="selectedProductsList">
                                    <div class="empty-state text-center py-4 text-muted small">
                                        <i class="fa-solid fa-box-open d-block mb-2 fs-4"></i>
                                        No products added yet
                                    </div>
                                </div>
                            </div>
                            </div>

                        <%-- Cột 2: Pricing & Status --%>
                        <div class="col-md-4 border-end">
                            <div class="mb-4">
                                <label class="form-label text-muted fw-bold small">Original Total Price</label>
                                <div class="input-group-custom bg-light">
                                    <input type="number" id="originalPrice" name="originalPrice" class="form-control input-custom" value="0" readonly>
                                    <span class="currency-suffix">đ</span>
                                </div>
                                <small class="text-muted italic">* Auto-calculated from products</small>
                            </div>

                            <div class="mb-4">
                                <label class="form-label text-muted fw-bold small">Combo Selling Price</label>
                                <div class="input-group-custom">
                                    <input type="number" id="sellingPrice" name="totalPrice" class="form-control input-custom" placeholder="0" required>
                                    <span class="currency-suffix">đ</span>
                                </div>
                            </div>

                            <div>
                                <label class="form-label text-muted fw-bold small">Status</label>
                                <div class="status-option-container">
                                    <div class="status-item">
                                        <input type="radio" name="statusCombo" id="st-pending" value="PENDING_APPROVAL" checked>
                                        <label for="st-pending">Pending Approval</label>
                                    </div>
                                    <div class="status-item">
                                        <input type="radio" name="statusCombo" id="st-active" value="ACTIVE" checked>
                                        <label for="st-active">Active</label>
                                    </div>
                                    <div class="status-item">
                                        <input type="radio" name="statusCombo" id="st-discontinued" value="DISCONTINUED">
                                        <label for="st-discontinued">Discontinued</label>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <%-- Cột 3: Image & Quick Actions --%>
                        <div class="col-md-4">
                            <label class="form-label text-muted fw-bold small">Combo Image</label>
                            <div class="image-upload-wrapper mb-3" onclick="document.getElementById('imageInput').click()">
                                <div class="image-preview-placeholder">
                                    <div class="inner-box shadow-sm" id="previewContainer">
                                        <i class="fa-solid fa-camera text-muted fs-2"></i>
                                    </div>
                                </div>
                            </div>
                            <input type="file" name="imageFile" id="imageInput" class="d-none" accept="image/*">

                            <div class="quick-actions-panel mt-4">
                                <label class="form-label text-muted fw-bold small d-block mb-3">Quick Discount</label>
                                <div class="d-flex gap-2">
                                    <button type="button" class="btn btn-outline-primary flex-fill fw-bold" onclick="applyDiscount(5)">-5%</button>
                                    <button type="button" class="btn btn-outline-primary flex-fill fw-bold" onclick="applyDiscount(10)">-10%</button>
                                    <button type="button" class="btn btn-outline-primary flex-fill fw-bold" onclick="applyDiscount(20)">-20%</button>
                                </div>
                                <p class="small text-muted mt-2 mt-2">Discount based on original total price.</p>
                            </div>
                        </div>
                    </div>

                    <div class="d-flex justify-content-end gap-3 mt-5 pt-4 border-top">
                        <a href="<c:url value='/combos/manage'/>" class="btn btn-light px-5 py-2 border fw-bold">Cancel</a>
                        <button type="submit" class="btn btn-primary px-5 py-2 fw-bold">Add Combo</button>
                    </div>
                </div>
            </form>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="<c:url value='/resources/js/combo/combo-app.js' />"></script>
</body>
</html>