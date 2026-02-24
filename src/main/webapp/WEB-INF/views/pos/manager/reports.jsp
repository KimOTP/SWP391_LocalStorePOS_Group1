<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html>
<head>
    <title>Sales report</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/reports/reports.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">


</head>
<body>

<jsp:include page="../../layer/header.jsp" />

<jsp:include page="../../layer/sidebar.jsp" />

<div class="report-container">

    <!-- HEADER -->
    <div class="report-header">
        <h2>Sales report</h2>

        <div class="report-actions">
            <button class="btn-outline">Refresh</button>
            <button class="btn-outline">Export excel</button>
        </div>
    </div>

    <!-- FILTER -->
    <div class="report-filter">

        <div class="filter-header">
            <span>📊 Report filter</span>
            <button class="btn-link" onclick="toggleFilter()">Extend</button>
        </div>

        <div class="filter-body" id="filterBody">
            <div class="filter-row">
                <label>Select a time range</label>
                <input type="date">
            </div>

            <div class="filter-row">
                <label>Cashier</label>
                <div class="radio-group">
                    <label><input type="radio" name="cashier"> Cashier A</label>
                    <label><input type="radio" name="cashier"> Cashier B</label>
                </div>
            </div>

            <div class="filter-row">
                <label>Payment methods</label>
                <div class="radio-group">
                    <label><input type="radio" name="payment"> Payment by cash</label>
                    <label><input type="radio" name="payment"> Payment via banking</label>
                </div>
            </div>
        </div>
    </div>

    <!-- DATE -->
    <div class="report-date">
        23/01/2026
    </div>

    <!-- SUMMARY -->
    <div class="report-summary">
        <div class="summary-card">
            <div>Total revenue</div>
            <strong>$0</strong>
        </div>
        <div class="summary-card">
            <div>Total order</div>
            <strong>0</strong>
        </div>
        <div class="summary-card">
            <div>Average value / unit</div>
            <strong>$0</strong>
        </div>
        <div class="summary-card">
            <div>Bestselling product</div>
            <strong>Product</strong>
        </div>
    </div>

</div>

<script>
    let expanded = false;

    function toggleFilter() {
        const body = document.getElementById('filterBody');
        const btn = document.querySelector('.btn-link');

        expanded = !expanded;
        body.style.display = expanded ? 'block' : 'none';
        btn.innerText = expanded ? 'Collapse' : 'Extend';
    }
</script>

</body>
</html>
