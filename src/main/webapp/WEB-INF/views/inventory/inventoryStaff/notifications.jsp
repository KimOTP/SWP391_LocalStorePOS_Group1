<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="en">
<head>
  <title>Stock-in Notifications | LocalStorePOS</title>
  <link rel="stylesheet" href="<c:url value='/resources/css/inventory/notifications.css'/>">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>
<jsp:include page="/WEB-INF/views/layer/header.jsp" />
<jsp:include page="/WEB-INF/views/layer/sidebar.jsp" />

<div class="main-content">
  <h3 class="page-title">Stock-in Notifications</h3>

  <div class="summary-section">
    <div class="stat-card">
      <div class="stat-title">Quantity of stock-in requests</div>
      <div class="stat-value">${totalPending}</div>
      <div class="stat-description">Total number of stock-in requests pending</div>
    </div>
  </div>

  <div class="table-section">
    <div class="table-container">
      <table class="table table-hover align-middle">
        <thead>
        <tr>
          <th class="text-center" style="width: 60px;">#</th>
          <th>Request ID</th>
          <th>Distinct Products</th>
          <th>Requested By</th>
          <th>Requested Time</th>
          <th class="text-center">Action</th>
        </tr>
        </thead>
        <tbody>
        <c:forEach items="${pendingRequests}" var="item" varStatus="status">
          <tr>
            <td class="text-center text-muted">${status.index + 1}</td>
            <td><span class="request-id">RI_${item.stockInId}</span></td>
            <td class="fw-bold">${item.details.size()} items</td>
            <td>${item.requester.fullName}</td>
            <td>
              <fmt:parseDate value="${item.createdAt}" pattern="yyyy-MM-dd'T'HH:mm" var="pDate" />
              <fmt:formatDate value="${pDate}" pattern="dd/MM/yyyy HH:mm" />
            </td>
            <td class="text-center">
              <c:url var="processUrl" value="/stockIn/process">
                <c:param name="id" value="${item.stockInId}" />
              </c:url>
              <a href="${processUrl}" class="action-link">Start Action</a>
            </td>
          </tr>
        </c:forEach>
        </tbody>
      </table>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="<c:url value='/resources/js/inventory/notifications'/>"></script>
</body>
</html>