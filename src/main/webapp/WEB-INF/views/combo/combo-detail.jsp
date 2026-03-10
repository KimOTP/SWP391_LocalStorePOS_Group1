<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<div class="row g-4">
    <div class="col-md-5 text-center">
        <img src="${not empty combo.imageUrl ? combo.imageUrl : '/resources/images/default-pkg.png'}"
             class="img-fluid rounded shadow-sm" alt="Combo Image">
    </div>
    <div class="col-md-7">
        <h4 class="fw-bold text-primary">${combo.comboName}</h4>
        <p class="text-muted">ID: <strong>${combo.comboId}</strong></p>
        <hr>
        <table class="table table-borderless sm">
            <tr>
                <td class="text-muted" style="width: 120px;">Price:</td>
                <td class="h5 text-danger fw-bold">
                    <fmt:formatNumber value="${combo.totalPrice}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                </td>
            </tr>
            <tr>
                <td class="text-muted">Status:</td>
                <td>
                    <span class="badge ${combo.statusCombo == 'ACTIVE' ? 'bg-success' : 'bg-warning'}">
                        ${combo.statusCombo}
                    </span>
                </td>
            </tr>
        </table>

        <h6 class="fw-bold mt-3">Included Products:</h6>
        <ul class="list-group list-group-flush small">
            <c:forEach var="detail" items="${combo.comboDetails}">
                <li class="list-group-item d-flex justify-content-between align-items-center px-0">
                    ${detail.product.productName}
                    <span class="badge bg-secondary rounded-pill">x${detail.quantity}</span>
                </li>
            </c:forEach>
        </ul>
    </div>
</div>