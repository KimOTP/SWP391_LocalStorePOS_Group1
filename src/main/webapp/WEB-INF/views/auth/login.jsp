<%--
  Created by IntelliJ IDEA.
  User: tranp
  Date: 2/4/2026
  Time: 10:08 AM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>


<html>
<head>
    <title>Login</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/login.css">
</head>
<body>

<form action="${pageContext.request.contextPath}/auth/login" method="post">
    <div class="overlay">
        <div class="login-box">

            <div class="logo">Store</div>

            <label>Username</label>
            <input type="text" name="username" placeholder="Enter your login name">

            <label>Password</label>
            <input type="password" name="password">

            <button type="submit">Login</button>

            <c:if test="${not empty error}">
                <p style="color:red">${error}</p>
            </c:if>
        </div>
    </div>
</form>
</body>
</html>
