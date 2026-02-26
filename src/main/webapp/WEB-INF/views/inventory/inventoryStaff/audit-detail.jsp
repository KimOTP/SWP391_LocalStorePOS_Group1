<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Audit Detailed | LocalStorePOS</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="stylesheet" href="<c:url value='/resources/css/inventory/stock-out.css'/>">
  <link rel="stylesheet" href="<c:url value='/resources/css/inventory/audit-session.css'/>">
</head>
<body>
<jsp:include page="../../layer/header.jsp" />
<jsp:include page="../../layer/sidebar.jsp" />

<div class="main-content">
  <div class="d-flex justify-content-between align-items-center mb-4">
    <h2 class="fw-bold mb-0">Audit Detailed</h2>
    <button class="btn-cancel" onclick="history.back()">
      <i class="fa-solid fa-arrow-left me-2"></i>Back To Reports
    </button>
  </div>

  <div class="info-card mb-4 border-primary border-top border-4">
    <div class="d-flex justify-content-between align-items-start mb-4">
      <h5 class="fw-bold mb-0 text-secondary">Log KK-${audit.auditId} Information</h5>

      <c:choose>
        <c:when test="${audit.status.transactionStatusId == 1}">
          <span class="status-badge status-discontinued">Input Pending</span>
        </c:when>
        <c:when test="${audit.status.transactionStatusId == 2}">
          <span class="status-badge status-pending">Pending Approval</span>
        </c:when>
        <c:when test="${audit.status.transactionStatusId == 3}">
          <span class="status-badge status-outstock">Rejected</span>
        </c:when>
        <c:when test="${audit.status.transactionStatusId == 4}">
          <span class="status-badge status-active">Completed</span>
        </c:when>
      </c:choose>
    </div>

    <div class="row g-4">
      <div class="col-md-3">
        <label class="info-label">Staff in Charge</label>
        <div class="info-value">${audit.staff.fullName}</div>
        <label class="info-label mt-3">Approver</label>
        <div class="info-value text-primary">${audit.approver != null ? audit.approver.fullName : "N/A"}</div>
      </div>
      <div class="col-md-3">
        <label class="info-label">Audit Date</label>
        <div class="info-value">
          <i class="fa-regular fa-calendar-check me-1 text-muted"></i>
          <fmt:parseDate value="${audit.auditDate}" pattern="yyyy-MM-dd'T'HH:mm" var="pDate" />
          <fmt:formatDate value="${pDate}" pattern="dd/MM/yyyy HH:mm" />
        </div>
      </div>
    </div>
  </div>

  <div class="table-section shadow-sm">
    <div class="table-responsive">
      <table class="table table-hover align-middle">
        <thead>
        <tr>
          <th style="width: 60px;" class="text-center">#</th>
          <th>Product Name</th>
          <th class="text-center">Expected</th>
          <th class="text-center">Actual</th>
          <th class="text-center">Change</th>
          <th class="text-center">Value Change</th>
          <th>Reason</th>
        </tr>
        </thead>
        <tbody>
        <c:forEach items="${audit.details}" var="d" varStatus="status">
          <c:set var="diff" value="${d.actualQuantity - d.expectedQuantity}" />
          <c:set var="valChange" value="${diff * d.unitCostAtAudit}" />
          <tr>
            <td class="text-center text-muted small">${status.index + 1}</td>
            <td>
              <div class="fw-bold">${d.product.productName}</div>
              <small class="text-sku">#${d.product.productId}</small>
            </td>
            <td class="text-center">
              <span class="badge bg-secondary-subtle text-dark px-3 rounded-pill">${d.expectedQuantity}</span>
            </td>
            <td class="text-center">
              <span class="view-only-box border bg-white">${d.actualQuantity}</span>
            </td>
            <td class="text-center">
                            <span class="badge ${diff >= 0 ? 'bg-success' : 'bg-danger'} px-3 rounded-pill">
                                ${diff > 0 ? '+' : ''}${diff}
                            </span>
            </td>
            <td class="text-center">
                            <span class="fw-bold ${diff >= 0 ? 'text-success' : 'text-danger'}">
                                ${diff > 0 ? '+' : ''}<fmt:formatNumber value="${valChange}" pattern="#,###"/> đ
                            </span>
            </td>
            <td class="text-muted small">${d.discrepancyReason}</td>
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