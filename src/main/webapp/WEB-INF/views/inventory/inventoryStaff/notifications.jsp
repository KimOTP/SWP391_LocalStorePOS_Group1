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
    <div>
      <h2 class="fw-bold mb-0">Stock-in Notifications</h2>
      <small class="text-muted">Manage incoming stock requests</small>
    </div>
  </div>

  <div class="row g-4">
    <div class="col-md-3">
      <div class="stat-card">
        <div class="stat-card-header">
          <div class="stat-card-info">
            <div class="stat-title">Pending Requests</div>
            <div class="stat-value text-pending">${totalPending}</div>
          </div>
          <div class="stat-card-icon stat-icon-pending">
            <i class="fa-solid fa-bell-concierge"></i>
          </div>
        </div>
        <div class="stat-sub">Requests awaiting processing</div>
      </div>
    </div>
  </div>

  <div class="filter-bar mt-4 mb-3">
    <div class="search-box-standalone" style="width: 250px;">
      <i class="fa-solid fa-calendar-day search-icon"></i>
      <input type="date" id="dateFilter" class="form-control" title="Filter by Date">
    </div>

    <div class="filter-actions">
      <div class="dropdown">
        <button class="btn btn-filter" type="button" data-bs-toggle="dropdown" data-bs-auto-close="outside">
          <span id="requesterLabel">All Requesters</span>
          <i class="fa-solid fa-chevron-down ms-1 tiny-icon"></i>
        </button>
        <div class="dropdown-menu shadow border-0 p-2" id="requesterFilterMenu" style="min-width: 200px;">
          <label class="dropdown-item d-flex align-items-center py-2" style="cursor: pointer;">
            <input type="checkbox" class="filter-checkbox filter-cb-all" checked>
            <span class="ms-2 fw-bold">Show All</span>
          </label>
          <li><hr class="dropdown-divider mx-2"></li>
        </div>
      </div>

      <button class="btn btn-filter-more text-primary border-primary" onclick="resetFilters()">
        <i class="fa-solid fa-rotate-left"></i> Reset
      </button>
    </div>
  </div>

  <div class="product-table-card">
    <div class="table-responsive">
      <table class="table table-hover align-middle" id="notificationTable">
        <thead>
        <tr class="thead-row">
          <th class="th-cell text-center" style="width: 60px;">#</th>
          <th class="th-cell">Request ID</th>
          <th class="th-cell">Items</th>
          <th class="th-cell">Requested By</th>
          <th class="th-cell">Requested Time</th>
          <th class="th-cell text-end">Action</th>
        </tr>
        </thead>
        <tbody>
        <c:forEach items="${pendingRequests}" var="item" varStatus="status">
          <tr class="request-row"
              data-requester="${item.requester.fullName}"
              data-date="<fmt:formatDate value='${pDate}' pattern='yyyy-MM-dd' />">
            <td class="td-cell text-center text-muted small">${status.index + 1}</td>
            <td class="td-cell"><span class="text-sku">SI_${item.stockInId}</span></td>
            <td class="td-cell fw-bold text-dark">${item.details.size()} items</td>
            <td class="td-cell col-requester">${item.requester.fullName}</td>
            <td class="td-cell col-date text-muted">
              <fmt:parseDate value="${item.createdAt}" pattern="yyyy-MM-dd'T'HH:mm" var="pDate" />
              <fmt:formatDate value="${pDate}" pattern="dd/MM/yyyy HH:mm" />
            </td>
            <td class="td-cell text-end">
              <a href="<c:url value='/stockIn/process?id=${item.stockInId}'/>" class="btn-add text-decoration-none">
                <i class="fa-solid fa-bolt me-2"></i>Process
              </a>
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
<script src="<c:url value='/resources/js/inventory/notifications.js'/>"></script>
</body>
</html>