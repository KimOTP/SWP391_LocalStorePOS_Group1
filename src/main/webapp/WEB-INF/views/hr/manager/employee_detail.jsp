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

        <!-- TITLE -->
        <div class="section-title">Employee Detail</div>
        <div class="section-subtitle">
            Information (Can not change ID, Creation time)
        </div>

        <div class="row">

            <!-- LEFT COLUMN -->
            <div class="col-md-6">

                <div class="info-label">Id</div>
                <div class="info-box">
                    <input class="info-input" value="3" readonly />
                </div>

                <div class="info-label">Full Name</div>
                <div class="info-box">
                    <input class="info-input" value="Tran Phu" />
                </div>

                <div class="info-label">Login Name</div>
                <div class="info-box">
                    <input class="info-input" value="Cashier1" />
                </div>

                <div class="info-label">Password</div>
                <div class="info-box">
                    <input type="password" class="info-input" value="********" />
                </div>

                <button class="btn-change mt-2">Save</button>
                <div class="success-text">Save Successfully!</div>

            </div>

            <!-- RIGHT COLUMN -->
            <div class="col-md-6">

                <div class="info-label">Role</div>
                <div class="info-box">
                    <input class="info-input" value="Cashier" />
                </div>

                <div class="info-label">E-Mail</div>
                <div class="info-box">
                    <input class="info-input" value="cashier1@gmail.com" />
                </div>

                <div class="info-label">Status</div>
                <div class="info-box">
                    <input class="info-input" value="Active" />
                </div>

                <div class="info-label">Account Creation Time</div>
                <div class="info-box">
                    <input class="info-input" value="01/01/2026 - 07:03" readonly />
                </div>

            </div>
        </div>

        <!-- BACK -->
        <a href="/employee/list" class="back-link">← Back</a>

    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>
