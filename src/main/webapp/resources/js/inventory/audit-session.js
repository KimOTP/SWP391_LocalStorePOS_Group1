let selectedProducts = new Set();

document.addEventListener('DOMContentLoaded', function() {
    // Xử lý thông báo từ Server
    checkServerNotifications();

    // 2. KHÔI PHỤC DỮ LIỆU CŨ (Nếu có lỗi từ Server)
    const oldDataRaw = document.getElementById('oldAuditDataJson')?.value;
    if (oldDataRaw && oldDataRaw !== "") {
        try {
            const oldItems = JSON.parse(oldDataRaw);
            // Với mỗi item cũ, ta cần lấy lại thông tin sản phẩm để vẽ lại dòng
            oldItems.forEach(item => {
                recoverAuditRow(item.productId, item.actual, item.note);
            });
        } catch (e) { console.error("Data recovery failed", e); }
    }

    const msgEl = document.getElementById('serverMessage');
    const statusEl = document.getElementById('serverStatus');
    if (msgEl && statusEl && msgEl.value.trim() !== "") {
        Swal.fire({
            title: statusEl.value === 'success' ? 'Success!' : 'Error',
            text: msgEl.value,
            icon: statusEl.value,
            timer: 3000,
            confirmButtonColor: '#2563eb',
            borderRadius: '16px'
        });
    }

    // Dọn dẹp modal khi đóng
    const modalEl = document.getElementById('productPickerModal');
    if (modalEl) {
        modalEl.addEventListener('hidden.bs.modal', function() {
            document.querySelectorAll('.product-cb').forEach(cb => cb.checked = false);
            document.getElementById('selectAllCheckbox').checked = false;
            document.querySelectorAll('#modalTable tbody tr').forEach(tr => tr.classList.remove('table-primary'));
        });
    }
});

async function recoverAuditRow(sku, actual, note) {
    try {
        const response = await fetch('/audit/api/products'); // Lấy lại list sản phẩm để lấy Expected Stock
        const products = await response.json();
        const p = products.find(prod => prod.sku === sku);
        if (p) {
            // Tận dụng logic addSelectedItems nhưng nạp giá trị cũ
            addSingleItemToTable(p, actual, note);
        }
    } catch (e) { console.error(e); }
}

// 1. Mở modal và nạp sản phẩm
async function openMultiProductModal() {
    try {
        const response = await fetch('/audit/api/products');
        const products = await response.json();
        const tbody = document.querySelector('#modalTable tbody');
        if (!tbody) return;
        tbody.innerHTML = '';

        if (products.length === 0) {
            tbody.innerHTML = '<tr><td colspan="4" class="td-cell text-center py-4 text-muted">No products found.</td></tr>';
        } else {
            products.forEach(p => {
                // Đánh dấu nếu đã thêm rồi
                const isAdded = selectedProducts.has(p.sku);
                const disabled = isAdded ? 'disabled' : '';
                const cursor = isAdded ? 'opacity: 0.6;' : 'cursor: pointer;';
                const onClickAction = isAdded ? '' : 'onclick="toggleSelectRow(this)"';

                tbody.innerHTML += `
                    <tr style="${cursor}" ${onClickAction}>
                        <td class="td-cell text-center">
                            <input type="checkbox" class="product-cb form-check-input" value='${JSON.stringify(p)}'
                                   onclick="event.stopPropagation(); toggleSelectRow(this.closest('tr'))" ${disabled}>
                        </td>
                        <td class="td-cell">
                            <div class="fw-bold text-dark">${p.name}</div>
                            <small class="text-muted">${p.unit}</small>
                        </td>
                        <td class="td-cell"><span class="text-sku">#${p.sku}</span></td>
                        <td class="td-cell text-end pe-4 fw-bold text-dark">${p.stock}</td>
                    </tr>`;
            });
        }

        const modalEl = document.getElementById('productPickerModal');
        if (modalEl) bootstrap.Modal.getOrCreateInstance(modalEl).show();
    } catch (error) {
        Swal.fire('Error', 'Failed to fetch products', 'error');
    }
}

// 2. Click cả dòng để chọn
function toggleSelectRow(row) {
    const checkbox = row.querySelector('.product-cb');
    if (checkbox && !checkbox.disabled) {
        if (event.target !== checkbox) {
            checkbox.checked = !checkbox.checked;
        }
        row.classList.toggle('table-primary', checkbox.checked);

        // Cập nhật trạng thái nút "Select All"
        const allChecked = Array.from(document.querySelectorAll('.product-cb:not(:disabled)')).every(cb => cb.checked);
        document.getElementById('selectAllCheckbox').checked = allChecked;
    }
}

// 3. Chọn nhanh tất cả
function toggleAll(master) {
    document.querySelectorAll('.product-cb:not(:disabled)').forEach(cb => {
        cb.checked = master.checked;
        cb.closest('tr').classList.toggle('table-primary', master.checked);
    });
}

// 4. Lọc tìm kiếm trong Modal
function filterModalProducts() {
    const keyword = document.getElementById('modalSearch').value.toLowerCase();
    document.querySelectorAll('#modalTable tbody tr').forEach(row => {
        const text = row.innerText.toLowerCase();
        row.style.display = text.includes(keyword) ? '' : 'none';
    });
}

// 5. Thêm các sản phẩm đã chọn vào bảng chính
function addSelectedItems() {
    const checkboxes = document.querySelectorAll('.product-cb:checked');
    const tbody = document.querySelector('#auditTable tbody');
    const emptyRow = document.getElementById('emptyRow');

    if (checkboxes.length === 0) return;
    if (emptyRow) emptyRow.style.display = 'none';

    checkboxes.forEach(cb => {
        const p = JSON.parse(cb.value);
        if (selectedProducts.has(p.sku)) return;

        const rowCount = tbody.querySelectorAll('tr:not(#emptyRow)').length + 1;

        // Render dòng mới theo chuẩn CSS mới
        const row = `
        <tr data-sku="${p.sku}" data-expected="${p.stock}">
            <td class="td-cell text-center text-muted small row-index">${rowCount}</td>
            <td class="td-cell">
                <div class="fw-bold text-dark mb-1">${p.name}</div>
                <span class="text-sku" style="font-size: 0.75rem;">#${p.sku}</span>
            </td>
            <td class="td-cell text-center"><span class="view-only-box border">${p.stock}</span></td>
            <td class="td-cell text-center">
                <input type="number" class="input-actual" placeholder="0" oninput="calculateDiff(this)">
            </td>
            <td class="td-cell text-center fw-bold diff-val diff-zero">0</td>
            <td class="td-cell">
                <input type="text" class="form-control border-0 bg-light rounded-2 input-note px-3" placeholder="Ghi chú...">
            </td>
            <td class="td-cell text-center">
                <button type="button" class="btn-delete-row shadow-sm" onclick="removeRow(this, '${p.sku}')">
                    <i class="fa-solid fa-trash-can"></i>
                </button>
            </td>
        </tr>`;

        tbody.insertAdjacentHTML('beforeend', row);
        selectedProducts.add(p.sku);
    });

    const modalEl = document.getElementById('productPickerModal');
    if (modalEl) bootstrap.Modal.getInstance(modalEl).hide();

    updateDashboardStats();
}

function addSingleItemToTable(p, actual = "", note = "") {
    const tbody = document.querySelector('#auditTable tbody');
    const emptyRow = document.getElementById('emptyRow');
    if (emptyRow) emptyRow.style.display = 'none';
    if (selectedProducts.has(p.sku)) return;

    const rowCount = tbody.querySelectorAll('tr:not(#emptyRow)').length + 1;
    const rowHtml = `
        <tr data-sku="${p.sku}" data-expected="${p.stock}">
            <td class="td-cell text-center text-muted small row-index">${rowCount}</td>
            <td class="td-cell">
                <div class="fw-bold text-dark mb-1">${p.name}</div>
                <span class="text-sku" style="font-size: 0.75rem;">#${p.sku}</span>
            </td>
            <td class="td-cell text-center"><span class="view-only-box border">${p.stock}</span></td>
            <td class="td-cell text-center">
                <input type="number" class="input-actual" value="${actual}" placeholder="0" oninput="calculateDiff(this)">
            </td>
            <td class="td-cell text-center fw-bold diff-val diff-zero">0</td>
            <td class="td-cell">
                <input type="text" class="form-control border-0 bg-light rounded-2 input-note px-3" value="${note}" placeholder="Note...">
            </td>
            <td class="td-cell text-center">
                <button type="button" class="btn-delete-row shadow-sm" onclick="removeRow(this, '${p.sku}')">
                    <i class="fa-solid fa-trash-can"></i>
                </button>
            </td>
        </tr>`;
    tbody.insertAdjacentHTML('beforeend', rowHtml);
    selectedProducts.add(p.sku);

    // Sau khi nạp xong, tính toán lại sai lệch ngay
    const lastRow = tbody.lastElementChild;
    calculateDiff(lastRow.querySelector('.input-actual'));
}

// 6. Tính toán sai lệch: Actual - Expected
function calculateDiff(input) {
    const row = input.closest('tr');
    const expected = parseInt(row.dataset.expected) || 0;
    const actualValue = input.value;
    const diffCell = row.querySelector('.diff-val');

    if (actualValue === "") {
        diffCell.innerText = "0";
        diffCell.className = "td-cell text-center fw-bold diff-val diff-zero";
        updateDashboardStats();
        return;
    }

    const actual = parseInt(actualValue);
    const diff = actual - expected;

    diffCell.innerText = diff > 0 ? `+${diff}` : diff;

    // Cập nhật màu sắc chuẩn Design System
    if (diff === 0) {
        diffCell.className = "td-cell text-center fw-bold diff-val diff-zero";
    } else if (diff > 0) {
        diffCell.className = "td-cell text-center fw-bold diff-val diff-positive";
    } else {
        diffCell.className = "td-cell text-center fw-bold diff-val diff-negative";
    }

    updateDashboardStats();
}

// 7. Cập nhật Dashboard & Progress Bar
function updateDashboardStats() {
    const rows = document.querySelectorAll('#auditTable tbody tr:not(#emptyRow)');
    let totalItems = rows.length;
    let countedCount = 0;
    let discrepancyCount = 0;

    rows.forEach(row => {
        const actualInput = row.querySelector('.input-actual');
        const diffText = row.querySelector('.diff-val').innerText;

        if (actualInput && actualInput.value !== "") countedCount++;
        if (diffText !== "0" && diffText !== "") discrepancyCount++;
    });

    const setVal = (id, val) => {
        const el = document.getElementById(id);
        if (el) el.innerText = val;
    };

    setVal('stat-total', totalItems);
    setVal('stat-diff', discrepancyCount);

    const progress = totalItems === 0 ? 0 : Math.round((countedCount / totalItems) * 100);
    setVal('stat-progress', progress + "%");

    const progressBar = document.getElementById('progress-bar');
    if (progressBar) progressBar.style.width = progress + "%";
}

// 8. Xóa dòng
function removeRow(btn, sku) {
    btn.closest('tr').remove();
    selectedProducts.delete(sku);

    const tbody = document.querySelector('#auditTable tbody');
    const rows = tbody.querySelectorAll('tr:not(#emptyRow)');

    if (rows.length === 0) {
        const emptyRow = document.getElementById('emptyRow');
        if (emptyRow) emptyRow.style.display = 'table-row';
    } else {
        // Đánh lại số thứ tự
        rows.forEach((row, index) => {
            row.querySelector('.row-index').innerText = index + 1;
        });
    }

    updateDashboardStats();
}

// 9. Gửi dữ liệu Audit
function submitAudit() {
    const rows = document.querySelectorAll('#auditTable tbody tr:not(#emptyRow)');
    if (rows.length === 0) {
        Swal.fire({ title: 'Warning', text: 'Please add products to audit!', icon: 'warning' });
        return;
    }

    let hasError = false;
    const items = [];

    rows.forEach(row => {
        const actualInput = row.querySelector('.input-actual');
        const actualVal = actualInput.value;

        // VALIDATE: Không được để trống và không được âm
        if (actualVal === "" || parseInt(actualVal) < 0) {
            hasError = true;
            actualInput.classList.add('is-invalid');
            actualInput.style.borderColor = "#dc2626";
        } else {
            actualInput.classList.remove('is-invalid');
            actualInput.style.borderColor = "";
            items.push({
                productId: row.dataset.sku,
                actual: parseInt(actualVal),
                note: row.querySelector('.input-note').value
            });
        }
    });

    if (hasError) {
        Swal.fire({
            title: 'Audit Error',
            text: 'Actual count cannot be empty or negative!',
            icon: 'error',
            confirmButtonColor: '#dc2626'
        });
        return;
    }

    Swal.fire({
        title: 'Confirm Audit?',
        text: "Submit inventory audit results for approval?",
        icon: 'question',
        showCancelButton: true,
        confirmButtonColor: '#2563eb',
        confirmButtonText: 'Yes, Submit'
    }).then((result) => {
        if (result.isConfirmed) {
            document.getElementById('auditDataJson').value = JSON.stringify(items);
            document.getElementById('auditForm').submit();
        }
    });
}