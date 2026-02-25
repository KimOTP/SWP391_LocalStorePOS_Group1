<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <title>Stock-in Notifications | LocalStorePOS</title>
    <link rel="stylesheet" href="<c:url value='/resources/css/inventory/stock-in.css'/>">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<jsp:include page="../../layer/header.jsp" />
<jsp:include page="../../layer/sidebar.jsp" />

<div class="main-content">
    <h3 class="fw-bold mb-4">Stock-In</h3>

    <div class="info-card mb-4">
        <h5 class="fw-bold mb-4">Request ID : <span class="text-muted">RI_${stockIn.stockInId}</span></h5>
        <div class="row g-4">
            <div class="col-md-3">
                <label class="info-label">Requested by :</label>
                <div class="info-value">${stockIn.requester.fullName}</div>
                <label class="info-label mt-3">Inbound time :</label>
                <div class="info-value">
                    <fmt:parseDate value="${stockIn.createdAt}" pattern="yyyy-MM-dd'T'HH:mm" var="parsedDate" type="both" />
                    <fmt:formatDate value="${parsedDate}" pattern="dd/MM/yyyy" />
                </div>
            </div>
            <div class="col-md-3">
                <label class="info-label">Request date :</label>
                <div class="info-value">
                    <fmt:formatDate value="${java.util.Date.from(stockIn.createdAt.atZone(java.time.ZoneId.systemDefault()).toInstant())}" pattern="dd/MM/yyyy" />
                </div>
                <label class="info-label mt-3">Staff :</label>
                <div class="info-value">${loggedInAccount.employee.fullName}</div>
            </div>
            <div class="col-md-6 text-end">
                <label class="info-label d-block">Status :</label>
                <span class="status-badge">In Progress</span>
            </div>
        </div>
    </div>

    <div class="table-section">
        <table class="table align-middle" id="processTable">
            <thead>
            <tr>
                <th style="width: 50px;">#</th>
                <th>SKU</th>
                <th>Product Name</th>
                <th>Unit</th>
                <th class="text-center">Expected quantity</th>
                <th class="text-center">Actual quantity</th>
            </tr>
            </thead>
            <tbody>
            <c:forEach items="${stockIn.details}" var="d" varStatus="s">
                <tr data-detail-id="${d.detailId}">
                    <td>${s.index + 1}</td>
                    <td class="small text-secondary">${d.product.productId}</td>
                    <td class="fw-bold">${d.product.productName}</td>
                    <td>${d.product.unit}</td>
                    <td class="text-center">
                        <span class="expected-badge">${d.requestedQuantity}</span>
                    </td>
                    <td class="text-center">
                        <input type="number" class="input-actual" value="${d.requestedQuantity}" min="0">
                    </td>
                </tr>
            </c:forEach>
            </tbody>
        </table>
    </div>

    <div class="d-flex justify-content-end gap-3 mt-4">
        <button class="btn-cancel" onclick="window.history.back()">Cancel</button>
        <button class="btn-confirm" onclick="submitStockIn()">Confirm</button>
    </div>
</div>

<form id="submitForm" action="/stockIn/submit-process" method="POST">
    <input type="hidden" name="stockInId" value="${stockIn.stockInId}">
    <input type="hidden" id="actualDataJson" name="actualDataJson">
</form>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="<c:url value='/resources/js/inventory/stock-in.js'/>"></script>
</body>
</html>