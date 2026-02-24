<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
    <title>Change Information</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<c:url value='/resources/css/manage/employee_list.css'/>">
</head>
<body>
<jsp:include page="/WEB-INF/views/layer/header.jsp" />
<jsp:include page="/WEB-INF/views/layer/sidebar.jsp" />

<div class="main-content">

    <div class="profile-wrapper">
        <!-- TITLE -->
        <div class="section-title">Shift Management</div>

        <!-- TABLE -->
        <div class="info-box" style="height:auto; padding:0;">
            <table class="table align-middle mb-0">
                <thead>
                <tr>
                    <th>Shift ID</th>
                    <th>Shift Name</th>
                    <th>Start</th>
                    <th>End</th>
                    <th>Shift Duration</th>
                    <th></th>
                </tr>
                </thead>
                <tbody>
                <c:forEach var="s" items="${shiftList}">
                    <tr id="row-${s.shiftId}">
                        <td>${s.shiftId}</td>

                        <td>
                            <span class="view">${s.shiftName}</span>
                            <input type="text" class="edit form-control d-none" value="${s.shiftName}">
                        </td>

                        <td>
                            <span class="view">${s.startTime}</span>
                            <input type="time" class="edit form-control d-none" value="${s.startTime}">
                        </td>

                        <td>
                            <span class="view">${s.endTime}</span>
                            <input type="time" class="edit form-control d-none" value="${s.endTime}">
                        </td>

                        <td class="duration">
                            ${java.time.Duration.between(s.startTime, s.endTime).toHours()}h
                        </td>

                        <td>
                            <button class="btn-change edit-btn"
                                    onclick="editRow(${s.shiftId})">
                                Edit
                            </button>
                        </td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
        </div>

        <!-- BACK -->
        <a href="/hr/manager/manager_profile" class="back-link">← Back To Profile</a>
    </div>
</div>

<script>
    const contextPath = "${pageContext.request.contextPath}";
</script>
<script src="<c:url value='/resources/js/manage/shift_management.js'/>"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
