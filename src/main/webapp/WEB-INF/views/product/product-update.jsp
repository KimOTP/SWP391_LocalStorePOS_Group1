<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Update Product - ${product.productId}</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<c:url value='/resources/css/product/product-add.css' />">
</head>
<body>

    <jsp:include page="../layer/header.jsp" />
    <jsp:include page="../layer/sidebar.jsp" />

    <div class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2 class="fw-bold mb-0">Update Product</h2>
            <a href="<c:url value='/products/manage'/>" class="btn btn-light border fw-bold px-3">
                <i class="fa-solid fa-arrow-left me-2"></i>Back to List
            </a>
        </div>

        <div class="card border-0 shadow-sm" style="border-radius: 15px;">
            <form action="${pageContext.request.contextPath}/products/do-update" method="POST" enctype="multipart/form-data">
                <div class="card-body p-5">
                    <div class="row g-5">

                        <%-- Column 1: Basic Information --%>
                        <div class="col-md-4 border-end">
                            <div class="mb-4">
                                <label class="form-label text-muted fw-bold small">Product Code (SKU)</label>
                                <input type="text" name="productId" class="form-control input-custom bg-light"
                                       value="${product.productId}" readonly>
                            </div>
                            <div class="mb-4">
                                <label class="form-label text-muted fw-bold small">Product Name</label>
                                <input type="text" name="productName" class="form-control input-custom"
                                       value="${product.productName}" placeholder="Enter name...">
                            </div>
                            <div class="mb-4">
                                <label class="form-label text-muted fw-bold small">Category</label>
                                <select name="category.categoryId" class="form-select input-custom">
                                    <c:forEach var="cat" items="${categories}">
                                        <option value="${cat.categoryId}" ${cat.categoryId == product.category.categoryId ? 'selected' : ''}>
                                            ${cat.categoryName}
                                        </option>
                                    </c:forEach>
                                </select>
                            </div>
                            <div class="mb-0">
                                <label class="form-label text-muted fw-bold small">Unit</label>
                                <select name="unit" class="form-select input-custom">
                                    <option value="Can" ${product.unit == 'Can' ? 'selected' : ''}>Can</option>
                                    <option value="Pack" ${product.unit == 'Pack' ? 'selected' : ''}>Pack</option>
                                    <option value="Unit" ${product.unit == 'Unit' ? 'selected' : ''}>Unit</option>
                                </select>
                            </div>
                        </div>

                        <%-- Column 2: Attributes & Status --%>
                        <div class="col-md-4 border-end">
                            <div class="mb-4">
                                <label class="form-label text-muted fw-bold small">Attribute</label>
                                <input type="text" name="attribute" class="form-control input-custom"
                                       value="${product.attribute}" placeholder="e.g. Size M, Red...">
                            </div>
                            <div class="mb-4">
                                <label class="form-label text-muted fw-bold small">Selling Price</label>
                                <div class="input-group-custom">
                                    <input type="number" name="price" class="form-control input-custom"
                                           value="${product.price}" placeholder="0">
                                    <span class="currency-suffix">đ</span>
                                </div>
                            </div>
                            <div>
                                <label class="form-label text-muted fw-bold small">Status</label>
                                <div class="status-option-container">
                                    <c:forEach var="st" items="${statuses}">
                                        <div class="status-item">
                                            <input type="radio" name="status.productStatusId" id="st-${st.productStatusId}"
                                                   value="${st.productStatusId}" ${st.productStatusId == product.status.productStatusId ? 'checked' : ''}>
                                            <label for="st-${st.productStatusId}">${st.productStatusName}</label>
                                        </div>
                                    </c:forEach>
                                </div>
                            </div>
                        </div>

                        <%-- Column 3: Image --%>
                        <div class="col-md-4">
                            <label class="form-label text-muted fw-bold small">Product Image</label>
                            <div class="image-upload-wrapper mb-3" onclick="document.getElementById('imageInput').click()" style="cursor: pointer;">
                                <div class="image-preview-placeholder">
                                    <div class="inner-box shadow-sm" id="previewContainer">
                                        <c:choose>
                                            <c:when test="${not empty product.imageUrl}">
                                                <img src="<c:url value='/resources/images/products/${product.imageUrl}'/>"
                                                     style="width:100%; height:100%; object-fit:cover; display:block;">
                                            </c:when>
                                            <c:otherwise>
                                                <i class="fa-solid fa-camera text-muted fs-2" id="placeholderIcon"></i>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>
                            </div>
                            <div class="d-flex flex-column align-items-start gap-2">
                                <input type="file" name="imageFile" id="imageInput" class="d-none" accept="image/*">
                                <div class="d-flex gap-2">
                                    <button type="button" class="btn btn-light border fw-bold px-3 py-2" onclick="document.getElementById('imageInput').click()">
                                        Change Photo
                                    </button>
                                </div>
                                <span class="text-muted small">(Keep empty to remain old photo)</span>
                            </div>
                        </div>

                    </div>

                    <div class="d-flex justify-content-end gap-3 mt-5 pt-4 border-top">
                        <a href="<c:url value='/products/manage'/>" class="btn btn-light px-5 py-2 border fw-bold" style="border-radius: 8px;">Cancel</a>
                        <button type="submit" class="btn btn-primary px-5 py-2 fw-bold" style="background-color: #2563eb; border-radius: 8px; border: none;">
                            Update Product
                        </button>
                    </div>
                </div>
            </form>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // JS Xử lý xem trước ảnh khi chọn file mới
        document.getElementById('imageInput').onchange = function(evt) {
            const file = evt.target.files[0];
            if (file) {
                const imgUrl = URL.createObjectURL(file);
                const container = document.getElementById('previewContainer');
                container.innerHTML = '';
                const newImg = document.createElement('img');
                newImg.src = imgUrl;
                newImg.style.width = '100%';
                newImg.style.height = '100%';
                newImg.style.objectFit = 'cover';
                newImg.style.display = 'block';
                container.appendChild(newImg);
            }
        };
    </script>
</body>
</html>