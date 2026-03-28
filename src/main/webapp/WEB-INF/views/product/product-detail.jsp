<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<link rel="stylesheet" href="<c:url value='/resources/css/product/product-detail.css' />">

<div class="product-detail-wrapper">

    <%-- Left: Product Image --%>
    <div class="product-detail-image-col">
        <div class="product-detail-image-box">
            <img src="${not empty product.imageUrl ? product.imageUrl : '/resources/images/default-prod.png'}"
                 alt="Product Image"
                 class="product-detail-img">
        </div>
    </div>

    <%-- Right: Product Info --%>
    <div class="product-detail-info-col">

        <%-- Header: Category + SKU --%>
        <div class="product-detail-meta">
            <span class="product-detail-category-badge">${product.category.categoryName}</span>
            <span class="product-detail-sku">SKU: ${product.productId}</span>
        </div>

        <%-- Product Name --%>
        <h2 class="product-detail-name">${product.productName}</h2>

        <%-- Price --%>
        <div class="product-detail-price">
            <fmt:formatNumber value="${product.price}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
        </div>

        <div class="product-detail-divider"></div>

        <%-- Specs Table --%>
        <c:set var="statusName" value="${product.status.productStatusName}" />
        <div class="product-detail-specs">
            <div class="product-detail-specs-title">
                <i class="fa-solid fa-list-ul"></i> Specifications
            </div>

            <div class="product-detail-spec-row">
                <span class="product-detail-spec-label">Unit</span>
                <span class="product-detail-spec-value">${product.unit}</span>
            </div>

            <div class="product-detail-spec-row">
                <span class="product-detail-spec-label">Attribute</span>
                <span class="product-detail-spec-value">${product.attribute}</span>
            </div>

            <div class="product-detail-spec-row">
                <span class="product-detail-spec-label">Status</span>
                <span class="product-detail-spec-value">
                    <span class="status-badge
                        ${statusName == 'Active'           ? 'status-active'       : ''}
                        ${statusName == 'Out of Stock'     ? 'status-outstock'     : ''}
                        ${statusName == 'Discontinued'     ? 'status-discontinued' : ''}
                        ${statusName == 'Pending Approval' ? 'status-pending'      : ''}">
                        ${statusName}
                    </span>
                </span>
            </div>
        </div>

        <%-- Action Buttons --%>
        <div class="product-detail-actions">
            <a href="<c:url value='/products/update/${product.productId}'/>"
               class="btn btn-add product-detail-btn-edit text-decoration-none">
                <i class="fa-regular fa-pen-to-square me-2"></i>Edit Product
            </a>
        </div>

    </div>
</div>
