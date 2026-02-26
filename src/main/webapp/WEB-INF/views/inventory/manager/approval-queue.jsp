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
  <h2 class="fw-bold mb-4">Approval Queue</h2>

  <input type="hidden" id="serverMessage" value="${message}">
  <input type="hidden" id="serverStatus" value="${status}">

  <div class="row g-4 mb-4">
    <div class="col-md-4">
      <div class="stat-card border-0 shadow-sm">
        <i class="fa-solid fa-list-check stat-icon"></i>
        <div class="stat-title">Pending Approvals</div>
        <div class="stat-value text-pending">${pendingRequests.size()}</div>
        <div class="small text-muted mt-2">Actions requiring attention</div>
      </div>
    </div>
  </div>

  <div class="card shadow-sm border-0 mb-4">
    <div class="card-body p-4">
      <div class="row g-3 align-items-end">
        <div class="col-md-3">
          <label class="small fw-bold text-muted text-uppercase mb-2">Filter by Date</label>
          <div class="search-box">
            <i class="fa-solid fa-calendar-day search-icon"></i>
            <input type="date" id="dateFilter" class="form-control">
          </div>
        </div>
        <div class="col-md-3">
          <label class="small fw-bold text-muted text-uppercase mb-2">Staff Member</label>
          <select id="staffFilter" class="form-select btn-filter">
            <option value="ALL">All Staff</option>
            <c:forEach items="${staffList}" var="s">
              <option value="${s.fullName}">${s.fullName}</option>
            </c:forEach>
          </select>
        </div>
        <div class="col-md-3">
          <label class="small fw-bold text-muted text-uppercase mb-2">Action Type</label>
          <select id="typeFilter" class="form-select btn-filter">
            <option value="ALL">All Types</option>
            <option value="Stock-in">Stock-in</option>
            <option value="Stock-out">Stock-out</option>
            <option value="Audit">Audit</option>
          </select>
        </div>
        <div class="col-md-3">
          <button class="btn btn-light w-100 fw-bold border" onclick="resetFilters()">
            <i class="fa-solid fa-rotate-left me-2"></i>Reset Filters
          </button>
        </div>
      </div>
    </div>
  </div>

  <div class="table-section shadow-sm border-0">
    <div class="table-responsive">
      <table class="table table-hover align-middle" id="approvalTable">
        <thead>
        <tr>
          <th class="text-center" style="width: 60px;">#</th>
          <th>Log ID</th>
          <th>Type</th>
          <th>Staff</th>
          <th>Completion Time</th>
          <th class="text-center">Approval Actions</th>
          <th class="text-end">Details</th>
        </tr>
        </thead>
        <tbody>
        <c:forEach items="${pendingRequests}" var="item" varStatus="status">
          <fmt:parseDate value="${item.time}" pattern="yyyy-MM-dd'T'HH:mm" var="pDate" />
          <tr class="request-row"
              data-date="<fmt:formatDate value='${pDate}' pattern='yyyy-MM-dd' />"
              data-staff="${item.staff}"
              data-type="${item.type}">

            <td class="text-center text-muted small">${status.index + 1}</td>
            <td><span class="log-id">${item.prefix}${item.id}</span></td>
            <td>
                <span class="badge rounded-pill border fw-normal text-dark px-3
                    ${item.type == 'Audit' ? 'border-info' : (item.type == 'Stock-out' ? 'border-danger' : 'border-primary')}">
                    ${item.type}
                </span>
            </td>
            <td class="staff-cell">${item.staff}</td>
            <td class="text-muted small">
              <fmt:formatDate value="${pDate}" pattern="dd/MM/yyyy HH:mm" />
            </td>
            <td class="text-center">
              <div class="d-flex justify-content-center gap-2">
                <button class="btn-reject" onclick="handleApproval('${item.type}', ${item.id}, false)">
                  <i class="fa-solid fa-xmark me-1"></i> Reject
                </button>
                <button class="btn-approve" onclick="handleApproval('${item.type}', ${item.id}, true)">
                  <i class="fa-solid fa-check me-1"></i> Approve
                </button>
              </div>
            </td>
            <td class="text-end">
              <c:choose>
                <c:when test="${item.type == 'Stock-in'}">
                  <a href="/stockIn/details?id=${item.id}" class="action-link">
                    View Detail <i class="fa-solid fa-chevron-right ms-1 small"></i>
                  </a>
                </c:when>
                <c:when test="${item.type == 'Stock-out'}">
                  <a href="/stockOut/details?id=${item.id}" class="action-link">
                    View Detail <i class="fa-solid fa-chevron-right ms-1 small"></i>
                  </a>
                </c:when>
                <c:when test="${item.type == 'Audit'}">
                  <a href="/audit/details?id=${item.id}" class="action-link">
                    View Detail <i class="fa-solid fa-chevron-right ms-1 small"></i>
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

<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script src="<c:url value='/resources/js/inventory/approval-queue.js'/>"></script>
</body>
</html>