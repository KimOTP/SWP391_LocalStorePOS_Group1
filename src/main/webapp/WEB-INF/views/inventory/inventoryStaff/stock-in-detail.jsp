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
    <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<c:url value='/resources/css/inventory/stock-in-request.css'/>">
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

<input type="hidden" id="serverMessage" value="${message}">
<input type="hidden" id="serverStatus" value="${status}">

<div class="main-content">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h2 class="fw-bold mb-0">Stock-In Details</h2>
            <small class="text-muted">Review finalized inventory quantities</small>
        </div>
        <button class="btn btn-cancel px-4 d-inline-flex align-items-center text-decoration-none" onclick="window.history.back()">
            <i class="fa-solid fa-arrow-left me-2"></i>Back to Reports
        </button>
    </div>

    <div class="card shadow-sm border-0 mb-4" style="border-radius: 16px; background: #ffffff;">
        <div class="card-body p-4">
            <div class="d-flex justify-content-between align-items-center mb-4 pb-3 border-bottom">
                <h5 class="fw-bold mb-0 text-dark">
                    <i class="fa-solid fa-file-invoice me-2" style="color: #2563eb;"></i>Request ID: <span class="text-primary ms-1">SI_${stockIn.stockInId}</span>
                </h5>

                <c:choose>
                    <c:when test="${stockIn.status.transactionStatusId == 1}">
                        <span class="status-badge badge-input-pending"><i class="fa-solid fa-pen-to-square me-2"></i>Input Pending</span>
                    </c:when>
                    <c:when test="${stockIn.status.transactionStatusId == 2}">
                        <span class="status-badge badge-pending"><i class="fa-solid fa-spinner fa-spin me-2"></i>Pending Approval</span>
                    </c:when>
                    <c:when test="${stockIn.status.transactionStatusId == 3}">
                        <span class="status-badge badge-rejected"><i class="fa-solid fa-xmark me-2"></i>Rejected</span>
                    </c:when>
                    <c:when test="${stockIn.status.transactionStatusId == 4}">
                        <span class="status-badge badge-completed"><i class="fa-solid fa-check-double me-2"></i>Completed</span>
                    </c:when>
                </c:choose>
            </div>

            <div class="row g-4 align-items-end">
                <div class="col-md-4">
                    <label class="info-label">Requested by</label>
                    <div class="info-value p-2 px-3 bg-light rounded-3 border text-dark fw-bold" style="height: 42px;">
                        <i class="fa-solid fa-user me-2 text-muted"></i>${stockIn.requester.fullName}
                    </div>
                </div>
                <div class="col-md-4">
                    <label class="info-label">Request Date</label>
                    <div class="info-value p-2 px-3 bg-light rounded-3 border text-muted" style="height: 42px;">
                        <i class="fa-regular fa-calendar me-2"></i>
                        <fmt:parseDate value="${stockIn.createdAt}" pattern="yyyy-MM-dd'T'HH:mm" var="cDate" />
                        <fmt:formatDate value="${cDate}" pattern="dd/MM/yyyy" />
                    </div>
                </div>
                <div class="col-md-4">
                    <label class="info-label">Inbound Time</label>
                    <div class="info-value p-2 px-3 bg-light rounded-3 border text-muted" style="height: 42px;">
                        <i class="fa-regular fa-clock me-2"></i>
                        <fmt:parseDate value="${stockIn.receivedAt}" pattern="yyyy-MM-dd'T'HH:mm" var="pDate" />
                        <fmt:formatDate value="${pDate}" pattern="dd/MM/yyyy HH:mm" />
                    </div>
                </div>

                <div class="col-md-4">
                    <label class="info-label">Staff in Charge (Receiver)</label>
                    <div class="info-value p-2 px-3 bg-primary-subtle text-primary border border-primary-subtle rounded-3 fw-bold" style="height: 42px;">
                        <i class="fa-solid fa-user-tie me-2"></i>${stockIn.staff.fullName}
                    </div>
                </div>

                <div class="col-md-4">
                    <label class="info-label">Approver</label>
                    <div class="info-value p-2 px-3 bg-success-subtle text-success border border-success-subtle rounded-3 fw-bold" style="height: 42px;">
                        <i class="fa-solid fa-user-check me-2"></i>
                        <c:choose>
                            <c:when test="${not empty stockIn.approver}">
                                ${stockIn.approver.fullName}
                            </c:when>
                            <c:otherwise>
                                <span class="text-muted fw-normal">Waiting for approval...</span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="d-flex justify-content-between align-items-center mb-3 mt-2">
        <h5 class="fw-bold mb-0 text-dark">Received Items</h5>
    </div>

    <div class="product-table-card mb-5">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead>
                <tr class="thead-row">
                    <th class="th-cell text-center" style="width: 60px;">#</th>
                    <th class="th-cell" style="width: 140px;">SKU</th>
                    <th class="th-cell">Product Information</th>
                    <th class="th-cell text-center" style="width: 120px;">Unit</th>
                    <th class="th-cell text-center" style="width: 160px;">Expected Qty</th>
                    <th class="th-cell text-center" style="width: 160px;">Actual Received</th>
                </tr>
                </thead>
                <tbody>
                <c:forEach items="${stockIn.details}" var="d" varStatus="s">
                    <tr class="${d.receivedQuantity != d.requestedQuantity ? 'table-warning' : ''}">
                        <td class="td-cell text-center text-muted fw-bold">${s.index + 1}</td>
                        <td class="td-cell align-middle text-center">
                            <div class="d-flex align-items-center justify-content-center h-100">
                                <span class="text-sku">#${d.product.productId}</span>
                            </div>
                        </td>
                        <td class="td-cell align-middle">
                            <div class="fw-bold text-dark">${d.product.productName}</div>
                        </td>
                        <td class="td-cell text-center align-middle">
                            <span class="badge border text-dark fw-normal px-3 py-2" style="background: #fff;">${d.product.unit}</span>
                        </td>
                        <td class="td-cell text-center align-middle">
                            <span class="badge bg-light text-secondary border px-3 py-2 fw-bold fs-6">${d.requestedQuantity}</span>
                        </td>
                        <td class="td-cell text-center align-middle">
                                <span class="badge ${d.receivedQuantity != d.requestedQuantity ? 'bg-danger' : 'bg-success'} px-3 py-2 fw-bold fs-6 text-white shadow-sm">
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
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script src="<c:url value='/resources/js/inventory/stock-in-detail.js'/>"></script>
</body>
</html>