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

    <!-- PAGE -->
    <div class="change-shift-page">

        <!-- TITLE -->
        <div class="section-title">Note View</div>

        <div class="container mt-4">

            <h4>${note.workShift.shiftName} - ${note.workDate}</h4>

            <div class="card mt-3">
                <div class="card-body">

                    <h5>${note.sender.fullName}</h5>

                    <p class="text-muted">
                        ${note.createdAt.toString().replace('T',' ').substring(0,16)}
                    </p>

                    <hr>

                    <p>${note.content}</p>

                </div>
            </div>

        </div>

    </div>

</div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>
