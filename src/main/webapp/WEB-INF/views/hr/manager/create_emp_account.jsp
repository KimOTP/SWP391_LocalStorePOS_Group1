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

        <div class="text-end mb-4">
            <a href="${pageContext.request.contextPath}/hr/manager_profile"
                   class="back-link">← Back To Profile</a>
        </div>
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
                        <input class="info-input" type="text" name="fullName" value="${fullName}"
                               placeholder="Enter employee name" required/>
                    </div>

                    <div class="info-label">Login Name</div>
                    <div class="info-box">
                        <input class="info-input" type="text" name="username" value="${username}"
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

                    <div class="info-box dropdown-custom">

                        <div class="dropdown-selected"
                             onclick="toggleDropdown('roleMenuCreate')">

                            <span id="selectedRoleCreate">

                                ${empty role ? 'Select Role' : role}

                            </span>

                            <span class="fa-solid fa-angle-down"></span>
                        </div>

                        <input type="hidden"
                               name="role"
                               id="roleInputCreate"
                               value="${role}"
                               required>

                        <div id="roleMenuCreate" class="dropdown-menu">

                            <div onclick="selectOptionNoSubmit(
                                'CASHIER','CASHIER',
                                'selectedRoleCreate','roleInputCreate','roleMenuCreate')">
                                CASHIER
                            </div>

                            <div onclick="selectOptionNoSubmit(
                                'INVENTORY STAFF','INVENTORY STAFF',
                                'selectedRoleCreate','roleInputCreate','roleMenuCreate')">
                                INVENTORY STAFF
                            </div>

                            <div onclick="selectOptionNoSubmit(
                                'MANAGER','MANAGER',
                                'selectedRoleCreate','roleInputCreate','roleMenuCreate')">
                                MANAGER
                            </div>

                        </div>

                    </div>

                    <div class="info-label">E-Mail</div>
                    <div class="info-box">
                        <input class="info-input" type="email" name="email" value="${email}"
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
<script src="<c:url value='/resources/js/manage/dropdown.js'/>"></script>
</body>
</html>