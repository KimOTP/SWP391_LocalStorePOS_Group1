let selectedProducts = new Set();

// 1. Mở modal và nạp sản phẩm
async function openMultiProductModal() {
    try {
        const response = await fetch('/audit/api/products');
        const products = await response.json();
        const tbody = document.querySelector('#modalTable tbody');
        if (!tbody) return;
        tbody.innerHTML = '';

        products.forEach(p => {
            tbody.innerHTML += `
                <tr>
                    <td class="ps-3"><input type="checkbox" class="product-cb form-check-input" value='${JSON.stringify(p)}'></td>
                    <td><div class="fw-bold">${p.name}</div><small class="text-muted">${p.unit}</small></td>
                    <td class="text-sku">#${p.sku}</td>
                    <td class="text-end pe-3 fw-bold">${p.stock}</td>
                </tr>`;
        });
        const modalEl = document.getElementById('productPickerModal');
        if (modalEl) new bootstrap.Modal(modalEl).show();
    } catch (error) {
        Swal.fire('Error', 'Failed to fetch products', 'error');
    }
}

// 2. Chọn nhanh tất cả
function toggleAll(master) {
    document.querySelectorAll('.product-cb').forEach(cb => cb.checked = master.checked);
}

// 3. Thêm các sản phẩm đã chọn
function addSelectedItems() {
    const checkboxes = document.querySelectorAll('.product-cb:checked');
    const tbody = document.querySelector('#auditTable tbody');
    const emptyRow = document.getElementById('emptyRow');

    if (checkboxes.length > 0 && emptyRow) emptyRow.style.display = 'none';

    checkboxes.forEach(cb => {
        const p = JSON.parse(cb.value);
        if (selectedProducts.has(p.sku)) return;

        const row = `
    <tr data-sku="${p.sku}" data-expected="${p.stock}">
        <td class="text-center text-muted small">${tbody.rows.length}</td>
        <td><div class="fw-bold text-dark">${p.name}</div><small class="text-sku">#${p.sku}</small></td>
        <td class="text-center"><span class="view-only-box border">${p.stock}</span></td>
        <td class="text-center">
            <input type="number" class="input-actual" placeholder="0" oninput="calculateDiff(this)">
        </td>
        <td class="text-center fw-bold diff-val">0</td>
        <td><input type="text" class="form-control border-0 bg-light rounded-2 input-note" placeholder="Ghi chú..."></td>
        <td class="text-center">
            <button class="btn btn-link text-danger p-0" onclick="removeRow(this, '${p.sku}')">
                <i class="fa-solid fa-trash-can"></i>
            </button>
        </td>
    </tr>`;
        tbody.insertAdjacentHTML('beforeend', row);
        selectedProducts.add(p.sku);
    });

    const modalEl = document.getElementById('productPickerModal');
    if (modalEl) {
        const modalInstance = bootstrap.Modal.getInstance(modalEl);
        if (modalInstance) modalInstance.hide();
    }
    updateDashboardStats(); // Cập nhật Dashboard sau khi thêm
}

// 4. Tính toán sai lệch: Actual - Expected
function calculateDiff(input) {
    const row = input.closest('tr');
    const expected = parseInt(row.dataset.expected) || 0;
    const actualValue = input.value;
    const diffCell = row.querySelector('.diff-val');

    if (actualValue === "") {
        diffCell.innerText = "0";
        diffCell.className = "text-center fw-bold diff-val";
        updateDashboardStats();
        return;
    }

    const actual = parseInt(actualValue);
    const diff = actual - expected;

    diffCell.innerText = diff > 0 ? `+${diff}` : diff;

    // Cập nhật màu sắc
    if (diff === 0) {
        diffCell.className = "text-center fw-bold diff-val text-muted";
    } else if (diff > 0) {
        diffCell.className = "text-center fw-bold diff-val text-success";
    } else {
        diffCell.className = "text-center fw-bold diff-val text-danger";
    }

    updateDashboardStats(); // Quan trọng: Cập nhật Progress Bar tại đây
}

// 5. Cập nhật Dashboard & Progress Bar
function updateDashboardStats() {
    const rows = document.querySelectorAll('#auditTable tbody tr:not(#emptyRow)');
    let totalItems = rows.length;
    let countedCount = 0;
    let discrepancyCount = 0;

    rows.forEach(row => {
        const actualInput = row.querySelector('.input-actual');
        const diffText = row.querySelector('.diff-val').innerText;

        if (actualInput && actualInput.value !== "") {
            countedCount++;
        }

        if (diffText !== "0" && diffText !== "") {
            discrepancyCount++;
        }
    });

    // Cập nhật giao diện (Có kiểm tra ID tồn tại)
    const setVal = (id, val) => {
        const el = document.getElementById(id);
        if (el) el.innerText = val;
    };

    setVal('stat-total', totalItems);
    setVal('stat-counted', countedCount);
    setVal('stat-diff', discrepancyCount);

    const progress = totalItems === 0 ? 0 : Math.round((countedCount / totalItems) * 100);
    setVal('stat-progress', progress + "%");

    const progressBar = document.getElementById('progress-bar');
    if (progressBar) progressBar.style.width = progress + "%";
}

// 6. Xóa dòng (Hàm bị thiếu trong code của bạn)
function removeRow(btn, sku) {
    btn.closest('tr').remove();
    selectedProducts.delete(sku);
    const tbody = document.querySelector('#auditTable tbody');
    const rows = tbody.querySelectorAll('tr:not(#emptyRow)');
    if (rows.length === 0 && document.getElementById('emptyRow')) {
        document.getElementById('emptyRow').style.display = 'table-row';
    }
    updateDashboardStats();
}

// 7. Gửi dữ liệu
function submitAudit() {
    const rows = document.querySelectorAll('#auditTable tbody tr:not(#emptyRow)');
    if (rows.length === 0) {
        Swal.fire('Warning', 'Please add products to audit!', 'warning');
        return;
    }

    const items = Array.from(rows).map(row => ({
        productId: row.dataset.sku,
        actual: row.querySelector('.input-actual').value || 0,
        note: row.querySelector('.input-note').value
    }));

    Swal.fire({
        title: 'Confirm Audit?',
        text: "Submit inventory audit results for approval?",
        icon: 'question',
        showCancelButton: true,
        confirmButtonColor: '#2563eb',
        confirmButtonText: 'Yes, Submit'
    }).then((result) => {
        if (result.isConfirmed) {
            const dataInput = document.getElementById('auditDataJson');
            const auditForm = document.getElementById('auditForm');
            if (dataInput && auditForm) {
                dataInput.value = JSON.stringify(items);
                auditForm.submit();
            }
        }
    });
}

// Xử lý thông báo
document.addEventListener('DOMContentLoaded', function() {
    const msgEl = document.getElementById('serverMessage');
    const statusEl = document.getElementById('serverStatus');
    if (msgEl && statusEl && msgEl.value) {
        Swal.fire({ title: statusEl.value === 'success' ? 'Success!' : 'Error', text: msgEl.value, icon: statusEl.value, timer: 3000 });
    }
});