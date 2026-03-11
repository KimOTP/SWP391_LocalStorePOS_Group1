<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
    <title>Shift Change Request</title>
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
        <a href="/hr/manager_profile" class="back-link">← Back To Profile</a>
        <!-- TITLE -->
        <div class="section-title">Shift Change Request</div>
        <br/>

        <!-- FILTER -->
        <form id="searchForm" method="get" action="/shift/shift_change_req">
            <div class="row mb-4">

                <!-- Employee ID (gõ tay) -->
                <div class="col-md-3">
                    <div class="info-label">Employee ID</div>
                    <div class="info-box">
                        <input type="text"
                               name="employeeId"
                               value="${param.employeeId}"
                               class="info-input"
                               placeholder="Enter Employee ID"/>
                    </div>
                </div>

                <!-- Current Shift -->
                <div class="col-md-3">
                    <div class="info-label">Current Shift</div>

                    <div class="info-box dropdown-custom">

                        <div class="dropdown-selected"
                             onclick="toggleDropdown('currentShiftMenu')">

                            <span id="selectedCurrentShift">
                                ${empty param.currentShiftId ? 'All' : param.currentShiftId}
                            </span>

                            <span class="fa-solid fa-angle-down"></span>
                        </div>

                        <input type="hidden"
                               name="currentShiftId"
                               id="currentShiftInput"
                               value="${param.currentShiftId}">

                        <div id="currentShiftMenu" class="dropdown-menu">

                            <div onclick="selectOption(
                                '','All',
                                'selectedCurrentShift','currentShiftInput','currentShiftMenu')">
                                All
                            </div>

                            <c:forEach var="s" items="${shiftList}">
                                <div onclick="selectOption(
                                    '${s.shiftId}','${s.shiftName}',
                                    'selectedCurrentShift','currentShiftInput','currentShiftMenu')">
                                    ${s.shiftName}
                                </div>
                            </c:forEach>

                        </div>

                    </div>
                </div>

                <!-- Requested Shift -->
                <div class="col-md-3">
                    <div class="info-label">Requested Shift</div>

                    <div class="info-box dropdown-custom">

                        <div class="dropdown-selected"
                             onclick="toggleDropdown('requestedShiftMenu')">

                            <span id="selectedRequestedShift">
                                ${empty param.requestedShiftId ? 'All' : param.requestedShiftId}
                            </span>

                            <span class="fa-solid fa-angle-down"></span>
                        </div>

                        <input type="hidden"
                               name="requestedShiftId"
                               id="requestedShiftInput"
                               value="${param.requestedShiftId}">

                        <div id="requestedShiftMenu" class="dropdown-menu">

                            <div onclick="selectOption(
                                '','All',
                                'selectedRequestedShift','requestedShiftInput','requestedShiftMenu')">
                                All
                            </div>

                            <c:forEach var="s" items="${shiftList}">
                                <div onclick="selectOption(
                                    '${s.shiftId}','${s.shiftName}',
                                    'selectedRequestedShift','requestedShiftInput','requestedShiftMenu')">
                                    ${s.shiftName}
                                </div>
                            </c:forEach>

                        </div>

                    </div>
                </div>

                <!-- Status -->
                <div class="col-md-3">
                    <div class="info-label">Status</div>

                    <div class="info-box dropdown-custom">

                        <div class="dropdown-selected"
                             onclick="toggleDropdown('statusMenuShift')">

                            <span id="selectedStatusShift">
                                ${empty param.status ? 'All' : param.status}
                            </span>

                            <span class="fa-solid fa-angle-down"></span>
                        </div>

                        <input type="hidden"
                               name="status"
                               id="statusShiftInput"
                               value="${param.status}">

                        <div id="statusMenuShift" class="dropdown-menu">

                            <div onclick="selectOption(
                                '','All',
                                'selectedStatusShift','statusShiftInput','statusMenuShift')">
                                All
                            </div>

                            <div onclick="selectOption(
                                'Pending','Pending',
                                'selectedStatusShift','statusShiftInput','statusMenuShift')">
                                Pending
                            </div>

                            <div onclick="selectOption(
                                'Approved','Approved',
                                'selectedStatusShift','statusShiftInput','statusMenuShift')">
                                Approved
                            </div>

                            <div onclick="selectOption(
                                'Rejected','Rejected',
                                'selectedStatusShift','statusShiftInput','statusMenuShift')">
                                Rejected
                            </div>

                        </div>

                    </div>
                </div>

            </div>
        </form>

        <!-- TABLE -->
        <div class="info-box" style="height:auto; padding:0;">
            <table class="table align-middle mb-0">
                <thead>
                <tr>
                    <th>Employee ID</th>
                    <th>Day Wanted To Switch</th>
                    <th>Current Shift</th>
                    <th>Requested Shift</th>
                    <th>Reason</th>
                    <th>Status</th>
                    <th>Manager Approval</th>
                    <th>Reviewed At</th>
                    <th></th>
                </tr>
                </thead>

                <tbody>
                <c:forEach var="req" items="${requests}">
                    <tr>
                        <td>${req.employee.employeeId}</td>
                        <td>${req.workDate}</td>
                        <td>${req.currentShift.shiftName}</td>
                        <td>${req.requestedShift.shiftName}</td>
                        <td>${req.reason}</td>

                        <!-- STATUS -->
                        <td>
                            <c:choose>
                                <c:when test="${req.status == 'Approved'}">
                                    <span class="status-active">Approved</span>
                                </c:when>
                                <c:when test="${req.status == 'Rejected'}">
                                    <span class="status-deactive">Rejected</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="status-pending">Pending</span>
                                </c:otherwise>
                            </c:choose>
                        </td>

                        <!-- MANAGER -->
                        <td>
                            <c:if test="${req.manager != null}">
                                ${req.manager.fullName}
                            </c:if>
                            <c:if test="${req.manager == null}">
                                ---
                            </c:if>
                        </td>

                        <!-- REVIEWED AT -->
                        <td>
                            <c:if test="${req.reviewedAt != null}">
                                ${req.reviewedAt.toString().replace('T',' ').substring(0,16)}
                            </c:if>
                            <c:if test="${req.reviewedAt == null}">
                                ---
                            </c:if>
                        </td>

                        <!-- BUTTON -->
                        <td>
                            <c:if test="${req.status == 'Pending'}">
                                <form action="/shift/manager/approve" method="post" style="display:inline;">
                                    <input type="hidden" name="id" value="${req.requestId}">
                                    <button class="btn-change">Approve</button>
                                </form>

                                <form action="/shift/manager/reject" method="post" style="display:inline;">
                                    <input type="hidden" name="id" value="${req.requestId}">
                                    <button class="btn-danger">Reject</button>
                                </form>
                            </c:if>
                        </td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
        </div>

        <!-- PAGINATION -->
        <div class="d-flex justify-content-center gap-2 mt-4">

            <c:if test="${requestPage.totalPages > 1}">

                <!-- LIMIT 5 PAGES -->
                <c:set var="startPage" value="${currentPage - 2}" />
                <c:set var="endPage" value="${currentPage + 2}" />

                <c:if test="${startPage < 0}">
                    <c:set var="startPage" value="0"/>
                </c:if>

                <c:if test="${endPage >= requestPage.totalPages}">
                    <c:set var="endPage" value="${requestPage.totalPages - 1}"/>
                </c:if>

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
                <c:forEach begin="${startPage}" end="${endPage}" var="i">
                    <a href="?page=${i}"
                       class="btn ${i == currentPage ? 'page-active' : 'btn-light'}">
                       ${i + 1}
                    </a>
                </c:forEach>

                <!-- > NEXT -->
                <c:if test="${currentPage < requestPage.totalPages - 1}">
                    <a href="?page=${currentPage + 1}"
                       class="btn btn-light">
                        >
                    </a>
                </c:if>

                <!-- >> LAST -->
                <c:if test="${currentPage < requestPage.totalPages - 1}">
                    <a href="?page=${requestPage.totalPages - 1}"
                       class="btn btn-light">
                        >>
                    </a>
                </c:if>
            </c:if>
        </div>

    </div>
</div>
<script src="<c:url value='/resources/js/manage/shift_change_req.js'/>"></script>
<script src="<c:url value='/resources/js/manage/dropdown.js'/>"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
