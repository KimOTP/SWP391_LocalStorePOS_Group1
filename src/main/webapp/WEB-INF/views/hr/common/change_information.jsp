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
            <div class="col-md-6">
                <div class="section-title">Change Info</div>
                <div class="section-subtitle">Basic Info</div>

                <div class="info-label">Id</div>
                <div class="info-box">3</div>

                <div class="info-label">Full Name</div>
                <div class="info-box">
                    <input class="info-input" value="Tran Phu"/>
                </div>

                <div class="info-label">Login Name</div>
                <div class="info-box">
                    <input class="info-input" value="Cashier1"/>
                </div>

                <div class="info-label">Role</div>
                <div class="info-box">Cashier</div>

                <div class="info-label">E-Mail</div>
                <div class="info-box">
                    <input class="info-input" value="cashier1@gmail.com"/>
                </div>

                <div class="info-label">Status</div>
                <div class="info-box">Active / Deactive</div>

                <button class="btn-change mt-2">Save</button>
                <div class="success-text">Save Successfully!</div>
            </div>

            <!-- RIGHT: CHANGE PASSWORD -->
            <div class="col-md-6">
                <div class="section-title">Change Password</div>
                <div class="section-subtitle">ㅤ</div>

                <div class="info-label">Old Password</div>
                <div class="info-box">
                    <input type="password" class="info-input"/>
                </div>

                <div class="info-label">New Password</div>
                <div class="info-box">
                    <input type="password" class="info-input"/>
                </div>

                <div class="info-label">Confirm New Password</div>
                <div class="info-box">
                    <input type="password" class="info-input"/><br/>
                </div>

                <button class="btn-change mt-2">Change</button>
                <div class="success-text">Change Successfully!</div>
            </div>
        </div>

        <!-- BACK LINK: PHẢI MÀN HÌNH -->
        <div class="text-end mt-4">
            <a href="/profile" class="back-link">← Back To Profile</a>
        </div>

    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>
