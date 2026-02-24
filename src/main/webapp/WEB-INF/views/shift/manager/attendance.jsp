<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
    <title>Attendance Management</title>
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

        <!-- TITLE -->
        <div class="section-title">Attendance Management</div>
        <div class="section-subtitle">Today's Attendance</div>

        <!-- FILTER -->
        <form id="searchForm" method="get" action="${pageContext.request.contextPath}/shift/manager/attendance">

            <div class="row mb-4">

                <!-- Employee -->
                <div class="col-md-3">
                    <div class="info-label">Employee</div>
                    <div class="info-box">
                        <input class="info-input"
                               type="text"
                               name="fullName"
                               value="${param.fullName}"
                               placeholder="Search employee..."/>
                    </div>
                </div>

                <!-- Shift -->
                <div class="col-md-3">
                    <div class="info-label">Shift</div>
                    <div class="info-box">
                        <select class="info-input" name="shift">
                            <option value="">All</option>
                            <option value="Morning" ${param.shift == 'Morning' ? 'selected' : ''}>Morning</option>
                            <option value="Afternoon" ${param.shift == 'Afternoon' ? 'selected' : ''}>Afternoon</option>
                            <option value="Evening" ${param.shift == 'Evening' ? 'selected' : ''}>Evening</option>
                        </select>
                    </div>
                </div>

                <!-- Status -->
                <div class="col-md-3">
                    <div class="info-label">Status</div>
                    <div class="info-box">
                        <select class="info-input" name="status">
                            <option value="">All</option>
                            <option value="Normal" ${param.status == 'Normal' ? 'selected' : ''}>Normal</option>
                            <option value="Late" ${param.status == 'Late' ? 'selected' : ''}>Late</option>
                            <option value="Early Leave" ${param.status == 'Early Leave' ? 'selected' : ''}>Early Leave</option>
                            <option value="Expired" ${param.status == 'Expired' ? 'selected' : ''}>Expired</option>
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
                    <th>Check-in</th>
                    <th>Check-out</th>
                    <th>Status</th>
                    <th></th>
                </tr>
                </thead>
                <tbody>
                <c:forEach var="a" items="${attendanceList}">
                <tr id="row-${a.attendanceId}">

                    <td>${a.employee.employeeId}</td>
                    <td>${a.employee.fullName}</td>
                    <td>${a.employee.role}</td>

                    <!-- SHIFT -->
                    <td>
                        <span class="view">${a.shift.shiftName}</span>

                        <select class="edit d-none form-select form-select-sm"
                                id="shift-${a.attendanceId}">
                            <c:forEach var="s" items="${shiftList}">
                                <option value="${s.shiftId}"
                                    ${s.shiftId == a.shift.shiftId ? 'selected' : ''}>
                                    ${s.shiftName}
                                </option>
                            </c:forEach>
                        </select>
                    </td>

                    <td>${a.workDate}</td>

                    <!-- CHECK IN -->
                    <td>
                        <span class="view">${a.checkInTime.toString().replace('T',' ').substring(0,16)}</span>
                        <input type="datetime-local"
                               class="edit d-none form-control form-control-sm"
                               id="checkin-${a.attendanceId}"
                               value="${a.checkInTime != null ? a.checkInTime.toString().substring(0,16) : ''}">
                    </td>

                    <!-- CHECK OUT -->
                    <td>
                        <span class="view">${a.checkOutTime.toString().replace('T',' ').substring(0,16)}</span>
                        <input type="datetime-local"
                               class="edit d-none form-control form-control-sm"
                               id="checkout-${a.attendanceId}"
                               value="${a.checkOutTime != null ? a.checkOutTime.toString().substring(0,16) : ''}">
                    </td>

                    <td>
                        <c:choose>

                            <c:when test="${a.autoCheckout}">
                                <span class="text-danger">Expired</span>
                            </c:when>

                            <c:when test="${a.isLate and a.isEarlyLeave}">
                                <span class="text-warning">Late, Early Leave</span>
                            </c:when>

                            <c:when test="${a.isLate}">
                                <span class="text-warning">Late</span>
                            </c:when>

                            <c:when test="${a.isEarlyLeave}">
                                <span class="text-warning">Early Leave</span>
                            </c:when>

                            <c:otherwise>
                                <span class="text-success">Normal</span>
                            </c:otherwise>

                        </c:choose>
                    </td>

                    <td>
                        <button class="btn btn-success btn-sm"
                                onclick="editRow(${a.attendanceId})"
                                id="editBtn-${a.attendanceId}">
                            Edit
                        </button>
                    </td>

                </tr>
                </c:forEach>
                </tbody>
            </table>
        </div>

        <!-- PAGINATION -->
        <div class="d-flex justify-content-center gap-2 mt-4">

            <c:if test="${employeePage.totalPages > 1}">

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
                           end="${employeePage.totalPages - 1}"
                           var="i">

                    <a href="?page=${i}"
                       class="btn ${i == currentPage ? 'page-active' : 'btn-light'}">
                        ${i + 1}
                    </a>

                </c:forEach>

                <!-- > NEXT -->
                <c:if test="${currentPage < employeePage.totalPages - 1}">
                    <a href="?page=${currentPage + 1}"
                       class="btn btn-light">
                        >
                    </a>
                </c:if>

                <!-- >> LAST -->
                <c:if test="${currentPage < employeePage.totalPages - 1}">
                    <a href="?page=${employeePage.totalPages - 1}"
                       class="btn btn-light">
                        >>
                    </a>
                </c:if>
            </c:if>
        </div>

        <!-- ACTION -->
        <div class="mt-3">

            <!-- View History -->
            <button class="btn-primary"
                onclick="window.location.href='${pageContext.request.contextPath}/shift/manager/attendance_history'">
                View Attendance History
            </button>

            </form>
        </div>



        <!-- BACK -->
        <a href="/hr/manager/manager_profile" class="back-link">← Back To Profile</a>

    </div>
</div>
<script>
    const contextPath = "${pageContext.request.contextPath}";
</script>
<script src="<c:url value='/resources/js/manage/attendance.js'/>"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
