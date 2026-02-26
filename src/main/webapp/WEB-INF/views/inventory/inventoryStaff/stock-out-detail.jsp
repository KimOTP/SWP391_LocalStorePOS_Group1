<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <title>Stock-Out Detailed | LocalStorePOS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="<c:url value='/resources/css/inventory/stock-out.css'/>">
</head>
<body>
<jsp:include page="../../layer/header.jsp" />
<jsp:include page="../../layer/sidebar.jsp" />

<div class="main-content">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2 class="fw-bold mb-0">Report detail</h2>
        <button class="btn-cancel" onclick="history.back()">
            <i class="fa-solid fa-arrow-left me-2"></i>Back To Reports
        </button>
    </div>

    <div class="info-card mb-4 border-primary-subtle border-start border-5">
        <div class="d-flex justify-content-between align-items-start mb-4">
            <h5 class="fw-bold mb-0">Request ID: <span class="text-primary">SO_${stockOut.stockOutId}</span></h5>

            <c:choose>
                <c:when test="${stockOut.status.transactionStatusId == 1}">
                    <span class="status-badge status-discontinued">Input Pending</span>
                </c:when>
                <c:when test="${stockOut.status.transactionStatusId == 2}">
                    <span class="status-badge status-pending">Pending Approval</span>
                </c:when>
                <c:when test="${stockOut.status.transactionStatusId == 3}">
                    <span class="status-badge status-outstock">Rejected</span>
                </c:when>
                <c:when test="${stockOut.status.transactionStatusId == 4}">
                    <span class="status-badge status-active">Completed</span>
                </c:when>
            </c:choose>
        </div>

        <div class="row g-4">
            <div class="col-md-3">
                <label class="info-label">Action type</label>
                <div class="info-value">Stock-out</div>

                <label class="info-label mt-3">Time</label>
                <div class="info-value">
                    <fmt:parseDate value="${stockOut.createdAt}" pattern="yyyy-MM-dd'T'HH:mm" var="parsedDate" />
                    <fmt:formatDate value="${parsedDate}" pattern="dd/MM/yyyy HH:mm" />
                </div>
            </div>
            <div class="col-md-3">
                <label class="info-label">Approver</label>
                <div class="info-value text-muted">
                    <i class="fa-solid fa-user-check me-1"></i> ${stockOut.approver != null ? stockOut.approver.fullName : "...."}
                </div>

                <label class="info-label mt-3">Staff</label>
                <div class="info-value">
                    <i class="fa-regular fa-id-badge me-1"></i> ${stockOut.requester.fullName}
                </div>
            </div>
            <div class="col-md-6">
                <label class="info-label">General Note</label>
                <div class="p-3 bg-light rounded-3 text-secondary min-vh-10" style="font-size: 0.9rem;">
                    ${stockOut.generalReason != null ? stockOut.generalReason : "No additional notes provided."}
                </div>
            </div>
        </div>
    </div>

    <div class="table-section shadow-sm border-0">
        <div class="table-responsive">
            <table class="table table-hover align-middle">
                <thead>
                <tr>
                    <th class="text-center" style="width: 50px;">#</th>
                    <th>SKU</th>
                    <th>Product Name</th>
                    <th>Unit</th>
                    <th class="text-center">Stock-out Quantity</th>
                    <th class="text-end">Price per Unit</th>
                    <th class="text-end">Total Price</th>
                    <th>Note</th>
                </tr>
                </thead>
                <tbody>
                <c:forEach items="${stockOut.details}" var="d" varStatus="s">
                    <tr>
                        <td class="text-center text-muted small">${s.index + 1}</td>
                        <td class="text-sku">#${d.product.productId}</td>
                        <td class="fw-bold">${d.product.productName}</td>
                        <td><span class="badge border text-dark fw-normal px-2">${d.product.unit}</span></td>
                        <td class="text-center">
                            <span class="badge rounded-pill bg-danger px-3 py-2">${d.quantity}</span>
                        </td>
                        <td class="text-end fw-bold">
                            <fmt:formatNumber value="${d.costAtExport}" type="currency" currencySymbol="đ" />
                        </td>
                        <td class="text-end fw-bold text-primary">
                            <fmt:formatNumber value="${d.quantity * d.costAtExport}" type="currency" currencySymbol="đ" />
                        </td>
                        <td>
                            <div class="view-only-box small">${d.reason}</div>
                        </td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
        </div>
    </div>

    <div class="d-flex justify-content-end mt-4">
        <button class="btn-cancel px-5" onclick="window.history.back()">
            <i class="fa-solid fa-chevron-left me-2"></i>Back to List
        </button>
    </div>
</div>
</body>
</html>