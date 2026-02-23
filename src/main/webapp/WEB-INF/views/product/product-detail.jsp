<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<div class="row g-4">
    <div class="col-md-5 text-center">
        <img src="${product.imageUrl != null ? product.imageUrl : '/resources/images/default-prod.png'}"
             class="img-fluid rounded shadow-sm" alt="Product Image">
    </div>
    <div class="col-md-7">
        <h4 class="fw-bold text-primary">${product.productName}</h4>
        <p class="text-muted">SKU: <strong>${product.productId}</strong></p>
        <hr>
        <table class="table table-borderless sm">
            <tr>
                <td class="text-muted" style="width: 120px;">Category:</td>
                <td><span class="badge bg-info text-dark">${product.category.categoryName}</span></td>
            </tr>
            <tr>
                <td class="text-muted">Unit:</td>
                <td>${product.unit}</td>
            </tr>
            <tr>
                <td class="text-muted">Price:</td>
                <td class="h5 text-danger fw-bold">
                    <fmt:formatNumber value="${product.price}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                </td>
            </tr>
            <tr>
                <td class="text-muted">Attribute:</td>
                <td>${product.attribute}</td>
            </tr>
            <tr>
                <td class="text-muted">Status:</td>
                <td>${product.status.productStatusName}</td>
            </tr>
        </table>
    </div>
</div>