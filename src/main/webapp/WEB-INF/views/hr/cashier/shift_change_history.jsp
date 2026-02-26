<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
    <title>Shift Change History</title>
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

        <!-- BACK -->
        <a href="/hr/cashier_profile" class="back-link">← Back To Profile</a>
        <!-- TITLE -->
        <div class="section-title">Shift Change History</div>
        <br/>

        <!-- TABLE -->
        <div class="info-box" style="height:auto; padding:0;">
            <table class="table align-middle mb-0">

                <thead>
                    <tr>
                        <th>My ID</th>
                        <th>Day Want To Switch Shift</th>
                        <th>Current Shift</th> <th>Requested Shift</th>
                        <th>Reason</th>
                        <th>Status</th>
                        <th>Manager Approval</th>
                        <th>Approval Time</th>
                    </tr>
                </thead>
                <tbody>
                <c:forEach var="req" items="${employeePage.content}">
                    <tr>
                        <td>${req.employee.employeeId}</td>

                        <td>
                            ${req.workDate}
                        </td>

                        <td>
                            ${req.currentShift.shiftName}
                        </td>

                        <td>
                            ${req.requestedShift.shiftName}
                        </td>

                        <td>
                            <c:choose>
                                <c:when test="${not empty req.reason}">
                                    ${req.reason}
                                </c:when>
                                <c:otherwise>---</c:otherwise>
                            </c:choose>
                        </td>

                        <td>
                            <c:choose>
                                <c:when test="${req.status == 'Pending'}">
                                    <span class="text-warning">Pending</span>
                                </c:when>
                                <c:when test="${req.status == 'Approved'}">
                                    <span class="text-success">Approved</span>
                                </c:when>
                                <c:when test="${req.status == 'Rejected'}">
                                    <span class="text-danger">Rejected</span>
                                </c:when>
                                <c:otherwise>${req.status}</c:otherwise>
                            </c:choose>
                        </td>

                        <td>
                            <c:choose>
                                <c:when test="${req.manager != null}">
                                    ${req.manager.fullName}
                                </c:when>
                                <c:otherwise>---</c:otherwise>
                            </c:choose>
                        </td>

                        <td>
                            <c:choose>
                                <c:when test="${req.reviewedAt != null}">
                                    ${req.reviewedAt.toString().replace('T',' ').substring(0,16)}
                                </c:when>
                                <c:otherwise>---</c:otherwise>
                            </c:choose>
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

    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
