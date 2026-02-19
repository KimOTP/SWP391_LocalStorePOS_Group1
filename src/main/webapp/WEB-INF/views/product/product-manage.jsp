<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Product</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<c:url value='/resources/css/product/product-manage.css' />">
</head>
<body>

<jsp:include page="../layer/header.jsp" />
<jsp:include page="../layer/sidebar.jsp" />

<div class="main-content">

    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2 class="fw-bold mb-0">Manage Product</h2>
    </div>

    <div class="row g-4 mb-5">
        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-title mb-2">Total Products</div>
                <div class="stat-value">100</div>
                <div class="small text-muted mt-1">Active: 98 | Stop: 2</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-title mb-2">Categories</div>
                <div class="stat-value">3</div>
                <div class="small text-muted mt-1">Product Categories</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-title mb-2">Out of Stock</div>
                <div class="stat-value">1</div>
                <div class="small text-muted mt-1">Restock Required</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-title mb-2">Pending Approval</div>
                <div class="stat-value">1</div>
                <div class="small text-muted mt-1">Needs Approval</div>
            </div>
        </div>
    </div>

    <div class="card shadow-sm border-0">
        <div class="card-body p-4">

            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h5 class="fw-bold mb-0">Products List</h5>
                    <small class="text-muted">Manage all products in system.</small>
                </div>
                <a href="<c:url value='/products/add'>" class="btn btn-add px-4 py-2 d-inline-flex align-items-center text-decoration-none">
                    <i class="fa-solid fa-plus me-2"></i>Add Product
                </a>
            </div>

            <div class="row g-2 mb-4">
                <div class="col-md-3">
                    <div class="input-group">
                        <input type="text" class="form-control" placeholder="Search products...">
                    </div>
                </div>
                <div class="col-md-2">
                    <select class="form-select"><option>+ Status</option></select>
                </div>
                <div class="col-md-2">
                    <select class="form-select"><option>+ Category</option></select>
                </div>
                <div class="col-md-2">
                    <select class="form-select"><option>+ Unit</option></select>
                </div>
            </div>

            <div class="table-responsive">
                <table class="table table-hover align-middle">
                    <thead>
                        <tr>
                            <th>SKU <i class="fa-solid fa-arrow-up-z-a ms-1 small text-muted"></i></th>
                            <th>Product Name <i class="fa-solid fa-arrow-up-z-a ms-1 small text-muted"></i></th>
                            <th>Attribute</th>
                            <th>Category</th>
                            <th>Unit</th>
                            <th>Unit Price <i class="fa-solid fa-arrow-up-z-a ms-1 small text-muted"></i></th>
                            <th>Status</th>
                            <th class="text-end"></th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="p" items="${listProducts}">
                            <tr>
                                <td class="text-muted small">${p.productId}</td>
                                <td class="product-name">${p.productName}</td>
                                <td class="text-muted">${p.attribute}</td>
                                <td>
                                    <span class="badge border text-dark rounded-pill px-3 fw-normal">
                                        ${p.category.categoryName}
                                    </span>
                                </td>
                                <td>${p.unit}</td>
                                <td class="fw-bold">
                                    <fmt:formatNumber value="${p.price}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                </td>
                                <td>
                                    <c:set var="statusName" value="${p.status.productStatusName}" />
                                    <span class="badge ${statusName == 'Active' ? 'bg-success' : 'bg-secondary'}">
                                        ${statusName}
                                    </span>
                                </td>
                                <td class="text-end">
                                    <div class="dropdown">
                                        <button class="btn btn-light btn-sm rounded-circle shadow-none" type="button" data-bs-toggle="dropdown" aria-expanded="false" style="width: 32px; height: 32px;">
                                            <i class="fa-solid fa-ellipsis-vertical"></i>
                                        </button>

                                        <ul class="dropdown-menu dropdown-menu-end shadow border-0 py-2" style="min-width: 160px; border-radius: 12px;">
                                            <li class="px-2 pb-1 text-muted small fw-bold">Action</li>

                                            <li>
                                                <button class="dropdown-item rounded-2 py-2" type="button" onclick="viewProductDetails('${p.productId}')">
                                                    <i class="fa-regular fa-eye me-2 text-primary" style="width: 18px;"></i>View
                                                </button>
                                            </li>

                                            <li>
                                                <a class="dropdown-item rounded-2 py-2" href="#">
                                                    <i class="fa-regular fa-copy me-2 text-info" style="width: 18px;"></i> Copy SKU
                                                </a>
                                            </li>

                                            <li>
                                                <a class="dropdown-item rounded-2 py-2" href="<c:url value='/products/update/${p.productId}'/>">
                                                    <i class="fa-regular fa-pen-to-square me-2 text-warning" style="width: 18px;"></i> Update
                                                </a>
                                            </li>

                                            <li><hr class="dropdown-divider mx-2"></li>

                                            <li>
                                                <a class="dropdown-item rounded-2 py-2 text-danger" href="<c:url value='/products/delete/${p.productId}'/>"
                                                   onclick="return confirm('Bạn có chắc chắn muốn xóa sản phẩm này?')">
                                                    <i class="fa-regular fa-trash-can me-2" style="width: 18px;"></i> Delete
                                                </a>
                                            </li>
                                        </ul>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>

        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<div class="modal fade" id="productDetailModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content border-0 shadow">
            <div class="modal-header bg-light">
                <h5 class="modal-title fw-bold" id="modalProductName">Product Details</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body" id="modalBodyContent">
                <div class="text-center py-5">
                    <div class="spinner-border text-primary" role="status"></div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
function viewProductDetails(productId) {
    const modal = new bootstrap.Modal(document.getElementById('productDetailModal'));
    modal.show();

    // Sửa đường dẫn: Bỏ dấu / ở cuối URL trong thẻ c:url
    // và đảm bảo URL được nối đúng: /context-path/products/view/ID
    const viewUrl = "<c:url value='/products/view'/>" + "/" + productId;

    fetch(viewUrl)
        .then(response => {
            if (!response.ok) throw new Error('Network response was not ok');
            return response.text();
        })
        .then(html => {
            document.getElementById('modalBodyContent').innerHTML = html;
        })
        .catch(err => {
            console.error(err);
            document.getElementById('modalBodyContent').innerHTML =
                '<div class="alert alert-danger">Error loading data: ' + err.message + '</div>';
        });
}
</script>
</body>
</html>