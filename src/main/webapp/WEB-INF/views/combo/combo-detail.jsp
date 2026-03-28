<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<link rel="stylesheet" href="<c:url value='/resources/css/combo/combo-detail.css' />">

<div class="combo-detail-wrapper">

    <%-- Left: Combo Image --%>
    <div class="combo-detail-image-col">
        <div class="combo-detail-image-box">
            <img src="${not empty combo.imageUrl ? combo.imageUrl : '/resources/images/default-pkg.png'}"
                 alt="Combo Image"
                 class="combo-detail-img">
        </div>
    </div>

    <%-- Right: Combo Info --%>
    <div class="combo-detail-info-col">

        <%-- Header: ID --%>
        <div class="combo-detail-meta">
            <span class="combo-detail-id-badge">
                <i class="fa-solid fa-layer-group me-1"></i>Combo
            </span>
            <span class="combo-detail-sku">ID: ${combo.comboId}</span>
        </div>

        <%-- Combo Name --%>
        <h2 class="combo-detail-name">${combo.comboName}</h2>

        <%-- Price --%>
        <div class="combo-detail-price">
            <fmt:formatNumber value="${combo.totalPrice}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
        </div>

        <div class="combo-detail-divider"></div>

        <%-- Status + Specs --%>
        <div class="combo-detail-specs">
            <div class="combo-detail-specs-title">
                <i class="fa-solid fa-list-ul"></i> Specifications
            </div>

            <div class="combo-detail-spec-row">
                <span class="combo-detail-spec-label">Status</span>
                <span class="combo-detail-spec-value">
                    <c:set var="statusCombo" value="${combo.statusCombo}" />
                    <span class="status-badge
                        ${statusCombo == 'ACTIVE'           ? 'status-active'       : ''}
                        ${statusCombo == 'PENDING_APPROVAL' ? 'status-pending'      : ''}
                        ${statusCombo == 'DISCONTINUED'     ? 'status-discontinued' : ''}">
                        ${statusCombo == 'ACTIVE' ? 'Active' :
                          statusCombo == 'PENDING_APPROVAL' ? 'Pending Approval' : 'Discontinued'}
                    </span>
                </span>
            </div>
        </div>

        <div class="combo-detail-divider"></div>

        <%-- Included Products --%>
        <div class="combo-detail-products">
            <div class="combo-detail-specs-title">
                <i class="fa-solid fa-box-open"></i> Included Products
            </div>

            <c:forEach var="detail" items="${combo.comboDetails}">
                <div class="combo-detail-product-row">
                    <div class="combo-detail-product-img">
                        <c:choose>
                            <c:when test="${not empty detail.product.imageUrl}">
                                <img src="${detail.product.imageUrl}" alt="${detail.product.productName}">
                            </c:when>
                            <c:otherwise>
                                <i class="fa-solid fa-image"></i>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div class="combo-detail-product-name">${detail.product.productName}</div>
                    <div class="combo-detail-product-unit-price">
                        <fmt:formatNumber value="${detail.product.price}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                    </div>
                    <div class="combo-detail-product-qty">x${detail.quantity}</div>
                </div>
            </c:forEach>
        </div>

        <%-- Tính originalPrice = tổng (price * quantity) của tất cả included products --%>
        <c:set var="originalPrice" value="${0}" />
        <c:forEach var="detail" items="${combo.comboDetails}">
            <c:set var="originalPrice" value="${originalPrice + detail.product.price * detail.quantity}" />
        </c:forEach>

        <%-- Price Summary --%>
        <div class="combo-detail-price-summary">
            <div class="combo-detail-summary-row">
                <span class="combo-detail-summary-label">Original Price</span>
                <span class="combo-detail-summary-original">
                    <fmt:formatNumber value="${originalPrice}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                </span>
            </div>
            <div class="combo-detail-summary-row">
                <span class="combo-detail-summary-label">You Save</span>
                <span class="combo-detail-summary-save">
                    - <fmt:formatNumber value="${originalPrice - combo.totalPrice}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                </span>
            </div>
        </div>

        <%-- Action Buttons --%>
        <div class="combo-detail-actions">
            <a href="<c:url value='/combos/update/${combo.comboId}'/>"
               class="btn btn-add combo-detail-btn-edit text-decoration-none">
                <i class="fa-regular fa-pen-to-square me-2"></i>Edit Combo
            </a>
        </div>

    </div>
</div>
