<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Product Request | LocalStorePOS</title>
  <link rel="stylesheet" href="<c:url value='/resources/css/inventory/approval-queue.css'/>">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>

<jsp:include page="../../layer/header.jsp" />
<jsp:include page="../../layer/sidebar.jsp" />

<div class="main-content">
  <h3 class="fw-bold mb-4">Approval Queue</h3>

  <div class="stat-section">
    <div class="stat-card">
      <div class="stat-title">On-going Approval Queue</div>
      <div class="stat-value">${pendingRequests.size()}</div>
      <div class="stat-desc">Need Approval</div>
    </div>
  </div>

  <div class="table-section shadow-sm">
    <table class="table align-middle">
      <thead>
      <tr>
        <th>Log ID</th>
        <th>Action Type</th>
        <th>Staff</th>
        <th>Completion Time</th>
        <th class="text-center">Act</th>
        <th class="text-center">Detailed</th>
      </tr>
      </thead>
      <tbody>
      <c:forEach items="${pendingRequests}" var="item" varStatus="status">
        <tr>
          <td class="text-center text-muted">${status.index + 1}</td>
          <td><span class="request-id">${item.prefix}${item.id}</span></td>
          <td>
                <span class="badge ${item.type == 'Audit' ? 'bg-info' : (item.type == 'Stock-in' ? 'bg-primary' : 'bg-warning')}">
                    ${item.type}
                </span>
          </td>
          <td>${item.staff}</td>
          <td>
            <fmt:parseDate value="${item.time}" pattern="yyyy-MM-dd'T'HH:mm" var="pDate" />
            <fmt:formatDate value="${pDate}" pattern="dd/MM/yyyy HH:mm" />
          </td>
          <td class="text-center">
            <div class="d-flex justify-content-center gap-2">
              <button class="btn-reject" onclick="handleApproval('${item.type}', ${item.id}, false)">Reject</button>
              <button class="btn-approve" onclick="handleApproval('${item.type}', ${item.id}, true)">Approve</button>
            </div>
          </td>
          <td class="text-center">
            <c:url var="detailUrl" value="/stockIn/inventory-staff/stock-in-details">
              <c:param name="id" value="${item.id}" />
            </c:url>
            <a href="${detailUrl}" class="action-link">View Detailed</a>
          </td>
        </tr>
      </c:forEach>
      </tbody>
    </table>
  </div>
</div>

<form id="actionForm" action="/inventory/admin/approval/action" method="POST">
  <input type="hidden" name="type" id="actionType">
  <input type="hidden" name="id" id="actionId">
  <input type="hidden" name="approve" id="isApprove">
</form>


<script src="<c:url value='/resources/js/inventory/approval-queue.js'/>"></script>
</body>
</html>