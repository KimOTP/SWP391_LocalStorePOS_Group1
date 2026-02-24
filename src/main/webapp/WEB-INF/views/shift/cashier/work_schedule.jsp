<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
    <title>Work Schedule</title>
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
        <div class="section-title">Work Schedule</div>

        <!-- TABLE -->
        <div class="info-box" style="height:auto; padding:0;">
            <table class="table align-middle mb-0">
                <thead>
                <tr>
                    <th>My ID</th>
                    <th>Shift</th>
                    <th>Work Date</th>
                    <th>Start Time</th>
                    <th>End Time</th>
                </tr>
                </thead>

                <tbody>
                <c:forEach var="schedule" items="${scheduleList}">
                    <tr>
                        <td>${schedule.employee.employeeId}</td>
                        <td>${schedule.shift.shiftName}</td>
                        <td>${schedule.workDate}</td>
                        <td>${schedule.shift.startTime}</td>
                        <td>${schedule.shift.endTime}</td>
                    </tr>
                </c:forEach>

                <c:if test="${empty scheduleList}">
                    <tr>
                        <td colspan="5" class="text-center text-muted">
                            No schedule available
                        </td>
                    </tr>
                </c:if>
                </tbody>
            </table>
        </div>

        <!-- BACK -->
        <a href="/hr/cashier/cashier_profile" class="back-link">← Back To Profile</a>

    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
