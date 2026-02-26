<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Stock-in Process | LocalStorePOS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<c:url value='/resources/css/inventory/stock-in.css'/>">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

</head>
<body>
<jsp:include page="../../layer/header.jsp" />
<jsp:include page="../../layer/sidebar.jsp" />

<div class="main-content">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2 class="fw-bold mb-0">Stock-In Verification</h2>
    </div>

    <input type="hidden" id="serverMessage" value="${message}">
    <input type="hidden" id="serverStatus" value="${status}">

    <div class="info-card mb-4">
        <div class="d-flex justify-content-between align-items-start mb-4">
            <h5 class="fw-bold mb-0">Request ID: <span class="text-primary">SI_${stockIn.stockInId}</span></h5>
            <span class="status-badge">
                <i class="fa-solid fa-clock-rotate-left me-1"></i> In Progress
            </span>
        </div>

        <div class="row g-4">
            <div class="col-md-3">
                <label class="info-label">Requested by</label>
                <div class="info-value">
                    <i class="fa-regular fa-user-circle me-1 text-muted"></i> ${stockIn.requester.fullName}
                </div>
            </div>
            <div class="col-md-3">
                <label class="info-label">Inbound Date</label>
                <div class="info-value">
                    <i class="fa-regular fa-calendar me-1 text-muted"></i>
                    <jsp:useBean id="now" class="java.util.Date" />
                    <fmt:formatDate value="${now}" pattern="dd/MM/yyyy" />
                </div>
            </div>
            <div class="col-md-3">
                <label class="info-label">Process Time</label>
                <div class="info-value">
                    <i class="fa-regular fa-clock me-1 text-muted"></i>
                    <fmt:formatDate value="${now}" pattern="HH:mm" />
                </div>
            </div>
            <div class="col-md-3">
                <label class="info-label">Staff in Charge</label>
                <div class="info-value text-primary">
                    <i class="fa-solid fa-user-tie me-1"></i> ${loggedInAccount.employee.fullName}
                </div>
            </div>
        </div>
    </div>

    <div class="table-section shadow-sm border-0">
        <div class="mb-4">
            <h5 class="fw-bold mb-0">Product Verification</h5>
            <small class="text-muted">Ensure physical stock matches the digital request.</small>
        </div>

        <div class="table-responsive">
            <table class="table table-hover align-middle" id="processTable">
                <thead>
                <tr>
                    <th style="width: 60px;" class="text-center">#</th>
                    <th>SKU</th>
                    <th>Product Name</th>
                    <th>Unit</th>
                    <th class="text-center">Expected Qty</th>
                    <th class="text-center">Actual Qty</th>
                </tr>
                </thead>
                <tbody>
                <c:forEach items="${stockIn.details}" var="d" varStatus="s">
                    <tr data-detail-id="${d.detailId}">
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
                            <input type="number" class="input-actual" value="${d.requestedQuantity}" min="0">
                        </td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
        </div>
    </div>

    <div class="d-flex justify-content-end gap-3 mt-4">
        <button class="btn-cancel" onclick="window.history.back()">
            <i class="fa-solid fa-arrow-left me-2"></i>Back to List
        </button>
        <button class="btn-confirm" onclick="submitStockIn()">
            <i class="fa-solid fa-check-double me-2"></i>Confirm Stock-In
        </button>
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