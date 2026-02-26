<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Stock-In Details | LocalStorePOS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="<c:url value='/resources/css/inventory/stock-in.css'/>">
</head>
<body>
<jsp:include page="../../layer/header.jsp" />
<jsp:include page="../../layer/sidebar.jsp" />

<div class="main-content">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2 class="fw-bold mb-0">Stock-In Details</h2>
        <button class="btn btn-light border fw-bold" onclick="window.history.back()">
            <i class="fa-solid fa-arrow-left me-2"></i>Back to Reports
        </button>
    </div>

    <div class="info-card mb-4">
        <div class="d-flex justify-content-between align-items-start mb-4">
            <h5 class="fw-bold mb-0">Request ID: <span class="text-primary">RI_${stockIn.stockInId}</span></h5>

            <c:choose>
                <c:when test="${stockIn.status.transactionStatusId == 1}">
                    <span class="status-badge status-discontinued">Input Pending</span>
                </c:when>
                <c:when test="${stockIn.status.transactionStatusId == 2}">
                    <span class="status-badge status-pending">Pending Approval</span>
                </c:when>
                <c:when test="${stockIn.status.transactionStatusId == 3}">
                    <span class="status-badge status-outstock">Rejected</span>
                </c:when>
                <c:when test="${stockIn.status.transactionStatusId == 4}">
                    <span class="status-badge status-active">Completed</span>
                </c:when>
            </c:choose>
        </div>

        <div class="row g-4">
            <div class="col-md-3">
                <label class="info-label">Requested by</label>
                <div class="info-value">
                    <i class="fa-regular fa-user-circle me-1 text-muted"></i> ${stockIn.requester.fullName}
                </div>
            </div>
            <div class="col-md-3">
                <label class="info-label">Inbound Time</label>
                <div class="info-value">
                    <i class="fa-regular fa-calendar-check me-1 text-muted"></i>
                    <fmt:parseDate value="${stockIn.receivedAt}" pattern="yyyy-MM-dd'T'HH:mm" var="pDate" />
                    <fmt:formatDate value="${pDate}" pattern="dd/MM/yyyy HH:mm" />
                </div>
            </div>
            <div class="col-md-3">
                <label class="info-label">Request Date</label>
                <div class="info-value">
                    <i class="fa-regular fa-calendar me-1 text-muted"></i>
                    <fmt:parseDate value="${stockIn.createdAt}" pattern="yyyy-MM-dd'T'HH:mm" var="cDate" />
                    <fmt:formatDate value="${cDate}" pattern="dd/MM/yyyy" />
                </div>
            </div>
            <div class="col-md-3">
                <label class="info-label">Staff in Charge</label>
                <div class="info-value text-primary">
                    <i class="fa-solid fa-user-tie me-1"></i> ${stockIn.staff.fullName}
                </div>
            </div>
        </div>
    </div>

    <div class="table-section shadow-sm border-0">
        <div class="mb-4">
            <h5 class="fw-bold mb-0">Received Items</h5>
            <small class="text-muted">Finalized inventory quantities for this request.</small>
        </div>

        <div class="table-responsive">
            <table class="table table-hover align-middle">
                <thead>
                <tr>
                    <th style="width: 60px;" class="text-center">#</th>
                    <th>SKU</th>
                    <th>Product Name</th>
                    <th>Unit</th>
                    <th class="text-center">Expected Qty</th>
                    <th class="text-center">Actual Received</th>
                </tr>
                </thead>
                <tbody>
                <c:forEach items="${stockIn.details}" var="d" varStatus="s">
                    <tr>
                        <td class="text-center text-muted small">${s.index + 1}</td>
                        <td class="text-sku">#${d.product.productId}</td>
                        <td>
                            <div class="fw-bold text-dark">${d.product.productName}</div>
                        </td>
                        <td><span class="badge border text-dark fw-normal px-3">${d.product.unit}</span></td>
                        <td class="text-center">
                            <span class="expected-badge">${d.requestedQuantity}</span>
                        </td>
                        <td class="text-center">
                                <span class="fw-bold fs-6 ${d.receivedQuantity != d.requestedQuantity ? 'text-danger' : 'text-primary'}">
                                        ${d.receivedQuantity}
                                </span>
                        </td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>