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
                <tr>
                    <td>3</td>
                    <td>Afternoon</td>
                    <td>21/01/2026</td>
                    <td>12:00</td>
                    <td>17:00</td>
                </tr>

                <tr>
                    <td>3</td>
                    <td>Afternoon</td>
                    <td>22/01/2026</td>
                    <td>12:00</td>
                    <td>17:00</td>
                </tr>

                <tr>
                    <td>3</td>
                    <td>Afternoon</td>
                    <td>23/01/2026</td>
                    <td>12:00</td>
                    <td>17:00</td>
                </tr>
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
