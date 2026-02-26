<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Product Request | LocalStorePOS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<c:url value='/resources/css/inventory/request-order.css'/>">
</head>
<body>

<jsp:include page="../../layer/header.jsp" />
<jsp:include page="../../layer/sidebar.jsp" />

<div class="main-content">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2 class="fw-bold mb-0">Product Request</h2>
    </div>

    <input type="hidden" id="serverMessage" value="${message}">
    <input type="hidden" id="serverStatus" value="${status}">

    <div class="request-wrapper">
        <div class="form-card shadow-sm">
            <h5 class="fw-bold mb-4 text-dark">Request Details</h5>

            <div class="row g-3 mb-4">
                <div class="col-md-6">
                    <label class="small fw-bold">Supplier Name</label>
                    <div class="d-flex gap-2">
                        <input type="text" id="supplierName" class="input-custom" placeholder="Type supplier name...">
                        <button class="btn-auto-fill" onclick="handleSupplierAutoFill()">Auto Fill</button>
                    </div>
                    <span id="supplierError" class="text-danger small fw-bold" style="display:none;"></span>
                </div>
                <div class="col-md-6">
                    <label class="small fw-bold">Email</label>
                    <input type="text" id="supplierEmail" class="input-custom" readonly placeholder="Auto-filled email">
                </div>
            </div>

            <hr class="my-4" style="border-top: 2px dashed #e2e8f0;">

            <div class="table-responsive">
                <table class="table table-borderless align-middle">
                    <thead class="small text-muted text-uppercase">
                    <tr>
                        <th style="width: 25%">Product Code (SKU)</th>
                        <th style="width: 30%">Product Name</th>
                        <th style="width: 15%">Unit Cost</th>
                        <th style="width: 15%">Quantity</th>
                        <th style="width: 15%">Sub-Total</th>
                    </tr>
                    </thead>
                    <tbody>
                    <tr class="product-row">
                        <td>
                            <select id="productSku" class="form-select input-custom" disabled onchange="handleProductSelect()">
                                <option value="">-- Select Supplier First --</option>
                            </select>
                        </td>
                        <td><input type="text" id="productName" class="input-custom product-name" readonly></td>
                        <td><input type="number" id="unitCost" class="input-custom unit-price" readonly placeholder="0.00"></td>
                        <td><input type="number" id="qty" class="input-custom quantity-input" value="1" min="1"></td>
                        <td><input type="text" class="input-custom total-amount text-primary fw-bold" readonly value="0.00"></td>
                    </tr>
                    </tbody>
                </table>
            </div>

            <div class="d-flex justify-content-end mt-4">
                <button class="btn-add-receipt px-5" id="btnAddItem">
                    <i class="fa-solid fa-plus me-2"></i>Add To Receipt
                </button>
            </div>
        </div>

        <div class="summary-card shadow-sm">
            <h6 class="text-center fw-bold text-uppercase mb-4">Order Summary</h6>

            <div class="small mb-4">
                <div class="d-flex justify-content-between align-items-center p-2 bg-light rounded-3">
                    <span class="text-muted">Status:</span>
                    <span class="badge bg-dark rounded-pill">Input-Pending</span>
                </div>
            </div>

            <div class="flex-grow-1">
                <table class="receipt-table">
                    <thead class="small text-muted text-uppercase">
                    <tr>
                        <th>Item</th>
                        <th class="text-center">Qty</th>
                        <th class="text-end">Total</th>
                        <th></th>
                    </tr>
                    </thead>
                    <tbody id="receiptItemsSummary"></tbody>
                </table>
            </div>

            <div class="mt-4 pt-4 border-top">
                <div class="d-flex justify-content-between align-items-center fw-bold mb-4">
                    <span class="text-muted small text-uppercase">Grand Total</span>
                    <span id="finalGrandTotal" class="text-danger fs-4">0.00 đ</span>
                </div>

                <form id="finalForm" action="/stockIn/stock-in" method="POST">
                    <input type="hidden" id="hiddenSupplierName" name="supplierName">
                    <input type="hidden" id="hiddenItemsJson" name="itemsJson">
                    <div class="d-flex gap-2">
                        <button type="button" class="btn btn-light flex-grow-1 border fw-bold" onclick="handleCancel()">Cancel</button>
                        <button type="button" class="btn btn-primary flex-grow-1 shadow-sm" onclick="submitFinalOrder()">Request Now</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script src="<c:url value='/resources/js/inventory/request-order.js'/>"></script>

</body>
</html>