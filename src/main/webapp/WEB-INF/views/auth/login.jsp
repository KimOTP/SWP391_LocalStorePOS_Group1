<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<html>
<head>
    <title>POS System Login</title>

    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/login/login.css">

    <link href="https://fonts.googleapis.com/css2?family=Public+Sans:wght@300;400;500;600;700&display=swap" rel="stylesheet">
</head>

<body>

<form action="${pageContext.request.contextPath}/auth/login" method="post">
    <div class="overlay">

        <div class="login-box">

            <!-- Logo -->
            <div class="logo-wrapper">
                <img src="${pageContext.request.contextPath}/resources/static/images/pos-logo.png"
                     alt="POS System Logo">
                <h2>POS System</h2>
                <p>Sign in to manage your business</p>
            </div>

            <!-- Username -->
            <label>Username</label>
            <input type="text" name="username" placeholder="Enter your username">

            <!-- Password -->
            <label>Password</label>
            <input type="password" name="password" placeholder="Enter your password">

            <!-- Login button -->
            <button type="submit">Login</button>

            <!-- Error -->
            <c:if test="${not empty error}">
                <p class="error">${error}</p>
            </c:if>

        </div>

    </div>
</form>

</body>
</html>