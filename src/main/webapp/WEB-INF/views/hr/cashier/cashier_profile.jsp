<%--
  Created by IntelliJ IDEA.
  User: tranp
  Date: 2/4/2026
  Time: 11:06 AM
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
            <div class="col-md-6">
                <div class="info-label">Id</div>
                <div class="info-box">${account.accountId}</div>

                <div class="info-label">Full Name</div>
                <div class="info-box">${account.employee.fullName}</div>

                <div class="info-label">Login Name</div>
                <div class="info-box">${account.username}</div>

                <div class="info-label">Password</div>
                <div class="info-box">********</div>

                <button class="btn-change mt-2"
                onclick="window.location.href='${pageContext.request.contextPath}/hr/common/change_information'">
                    Change Info
                </button>
            </div>

            <div class="col-md-6">
                <div class="info-label">Role</div>
                <div class="info-box">${account.employee.role}</div>

                <div class="info-label">E-Mail</div>
                <div class="info-box">${account.employee.email}</div>

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

                <div class="info-label">Last Login</div>
                <div class="info-box">
                    ${lastLoginFormatted}
                </div>
            </div>
        </div>

        <!-- SHIFT INFO -->
        <div class="section-divider">Shift Info</div>

        <div class="row">
            <div class="col-md-6">
                <div class="info-label">Current Shift</div>
                <div class="info-box">
                    Afternoon
                    <a href="/shift/cashier/change_shift" class="link-detail">Change Shift</a>
                </div>
            </div>

            <div class="col-md-6">
                <div class="info-label">Work schedule</div>
                <div class="info-box">
                    <a href="/shift/cashier/work_schedule" class="link-detail">Detail</a>
                </div>
            </div>
        </div>

        <!-- ATTENDANCE -->
        <div class="section-divider">Attendance Info</div>

        <div class="row">
            <div class="col-md-6">
                <div class="info-label">Attendance Record</div>
                <div class="info-box">
                    <a href="/hr/cashier/attendance_record" class="link-detail">Detail</a>
                </div>
            </div>

            <div class="col-md-6">
                <div class="info-label">Shift Change History</div>
                <div class="info-box">
                    <a href="/hr/cashier/shift_change_history" class="link-detail">Detail</a>
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
