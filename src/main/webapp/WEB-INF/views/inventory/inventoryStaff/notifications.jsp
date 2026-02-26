<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Stock-in Notifications | LocalStorePOS</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css" rel="stylesheet">
  <link rel="stylesheet" href="<c:url value='/resources/css/inventory/notifications.css'/>">
</head>
<body>

<jsp:include page="/WEB-INF/views/layer/header.jsp" />
<jsp:include page="/WEB-INF/views/layer/sidebar.jsp" />

<div class="main-content">
  <div class="d-flex justify-content-between align-items-center mb-4">
    <h2 class="fw-bold mb-0">Stock-in Notifications</h2>
  </div>

  <div class="row g-4 mb-4">
    <div class="col-md-4">
      <div class="stat-card">
        <i class="fa-solid fa-bell-concierge stat-icon"></i>
        <div class="stat-title">Quantity of stock-in requests</div>
        <div class="stat-value">${totalPending}</div>
        <div class="small text-muted mt-2">Requests awaiting processing</div>
      </div>
    </div>
  </div>

  <div class="card shadow-sm border-0">
    <div class="card-body p-4 notification-container">

      <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
          <h5 class="fw-bold mb-0">Pending Requests</h5>
          <small class="text-muted">Use filters to find specific requests.</small>
        </div>
      </div>

      <div class="row g-2 mb-4 align-items-center">
        <div class="col-md-3">
          <label class="small fw-bold text-muted mb-1 text-uppercase">Filter by Date</label>
          <div class="search-box">
            <i class="fa-solid fa-calendar-day search-icon"></i>
            <input type="date" id="dateFilter" class="form-control">
          </div>
        </div>

        <div class="col-md-3">
          <label class="small fw-bold text-muted mb-1 text-uppercase">Filter by Requester</label>
          <div class="dropdown">
            <button class="btn btn-filter" type="button" data-bs-toggle="dropdown" data-bs-auto-close="outside">
              <span id="requesterLabel">All Requesters</span>
              <i class="fa-solid fa-chevron-down tiny-icon"></i>
            </button>
            <div class="dropdown-menu shadow border-0 p-2" id="requesterFilterMenu" style="min-width: 200px;">
              <label class="dropdown-item d-flex align-items-center py-2">
                <input type="checkbox" class="filter-cb-all" checked>
                <span class="ms-2">Show All</span>
              </label>
              <hr class="dropdown-divider">
            </div>
          </div>
        </div>

        <div class="col-md-2 mt-4">
          <button class="btn btn-light btn-sm text-primary fw-bold" onclick="resetFilters()">
            <i class="fa-solid fa-rotate-left me-1"></i> Reset
          </button>
        </div>
      </div>

      <div class="table-responsive">
        <table class="table table-hover align-middle" id="notificationTable">
          <thead>
          <tr>
            <th class="text-center" style="width: 60px;">#</th>
            <th>Request ID</th>
            <th>Distinct Products</th>
            <th>Requested By</th>
            <th>Requested Time</th>
            <th class="text-end">Action</th>
          </tr>
          </thead>
          <tbody>
          <c:forEach items="${pendingRequests}" var="item" varStatus="status">
            <tr class="request-row"
                data-requester="${item.requester.fullName}"
                data-date="<fmt:formatDate value='${pDate}' pattern='yyyy-MM-dd' />">

              <td class="text-center text-muted small">${status.index + 1}</td>
              <td><span class="request-id">RI_${item.stockInId}</span></td>
              <td class="fw-bold">${item.details.size()} items</td>
              <td class="col-requester">${item.requester.fullName}</td>
              <td class="col-date">
                <fmt:parseDate value="${item.createdAt}" pattern="yyyy-MM-dd'T'HH:mm" var="pDate" />
                <fmt:formatDate value="${pDate}" pattern="dd/MM/yyyy HH:mm" />
              </td>
              <td class="text-end">
                <a href="/stockIn/process?id=${item.stockInId}" class="action-link">Start Action</a>
              </td>
            </tr>
          </c:forEach>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script src="<c:url value='/resources/js/inventory/notifications.js'/>"></script>
</body>
</html>