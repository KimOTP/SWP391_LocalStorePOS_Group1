<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
    <title>Create Employee Account</title>
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

        <a href="${pageContext.request.contextPath}/hr/manager_profile"
                   class="back-link">← Back To Profile</a>
        <div class="section-title">Create Employee Accounts</div>
        <div class="section-subtitle">Information</div>
        <br/>
        <!-- FORM BẮT ĐẦU -->
        <form action="${pageContext.request.contextPath}/hr/create_emp_account" method="post">

            <div class="row">

                <!-- ================= CỘT 1 ================= -->
                <div class="col-md-4">

                    <div class="info-label">Employee Name</div>
                    <div class="info-box">
                        <input class="info-input" type="text" name="fullName"
                               placeholder="Enter employee name" required/>
                    </div>

                    <div class="info-label">Login Name</div>
                    <div class="info-box">
                        <input class="info-input" type="text" name="username"
                               placeholder="Enter login name" required/>
                    </div>

                    <!-- BUTTON Ở CỘT 1 -->
                    <button type="submit" class="btn-change mt-3">Create</button>

                    <!-- ERROR -->
                    <c:if test="${not empty error}">
                        <div class="text-danger mt-2">${error}</div>
                    </c:if>

                    <!-- SUCCESS -->
                    <c:if test="${not empty success}">
                        <div class="text-success mt-2">${success}</div>
                    </c:if>

                </div>


                <!-- ================= CỘT 2 ================= -->
                <div class="col-md-4">

                    <div class="info-label">Role</div>
                    <div class="info-box">
                        <select class="info-input" name="role" required>
                            <option value="CASHIER">CASHIER</option>
                            <option value="INVENTORY STAFF">INVENTORY STAFF</option>
                            <option value="MANAGER">MANAGER</option>
                        </select>
                    </div>

                    <div class="info-label">E-Mail</div>
                    <div class="info-box">
                        <input class="info-input" type="email" name="email"
                               placeholder="example@gmail.com" required/>
                    </div>

                </div>


                <!-- ================= CỘT 3 ================= -->
                <div class="col-md-4">

                    <div class="info-label">Password</div>
                    <div class="info-box">
                        <input type="password" class="info-input" name="password" required/>
                    </div>

                    <div class="info-label">Confirm Password</div>
                    <div class="info-box">
                        <input type="password" class="info-input" name="confirmPassword" required/>
                    </div>

                </div>

            </div>

        </form>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>