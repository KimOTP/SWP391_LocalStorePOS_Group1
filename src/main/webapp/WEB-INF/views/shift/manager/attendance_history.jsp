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
        <form id="searchForm" method="get" action="${pageContext.request.contextPath}/shift/attendance_history">

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

                <div class="info-box dropdown-custom">

                    <div class="dropdown-selected"
                         onclick="toggleDropdown('shiftFilterMenu')">

                        <span id="selectedShiftFilter">
                            ${empty shift ? 'All' : shift}
                        </span>

                        <span class="fa-solid fa-angle-down"></span>
                    </div>

                    <input type="hidden"
                           name="shift"
                           id="shiftFilterInput"
                           value="${shift}">

                    <div id="shiftFilterMenu" class="dropdown-menu">

                        <div onclick="selectOption(
                            '','All',
                            'selectedShiftFilter','shiftFilterInput','shiftFilterMenu')">
                            All
                        </div>

                        <div onclick="selectOption(
                            'Morning','Morning',
                            'selectedShiftFilter','shiftFilterInput','shiftFilterMenu')">
                            Morning
                        </div>

                        <div onclick="selectOption(
                            'Afternoon','Afternoon',
                            'selectedShiftFilter','shiftFilterInput','shiftFilterMenu')">
                            Afternoon
                        </div>

                        <div onclick="selectOption(
                            'Evening','Evening',
                            'selectedShiftFilter','shiftFilterInput','shiftFilterMenu')">
                            Evening
                        </div>

                    </div>

                </div>
            </div>

            <div class="col-md-2">
                <div class="info-label">Status</div>

                <div class="info-box dropdown-custom">

                    <div class="dropdown-selected"
                         onclick="toggleDropdown('attendanceStatusMenu')">

                        <span id="selectedAttendanceStatus">
                            ${empty status ? 'All' : status}
                        </span>

                        <span class="fa-solid fa-angle-down"></span>
                    </div>

                    <input type="hidden"
                           name="status"
                           id="attendanceStatusInput"
                           value="${status}">

                    <div id="attendanceStatusMenu" class="dropdown-menu">

                        <div onclick="selectOption(
                            '','All',
                            'selectedAttendanceStatus','attendanceStatusInput','attendanceStatusMenu')">
                            All
                        </div>

                        <div onclick="selectOption(
                            'Normal','Normal',
                            'selectedAttendanceStatus','attendanceStatusInput','attendanceStatusMenu')">
                            Normal
                        </div>

                        <div onclick="selectOption(
                            'Late','Late',
                            'selectedAttendanceStatus','attendanceStatusInput','attendanceStatusMenu')">
                            Late
                        </div>

                        <div onclick="selectOption(
                            'Early Leave','Early Leave',
                            'selectedAttendanceStatus','attendanceStatusInput','attendanceStatusMenu')">
                            Early Leave
                        </div>

                    </div>

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
                        <td>
                        <c:if test="${a.checkInTime != null}">
                        ${a.checkInTime.toString().replace('T',' ').substring(0,16)}
                        </c:if>
                        </td>
                        <td>
                        <c:if test="${a.checkOutTime != null}">
                        ${a.checkOutTime.toString().replace('T',' ').substring(0,16)}
                        </c:if>
                        </td>

                        <td>
                            <c:choose>

                                <c:when test="${a.isLate == true and a.isEarlyLeave == true}">
                                    <span class="status-pending">Late, Early Leave</span>
                                </c:when>

                                <c:when test="${a.isLate == true}">
                                    <span class="status-deactive">Late</span>
                                </c:when>

                                <c:when test="${a.isEarlyLeave == true}">
                                    <span class="status-pending">Early Leave</span>
                                </c:when>

                                <c:otherwise>
                                    <span class="status-active">Normal</span>
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

                <!-- LIMIT 5 PAGES -->
                <c:set var="startPage" value="${currentPage - 2}" />
                <c:set var="endPage" value="${currentPage + 2}" />

                <c:if test="${startPage < 0}">
                    <c:set var="startPage" value="0"/>
                </c:if>

                <c:if test="${endPage >= attendancePage.totalPages}">
                    <c:set var="endPage" value="${attendancePage.totalPages - 1}"/>
                </c:if>

                <!-- << FIRST -->
                <c:if test="${currentPage > 0}">
                    <c:url var="firstUrl" value="/shift/attendance_history">
                        <c:param name="page" value="0"/>
                        <c:param name="fullName" value="${fullName}"/>
                        <c:param name="shift" value="${shift}"/>
                        <c:param name="status" value="${status}"/>
                        <c:param name="fromDate" value="${fromDate}"/>
                        <c:param name="toDate" value="${toDate}"/>
                    </c:url>

                    <a href="${firstUrl}" class="btn btn-light">
                    <<
                    </a>
                </c:if>

                <!-- < PREVIOUS -->
                <c:if test="${currentPage > 0}">
                    <c:url var="prevUrl" value="/shift/attendance_history">
                        <c:param name="page" value="${currentPage - 1}"/>
                        <c:param name="fullName" value="${fullName}"/>
                        <c:param name="shift" value="${shift}"/>
                        <c:param name="status" value="${status}"/>
                        <c:param name="fromDate" value="${fromDate}"/>
                        <c:param name="toDate" value="${toDate}"/>
                    </c:url>

                    <a href="${prevUrl}" class="btn btn-light">
                    <
                    </a>
                </c:if>

                <!-- PAGE NUMBERS -->
                <c:forEach begin="${startPage}" end="${endPage}" var="i">
                    <c:url var="pageUrl" value="/shift/attendance_history">
                        <c:param name="page" value="${i}"/>
                        <c:param name="fullName" value="${fullName}"/>
                        <c:param name="shift" value="${shift}"/>
                        <c:param name="status" value="${status}"/>
                        <c:param name="fromDate" value="${fromDate}"/>
                        <c:param name="toDate" value="${toDate}"/>
                    </c:url>

                    <a href="${pageUrl}"
                    class="btn ${i == currentPage ? 'page-active' : 'btn-light'}">
                    ${i + 1}
                    </a>
                </c:forEach>

                <!-- > NEXT -->
                <c:if test="${currentPage < attendancePage.totalPages - 1}">
                    <c:url var="nextUrl" value="/shift/attendance_history">
                        <c:param name="page" value="${currentPage + 1}"/>
                        <c:param name="fullName" value="${fullName}"/>
                        <c:param name="shift" value="${shift}"/>
                        <c:param name="status" value="${status}"/>
                        <c:param name="fromDate" value="${fromDate}"/>
                        <c:param name="toDate" value="${toDate}"/>
                    </c:url>

                    <a href="${nextUrl}" class="btn btn-light">
                    >
                    </a>
                </c:if>

                <!-- >> LAST -->
                <c:if test="${currentPage < attendancePage.totalPages - 1}">
                    <c:url var="lastUrl" value="/shift/attendance_history">
                        <c:param name="page" value="${attendancePage.totalPages - 1}"/>
                        <c:param name="fullName" value="${fullName}"/>
                        <c:param name="shift" value="${shift}"/>
                        <c:param name="status" value="${status}"/>
                        <c:param name="fromDate" value="${fromDate}"/>
                        <c:param name="toDate" value="${toDate}"/>
                    </c:url>

                    <a href="${lastUrl}" class="btn btn-light">
                    >>
                    </a>
                </c:if>

            </c:if>

        </div>

    </div>
</div>
<script src="<c:url value='/resources/js/manage/attendance_history.js'/>"></script>
<script src="<c:url value='/resources/js/manage/dropdown.js'/>"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
