// Khởi tạo Modal Bootstrap
let productModal;
document.addEventListener('DOMContentLoaded', function() {
    const modalElement = document.getElementById('productModal');
    if (modalElement) {
        productModal = new bootstrap.Modal(modalElement);
        modalElement.addEventListener('shown.bs.modal', function () {
            document.getElementById('productSearchInput').value = '';
            fetchProducts('');
        });
    }
});

function showProductSearchModal() {
    productModal.show();
}

// Hàm fetch dữ liệu linh hoạt (tải tất cả hoặc tìm kiếm)
async function fetchProducts(term = '') {
    try {
        // Gọi endpoint /stockOut/search-products?term=
        const response = await fetch(`/stockOut/search-products?term=${encodeURIComponent(term)}`);
        const data = await response.json();
        renderSearchTable(data);
    } catch (error) {
        console.error("Failed to load products:", error);
    }
}

// Hàm render dữ liệu vào Modal
function renderSearchTable(data) {
    const tbody = document.querySelector('#searchResultTable tbody');
    tbody.innerHTML = '';

    if (data.length === 0) {
        tbody.innerHTML = '<tr><td colspan="4" class="text-center py-3 text-muted">No products found.</td></tr>';
        return;
    }

    data.forEach(item => {
        tbody.innerHTML += `
            <tr>
                <td>
                    <div class="fw-bold text-dark">${item.name}</div>
                    <small class="text-muted">${item.unit}</small>
                </td>
                <td class="text-sku">#${item.sku}</td>
                <td class="text-center">
                    <span class="stock-badge ${item.currentStock <= 0 ? 'bg-danger-subtle text-danger' : ''}">
                        ${item.currentStock}
                    </span>
                </td>
                <td class="text-center">
                    <button class="btn btn-sm btn-primary rounded-pill px-3" 
                            ${item.currentStock <= 0 ? 'disabled' : ''}
                            onclick='selectItem(${JSON.stringify(item)})'>
                        Select
                    </button>
                </td>
            </tr>
        `;
    });
}
// Xử lý khi gõ phím tìm kiếm
function liveSearch() {
    const term = document.getElementById('productSearchInput').value;
    fetchProducts(term);
}
function selectItem(item) {
    const tbody = document.querySelector('#stockOutTable tbody');
    const emptyRow = document.getElementById('emptyRow');
    if (emptyRow) emptyRow.style.display = 'none';

    if (document.querySelector(`tr[data-sku="${item.sku}"]`)) {
        alert("Product already in list!"); return;
    }

    const row = `
        <tr data-sku="${item.sku}">
            <td class="text-center text-muted small">${tbody.querySelectorAll('tr:not(#emptyRow)').length + 1}</td>
            <td class="text-sku">#${item.sku}</td>
            <td><div class="fw-bold text-dark">${item.name}</div></td>
            <td><span class="badge border text-dark fw-normal px-2">${item.unit}</span></td>
            <td class="text-center"><span class="expected-badge">${item.currentStock}</span></td>
            <td class="text-center">
                <input type="number" class="input-actual" value="1" min="1" max="${item.currentStock}">
            </td>
            <td><input type="text" class="input-reason form-control border-0 bg-light rounded-2" placeholder="Note..."></td>
            <td class="text-center">
                <button class="btn btn-link text-danger p-0" onclick="removeRow(this)">
                    <i class="fa-solid fa-trash-can"></i>
                </button>
            </td>
        </tr>
    `;
    tbody.insertAdjacentHTML('beforeend', row);
    bootstrap.Modal.getInstance(document.getElementById('productModal')).hide();
}

// Xóa dòng sản phẩm
function removeRow(btn) {
    btn.closest('tr').remove();
    const tbody = document.querySelector('#stockOutTable tbody');
    if (tbody.querySelectorAll('tr:not(#emptyRow)').length === 0) {
        document.getElementById('emptyRow').style.display = 'table-row';
    }
}

function submitStockOut() {

    const rows = document.querySelectorAll('#stockOutTable tbody tr:not(#emptyRow)');
    // 1. Kiểm tra danh sách trống
    if (rows.length === 0) {
        Swal.fire({
            title: 'Warning',
            text: 'Please add at least one product to export!',
            icon: 'warning',
            confirmButtonColor: '#2563eb'
        });
        return;
    }

    // 2. Hiển thị Pop-up xác nhận
    Swal.fire({
        title: 'Confirm Export?',
        text: "Are you sure you want to process this stock-out transaction?",
        icon: 'question',
        showCancelButton: true,
        confirmButtonColor: '#2563eb',
        cancelButtonColor: '#64748b',
        confirmButtonText: 'Yes, Confirm',
        cancelButtonText: 'Cancel'
    }).then((result) => {
        if (result.isConfirmed) {
            console.log("User confirmed. Processing data...");
            try {
                const data = [];
                rows.forEach(row => {
                    data.push({
                        sku: row.getAttribute('data-sku'),
                        qty: row.querySelector('.input-actual').value,
                        reason: row.querySelector('.input-reason').value
                    });
                });

                // Gán dữ liệu vào các thẻ ẩn
                const generalNote = document.getElementById('generalNote').value;
                document.getElementById('formNote').value = generalNote;
                document.getElementById('formItems').value = JSON.stringify(data);

                console.log("Submitting form to: " + document.getElementById('submitForm').action);

                // Gửi form
                document.getElementById('submitForm').submit();
            } catch (error) {
                console.error("Error gathering data:", error);
                Swal.fire('Error', 'An error occurred while preparing data.', 'error');
            }
        }
    });
}

document.addEventListener('DOMContentLoaded', function() {
    const message = document.getElementById('serverMessage').value;
    const status = document.getElementById('serverStatus').value;

    if (message && message.trim() !== "") {
        // Kích hoạt SweetAlert2
        Swal.fire({
            title: status === 'success' ? 'Success!' : 'Oops...',
            text: message,
            icon: status, // 'success', 'error', 'warning', 'info'
            confirmButtonColor: '#2563eb', // Đồng bộ với màu Slate/Blue của bạn
            timer: 3000, // Tự đóng sau 3 giây
            timerProgressBar: true,
            borderRadius: '16px'
        });
    }
});
// Thêm đoạn code này vào cuối file stock-out.js của bạn
document.addEventListener('DOMContentLoaded', function() {
    // 1. Lấy productId từ URL (ví dụ: ?productId=SP001)
    const urlParams = new URLSearchParams(window.location.search);
    const productId = urlParams.get('productId');

    if (productId) {
        autoSelectProduct(productId);
    }
});

async function autoSelectProduct(id) {
    try {
        // 2. Gọi API để lấy thông tin chi tiết của 1 sản phẩm
        const response = await fetch(`/stockOut/search-products?term=${encodeURIComponent(id)}`);
        const data = await response.json();

        // 3. Nếu tìm thấy sản phẩm, thực hiện chọn vào bảng
        if (data && data.length > 0) {
            // Tìm sản phẩm khớp chính xác ID trong danh sách trả về
            const targetProduct = data.find(p => p.sku === id);
            if (targetProduct) {
                selectItem(targetProduct); // Tái sử dụng hàm selectItem bạn đã viết
            }
        }
    } catch (error) {
        console.error("Lỗi tự động thêm sản phẩm:", error);
    }
}