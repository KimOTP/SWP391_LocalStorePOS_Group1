<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<html>
<head>
    <title>Notes</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

```
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
<link rel="stylesheet" href="<c:url value='/resources/css/profile/profile.css'/>">
```

</head>
<body>

<jsp:include page="/WEB-INF/views/layer/header.jsp"/>
<jsp:include page="/WEB-INF/views/layer/sidebar.jsp"/>

<div class="main-content">

<div class="profile-wrapper">

    <div class="text-end mb-4">
        <c:choose>
            <c:when test="${account.employee.role == 'MANAGER'}">
                <a href="${pageContext.request.contextPath}/hr/manager_profile"
                   class="back-link">← Back To Profile</a>
            </c:when>

            <c:otherwise>
                <a href="${pageContext.request.contextPath}/hr/cashier_profile"
                   class="back-link">← Back To Profile</a>
            </c:otherwise>
        </c:choose>
    </div>

    <!-- PAGE -->
    <div class="change-shift-page">

        <!-- TITLE -->
        <div class="section-title">Notes</div>

        <!-- FORM -->
        <form action="${pageContext.request.contextPath}/hr/note/send" method="post">

            <!-- EMPLOYEE NAME -->
            <div class="info-label">Employee Name</div>
            <div class="info-box">
                <input type="text"
                       class="info-input"
                       value="${account.employee.fullName}"
                       readonly>
            </div>

            <!-- SHIFT -->
            <div class="info-label">Shift</div>

            <div class="info-box dropdown-custom">

                <div class="dropdown-selected"
                     onclick="toggleDropdown('shiftMenuForm')">

                    <span id="selectedShiftForm">
                        Select Shift
                    </span>

                    <span class="fa-solid fa-angle-down"></span>
                </div>

                <input type="hidden"
                       name="shiftId"
                       id="shiftFormInput">

                <div id="shiftMenuForm" class="dropdown-menu">

                    <c:forEach var="s" items="${shifts}">
                        <div onclick="selectOption(
                            '${s.shiftId}','${s.shiftName}',
                            'selectedShiftForm','shiftFormInput','shiftMenuForm')">

                            ${s.shiftName}
                        </div>
                    </c:forEach>

                </div>

            </div>

            <!-- TITLE -->
            <div class="info-label">Title</div>
            <div class="info-box">
                <input type="text"
                       name="title"
                       class="info-input"
                       placeholder="Enter note title">
            </div>

            <!-- CONTENT -->
            <div class="info-label">Content</div>
            <div class="info-box">
                <input type="text"
                       name="content"
                       class="info-input"
                       placeholder="Enter your note">
            </div>

            <!-- BUTTON -->
            <button type="submit" class="btn-change mt-2">
                Send
            </button>

            <!-- ERROR -->
            <c:if test="${not empty error}">
                <div class="text-danger mt-3">
                    ${error}
                </div>
            </c:if>

            <!-- SUCCESS -->
            <c:if test="${not empty success}">
                <div class="success-text">
                    ${success}
                </div>
            </c:if>

        </form>

    </div>

</div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="<c:url value='/resources/js/manage/dropdown.js'/>"></script>
</body>
</html>
