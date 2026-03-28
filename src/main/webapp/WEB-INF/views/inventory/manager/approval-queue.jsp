<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Approval Queue | LocalStorePOS</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css" rel="stylesheet">
  <link rel="stylesheet" href="<c:url value='/resources/css/inventory/approval-queue.css'/>">
</head>
<body>

<jsp:include page="../../layer/header.jsp" />
<jsp:include page="../../layer/sidebar.jsp" />

<div class="main-content">

  <input type="hidden" id="serverMessage" value="${message}">
  <input type="hidden" id="serverStatus" value="${status}">

  <div class="d-flex justify-content-between align-items-center mb-4">
    <div>
      <h2 class="fw-bold mb-0">Approval Queue</h2>
      <small class="text-muted">Manage pending approvals</small>
    </div>
  </div>

  <div class="row g-4">
    <div class="col-md-3">
      <div class="stat-card">
        <div class="stat-card-header">
          <div class="stat-card-info">
            <div class="stat-title">Pending Approvals</div>
            <div class="stat-value text-pending">${pendingRequests.size()}</div>
          </div>
          <div class="stat-card-icon stat-icon-pending">
            <i class="fa-solid fa-list-check"></i>
          </div>
        </div>
        <div class="stat-sub">Actions requiring attention</div>
      </div>
    </div>
  </div>

  <div class="card shadow-sm border-0 mb-4" style="border-radius: 16px; background: #ffffff;">
    <div class="card-body p-4">
      <div class="row g-3 align-items-end">
        <div class="col-md-3">
          <label class="small fw-bold text-muted text-uppercase mb-2">Filter by Date</label>
          <div class="search-box-standalone w-100">
            <i class="fa-solid fa-calendar-day search-icon"></i>
            <input type="date" id="dateFilter" class="form-control">
          </div>
        </div>
        <div class="col-md-3">
          <label class="small fw-bold text-muted text-uppercase mb-2">Staff Member</label>
          <select id="staffFilter" class="form-select custom-filter-select">
            <option value="ALL">All Staff</option>
            <c:forEach items="${staffList}" var="s">
              <option value="${s.fullName}">${s.fullName}</option>
            </c:forEach>
          </select>
        </div>
        <div class="col-md-3">
          <label class="small fw-bold text-muted text-uppercase mb-2">Action Type</label>
          <select id="typeFilter" class="form-select custom-filter-select">
            <option value="ALL">All Types</option>
            <option value="Stock-in">Stock-in</option>
            <option value="Stock-out">Stock-out</option>
            <option value="Audit">Audit</option>
          </select>
        </div>
        <div class="col-md-3">
          <button class="btn btn-filter-reset w-100" onclick="resetFilters()">
            <i class="fa-solid fa-rotate-left me-2"></i>Reset Filters
          </button>
        </div>
      </div>
    </div>
  </div>

  <div class="product-table-card">
    <div class="table-responsive">
      <table class="table table-hover align-middle" id="approvalTable">
        <thead>
        <tr class="thead-row">
          <th class="th-cell text-center" style="width: 60px;">#</th>
          <th class="th-cell">Log ID</th>
          <th class="th-cell text-center">Type</th>
          <th class="th-cell">Staff</th>
          <th class="th-cell">Completion Time</th>
          <th class="th-cell text-center">Approval Actions</th>
          <th class="th-cell text-end">Details</th>
        </tr>
        </thead>
        <tbody>
        <c:forEach items="${pendingRequests}" var="item" varStatus="status">
          <fmt:parseDate value="${item.time}" pattern="yyyy-MM-dd'T'HH:mm" var="pDate" />
          <tr class="request-row"
              data-date="<fmt:formatDate value='${pDate}' pattern='yyyy-MM-dd' />"
              data-staff="${item.staff}"
              data-type="${item.type}">

            <td class="td-cell text-center text-muted small">${status.index + 1}</td>
            <td class="td-cell"><span class="text-sku">${item.prefix}${item.id}</span></td>
            <td class="td-cell text-center">
                                <span class="type-badge
                                    ${item.type == 'Audit' ? 'type-audit' : (item.type == 'Stock-out' ? 'type-stockout' : 'type-stockin')}">
                                    ${item.type}
                                </span>
            </td>

            <td class="td-cell staff-cell fw-bold text-dark">${item.staff}</td>

            <td class="td-cell text-muted small">
              <fmt:formatDate value="${pDate}" pattern="dd/MM/yyyy HH:mm" />
            </td>

            <td class="td-cell text-center">
              <div class="d-flex justify-content-center gap-2">
                <button class="btn-reject" onclick="handleApproval('${item.type}', ${item.id}, false)">
                  <i class="fa-solid "></i>  Reject
                </button>
                <button class="btn-approve" onclick="handleApproval('${item.type}', ${item.id}, true)">
                  <i class="fa-solid "></i>  Approve
                </button>
              </div>
            </td>

            <td class="td-cell text-end">
              <c:choose>
                <c:when test="${item.type == 'Stock-in'}">
                  <a href="<c:url value='/stockIn/details?id=${item.id}'/>" class="btn-view-detail">
                    <i class="fa-regular fa-eye"></i> View
                  </a>
                </c:when>
                <c:when test="${item.type == 'Stock-out'}">
                  <a href="<c:url value='/stockOut/details?id=${item.id}'/>" class="btn-view-detail">
                    <i class="fa-regular fa-eye"></i> View
                  </a>
                </c:when>
                <c:when test="${item.type == 'Audit'}">
                  <a href="<c:url value='/audit/details?id=${item.id}'/>" class="btn-view-detail">
                    <i class="fa-regular fa-eye"></i> View
                  </a>
                </c:when>
              </c:choose>
            </td>
          </tr>
        </c:forEach>
        </tbody>
      </table>
    </div>
  </div>
</div>

<form id="actionForm" action="/inventory/approval/action" method="POST">
  <input type="hidden" name="type" id="actionType">
  <input type="hidden" name="id" id="actionId">
  <input type="hidden" name="approve" id="isApprove">
</form>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script src="<c:url value='/resources/js/inventory/approval-queue.js'/>"></script>
</body>
</html>