<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Add New Product</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<c:url value='/resources/css/product/product-add.css' />">
</head>
<body>

    <jsp:include page="../layer/header.jsp" />
    <jsp:include page="../layer/sidebar.jsp" />

    <div class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2 class="fw-bold mb-0">Add New Product</h2>
            <a href="<c:url value='/products/manager/manage'/>" class="btn btn-light border fw-bold px-3">
                <i class="fa-solid fa-arrow-left me-2"></i>Back to List
            </a>
        </div>

        <div class="card border-0 shadow-sm" style="border-radius: 15px;">
            <form action="${pageContext.request.contextPath}/products/manager/add" method="POST" enctype="multipart/form-data">
                <div class="card-body p-5">
                    <div class="row g-5">
                        <%-- Cột 1: Basic Info --%>
                        <div class="col-md-4 border-end">
                            <div class="mb-4">
                                <label class="form-label text-muted fw-bold small">Product Code (SKU) - Auto Generate</label>
                                <input type="text" name="productId" class="form-control input-custom" placeholder="SKU_PRODUCTNAME_ATTRIBUTE" readonly>
                            </div>
                            <div class="mb-4">
                                <label class="form-label text-muted fw-bold small">Product Name</label>
                                <input type="text" name="productName" class="form-control input-custom" placeholder="Enter name..." required>
                            </div>

                                    <%-- Custom Category Dropdown --%>
                                   <div class="mb-4">
                                       <label class="form-label text-muted fw-bold small">Category</label>
                                       <div class="dropdown custom-select-wrapper">
                                           <button class="btn input-custom dropdown-toggle w-100 text-start d-flex justify-content-between align-items-center"
                                                   type="button" id="categoryDropdown" data-bs-toggle="dropdown">
                                               <span id="categoryLabel" class="text-muted">Select category</span>
                                           </button>
                                           <ul class="dropdown-menu w-100 shadow-sm custom-dropdown-menu">
                                               <c:forEach var="cat" items="${categories}">
                                                   <li><a class="dropdown-item" href="javascript:void(0)"
                                                          onclick="selectCategory('${cat.categoryId}', '${cat.categoryName}')">${cat.categoryName}</a></li>
                                               </c:forEach>
                                           </ul>
                                           <input type="hidden" name="categoryId" id="selectedCategoryId" required>
                                       </div>
                                   </div>

                                   <%-- Custom Unit Dropdown --%>
                                   <div class="mb-0">
                                       <label class="form-label text-muted fw-bold small">Unit</label>
                                       <div class="dropdown custom-select-wrapper">
                                           <button class="btn input-custom dropdown-toggle w-100 text-start d-flex justify-content-between align-items-center"
                                                   type="button" id="unitDropdown" data-bs-toggle="dropdown">
                                               <span id="unitLabel" class="text-muted">Select unit</span>
                                           </button>
                                           <ul class="dropdown-menu w-100 shadow-sm custom-dropdown-menu">
                                               <li><a class="dropdown-item" href="javascript:void(0)" onclick="selectUnit('Can')">Can</a></li>
                                               <li><a class="dropdown-item" href="javascript:void(0)" onclick="selectUnit('Pack')">Pack</a></li>
                                               <li><a class="dropdown-item" href="javascript:void(0)" onclick="selectUnit('Unit')">Unit</a></li>
                                               <li><a class="dropdown-item" href="javascript:void(0)" onclick="selectUnit('Bottle')">Bottle</a></li>
                                           </ul>
                                           <input type="hidden" name="unit" id="selectedUnit" value="">
                                       </div>
                                   </div>
                               </div>

                        <%-- Cột 2: Attributes & Dynamic Status --%>
                        <div class="col-md-4 border-end">
                            <div class="mb-4">
                                <label class="form-label text-muted fw-bold small">Attribute</label>
                                <input type="text" name="attribute" class="form-control input-custom" placeholder="e.g. 330ml, Spicy...">
                            </div>
                            <div class="mb-4">
                                <label class="form-label text-muted fw-bold small">Selling Price</label>
                                <div class="input-group-custom">
                                    <input type="number" name="price" class="form-control input-custom" placeholder="0">
                                    <span class="currency-suffix">đ</span>
                                </div>
                            </div>
                            <div>
                                <label class="form-label text-muted fw-bold small">Status</label>
                                <div class="status-option-container">
                                    <%-- Lấy động từ danh sách ProductStatus truyền từ Controller --%>
                                    <c:forEach var="st" items="${statuses}" varStatus="loop">
                                        <div class="status-item">
                                            <input type="radio" name="statusId" id="st-${st.productStatusId}"
                                                   value="${st.productStatusId}" ${loop.first ? 'checked' : ''}>
                                            <label for="st-${st.productStatusId}">${st.productStatusName}</label>
                                        </div>
                                    </c:forEach>
                                </div>
                            </div>
                        </div>

                        <%-- Cột 3: Image (Cloudinary Upload) --%>
                        <div class="col-md-4">
                            <label class="form-label text-muted fw-bold small">Product Image</label>
                            <div class="image-upload-wrapper mb-3" onclick="document.getElementById('imageInput').click()">
                                <div class="image-preview-placeholder">
                                    <div class="inner-box shadow-sm" id="previewContainer">
                                        <i class="fa-solid fa-camera text-muted fs-2" id="placeholderIcon"></i>
                                    </div>
                                </div>
                            </div>
                            <div class="d-flex flex-column align-items-start gap-2">
                                <input type="file" name="imageFile" id="imageInput" class="d-none" accept="image/*">
                                <button type="button" class="btn btn-light border fw-bold px-3 py-2" onclick="document.getElementById('imageInput').click()">
                                    Choose Image
                                </button>
                                <span class="text-muted small">Upload to Cloudinary (Max 5MB)</span>
                            </div>
                        </div>
                    </div>

                    <div class="d-flex justify-content-end gap-3 mt-5 pt-4 border-top">
                        <a href="<c:url value='/products/manager/manage'/>" class="btn btn-light px-5 py-2 border fw-bold">Cancel</a>
                        <button type="submit" class="btn btn-primary px-5 py-2 fw-bold">Add Product</button>
                    </div>
                </div>
            </form>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="<c:url value='/resources/js/product/product-app.js' />"></script>
</body>
</body>
</html>