<%--
  Created by IntelliJ IDEA.
  User: tranp
  Date: 2/6/2026
  Time: 8:53 PM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
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

        <div class="row">
            <!-- LEFT: CHANGE INFO -->
            <div class="col-md-8">
                <div class="section-title">Change Info</div>
                <div class="section-subtitle">Basic Info</div>

            <form action="<c:url value='/hr/common/update_information'/>" method="post">

                <div class="row">
                    <!-- CỘT 1 -->
                    <div class="col-md-6">
                        <div class="info-label">Id</div>
                        <div class="info-box">
                            <input type="text" name="id" class="info-input"
                                   value="${account.accountId}" readonly />
                        </div>

                        <div class="info-label">Full Name</div>
                        <div class="info-box">
                            <input type="text" name="fullName" class="info-input"
                                   value="${account.employee.fullName}" required />
                        </div>

                        <div class="info-label">Login Name</div>
                        <div class="info-box">
                            <input type="text" name="username" class="info-input"
                                   value="${account.username}" required />
                        </div>
                    </div>

                    <!-- CỘT 2 -->
                    <div class="col-md-6">
                        <div class="info-label">Role</div>
                        <div class="info-box">
                            <input type="text" class="info-input"
                                   value="${account.employee.role}" readonly />
                        </div>

                        <div class="info-label">E-Mail</div>
                        <div class="info-box">
                            <input type="email" name="email" class="info-input"
                                   value="${account.employee.email}" required />
                        </div>

                        <div class="info-label">Status</div>
                        <div class="info-box">
                            <c:choose>
                                <c:when test="${account.employee.status}">
                                    <span style="color: green;">Active</span>
                                </c:when>
                                <c:otherwise>
                                    <span style="color: red;">Deactive</span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>

                <button type="submit" class="btn-change mt-3">Save</button>

                <c:if test="${not empty success}">
                    <p style="color: green; margin-top: 10px;">
                        ${success}
                    </p>
                </c:if>

                <c:if test="${not empty error}">
                    <p style="color: red; margin-top: 10px;">
                        ${error}
                    </p>
                </c:if>

            </form>
            </div>

            <!-- RIGHT: CHANGE PASSWORD -->
            <div class="col-md-4">
                <div class="section-title">Change Password</div>
                <div class="section-subtitle">ㅤ</div>

            <form action="<c:url value='/hr/common/change_password'/>" method="post">

                <div class="info-label">Old Password</div>
                <div class="info-box">
                    <input type="password" name="oldPassword" class="info-input" required />
                </div>

                <div class="info-label">New Password</div>
                <div class="info-box">
                    <input type="password" name="newPassword" class="info-input" required />
                </div>

                <div class="info-label">Confirm New Password</div>
                <div class="info-box">
                    <input type="password" name="confirmPassword" class="info-input" required />
                </div>

                <button type="submit" class="btn-change mt-2">Change</button>
                <c:if test="${not empty successPass}">
                    <p style="color: green; margin-top: 10px;">
                        ${successPass}
                    </p>
                </c:if>

                <c:if test="${not empty errorPass}">
                    <p style="color: red; margin-top: 10px;">
                        ${errorPass}
                    </p>
                </c:if>
            </form>
            </div>
        </div>

        <!-- BACK LINK: PHẢI MÀN HÌNH -->
        <div class="text-end mt-4">
            <c:choose>
                <c:when test="${sessionScope.account.employee.role == 'MANAGER'}">
                    <a href="/hr/manager/manager_profile" class="back-link">← Back To Profile</a>
                </c:when>

                <c:when test="${sessionScope.account.employee.role == 'CASHIER'}">
                    <a href="/hr/cashier/cashier_profile" class="back-link">← Back To Profile</a>
                </c:when>

                <c:otherwise>
                    <a href="/profile" class="back-link">← Back To Profile</a>
                </c:otherwise>
            </c:choose>
        </div>

    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>
