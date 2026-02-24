<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <title>Report Detailed | LocalStorePOS</title>
    <link rel="stylesheet" href="<c:url value='/resources/css/inventory/stock-in.css'/>">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<jsp:include page="../../layer/header.jsp" />
<jsp:include page="../../layer/sidebar.jsp" />

<div class="main-content">
    <h3 class="fw-bold mb-4">Report Detailed</h3>

    <div class="info-card mb-4">
        <h5 class="fw-bold mb-4">Request ID : <span class="text-muted">RI_${stockIn.stockInId}</span></h5>
        <div class="row g-4">
            <div class="col-md-3">
                <label class="info-label">Requested by :</label>
                <div class="info-value">${stockIn.requester.fullName}</div>

                <label class="info-label mt-3">Inbound time :</label>
                <div class="info-value">
                    <fmt:parseDate value="${stockIn.receivedAt}" pattern="yyyy-MM-dd'T'HH:mm" var="pDate" />
                    <fmt:formatDate value="${pDate}" pattern="dd/MM/yyyy HH:mm" />
                </div>
            </div>
            <div class="col-md-3">
                <label class="info-label">Request date :</label>
                <div class="info-value">
                    <fmt:parseDate value="${stockIn.createdAt}" pattern="yyyy-MM-dd'T'HH:mm" var="cDate" />
                    <fmt:formatDate value="${cDate}" pattern="dd/MM/yyyy" />
                </div>

                <label class="info-label mt-3">Staff :</label>
                <div class="info-value">${stockIn.staff.fullName}</div>
            </div>
            <div class="col-md-6 text-end">
                <label class="info-label d-block">Status :</label>
                <c:choose>
                    <c:when test="${stockIn.status.transactionStatusId == 1}">
                        <span class="status-badge bg-secondary">Input Pending</span>
                    </c:when>
                    <c:when test="${stockIn.status.transactionStatusId == 2}">
                        <span class="status-badge bg-dark">Pending Approval</span>
                    </c:when>
                    <c:when test="${stockIn.status.transactionStatusId == 3}">
                        <span class="status-badge bg-danger">Rejected</span>
                    </c:when>
                    <c:when test="${stockIn.status.transactionStatusId == 4}">
                        <span class="status-badge bg-success">Completed</span>
                    </c:when>
                </c:choose>
            </div>
        </div>
    </div>

    <div class="table-section">
        <table class="table align-middle">
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
                <tr>
                    <td>${s.index + 1}</td>
                    <td class="small text-secondary">${d.product.productId}</td>
                    <td class="fw-bold">${d.product.productName}</td>
                    <td>${d.product.unit}</td>
                    <td class="text-center">
                        <span class="expected-badge">${d.requestedQuantity}</span>
                    </td>
                    <td class="text-center">
                        <div class="view-only-box text-center">${d.receivedQuantity}</div>
                    </td>
                </tr>
            </c:forEach>
            </tbody>
        </table>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>