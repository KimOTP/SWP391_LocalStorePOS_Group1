<%--
  Created by IntelliJ IDEA.
  User: tranp
  Date: 2/4/2026
  Time: 10:48 AM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
    <title>Profile</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Product</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<c:url value='/resources/css/profile/profile.css'/>">
</head>
<body>
<jsp:include page="/WEB-INF/views/layer/header.jsp" />
<jsp:include page="/WEB-INF/views/layer/sidebar.jsp" />

<div class="main-content">
    <div class="profile-wrapper">

        <div class="section-title">Personal Information</div>
        <div class="section-subtitle">Basic Information</div>

        <div class="row">
            <div class="col-md-3">
                <div class="info-label">Id</div>
                <div class="info-box">${account.accountId}</div>

                <div class="info-label">Role</div>
                <div class="info-box">${account.employee.role}</div>

                <button class="btn-change mt-2"
                onclick="window.location.href='${pageContext.request.contextPath}/hr/common/change_information'">
                    Change Info
                </button>
            </div>

            <div class="col-md-3">
                <div class="info-label">Full Name</div>
                <div class="info-box">${account.employee.fullName}</div>

                <div class="info-label">E-Mail</div>
                <div class="info-box">${account.employee.email}</div>
            </div>

            <div class="col-md-3">
                <div class="info-label">Login Name</div>
                <div class="info-box">${account.username}</div>

            <div class="info-label">Status</div>
                <div class="info-box">
                    <c:choose>
                        <c:when test="${account.employee.status}">
                            <span class="status-active">Active</span>
                        </c:when>
                        <c:otherwise>
                            <span class="status-deactive">Deactive</span>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <div class="col-md-3">
                <div class="info-label">Password</div>
                <div class="info-box">********</div>

            <div class="info-label">Last Login</div>
                <div class="info-box">
                    ${lastLoginFormatted}
                </div>
            </div>
        </div>

        <!-- MANAGE -->
        <div class="section-divider">Manage</div>
        <div class="row row-cols-1 row-cols-md-5 g-3">

            <div class="col">
                <div class="info-label">Employee List</div>
                <div class="info-box">
                    <a href="/hr/manager/employee_list" class="link-detail">Detail</a>
                </div>
            </div>

            <div class="col">
                <div class="info-label">Create Employee Accounts</div>
                <div class="info-box">
                    <a href="/hr/manager/create_emp_account" class="link-detail">Detail</a>
                </div>
            </div>

<!--<div class="col">
                <div class="info-label">Employee Shift</div>
                <div class="info-box">
                    <a href="/shift/manager/employee_shift" class="link-detail">Detail</a>
                </div>
</div>-->

            <div class="col">
                <div class="info-label">Shifts</div>
                <div class="info-box">
                    <a href="/shift/manager/shift_management" class="link-detail">Detail</a>
                </div>
            </div>

            <div class="col">
                <div class="info-label">Shift Change Request</div>
                <div class="info-box">
                    <a href="/shift/manager/shift_change_req" class="link-detail">Detail</a>
                </div>
            </div>

            <div class="col">
                <div class="info-label">Attendance</div>
                <div class="info-box">
                    <a href="/shift/manager/attendance" class="link-detail">Detail</a>
                </div>
            </div>

        </div>

        <div class="text-end mt-4">
            <a href="/" class="back-link">← Back To Homepage</a>
        </div>

    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
