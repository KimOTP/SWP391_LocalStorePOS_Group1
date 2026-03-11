<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
    <title>Profile</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<c:url value='/resources/css/profile/profile.css'/>">
</head>

<body>

<jsp:include page="/WEB-INF/views/layer/header.jsp"/>
<jsp:include page="/WEB-INF/views/layer/sidebar.jsp"/>

<div class="main-content">

    <div class="text-end mb-4">
        <a href="/dashboard" class="back-link">← Back To Homepage</a>
    </div>

    <div class="section-title">Personal Information</div>
    <div class="section-subtitle">Basic Information</div>

    <div class="profile-wrapper mb-5">

        <div class="row g-4">

            <div class="col-md-3">
                <div class="info-label">Id</div>
                <div class="info-box">${account.accountId}</div>

                <div class="info-label">Role</div>
                <div class="info-box">${account.employee.role}</div>

                <button class="btn-change mt-2"
                        onclick="window.location.href='${pageContext.request.contextPath}/hr/change_information'">
                    <i class="fas fa-pen me-1"></i> Change Info
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
                <div class="info-box">${lastLoginFormatted}</div>
            </div>

        </div>

    </div>


    <!-- SHIFT & ATTENDANCE -->
    <div class="manage-section-title">
        <span class="manage-accent"></span> Shift & Attendance Info
    </div>

    <div class="row row-cols-1 row-cols-md-5 g-3">

        <div class="col">
            <a href="/shift/change_shift" class="manage-card">
                <div class="manage-card-icon">
                    <i class="fas fa-user-clock"></i>
                </div>
                <span class="manage-card-label">
                    Current: ${todayShift}
                </span>
                <i class="fas fa-chevron-right manage-card-arrow"></i>
            </a>
        </div>

        <div class="col">
            <a href="/shift/work_schedule" class="manage-card">
                <div class="manage-card-icon">
                    <i class="fas fa-calendar-days"></i>
                </div>
                <span class="manage-card-label">
                    Work Schedule
                </span>
                <i class="fas fa-chevron-right manage-card-arrow"></i>
            </a>
        </div>

        <div class="col">
            <a href="/hr/attendance_record" class="manage-card">
                <div class="manage-card-icon">
                    <i class="fas fa-calendar-check"></i>
                </div>
                <span class="manage-card-label">
                    Attendance Record
                </span>
                <i class="fas fa-chevron-right manage-card-arrow"></i>
            </a>
        </div>

        <div class="col">
            <a href="/hr/shift_change_history" class="manage-card">
                <div class="manage-card-icon">
                    <i class="fas fa-clock-rotate-left"></i>
                </div>
                <span class="manage-card-label">
                    Shift Change History
                </span>
                <i class="fas fa-chevron-right manage-card-arrow"></i>
            </a>
        </div>

        <div class="col">
            <a href="/hr/note" class="manage-card">
                <div class="manage-card-icon">
                    <i class="fas fa-note-sticky"></i>
                </div>
                <span class="manage-card-label">
                    Note
                </span>
                <i class="fas fa-chevron-right manage-card-arrow"></i>
            </a>
        </div>

    </div>

</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>