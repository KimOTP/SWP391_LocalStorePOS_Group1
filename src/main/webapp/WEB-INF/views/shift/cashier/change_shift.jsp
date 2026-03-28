<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
    <title>Change Shift</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<c:url value='/resources/css/profile/profile.css'/>">
</head>
<body>

<jsp:include page="/WEB-INF/views/layer/header.jsp"/>
<jsp:include page="/WEB-INF/views/layer/sidebar.jsp"/>

<div class="main-content">
    <div class="profile-wrapper">

        <!-- BACK -->
        <div class="text-end">
            <a href="/hr/cashier_profile" class="back-link">← Back To Profile</a>
        </div>

        <div class="change-shift-page">
            <!-- TITLE -->
            <div class="section-title">Change Shift</div>

            <!-- FORM -->
            <form action="/shift/change_shift" method="post" style="max-width: 420px;">

                <!--<div class="info-label">Day I Want To Switch Shift</div>-->
                <!--<div class="info-box">
                    <input type="date"
                           name="workDate"
                           class="info-input"
                           min="<%= java.time.LocalDate.now() %>"
                           max="<%= java.time.LocalDate.now().plusDays(7) %>"
                           value="${selectedDate}" />
                </div>-->

                <!-- DAY I WANT TO SWITCH SHIFT -->
                <div class="info-label">Day I Want To Switch Shift</div>

                <div class="info-box dropdown-custom">

                    <div class="dropdown-selected" onclick="toggleDropdown('switchCalendarMenu')">
                        <span id="selectedSwitchDateText">
                            ${empty selectedDate ? 'Select Date' : selectedDate}
                        </span>
                        <span class="dropdown-arrow">📅</span>
                    </div>

                    <!-- VALUE SEND TO BACKEND -->
                    <input type="hidden"
                           name="workDate"
                           id="switchDateInput"
                           min="<%= java.time.LocalDate.now() %>"
                           max="<%= java.time.LocalDate.now().plusDays(7) %>"
                           value="${selectedDate}">

                    <!-- CALENDAR -->
                    <div id="switchCalendarMenu" class="calendar-menu">

                        <div class="calendar-header">
                            <button type="button" onclick="changeMonth(-1)">‹</button>
                            <span id="calendarMonth"></span>
                            <button type="button" onclick="changeMonth(1)">›</button>
                        </div>

                        <div class="calendar-days">
                            <span>SU</span>
                            <span>MO</span>
                            <span>TU</span>
                            <span>WE</span>
                            <span>TH</span>
                            <span>FR</span>
                            <span>SA</span>
                        </div>

                        <div id="calendarDates" class="calendar-dates"></div>

                        <div class="calendar-footer">
                            <button type="button" onclick="selectToday()">Today</button>
                            <button type="button" onclick="applySwitchDate()">Apply</button>
                        </div>

                    </div>

                </div>

                <div class="info-label">Current Shift</div>
                <div class="info-box">
                    <input type="text"
                           class="info-input"
                           value="${currentShift}"
                           readonly>
                </div>

                <!-- REQUESTED SHIFT -->
                <div class="info-label">Requested Shift</div>

                <div class="info-box dropdown-custom">

                    <div class="dropdown-selected"
                         onclick="toggleDropdown('shiftMenu')">

                        <span id="selectedShiftText">
                            Select Shift
                        </span>

                        <span class="fa-solid fa-angle-down"></span>

                    </div>

                    <!-- VALUE SEND TO BACKEND -->
                    <input type="hidden"
                           name="requestedShift"
                           id="shiftInput">

                    <!-- MENU -->
                    <div id="shiftMenu" class="dropdown-menu">

                        <div onclick="selectOptionNoSubmit(
                                'Morning',
                                'Morning',
                                'selectedShiftText',
                                'shiftInput',
                                'shiftMenu'
                        )">
                            Morning
                        </div>

                        <div onclick="selectOptionNoSubmit(
                                'Afternoon',
                                'Afternoon',
                                'selectedShiftText',
                                'shiftInput',
                                'shiftMenu'
                        )">
                            Afternoon
                        </div>

                        <div onclick="selectOptionNoSubmit(
                                'Evening',
                                'Evening',
                                'selectedShiftText',
                                'shiftInput',
                                'shiftMenu'
                        )">
                            Evening
                        </div>

                    </div>

                </div>

                <div class="info-label">Reason</div>
                <div class="info-box">
                    <input type="text" name="reason" class="info-input" placeholder="Enter your reason">
                </div>

                <button type="submit" class="btn-change mt-2">Send</button>

                <!-- ERROR MESSAGE -->
                <c:if test="${not empty error}">
                    <div class="text-danger mt-3">
                        ${error}
                    </div>
                </c:if>

                <!-- SUCCESS MESSAGE -->
                <c:if test="${not empty success}">
                    <div class="text-success mt-3">
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
