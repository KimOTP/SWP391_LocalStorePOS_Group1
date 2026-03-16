<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Audit Details | LocalStorePOS</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="stylesheet" href="<c:url value='/resources/css/inventory/audit-session.css'/>">
  <style>
    /* CSS Badge Trạng thái chuẩn hệ thống */
    .status-badge { padding: 6px 16px !important; border-radius: 8px !important; font-size: 0.75rem !important; font-weight: 700 !important; display: inline-flex !important; align-items: center !important; }
    .badge-pending { background: #fef9c3 !important; color: #ca8a04 !important; border: 1px solid #fef08a !important; }
    .badge-completed { background: #dcfce7 !important; color: #16a34a !important; border: 1px solid #bbf7d0 !important; }
    .badge-rejected { background: #fee2e2 !important; color: #dc2626 !important; border: 1px solid #fecaca !important; }
    .badge-input-pending { background: #e0f2fe !important; color: #0284c7 !important; border: 1px solid #bae6fd !important; }
  </style>
</head>
<body>
<jsp:include page="../../layer/header.jsp" />
<jsp:include page="../../layer/sidebar.jsp" />

<div class="main-content">
  <div class="d-flex justify-content-between align-items-center mb-4">
    <div>
      <h2 class="fw-bold mb-0">Audit Details</h2>
      <small class="text-muted">Review inventory audit session information</small>
    </div>
    <button class="btn btn-cancel px-4 d-inline-flex align-items-center text-decoration-none" onclick="window.history.back()">
      <i class="fa-solid fa-arrow-left me-2"></i>Back to Reports
    </button>
  </div>

  <div class="card shadow-sm border-0 mb-4" style="border-radius: 16px; background: #ffffff;">
    <div class="card-body p-4">
      <div class="d-flex justify-content-between align-items-center mb-4 pb-3 border-bottom">
        <h5 class="fw-bold mb-0 text-dark">
          <i class="fa-solid fa-clipboard-check me-2" style="color: #2563eb;"></i>Log ID: <span class="text-primary ms-1">KK-${audit.auditId}</span>
        </h5>

        <c:choose>
          <c:when test="${audit.status.transactionStatusId == 1}">
            <span class="status-badge badge-input-pending"><i class="fa-solid fa-pen-to-square me-2"></i>Input Pending</span>
          </c:when>
          <c:when test="${audit.status.transactionStatusId == 2}">
            <span class="status-badge badge-pending"><i class="fa-solid fa-spinner fa-spin me-2"></i>Pending Approval</span>
          </c:when>
          <c:when test="${audit.status.transactionStatusId == 3}">
            <span class="status-badge badge-rejected"><i class="fa-solid fa-xmark me-2"></i>Rejected</span>
          </c:when>
          <c:when test="${audit.status.transactionStatusId == 4}">
            <span class="status-badge badge-completed"><i class="fa-solid fa-check-double me-2"></i>Completed</span>
          </c:when>
        </c:choose>
      </div>

      <div class="row g-4 align-items-start">
        <div class="col-md-3">
          <label class="info-label">Audit Date</label>
          <div class="info-value p-2 px-3 bg-light rounded-3 border text-muted" style="min-height: 42px;">
            <i class="fa-regular fa-calendar-check me-2"></i>
            <fmt:parseDate value="${audit.auditDate}" pattern="yyyy-MM-dd'T'HH:mm" var="pDate" />
            <fmt:formatDate value="${pDate}" pattern="dd/MM/yyyy HH:mm" />
          </div>
        </div>

        <div class="col-md-3">
          <label class="info-label">Staff in Charge</label>
          <div class="info-value p-2 px-3 bg-light rounded-3 border text-dark fw-bold" style="min-height: 42px;">
            <i class="fa-regular fa-id-badge me-2 text-muted"></i>${audit.staff.fullName}
          </div>
        </div>

        <div class="col-md-3">
          <label class="info-label">Approver</label>
          <div class="info-value p-2 px-3 bg-primary-subtle text-primary border border-primary-subtle rounded-3 fw-bold" style="min-height: 42px;">
            <i class="fa-solid fa-user-check me-2"></i>${audit.approver != null ? audit.approver.fullName : "N/A"}
          </div>
        </div>
      </div>
    </div>
  </div>

  <div class="d-flex justify-content-between align-items-center mb-3 mt-2">
    <h5 class="fw-bold mb-0 text-dark">Audited Items</h5>
  </div>

  <div class="product-table-card mb-5">
    <div class="table-responsive">
      <table class="table table-hover align-middle mb-0">
        <thead>
        <tr class="thead-row">
          <th class="th-cell text-center" style="width: 50px;">#</th>
          <th class="th-cell text-center" style="width: 140px;">SKU</th>
          <th class="th-cell">Product Name</th>
          <th class="th-cell text-center" style="width: 120px;">Expected</th>
          <th class="th-cell text-center" style="width: 120px;">Actual</th>
          <th class="th-cell text-center" style="width: 120px;">Change</th>
          <th class="th-cell text-end" style="width: 180px;">Value Change</th>
          <th class="th-cell" style="width: 250px;">Reason</th>
        </tr>
        </thead>
        <tbody>
        <c:forEach items="${audit.details}" var="d" varStatus="status">
          <c:set var="diff" value="${d.actualQuantity - d.expectedQuantity}" />
          <c:set var="valChange" value="${diff * d.unitCostAtAudit}" />

          <tr>
            <td class="td-cell text-center text-muted fw-bold">${status.index + 1}</td>

            <td class="td-cell align-middle text-center">
              <div class="d-flex align-items-center justify-content-center h-100">
                <span class="text-sku">#${d.product.productId}</span>
              </div>
            </td>

            <td class="td-cell align-middle">
              <div class="fw-bold text-dark">${d.product.productName}</div>
            </td>

            <td class="td-cell text-center align-middle">
              <span class="badge border text-dark fw-normal px-3 py-2" style="background: #fff;">${d.expectedQuantity}</span>
            </td>

            <td class="td-cell text-center align-middle">
              <span class="badge bg-light text-secondary border px-3 py-2 fw-bold fs-6">${d.actualQuantity}</span>
            </td>

            <td class="td-cell text-center align-middle">
                                <span class="badge ${diff >= 0 ? 'bg-success' : 'bg-danger'} px-3 py-2 fw-bold shadow-sm">
                                    ${diff > 0 ? '+' : ''}${diff}
                                </span>
            </td>

            <td class="td-cell text-end align-middle">
                                <span class="fw-bold ${diff >= 0 ? 'text-success' : 'text-danger'}">
                                    ${diff > 0 ? '+' : ''}<fmt:formatNumber value="${valChange}" pattern="#,##0"/> VND
                                </span>
            </td>

            <td class="td-cell align-middle">
              <div class="p-2 bg-light border rounded-2 text-muted small" style="min-height: 36px; display: flex; align-items: center;">
                  ${d.discrepancyReason != null && !d.discrepancyReason.isEmpty() ? d.discrepancyReason : "N/A"}
              </div>
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