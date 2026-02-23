<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Product Request | LocalStorePOS</title>
    <link rel="stylesheet" href="<c:url value='/resources/css/inventory/request-order.css'/>">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>

<jsp:include page="../layer/header.jsp" />
<jsp:include page="../layer/sidebar.jsp" />

<div class="main-content">
    <div class="request-wrapper">

        <div class="form-card">
            <h4 class="fw-bold mb-4">Product Request</h4>

            <div class="row mb-2">
                <div class="col-md-6">
                    <label class="small fw-bold mb-1">Supplier Name</label>
                    <div class="d-flex gap-2">
                        <input type="text" id="supplierName" class="input-custom mb-0" placeholder="Type supplier name...">
                        <button class="btn-auto-fill" onclick="handleSupplierAutoFill()">Auto Fill</button>
                    </div>
                    <span id="supplierError" class="text-danger small fw-bold" style="display:none;"></span>
                </div>
                <div class="col-md-6">
                    <label class="small fw-bold mb-1">Email</label>
                    <input type="text" id="supplierEmail" class="input-custom" readonly placeholder="Auto-filled email">
                </div>
            </div>

            <hr class="my-4" style="border-top: 2px dashed #bbb;">

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
                        <select id="productSku" class="input-custom mb-0 form-select" disabled onchange="handleProductSelect()">
                            <option value="">-- Select Supplier First --</option>
                        </select>
                    </td>
                    <td>
                        <input type="text" id="productName" class="input-custom mb-0 product-name" readonly>
                    </td>
                    <td>
                        <input type="number" id="unitCost" class="input-custom mb-0 unit-price" readonly placeholder="0.00">
                    </td>
                    <td>
                        <input type="number" id="qty" class="input-custom mb-0 quantity-input" value="1" min="1">
                    </td>
                    <td>
                        <input type="text" class="input-custom mb-0 total-amount text-primary fw-bold" readonly value="0.00">
                    </td>
                </tr>
                </tbody>
            </table>

            <div class="d-flex justify-content-end mt-3">
                <button class="btn-add-receipt px-5" id="btnAddItem">
                    <i class="fa-solid fa-plus me-2"></i>Add To Receipt
                </button>
            </div>
        </div>

        <div class="summary-card shadow-sm">
            <div>
                <h6 class="text-center fw-bold text-uppercase mb-4">Request Order Summary</h6>

                <div class="small mb-4 text-secondary">
                    <div class="d-flex justify-content-between mt-1">
                        <span>Status:</span>
                        <span class="badge bg-dark rounded-pill">Input-Pending</span>
                    </div>
                </div>

                <table class="receipt-table">
                    <thead class="small text-muted">
                    <tr>
                        <th>Item</th>
                        <th class="text-center">Qty</th>
                        <th class="text-end">Total</th>
                        <th></th>
                    </tr>
                    </thead>
                    <tbody id="receiptItemsSummary">
                    </tbody>
                </table>
            </div>

            <div class="mt-auto pt-4 border-top border-secondary">
                <div class="d-flex justify-content-between fw-bold mb-4 fs-5">
                    <span>Grand Total</span>
                    <span id="finalGrandTotal" class="text-danger">0.00 đ</span>
                </div>
                <div class="d-flex gap-2">
                    <button class="btn btn-outline-secondary flex-grow-1 py-2" onclick="location.reload()">
                        Cancel
                    </button>
                    <button class="btn btn-primary flex-grow-1 py-2 fw-bold" id="btnSubmitRequest">
                        Request
                    </button>
                </div>
            </div>
        </div>

    </div>
</div>

<script src="<c:url value='/resources/js/inventory/request-order.js'/>"></script>
</body>
</html>