let allProducts = [];

document.addEventListener('DOMContentLoaded', function() {
    checkServerNotifications();

    const modalEl = document.getElementById('productPickerModal');
    if (modalEl) {
        modalEl.addEventListener('shown.bs.modal', function () {
            document.getElementById('modalSearch').value = '';
            document.getElementById('selectAllCheckbox').checked = false;
            fetchProducts();
        });
        modalEl.addEventListener('hidden.bs.modal', function() {
            document.querySelectorAll('.product-cb').forEach(cb => cb.checked = false);
            document.querySelectorAll('#modalProductList tr').forEach(tr => tr.classList.remove('table-primary'));
        });
    }

    const searchInput = document.getElementById('modalSearch');
    if(searchInput) {
        searchInput.addEventListener('input', function() {
            const term = this.value.toLowerCase();
            const filtered = allProducts.filter(item => {
                const name = (item.product?.productName || item.name || '').toLowerCase();
                const sku = (item.product?.productId || item.sku || '').toLowerCase();
                return name.includes(term) || sku.includes(term);
            });
            renderModalTable(filtered);
        });
    }
});

async function fetchProducts() {
    try {
        const response = await fetch('/stockIn/api/all-prioritized');
        if (!response.ok) throw new Error("API Error");

        allProducts = await response.json();
        renderModalTable(allProducts);
    } catch (error) {
        document.getElementById('modalProductList').innerHTML =
            '<tr><td colspan="4" class="td-cell text-center py-4 text-danger">Failed to load products. API Error!</td></tr>';
    }
}

function renderModalTable(data) {
    const tbody = document.getElementById('modalProductList');
    tbody.innerHTML = '';

    if (!data || data.length === 0) {
        tbody.innerHTML = '<tr><td colspan="4" class="td-cell text-center py-4 text-muted">No products found.</td></tr>';
        return;
    }

    const existingSkus = Array.from(document.querySelectorAll('#stockInBody tr[data-sku]')).map(tr => tr.getAttribute('data-sku'));

    data.forEach(item => {
        const itemSku = item.product?.productId || item.sku || item.productId || 'N/A';
        const itemName = item.product?.productName || item.name || item.productName || 'Unknown Product';
        const currentStock = item.currentQuantity ?? 0;
        const minStock = item.minThreshold ?? 0;

        const isAdded = existingSkus.includes(itemSku);
        const disabled = isAdded ? 'disabled' : '';
        const cursor = isAdded ? 'opacity: 0.6;' : 'cursor: pointer;';
        const onClickAction = isAdded ? '' : 'onclick="toggleSelectRow(this)"';

        const safeJson = encodeURIComponent(JSON.stringify(item));
        const stockDisplayClass = currentStock < minStock ? 'text-danger fw-bold' : 'text-muted';

        tbody.innerHTML += `
            <tr style="${cursor}" ${onClickAction}>
                <td class="td-cell text-center align-middle">
                    <input type="checkbox" class="product-cb form-check-input mb-0" value="${safeJson}"
                           onclick="event.stopPropagation(); toggleSelectRow(this.closest('tr'))" ${disabled}>
                </td>
                <td class="td-cell align-middle">
                    <div class="fw-bold text-dark">${itemName}</div>
                    <span class="text-sku mt-1" style="font-size: 0.7rem;">#${itemSku}</span>
                </td>
                <td class="td-cell text-center align-middle ${stockDisplayClass}">
                    ${currentStock} / <span>${minStock}</span>
                </td>
                <td class="td-cell text-center align-middle">
                    ${isAdded ? '<span class="badge bg-success"><i class="fa-solid fa-check me-1"></i>Added</span>' : '<span class="badge bg-primary">Select</span>'}
                </td>
            </tr>
        `;
    });
}

function toggleSelectRow(row) {
    const checkbox = row.querySelector('.product-cb');
    if (checkbox && !checkbox.disabled) {
        if (event.target !== checkbox) {
            checkbox.checked = !checkbox.checked;
        }
        row.classList.toggle('table-primary', checkbox.checked);

        const allChecked = Array.from(document.querySelectorAll('.product-cb:not(:disabled)')).every(cb => cb.checked);
        document.getElementById('selectAllCheckbox').checked = allChecked;
    }
}

function toggleAll(master) {
    document.querySelectorAll('.product-cb:not(:disabled)').forEach(cb => {
        cb.checked = master.checked;
        cb.closest('tr').classList.toggle('table-primary', master.checked);
    });
}

function processSelectedProducts() {
    const checkboxes = document.querySelectorAll('.product-cb:checked');
    if (checkboxes.length === 0) return;

    checkboxes.forEach(cb => {
        const item = JSON.parse(decodeURIComponent(cb.value));
        appendRowToMainTable(item, 1);
    });

    closeModalAndRefresh();
}

function autoSelectLowStock() {
    const lowStockItems = allProducts.filter(item => {
        const currentStock = item.currentQuantity ?? 0;
        const minStock = item.minThreshold ?? 0;
        return currentStock < minStock;
    });

    if (lowStockItems.length === 0) {
        Swal.fire({ title: 'Info', text: 'All products have sufficient stock levels!', icon: 'info', confirmButtonColor: '#2563eb' });
        return;
    }

    let addedCount = 0;
    lowStockItems.forEach(item => {
        const currentStock = item.currentQuantity ?? 0;
        const minStock = item.minThreshold ?? 0;

        let neededQty = minStock - currentStock;
        if (neededQty <= 0) neededQty = 1;

        if (appendRowToMainTable(item, neededQty)) {
            addedCount++;
        }
    });

    if (addedCount > 0) {
        Swal.fire({
            title: 'Auto-fill Success!',
            text: `Successfully auto-filled ${addedCount} low-stock product(s).`,
            icon: 'success',
            timer: 2000,
            showConfirmButton: false
        });
    } else {
        Swal.fire({ title: 'Info', text: 'All low-stock products are already in the list!', icon: 'info', confirmButtonColor: '#2563eb' });
    }

    closeModalAndRefresh();
}

function closeModalAndRefresh() {
    const emptyState = document.getElementById('emptyState');
    if (emptyState) emptyState.style.display = 'none';

    const modalElement = document.getElementById('productPickerModal');
    if(modalElement) bootstrap.Modal.getInstance(modalElement).hide();

    updateSummary();
}

function appendRowToMainTable(item, defaultQty = 1) {
    const tbody = document.getElementById('stockInBody');

    const itemId = item.product?.productId || item.productId || item.id || item.sku;
    const itemSku = item.product?.productId || item.sku || item.productId || 'N/A';
    const itemName = item.product?.productName || item.name || item.productName;
    const currentStock = item.currentQuantity ?? 0;
    const minStock = item.minThreshold ?? 0;
    const price = item.product?.unitCost ?? item.unitCost ?? 0;

    if (document.querySelector(`tr[data-id="${itemId}"]`)) return false;

    // FIX TRIỆT ĐỂ: Bỏ d-flex ở thẻ bọc ngoài cục SKU, set cứng thẻ td
    const row = `
        <tr data-sku="${itemSku}" data-id="${itemId}">
            <td class="td-cell align-middle text-center" style="width: 140px;">
                <span class="text-sku">#${itemSku}</span>
            </td>
            <td class="td-cell align-middle">
                <div class="fw-bold text-dark">${itemName}</div>
                <small class="text-muted">Stock: ${currentStock} | Min: ${minStock}</small>
            </td>
            <td class="td-cell text-center align-middle" style="width: 140px;">
                <input type="number" class="qty-input form-control mx-auto" value="${defaultQty}" min="1" oninput="calculateRow(this)">
            </td>
            <td class="td-cell text-center align-middle" style="width: 180px;">
                <div class="input-group input-group-sm flex-nowrap mx-auto" style="width: 140px;">
                    <input type="number" class="price-input form-control text-end border-end-0" value="${price}" min="0" oninput="calculateRow(this)">
                    <span class="input-group-text bg-white text-muted border-start-0 fw-bold px-2">VND</span>
                </div>
            </td>
            <td class="td-cell text-end fw-bold text-primary row-subtotal align-middle" style="width: 180px;">
                ${formatCurrency(defaultQty * price)}
            </td>
            <td class="td-cell text-center align-middle" style="width: 60px;">
                <button type="button" class="btn-remove mx-auto shadow-sm" onclick="removeRow(this)">
                    <i class="fa-solid fa-trash-can"></i>
                </button>
            </td>
        </tr>
    `;
    tbody.insertAdjacentHTML('beforeend', row);
    return true;
}

function calculateRow(input) {
    const row = input.closest('tr');
    const qty = parseFloat(row.querySelector('.qty-input').value) || 0;
    const price = parseFloat(row.querySelector('.price-input').value) || 0;
    row.querySelector('.row-subtotal').innerText = formatCurrency(qty * price);
    updateSummary();
}

function removeRow(btn) {
    btn.closest('tr').remove();
    const tbody = document.getElementById('stockInBody');
    if (tbody.children.length === 0) {
        document.getElementById('emptyState').style.display = 'block';
    }
    updateSummary();
}

function updateSummary() {
    const rows = document.querySelectorAll('#stockInBody tr');
    let totalValue = 0;
    rows.forEach(row => {
        const qty = parseFloat(row.querySelector('.qty-input').value) || 0;
        const price = parseFloat(row.querySelector('.price-input').value) || 0;
        totalValue += (qty * price);
    });

    document.getElementById('itemCount').innerText = rows.length + (rows.length === 1 ? ' Item' : ' Items');
    document.getElementById('grandTotal').innerText = formatCurrency(totalValue);
}

function formatCurrency(amount) {
    return new Intl.NumberFormat('en-US').format(amount) + ' VND';
}

function submitStockIn() {
    const supplierId = document.getElementById('supplierSelect').value;
    const rows = document.querySelectorAll('#stockInBody tr');

    if (!supplierId) {
        Swal.fire({ title: 'Warning', text: 'Please select a supplier!', icon: 'warning', confirmButtonColor: '#2563eb' });
        return;
    }
    if (rows.length === 0) {
        Swal.fire({ title: 'Warning', text: 'Please add at least one product to restock!', icon: 'warning', confirmButtonColor: '#2563eb' });
        return;
    }

    Swal.fire({
        title: 'Submit Stock-in Request?',
        text: "Are you sure you want to send this request?",
        icon: 'question',
        showCancelButton: true,
        confirmButtonColor: '#2563eb',
        cancelButtonColor: '#94a3b8',
        confirmButtonText: 'Yes, Submit',
        borderRadius: '16px'
    }).then((result) => {
        if (result.isConfirmed) {
            const data = [];
            rows.forEach(row => {
                data.push({
                    sku: row.getAttribute('data-sku'),
                    qty: parseInt(row.querySelector('.qty-input').value) || 0,
                    // QUAN TRỌNG: Đã xóa đuôi .toString() để gửi đi dạng Số (Number)
                    // Dữ liệu này sẽ map hoàn hảo vào private BigDecimal price; của StockInItemDTO
                    price: parseFloat(row.querySelector('.price-input').value) || 0
                });
            });

            document.getElementById('formSupplierId').value = parseInt(supplierId);
            document.getElementById('formItems').value = JSON.stringify(data);

            console.log("Data sending to server:", JSON.stringify(data));
            document.getElementById('submitForm').submit();
        }
    });
}

function checkServerNotifications() {
    const messageInput = document.getElementById('serverMessage');
    const statusInput = document.getElementById('serverStatus');

    if (messageInput && messageInput.value.trim() !== "") {
        const status = statusInput ? statusInput.value : 'info';
        const iconAlert = status === 'danger' ? 'error' : 'success';

        Swal.fire({
            title: status === 'success' ? 'Success!' : 'Oops...',
            text: messageInput.value,
            icon: iconAlert,
            confirmButtonColor: '#2563eb',
            timer: 3000,
            timerProgressBar: true,
            borderRadius: '16px'
        });
    }
}