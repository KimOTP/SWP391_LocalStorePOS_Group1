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
        <form id="searchForm" method="get" action="<c:url value='/hr/manager/employee_list'/>">
            <div class="row mb-4">
                <div class="col-md-3">
                    <div class="info-label">Full Name</div>
                    <div class="info-box">
                        <input class="info-input" name="fullName" value="${param.fullName}"/>
                    </div>
                </div>

                <div class="col-md-3">
                    <div class="info-label">Role</div>
                    <div class="info-box">
                        <select class="info-input" name="role">
                            <option value="">All</option>
                            <option value="Cashier"
                                ${param.role == 'Cashier' ? 'selected' : ''}>
                                Cashier
                            </option>
                            <option value="Manager"
                                ${param.role == 'Manager' ? 'selected' : ''}>
                                Manager
                            </option>
                            <option value="Supplier"
                                ${param.role == 'Supplier' ? 'selected' : ''}>
                                Supplier
                            </option>
                        </select>
                    </div>
                </div>

                <div class="col-md-3">
                    <div class="info-label">Status</div>
                    <div class="info-box">
                        <select class="info-input" name="status">
                            <option value="">All</option>
                            <option value="true"
                                ${param.status == 'true' ? 'selected' : ''}>
                                Active
                            </option>
                            <option value="false"
                                ${param.status == 'false' ? 'selected' : ''}>
                                Deactive
                            </option>
                        </select>
                    </div>
                </div>

                <div class="col-md-3">
                    <div class="info-label">Creation Time</div>
                    <div class="info-box">
                        <input type="date"
                               name="creationDate"
                               class="info-input"
                               value="${param.creationDate}">
                    </div>
                </div>
            </div>
        </form>

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
                <c:forEach var="emp" items="${employees}">
                    <tr>
                        <td>${emp.employeeId}</td>
                        <td>${emp.fullName}</td>
                        <td>
                            <c:set var="foundUsername" value="false"/>

                            <c:forEach var="acc" items="${accounts}">
                                <c:if test="${acc.employee.employeeId == emp.employeeId}">
                                    ${acc.username}
                                    <c:set var="foundUsername" value="true"/>
                                </c:if>
                            </c:forEach>

                            <c:if test="${foundUsername == false}">
                                --
                            </c:if>
                        </td>
                        <td>${emp.email}</td>
                        <td>${emp.role}</td>

                        <td class="${emp.status ? 'text-success' : 'text-danger'}">
                            ${emp.status ? 'Active' : 'Deactive'}
                        </td>

                        <td>
                            ${fn:substring(fn:replace(emp.createdAt, 'T', ' '), 0, 16)}
                        </td>

                        <td>
                            <a href="<c:url value='/hr/manager/employee_detail/${emp.employeeId}'/>"
                               class="btn-change">
                                Edit
                            </a>
                        </td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
        </div>

        <!-- PAGINATION -->
        <div class="d-flex justify-content-center gap-2 mt-4">

            <c:if test="${employeePage.totalPages > 1}">

                <!-- << FIRST -->
                <c:if test="${currentPage > 0}">
                    <a href="?page=0"
                       class="btn btn-light">
                        <<
                    </a>
                </c:if>

                <!-- < PREVIOUS -->
                <c:if test="${currentPage > 0}">
                    <a href="?page=${currentPage - 1}"
                       class="btn btn-light">
                        <
                    </a>
                </c:if>

                <!-- PAGE NUMBERS -->
                <c:forEach begin="0"
                           end="${employeePage.totalPages - 1}"
                           var="i">

                    <a href="?page=${i}"
                       class="btn ${i == currentPage ? 'page-active' : 'btn-light'}">
                        ${i + 1}
                    </a>

                </c:forEach>

                <!-- > NEXT -->
                <c:if test="${currentPage < employeePage.totalPages - 1}">
                    <a href="?page=${currentPage + 1}"
                       class="btn btn-light">
                        >
                    </a>
                </c:if>

                <!-- >> LAST -->
                <c:if test="${currentPage < employeePage.totalPages - 1}">
                    <a href="?page=${employeePage.totalPages - 1}"
                       class="btn btn-light">
                        >>
                    </a>
                </c:if>

            </c:if>

        </div>

        <!-- BACK -->
        <a href="/hr/manager/manager_profile" class="back-link">← Back To Profile</a>

    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="<c:url value='/resources/js/manage/employee_list.js'/>"></script>
</body>
</html>
