<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
    <title>Shift Change Request</title>
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
        <div class="section-title">Shift Change Request</div>

        <!-- FILTER -->
        <div class="row mb-4">
            <div class="col-md-3">
                <div class="info-label">Employee</div>
                <div class="info-box">
                    <input class="info-input" placeholder="---"/>
                </div>
            </div>

            <div class="col-md-3">
                <div class="info-label">Current Shift</div>
                <div class="info-box">
                    <input class="info-input" placeholder="---"/>
                </div>
            </div>

            <div class="col-md-3">
                <div class="info-label">Requested Shift</div>
                <div class="info-box">
                    <input class="info-input" placeholder="---"/>
                </div>
            </div>

            <div class="col-md-3">
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
                    <th>Day Wanted To Switch</th>
                    <th>Current Shift</th>
                    <th>Requested Shift</th>
                    <th>Reason</th>
                    <th>Status</th>
                    <th>Manager Approval</th>
                    <th>Reviewed At</th>
                    <th></th>
                </tr>
                </thead>

                <tbody>
                <tr>
                    <td>5</td>
                    <td>22/01/2026</td>
                    <td>Morning</td>
                    <td>Afternoon</td>
                    <td>Afternoon</td>
                    <td class="text-danger">Rejected</td>
                    <td>Tran Minh</td>
                    <td>20/01/2026 10:04</td>
                    <td>
                        <button class="btn-change">Approve</button>
                        <button class="btn-danger">Reject</button>
                    </td>
                </tr>

                <tr>
                    <td>3</td>
                    <td>22/01/2026</td>
                    <td>Afternoon</td>
                    <td>Evening</td>
                    <td>Evening</td>
                    <td>---</td>
                    <td>---</td>
                    <td>---</td>
                    <td>
                        <button class="btn-change">Approve</button>
                        <button class="btn-danger">Reject</button>
                    </td>
                </tr>

                <tr>
                    <td>4</td>
                    <td>22/01/2026</td>
                    <td>Evening</td>
                    <td>Morning</td>
                    <td>Morning</td>
                    <td>---</td>
                    <td>---</td>
                    <td>---</td>
                    <td>
                        <button class="btn-change">Approve</button>
                        <button class="btn-danger">Reject</button>
                    </td>
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
