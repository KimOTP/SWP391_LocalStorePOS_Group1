<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
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
            <a href="<c:url value='/products'/>" class="btn btn-light border fw-bold px-3">
                <i class="fa-solid fa-arrow-left me-2"></i>Back to List
            </a>
        </div>

        <div class="card border-0 shadow-sm" style="border-radius: 15px;">
            <form action="${pageContext.request.contextPath}/products/add" method="POST" enctype="multipart/form-data">
                <div class="card-body p-5">
                    <div class="row g-5">

                        <%-- Cột 1: Thông tin cơ bản --%>
                        <div class="col-md-4 border-end">
                            <div class="mb-4">
                                <label class="form-label text-muted fw-bold small">Product Code</label>
                                <input type="text" name="productId" class="form-control input-custom" placeholder="Enter code...">
                            </div>
                            <div class="mb-4">
                                <label class="form-label text-muted fw-bold small">Product Name</label>
                                <input type="text" name="productName" class="form-control input-custom" placeholder="Enter name...">
                            </div>
                            <div class="mb-4">
                                <label class="form-label text-muted fw-bold small">Category</label>
                                <select name="categoryId" class="form-select input-custom">
                                    <option selected disabled>Select category</option>
                                    <option value="1">Drink</option>
                                    <option value="2">Food</option>
                                    <option value="3">Supplies</option>
                                </select>
                            </div>
                            <div class="mb-0">
                                <label class="form-label text-muted fw-bold small">Unit</label>
                                <select name="unit" class="form-select input-custom">
                                    <option selected disabled>Select unit</option>
                                    <option value="Can">Can</option>
                                    <option value="Pack">Pack</option>
                                    <option value="Unit">Unit</option>
                                </select>
                            </div>
                        </div>

                        <%-- Cột 2: Thuộc tính & Trạng thái --%>
                        <div class="col-md-4 border-end">
                            <div class="mb-4">
                                <label class="form-label text-muted fw-bold small">Attribute</label>
                                <input type="text" name="attribute" class="form-control input-custom" placeholder="e.g. Size M, Red...">
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
                                    <div class="status-item">
                                        <input type="radio" name="status" id="statusActive" value="Active" checked>
                                        <label for="statusActive">Active</label>
                                    </div>
                                    <div class="status-item">
                                        <input type="radio" name="status" id="statusDiscontinued" value="Discontinued">
                                        <label for="statusDiscontinued">Discontinued</label>
                                    </div>
                                    <div class="status-item">
                                        <input type="radio" name="status" id="statusOutStock" value="Out of Stock">
                                        <label for="statusOutStock">Out of Stock</label>
                                    </div>
                                    <div class="status-item">
                                        <input type="radio" name="status" id="statusPending" value="Pending Approval">
                                        <label for="statusPending">Pending Approval</label>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <%-- Cột 3: Hình ảnh --%>
                        <div class="col-md-4">
                            <label class="form-label text-muted fw-bold small">Product Image</label>
                            <div class="image-upload-wrapper mb-3" onclick="document.getElementById('imageInput').click()" style="cursor: pointer;">
                                <div class="image-preview-placeholder">
                                    <div class="inner-box shadow-sm" id="previewContainer">
                                        <i class="fa-solid fa-camera text-muted fs-2" id="placeholderIcon"></i>
                                    </div>
                                </div>
                            </div>
                            <div class="d-flex flex-column align-items-start gap-2">
                                <input type="file" name="imageFile" id="imageInput" class="d-none" accept="image/*">

                                <div class="d-flex gap-2">
                                    <button type="button" class="btn btn-light border fw-bold px-3 py-2" onclick="document.getElementById('imageInput').click()">
                                        Choose File
                                    </button>
                                    <button type="button" class="btn btn-outline-danger btn-sm d-none" id="removeImgBtn" onclick="removeImage(event)">
                                        <i class="fa-solid fa-trash"></i>
                                    </button>
                                </div>
                                <span class="text-muted small">(PNG, JPG, GIF max 5MB)</span>
                            </div>
                        </div>


                    <div class="d-flex justify-content-end gap-3 mt-5 pt-4 border-top">
                        <a href="<c:url value='/product'/>" class="btn btn-light px-5 py-2 border fw-bold" style="border-radius: 8px;">Cancel</a>
                        <button type="submit" class="btn btn-primary px-5 py-2 fw-bold" style="background-color: #2563eb; border-radius: 8px; border: none;">
                            Add Product
                        </button>
                    </div>
                </div>
            </form>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        document.getElementById('imageInput').onchange = function(evt) {
            const file = evt.target.files[0];
            if (file) {
                // 1. Tạo URL ảnh
                const imgUrl = URL.createObjectURL(file);
                console.log("Image URL created:", imgUrl);

                // 2. Tìm container
                const container = document.getElementById('previewContainer');

                // 3. Xóa nội dung cũ (icon hoặc ảnh cũ)
                container.innerHTML = '';

                // 4. Tạo thẻ img bằng Object (Cách này an toàn nhất, không lo sai dấu ngoặc)
                const newImg = document.createElement('img');
                newImg.src = imgUrl; // Gán URL vào src
                newImg.style.width = '100%';
                newImg.style.height = '100%';
                newImg.style.objectFit = 'cover';
                newImg.style.display = 'block';

                // 5. Thêm vào ô vuông trắng
                container.appendChild(newImg);
            }
        };
    </script>
</body>
</html>