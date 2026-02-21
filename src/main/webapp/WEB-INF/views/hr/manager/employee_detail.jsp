<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<html>
<head>
    <title>Change Information</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<c:url value='/resources/css/profile/profile.css'/>">
</head>
<body>
<jsp:include page="/WEB-INF/views/layer/header.jsp" />
<jsp:include page="/WEB-INF/views/layer/sidebar.jsp" />

<div class="main-content">

    <div class="profile-wrapper">

        <!-- TITLE -->
        <div class="section-title">Employee Detail</div>
        <div class="section-subtitle">
            Information (Can not change ID, Creation time)
        </div>

        <form method="post" action="<c:url value='/hr/manager/edit_employee'/>">
        <div class="row">
            <!-- LEFT COLUMN -->
            <div class="col-md-6">

                <div class="info-label">Id</div>
                <div class="info-box">
                    <!-- gửi về backend -->
                    <input type="hidden" name="employeeId" value="${employee.employeeId}" />
                    <!-- hiển thị -->
                    <input class="info-input" value="${employee.employeeId}" readonly />
                </div>

                <div class="info-label">Full Name</div>
                <div class="info-box">
                    <input class="info-input" name="fullName" value="${employee.fullName}" />
                </div>

                <div class="info-label">Login Name</div>
                <div class="info-box">
                    <input class="info-input" name="username" value="${account.username}" />
                </div>

                <div class="info-label">Password</div>
                <div class="info-box">
                    <input type="password" class="info-input" name="password" placeholder="Leave blank if not change" />
                </div>

                <button type="submit" class="btn-change mt-2">Save</button>
                <div class="success-text">Save Successfully!</div>

            </div>

            <!-- RIGHT COLUMN -->
            <div class="col-md-6">

                <div class="info-label">Role</div>
                <div class="info-box">
                    <select class="info-input" name="role">
                        <option value="CASHIER"
                            ${employee.role == 'CASHIER' ? 'selected' : ''}>
                            CASHIER
                        </option>
                        <option value="MANAGER"
                            ${employee.role == 'MANAGER' ? 'selected' : ''}>
                            MANAGER
                        </option>
                    </select>
                </div>

                <div class="info-label">E-Mail</div>
                <div class="info-box">
                    <input class="info-input"
                           name="email"
                           value="${employee.email}" />
                </div>

                <div class="info-label">Status</div>
                <div class="info-box">
                    <select class="info-input" name="status">
                        <option value="true"
                            ${employee.status ? 'selected' : ''}>
                            Active
                        </option>
                        <option value="false"
                            ${!employee.status ? 'selected' : ''}>
                            Deactive
                        </option>
                    </select>
                </div>

                <div class="info-label">Account Creation Time</div>
                <div class="info-box">
                    <input class="info-input"
                           value="${fn:substring(fn:replace(employee.createdAt, 'T', ' '), 0, 16)}"
                           readonly />
                </div>
            </div>
        </div>
        </form>

        <!-- BACK -->
        <a href="/employee/list" class="back-link">← Back</a>

    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>
