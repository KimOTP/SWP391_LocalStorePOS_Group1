/**
 * Add Stock-out Logic
 * Synchronized with Design System & Multi-select capability
 */

document.addEventListener('DOMContentLoaded', function() {
    // 1. Xử lý thông báo từ server (SweetAlert2)
    checkServerNotifications();

    // 2. Khởi tạo Modal an toàn (Chống kẹt nền xám)
    const modalElement = document.getElementById('productModal');
    if (modalElement) {
        modalElement.addEventListener('shown.bs.modal', function () {
            document.getElementById('productSearchInput').value = '';
            fetchProducts('');
        });

        // Dọn dẹp checkbox khi đóng modal
        modalElement.addEventListener('hidden.bs.modal', function() {
            document.querySelectorAll('.product-checkbox').forEach(cb => cb.checked = false);
            document.querySelectorAll('#searchResultTable tbody tr').forEach(tr => tr.classList.remove('table-primary'));
        });
    }

    // 3. Tự động thêm sản phẩm từ URL (Nếu có)
    const urlParams = new URLSearchParams(window.location.search);
    const productId = urlParams.get('productId');
    if (productId) {
        autoSelectProduct(productId);
    }
});

function showProductSearchModal() {
    const modalElement = document.getElementById('productModal');
    const modal = bootstrap.Modal.getOrCreateInstance(modalElement);
    modal.show();
}

// Hàm fetch dữ liệu linh hoạt (tải tất cả hoặc tìm kiếm)
async function fetchProducts(term = '') {
    try {
        const response = await fetch(`/stockOut/search-products?term=${encodeURIComponent(term)}`);
        const data = await response.json();
        renderSearchTable(data);
    } catch (error) {
        console.error("Failed to load products:", error);
    }
}

// Xử lý khi gõ phím tìm kiếm
function liveSearch() {
    const term = document.getElementById('productSearchInput').value;
    fetchProducts(term);
}

// Render dữ liệu vào Modal + Tích hợp Multi-select
function renderSearchTable(data) {
    const tbody = document.querySelector('#searchResultTable tbody');
    tbody.innerHTML = '';

    // Lấy danh sách các SKU đã có trong bảng chính để vô hiệu hóa
    const existingSkus = Array.from(document.querySelectorAll('#stockOutTable tbody tr[data-sku]')).map(tr => tr.getAttribute('data-sku'));

    if (data.length === 0) {
        tbody.innerHTML = '<tr><td colspan="4" class="td-cell text-center py-4 text-muted">No products found.</td></tr>';
        return;
    }

    data.forEach(item => {
        const isAdded = existingSkus.includes(item.sku);
        const isOutOfStock = item.currentStock <= 0;
        const disabled = isAdded || isOutOfStock;

        // Thêm onclick vào thẻ tr để click cả dòng là chọn
        tbody.innerHTML += `
            <tr class="${disabled ? 'bg-light' : ''}" 
                style="${!disabled ? 'cursor: pointer;' : 'opacity: 0.7;'}"
                onclick="${!disabled ? `toggleSelectRow(this)` : ''}">
                <td class="td-cell">
                    <div class="d-flex align-items-center gap-3">
                        <div class="form-check mb-0">
                            <input class="form-check-input product-checkbox" type="checkbox" 
                                   value='${JSON.stringify(item).replace(/'/g, "&#39;")}'
                                   onclick="event.stopPropagation(); toggleSelectRow(this.closest('tr'))" 
                                   ${disabled ? 'disabled' : ''}>
                        </div>
                        <div>
                            <div class="fw-bold text-dark">${item.name}</div>
                            <small class="text-muted">${item.unit}</small>
                        </div>
                    </div>
                </td>
                <td class="td-cell"><span class="text-sku">#${item.sku}</span></td>
                <td class="td-cell text-center">
                    <span class="stock-badge ${isOutOfStock ? 'bg-danger-subtle text-danger' : ''}">
                        ${item.currentStock}
                    </span>
                </td>
                <td class="td-cell text-center">
                    ${isAdded ? '<span class="badge bg-success"><i class="fa-solid fa-check me-1"></i>Added</span>' :
            (isOutOfStock ? '<span class="badge bg-danger">Out of Stock</span>' : '<span class="badge bg-primary">Select</span>')}
                </td>
            </tr>
        `;
    });

    injectAddSelectedButton();
}

// Hàm đổi trạng thái chọn khi click vào dòng
function toggleSelectRow(row) {
    const checkbox = row.querySelector('.product-checkbox');
    if (checkbox && !checkbox.disabled) {
        // Nếu click thẳng vào checkbox thì trình duyệt tự đổi state rồi, không cần đảo ngược lại
        if (event.target !== checkbox) {
            checkbox.checked = !checkbox.checked;
        }
        // Thêm màu nền xanh nhạt cho dòng được chọn
        row.classList.toggle('table-primary', checkbox.checked);
    }
}

// Tự động thêm nút "Add Selected" vào Modal nếu chưa có
function injectAddSelectedButton() {
    const modalBody = document.querySelector('#productModal .modal-body');
    if (!document.getElementById('btnAddSelectedContainer')) {
        const btnHtml = `
            <div class="mt-4 pt-3 border-top d-flex justify-content-end" id="btnAddSelectedContainer">
                <button class="btn btn-add px-4" onclick="processSelectedProducts()">
                    <i class="fa-solid fa-check-double me-2"></i>Add Selected Products
                </button>
            </div>
        `;
        modalBody.insertAdjacentHTML('beforeend', btnHtml);
    }
}

// Xử lý khi nhấn nút "Add Selected Products"
function processSelectedProducts() {
    const checkboxes = document.querySelectorAll('.product-checkbox:checked');
    if (checkboxes.length === 0) return; // Không làm gì nếu chưa chọn

    checkboxes.forEach(cb => {
        const item = JSON.parse(cb.value);
        appendRowToMainTable(item);
    });

    // Ẩn modal sau khi thêm xong
    const modalElement = document.getElementById('productModal');
    bootstrap.Modal.getInstance(modalElement).hide();
}

// Hàm lõi chèn dòng HTML chuẩn Design System
function appendRowToMainTable(item) {
    const tbody = document.querySelector('#stockOutTable tbody');
    const emptyRow = document.getElementById('emptyRow');
    if (emptyRow) emptyRow.style.display = 'none';

    // Đề phòng trường hợp trùng
    if (document.querySelector(`tr[data-sku="${item.sku}"]`)) return;

    const rowCount = tbody.querySelectorAll('tr:not(#emptyRow)').length + 1;

    // HTML chuẩn có td-cell bao quanh text-sku
    const row = `
        <tr data-sku="${item.sku}">
            <td class="td-cell text-center text-muted small row-index">${rowCount}</td>
            <td class="td-cell"><span class="text-sku">#${item.sku}</span></td>
            <td class="td-cell fw-bold text-dark">${item.name}</td>
            <td class="td-cell"><span class="badge border text-dark fw-normal px-2">${item.unit}</span></td>
            <td class="td-cell text-center"><span class="stock-badge">${item.currentStock}</span></td>
            <td class="td-cell text-center">
                <input type="number" class="input-actual" value="1" min="1" max="${item.currentStock}">
            </td>
            <td class="td-cell">
                <input type="text" class="input-reason form-control border-0 bg-light rounded-2 px-3" placeholder="Note...">
            </td>
            <td class="td-cell text-center">
                <button type="button" class="btn-delete-row shadow-sm" onclick="removeRow(this)">
                    <i class="fa-solid fa-trash-can"></i>
                </button>
            </td>
        </tr>
    `;
    tbody.insertAdjacentHTML('beforeend', row);
}

// Xóa dòng và cập nhật lại số thứ tự (STT)
function removeRow(btn) {
    const tbody = document.querySelector('#stockOutTable tbody');
    btn.closest('tr').remove();

    const remainingRows = tbody.querySelectorAll('tr:not(#emptyRow)');
    if (remainingRows.length === 0) {
        document.getElementById('emptyRow').style.display = 'table-row';
    } else {
        // Đánh lại STT
        remainingRows.forEach((row, index) => {
            row.querySelector('.row-index').innerText = index + 1;
        });
    }
}

// Submit Form
function submitStockOut() {
    const rows = document.querySelectorAll('#stockOutTable tbody tr:not(#emptyRow)');

    if (rows.length === 0) {
        Swal.fire({
            title: 'Warning',
            text: 'Please add at least one product to export!',
            icon: 'warning',
            confirmButtonColor: '#2563eb',
            borderRadius: '16px'
        });
        return;
    }

    Swal.fire({
        title: 'Confirm Export?',
        text: "Are you sure you want to process this stock-out transaction?",
        icon: 'question',
        showCancelButton: true,
        confirmButtonColor: '#2563eb',
        cancelButtonColor: '#94a3b8',
        confirmButtonText: '<i class="fa-solid fa-check me-2"></i>Yes, Confirm',
        cancelButtonText: 'Cancel',
        borderRadius: '16px'
    }).then((result) => {
        if (result.isConfirmed) {
            try {
                const data = [];
                rows.forEach(row => {
                    data.push({
                        sku: row.getAttribute('data-sku'),
                        qty: row.querySelector('.input-actual').value,
                        reason: row.querySelector('.input-reason').value
                    });
                });

                document.getElementById('formNote').value = document.getElementById('generalNote').value;
                document.getElementById('formItems').value = JSON.stringify(data);
                document.getElementById('submitForm').submit();
            } catch (error) {
                Swal.fire('Error', 'An error occurred while preparing data.', 'error');
            }
        }
    });
}

// Tự động chọn từ URL
async function autoSelectProduct(id) {
    try {
        const response = await fetch(`/stockOut/search-products?term=${encodeURIComponent(id)}`);
        const data = await response.json();

        if (data && data.length > 0) {
            const targetProduct = data.find(p => p.sku === id);
            if (targetProduct) {
                appendRowToMainTable(targetProduct);
            }
        }
    } catch (error) {
        console.error("Auto select failed:", error);
    }
}

function checkServerNotifications() {
    const messageInput = document.getElementById('serverMessage');
    const statusInput = document.getElementById('serverStatus');

    if (messageInput && messageInput.value.trim() !== "") {
        const status = statusInput ? statusInput.value : 'info';
        Swal.fire({
            title: status === 'success' ? 'Success!' : 'Oops...',
            text: messageInput.value,
            icon: status,
            confirmButtonColor: '#2563eb',
            timer: 3000,
            timerProgressBar: true,
            borderRadius: '16px'
        });
    }
}