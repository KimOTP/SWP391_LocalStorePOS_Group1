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

        <!-- TITLE -->
        <div class="section-title">Attendance Management</div>
        <div class="section-subtitle">Attendance History</div>

        <!-- FILTER -->
        <div class="row mb-4">
            <div class="col-md-2">
                <div class="info-label">From Date</div>
                <div class="info-box">
                    <input class="info-input" value="20/01/2026"/>
                </div>
            </div>

            <div class="col-md-2">
                <div class="info-label">To Date</div>
                <div class="info-box">
                    <input class="info-input" value="20/01/2026"/>
                </div>
            </div>

            <div class="col-md-3">
                <div class="info-label">Employee</div>
                <div class="info-box">
                    <input class="info-input" value="Tran Phu"/>
                </div>
            </div>

            <div class="col-md-2">
                <div class="info-label">Shift</div>
                <div class="info-box">
                    <input class="info-input" placeholder="---"/>
                </div>
            </div>

            <div class="col-md-2">
                <div class="info-label">Status</div>
                <div class="info-box">
                    <input class="info-input" placeholder="---"/>
                </div>
            </div>
        </div>

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

                <tr>
                    <td>5</td>
                    <td>Tran Phu 2</td>
                    <td>Cashier</td>
                    <td>Morning</td>
                    <td>20/01/2026</td>
                    <td>20/01/2026 07:02</td>
                    <td>20/01/2026 11:45</td>
                    <td class="text-warning">Early Leave</td>
                </tr>

                <tr>
                    <td>3</td>
                    <td>Tran Phu</td>
                    <td>Cashier</td>
                    <td>Afternoon</td>
                    <td>20/01/2026</td>
                    <td>20/01/2026 12:03</td>
                    <td>20/01/2026 17:00</td>
                    <td class="text-success">Normal</td>
                </tr>

                <tr>
                    <td>4</td>
                    <td>Tran Phu 1</td>
                    <td>Cashier</td>
                    <td>Evening</td>
                    <td>20/01/2026</td>
                    <td>20/01/2026 17:11</td>
                    <td>20/01/2026 22:00</td>
                    <td class="text-danger">Late</td>
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
        <a href="/hr/manager/manager_profile" class="back-link">← Back To Profile</a>

    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
