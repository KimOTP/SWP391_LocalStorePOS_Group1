<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
    <title>Shift Change History</title>
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
        <div class="section-title">Shift Change History</div>

        <!-- TABLE -->
        <div class="info-box" style="height:auto; padding:0;">
            <table class="table align-middle mb-0">
                <thead>
                <tr>
                    <th>My ID</th>
                    <th>Day Want To Switch Shift</th>
                    <th>Current Shift</th>
                    <th>Requested Shift</th>
                    <th>Reason</th>
                    <th>Status</th>
                    <th>Manager Approval</th>
                    <th>Approval Time</th>
                </tr>
                </thead>

                <tbody>
                <tr>
                    <td>3</td>
                    <td>21/01/2026</td>
                    <td>Afternoon</td>
                    <td>Evening</td>
                    <td>nha co viec</td>
                    <td class="text-warning">Pending</td>
                    <td>---</td>
                    <td>---</td>
                </tr>

                <tr>
                    <td>3</td>
                    <td>18/01/2026</td>
                    <td>Afternoon</td>
                    <td>Evening</td>
                    <td>---</td>
                    <td class="text-danger">Rejected</td>
                    <td>Manager1</td>
                    <td>18/01/2026 - 18:00</td>
                </tr>
                </tbody>
            </table>
        </div>

        <!-- PAGINATION -->
        <div class="d-flex justify-content-center gap-2 mt-4">
            <button class="btn btn-light">&laquo;</button>
            <button class="btn btn-light">&lsaquo;</button>
            <button class="btn btn-primary">1</button>
            <button class="btn btn-light">2</button>
            <button class="btn btn-light">3</button>
            <button class="btn btn-light">&rsaquo;</button>
            <button class="btn btn-light">&raquo;</button>
        </div>

        <!-- BACK -->
        <a href="/hr/cashier/cashier_profile" class="back-link">← Back To Profile</a>

    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
