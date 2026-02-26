<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
    <title>Attendance Record</title>
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
        <a href="/hr/cashier_profile" class="back-link">← Back To Profile</a>
        <!-- TITLE -->
        <div class="section-title">Attendance Record</div>
        <br/>

        <!-- TABLE -->
        <div class="info-box" style="height:auto; padding:0;">
            <table class="table align-middle mb-0">
                <thead>
                <tr>
                    <th>My ID</th>
                    <th>Shift</th>
                    <th>Work Date</th>
                    <th>Check-in</th>
                    <th>Check-out</th>
                    <th>Late</th>
                    <th>Early Leave</th>
                    <th>Status</th>
                    <th>Record Creation Time</th>
                </tr>
                </thead>

                <tbody>
                <c:forEach var="att" items="${attendancePage.content}">
                    <tr>
                        <td>${att.employee.employeeId}</td>
                        <td>${att.shift.shiftName}</td>
                        <td>${att.workDate}</td>
                        <td>${att.checkInTime.toString().replace('T',' ').substring(0,16)}</td>
                        <td>${att.checkOutTime.toString().replace('T',' ').substring(0,16)}</td>

                        <td>
                            <c:choose>
                                <c:when test="${att.isLate}">
                                    Yes
                                </c:when>
                                <c:otherwise>No</c:otherwise>
                            </c:choose>
                        </td>

                        <td>
                            <c:choose>
                                <c:when test="${att.isEarlyLeave}">
                                    Yes
                                </c:when>
                                <c:otherwise>No</c:otherwise>
                            </c:choose>
                        </td>

                        <td>
                            <c:choose>
                                <c:when test="${att.isLate and att.isEarlyLeave}">
                                    <span class="text-warning">Late, Early Leave</span>
                                </c:when>
                                <c:when test="${att.isLate}">
                                    <span class="text-danger">Late</span>
                                </c:when>
                                <c:when test="${att.isEarlyLeave}">
                                    <span class="text-warning">Early Leave</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="text-success">Normal</span>
                                </c:otherwise>
                            </c:choose>
                        </td>

                        <td>${att.checkOutTime.toString().replace('T',' ').substring(0,16)}</td>
                    </tr>
                </c:forEach>
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

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
