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
        <div class="section-title">Employee List</div>

        <!-- FILTER -->
        <div class="row mb-4">
            <div class="col-md-3">
                <div class="info-label">Full Name</div>
                <div class="info-box">
                    <input class="info-input"/>
                </div>
            </div>

            <div class="col-md-3">
                <div class="info-label">Role</div>
                <div class="info-box">
                    <select class="info-input" name="role">
                        <option>Cashier</option>
                        <option>Manager</option>
                    </select>
                </div>
            </div>

            <div class="col-md-3">
                <div class="info-label">Status</div>
                <div class="info-box">
                    <select class="info-input" name="status">
                        <option>Active</option>
                        <option>Deactive</option>
                    </select>
                </div>
            </div>

            <div class="col-md-3">
                <div class="info-label">Creation Time</div>
                <div class="info-box">
                    <input type="date" name="creationTime" class="info-input" value="2026-01-21">
                </div>
            </div>
        </div>

        <!-- TABLE -->
        <div class="info-box" style="height:auto; padding:0;">
            <table class="table align-middle mb-0">
                <thead>
                <tr class="text-muted">
                    <th>ID</th>
                    <th>Full Name</th>
                    <th>Login Name</th>
                    <th>E-Mail</th>
                    <th>Role</th>
                    <th>Status</th>
                    <th>Account Creation Time</th>
                    <th></th>
                </tr>
                </thead>
                <tbody>
                <tr>
                    <td>05</td>
                    <td>Tran Phu 2</td>
                    <td>cashier5</td>
                    <td>cashier5@gmail.com</td>
                    <td>Cashier</td>
                    <td class="text-success">Active</td>
                    <td>01/01/2026 - 07:23</td>
                    <td>
                        <button class="btn-change">Edit</button>
                    </td>
                </tr>
                <tr>
                    <td>04</td>
                    <td>Tran Phu 1</td>
                    <td>cashier4</td>
                    <td>cashier4@gmail.com</td>
                    <td>Cashier</td>
                    <td class="text-success">Active</td>
                    <td>01/01/2026 - 07:12</td>
                    <td>
                        <button class="btn-change">Edit</button>
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
