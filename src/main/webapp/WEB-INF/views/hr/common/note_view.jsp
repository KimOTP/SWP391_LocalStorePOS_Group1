<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<html>
<head>
    <title>Notes</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">


<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
<link rel="stylesheet" href="<c:url value='/resources/css/profile/profile.css'/>">
<link rel="stylesheet" href="<c:url value='/resources/css/manage/note.css'/>">


</head>
<body>

<jsp:include page="/WEB-INF/views/layer/header.jsp"/>
<jsp:include page="/WEB-INF/views/layer/sidebar.jsp"/>

<div class="main-content">

<div class="profile-wrapper1">

    <!-- PAGE -->
    <div class="change-shift-page">

        <!-- TITLE -->
        <div class="section-title">Note View</div>

        <div class="container mt-4 note-view-container">

            <!-- HEADER NOTE -->
            <div class="note-header">

                <div class="note-shift">
                    <i class="fa-solid fa-clock"></i>
                    ${note.workShift.shiftName} - ${note.workDate}
                </div>

                <a href="javascript:history.back()" class="back-link">
                    <i class="fa-solid fa-arrow-left"></i> Back
                </a>

            </div>


            <!-- NOTE CARD -->
            <div class="note-card">

                <!-- AUTHOR -->
                <div class="note-author">

                    <div class="note-avatar">
                        <i class="fa-solid fa-user"></i>
                    </div>

                    <div class="note-author-info">
                        <div class="note-author-name">
                            ${note.sender.fullName}
                        </div>

                        <div class="note-time">
                            <i class="fa-regular fa-clock"></i>
                            ${note.createdAt.toString().replace('T',' ').substring(0,16)}
                        </div>
                    </div>

                </div>

                <div class="note-divider"></div>

                <!-- CONTENT -->
                <div class="note-content">
                    ${note.content}
                </div>

            </div>

        </div>

    </div>

</div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>
