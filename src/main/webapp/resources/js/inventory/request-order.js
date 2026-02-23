/**
 * LocalStorePOS - Product Request Logic (English Version)
 */
let receiptItems = [];

document.addEventListener('DOMContentLoaded', function() {
    // Dynamic calculation
    document.addEventListener('input', function(e) {
        if (e.target.classList.contains('quantity-input') || e.target.classList.contains('unit-price')) {
            const row = e.target.closest('tr');
            calculateRowTotal(row);
        }
    });

    const btnAdd = document.getElementById('btnAddItem');
    if (btnAdd) btnAdd.addEventListener('click', addItemToReceipt);

    const btnSubmit = document.getElementById('btnSubmitRequest');
    if (btnSubmit) btnSubmit.addEventListener('click', submitFinalOrder);
});

/**
 * Supplier Auto Fill & Error Handling
 */
async function handleSupplierAutoFill() {
    const name = document.getElementById('supplierName').value.trim();
    const errorSpan = document.getElementById('supplierError');
    const emailField = document.getElementById('supplierEmail');
    const productSelect = document.getElementById('productSku');

    errorSpan.style.display = 'none';
    emailField.value = '';
    productSelect.innerHTML = '<option value="">-- Select Supplier First --</option>';
    productSelect.disabled = true;

    if (!name) {
        showError("Please enter a supplier name!");
        return;
    }

    try {
        const response = await fetch(`/requestOrder/admin/supplier-info?name=${encodeURIComponent(name)}`);

        if (!response.ok) {
            throw new Error("Supplier not found in the system!");
        }

        const data = await response.json();
        emailField.value = data.email;
        loadProductsBySupplier(name); // Unlock Product Dropdown

    } catch (err) {
        showError(err.message);
    }
}

function showError(msg) {
    const errorSpan = document.getElementById('supplierError');
    errorSpan.innerText = msg;
    errorSpan.style.display = 'block';
}

/**
 * Load products filtered by the selected Supplier
 */
async function loadProductsBySupplier(name) {
    const productSelect = document.getElementById('productSku');

    try {
        const response = await fetch(`/requestOrder/admin/products-by-supplier?name=${encodeURIComponent(name)}`);
        const products = await response.json();

        if (products && products.length > 0) {
            let options = '<option value="">-- Select SKU --</option>';
            products.forEach(p => {
                options += `<option value="${p.productId}">${p.productId}</option>`;
            });
            productSelect.innerHTML = options;
            productSelect.disabled = false;
        } else {
            productSelect.innerHTML = '<option value="">No products for this supplier</option>';
        }
    } catch (err) {
        console.error("Error loading product list:", err);
    }
}

async function handleProductSelect() {
    const sku = document.getElementById('productSku').value;
    const row = document.querySelector('.product-row');
    if (!sku) return;

    try {
        const response = await fetch(`/requestOrder/admin/product-info?sku=${encodeURIComponent(sku)}`);
        const data = await response.json();
        if (data) {
            row.querySelector('.product-name').value = data.productName;
            row.querySelector('.unit-price').value = data.unitCost;
            calculateRowTotal(row);
        }
    } catch (err) {
        console.error("Error fetching product details:", err);
    }
}

function calculateRowTotal(row) {
    const qty = parseFloat(row.querySelector('.quantity-input').value) || 0;
    const price = parseFloat(row.querySelector('.unit-price').value) || 0;
    const total = qty * price;
    row.querySelector('.total-amount').value = total.toLocaleString('en-US', {minimumFractionDigits: 2});
}

function addItemToReceipt() {
    const row = document.querySelector('.product-row');
    const sku = document.getElementById('productSku').value; // Đây là productId từ select
    const name = row.querySelector('.product-name').value;
    const price = parseFloat(row.querySelector('.unit-price').value) || 0;
    const qty = parseInt(row.querySelector('.quantity-input').value) || 0;

    if (!sku || !name || qty <= 0) {
        alert("Vui lòng chọn sản phẩm và nhập số lượng hợp lệ!");
        return;
    }
    lockSupplierFields(true);

    const existingItem = receiptItems.find(item => item.sku === sku);

    if (existingItem) {
        existingItem.qty += qty;
        existingItem.total = existingItem.qty * existingItem.price;
    } else {
        receiptItems.push({
            sku,
            name,
            qty,
            price,
            total: qty * price
        });
    }

    renderSummary();
    resetRow(row);
}

function renderSummary() {
    const tbody = document.getElementById('receiptItemsSummary');
    let grandTotal = 0;

    tbody.innerHTML = receiptItems.map((item, index) => {
        grandTotal += item.total;
        return `
            <tr>
                <td>${item.name}</td>
                <td class="text-center">${item.qty}</td>
                <td class="text-end">${item.total.toLocaleString()}</td>
                <td><button class="btn btn-sm text-danger" onclick="removeItem(${index})"><i class="fa-solid fa-xmark"></i></button></td>
            </tr>
        `;
    }).join('');

    document.getElementById('finalGrandTotal').innerText = grandTotal.toLocaleString() + " đ";
}

function lockSupplierFields(isLocked) {
    const supplierInput = document.getElementById('supplierName');
    // Nếu đã có sản phẩm, không cho phép đổi supplier
    if (supplierInput) {
        supplierInput.readOnly = isLocked;
        // Có thể thêm style để người dùng biết là đã bị khóa
        supplierInput.style.backgroundColor = isLocked ? "#e9ecef" : "#fff";
    }
}

function removeItem(index) {
    receiptItems.splice(index, 1);

    // Nếu xóa hết sản phẩm, cho phép sửa lại Supplier
    if (receiptItems.length === 0) {
        lockSupplierFields(false);
    }

    renderSummary();
}

function resetRow(row) {
    document.getElementById('productSku').value = '';
    row.querySelector('.product-name').value = '';
    row.querySelector('.unit-price').value = '';
    row.querySelector('.quantity-input').value = '1';
    row.querySelector('.total-amount').value = '0.00';
}

async function submitFinalOrder() {
    const supplierName = document.getElementById('supplierName').value;
    if (!supplierName || receiptItems.length === 0) {
        alert("Please enter supplier details and add at least one product!");
        return;
    }

    const payload = { supplierName, items: receiptItems };

    try {
        const res = await fetch('/requestOrder/admin/stock-in', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload)
        });

        if (res.ok) {
            alert("Request submitted successfully! Status: Input-Pending");
            location.reload();
        }
    } catch (err) {
        alert("Server connection error!");
    }
}