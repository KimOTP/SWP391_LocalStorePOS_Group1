<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
    <title>Attendance History</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<c:url value='/resources/css/manage/employee_list.css'/>">
</head>
<body>

<jsp:include page="/WEB-INF/views/layer/header.jsp"/>
<jsp:include page="/WEB-INF/views/layer/sidebar.jsp"/>

<div class="main-content">
    <div class="profile-wrapper">

        <!-- BACK -->
        <a href="/hr/manager_profile" class="back-link">← Back To Profile</a>
        <!-- TITLE -->
        <div class="section-title">Attendance Management</div>
        <div class="section-subtitle">Attendance History</div>

        <!-- FILTER -->
        <form id="searchForm" method="get">

        <div class="row mb-4">

            <div class="col-md-2">
                <div class="info-label">From Date</div>
                <div class="info-box">
                    <input type="date"
                           name="fromDate"
                           class="info-input"
                           value="${fromDate}">
                </div>
            </div>

            <div class="col-md-2">
                <div class="info-label">To Date</div>
                <div class="info-box">
                    <input type="date"
                           name="toDate"
                           class="info-input"
                           value="${toDate}">
                </div>
            </div>

            <div class="col-md-3">
                <div class="info-label">Employee</div>
                <div class="info-box">
                    <input type="text"
                           name="fullName"
                           class="info-input"
                           value="${fullName}">
                </div>
            </div>

            <div class="col-md-2">
                <div class="info-label">Shift</div>
                <div class="info-box">
                    <select name="shift" class="info-input">
                        <option value="">All</option>
                        <option value="Morning"
                            ${shift == 'Morning' ? 'selected' : ''}>
                            Morning
                        </option>
                        <option value="Afternoon"
                            ${shift == 'Afternoon' ? 'selected' : ''}>
                            Afternoon
                        </option>
                        <option value="Evening"
                            ${shift == 'Evening' ? 'selected' : ''}>
                            Evening
                        </option>
                    </select>
                </div>
            </div>

            <div class="col-md-2">
                <div class="info-label">Status</div>
                <div class="info-box">
                    <select name="status" class="info-input">
                        <option value="" ${empty status ? 'selected' : ''}>All</option>

                        <option value="Normal"
                            ${status == 'Normal' ? 'selected' : ''}>
                            Normal
                        </option>

                        <option value="Late"
                            ${status == 'Late' ? 'selected' : ''}>
                            Late
                        </option>

                        <option value="Early Leave"
                            ${status == 'Early Leave' ? 'selected' : ''}>
                            Early Leave
                        </option>
                    </select>
                </div>
            </div>

        </div>
        </form>

        <!-- TABLE -->
        <div class="info-box" style="height:auto; padding:0;">
            <table class="table align-middle mb-0">
                <thead>
                <tr>
                    <th>Employee ID</th>
                    <th>Full Name</th>
                    <th>Role</th>
                    <th>Shift</th>
                    <th>Date</th>
                    <th>Check-in Time</th>
                    <th>Check-out Time</th>
                    <th>Status</th>
                </tr>
                </thead>
                <tbody>

                <c:forEach var="a" items="${attendancePage.content}">

                    <tr>
                        <td>${a.employee.employeeId}</td>
                        <td>${a.employee.fullName}</td>
                        <td>${a.employee.role}</td>
                        <td>${a.shift.shiftName}</td>
                        <td>${a.workDate}</td>
                        <td>${a.checkInTime.toString().replace('T',' ').substring(0,16)}</td>
                        <td>${a.checkOutTime.toString().replace('T',' ').substring(0,16)}</td>

                        <td>
                            <c:choose>

                                <c:when test="${a.autoCheckout == true}">
                                    <span class="text-danger">Expired</span>
                                </c:when>

                                <c:when test="${a.isLate == true and a.isEarlyLeave == true}">
                                    <span class="text-warning">Late, Early Leave</span>
                                </c:when>

                                <c:when test="${a.isLate == true}">
                                    <span class="text-warning">Late</span>
                                </c:when>

                                <c:when test="${a.isEarlyLeave == true}">
                                    <span class="text-warning">Early Leave</span>
                                </c:when>

                                <c:otherwise>
                                    <span class="text-success">Normal</span>
                                </c:otherwise>

                            </c:choose>
                        </td>
                    </tr>

                </c:forEach>

                <c:if test="${attendancePage.totalElements == 0}">
                    <tr>
                        <td colspan="8" class="text-center">No data</td>
                    </tr>
                </c:if>

                </tbody>
            </table>
        </div>

        <!-- PAGINATION -->
        <div class="d-flex justify-content-center gap-2 mt-4">

            <c:if test="${attendancePage.totalPages > 1}">

                <!-- << FIRST -->
                <c:if test="${currentPage > 0}">
                    <a href="?page=0"
                       class="btn btn-light">
                        <<
                    </a>
                </c:if>

                <!-- < PREVIOUS -->
                <c:if test="${currentPage > 0}">
                    <a href="?page=${currentPage - 1}"
                       class="btn btn-light">
                        <
                    </a>
                </c:if>

                <!-- PAGE NUMBERS -->
                <c:forEach begin="0"
                           end="${attendancePage.totalPages - 1}"
                           var="i">

                    <a href="?page=${i}"
                       class="btn ${i == currentPage ? 'page-active' : 'btn-light'}">
                        ${i + 1}
                    </a>

                </c:forEach>

                <!-- > NEXT -->
                <c:if test="${currentPage < attendancePage.totalPages - 1}">
                    <a href="?page=${currentPage + 1}"
                       class="btn btn-light">
                        >
                    </a>
                </c:if>

                <!-- >> LAST -->
                <c:if test="${currentPage < attendancePage.totalPages - 1}">
                    <a href="?page=${attendancePage.totalPages - 1}"
                       class="btn btn-light">
                        >>
                    </a>
                </c:if>

            </c:if>

        </div>

    </div>
</div>
<script src="<c:url value='/resources/js/manage/attendance_history.js'/>"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
