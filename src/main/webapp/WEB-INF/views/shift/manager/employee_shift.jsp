<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
    <title>Employee Shift Management</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<c:url value='/resources/css/manage/employee_list.css'/>">
</head>
<body>

<jsp:include page="/WEB-INF/views/layer/header.jsp"/>
<jsp:include page="/WEB-INF/views/layer/sidebar.jsp"/>

<div class="main-content">
    <div class="profile-wrapper">

        <!-- TITLE -->
        <div class="section-title">Employee Shift Management</div>

        <!-- FILTER -->
        <div class="row mb-4">
            <div class="col-md-3">
                <div class="info-label">Employee</div>
                <div class="info-box">
                    <input class="info-input" value="Tran Phu"/>
                </div>
            </div>

            <div class="col-md-3">
                <div class="info-label">Shift</div>
                <div class="info-box">
                    <input class="info-input" placeholder="---"/>
                </div>
            </div>

            <div class="col-md-3">
                <div class="info-label">Status</div>
                <div class="info-box">
                    <input class="info-input" placeholder="---"/>
                </div>
            </div>
        </div>

        <!-- TABLE -->
        <div class="info-box" style="height:auto; padding:0;">
            <table class="table align-middle mb-0">
                <thead>
                <tr>
                    <th>Employee ID</th>
                    <th>Full Name</th>
                    <th>Role</th>
                    <th>Work Date</th>
                    <th>Shift</th>
                    <th>Time</th>
                    <th>Shift Status</th>
                    <th>Violation Status</th>
                    <th></th>
                </tr>
                </thead>

                <tbody>
                <tr>
                    <td>5</td>
                    <td>Tran Phu 2</td>
                    <td>Cashier</td>
                    <td>20/01/2026</td>
                    <td>Morning</td>
                    <td>07:00 - 12:00</td>
                    <td class="text-primary">Completed</td>
                    <td class="text-warning">Early Leave</td>
                    <td>
                        <button class="btn-change">Change Shift</button>
                    </td>
                </tr>

                <tr>
                    <td>3</td>
                    <td>Tran Phu</td>
                    <td>Cashier</td>
                    <td>20/01/2026</td>
                    <td>Afternoon</td>
                    <td>12:00 - 17:00</td>
                    <td class="text-success">Working</td>
                    <td class="text-success">Normal</td>
                    <td>
                        <button class="btn-change">Change Shift</button>
                    </td>
                </tr>

                <tr>
                    <td>4</td>
                    <td>Tran Phu 1</td>
                    <td>Cashier</td>
                    <td>20/01/2026</td>
                    <td>Evening</td>
                    <td>17:00 - 22:00</td>
                    <td class="text-success">Working</td>
                    <td class="text-danger">Late</td>
                    <td>
                        <button class="btn-change">Change Shift</button>
                    </td>
                </tr>
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
</body>
</html>
