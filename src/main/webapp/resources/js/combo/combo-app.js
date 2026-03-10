// Biến toàn cục để quản lý danh sách sản phẩm trong Combo
let selectedProducts = [];

// --- 1. Xử lý Xem trước ảnh ---
function initImagePreview() {
    const imageInput = document.getElementById('imageInput');
    const container = document.getElementById('previewContainer');
    if (imageInput && container) {
        imageInput.addEventListener('change', function(evt) {
            const file = evt.target.files[0];
            if (file) {
                if (!file.type.startsWith('image/')) {
                    alert("Please select image!");
                    return;
                }
                const imgUrl = URL.createObjectURL(file);
                container.innerHTML = '';
                const newImg = document.createElement('img');
                newImg.src = imgUrl;
                newImg.className = "img-fluid rounded";
                container.appendChild(newImg);
                newImg.onload = () => URL.revokeObjectURL(imgUrl);
            }
        });
    }
}

// --- 2. Logic Tìm kiếm sản phẩm trong Dropdown (Trang Add/Update) ---
function initProductSearch() {
    const searchInput = document.getElementById('productSearchInside');
    const productItems = document.querySelectorAll('.product-item-li');
    const noResult = document.getElementById('noProductFound');
    const dropdownBtn = document.getElementById('dropdownProductBtn');

    if (searchInput) {
        searchInput.addEventListener('input', function() {
            const keyword = this.value.toLowerCase().trim();
            let hasResult = false;
            productItems.forEach(item => {
                const productName = item.querySelector('.p-name').textContent.toLowerCase();
                if (productName.includes(keyword) || item.textContent.toLowerCase().includes(keyword)) {
                    item.classList.remove('d-none');
                    hasResult = true;
                } else {
                    item.classList.add('d-none');
                }
            });
            noResult.classList.toggle('d-none', hasResult);
        });
        if (dropdownBtn) {
            dropdownBtn.addEventListener('shown.bs.dropdown', () => searchInput.focus());
        }
    }
}

// --- 3. Thêm/Xóa/Sửa số lượng sản phẩm Combo ---
function addProductToCombo(id, name, price) {
    const existing = selectedProducts.find(p => p.id === id);
    if (existing) { existing.quantity += 1; }
    else { selectedProducts.push({ id, name, price, quantity: 1 }); }
    renderProductList();
    calculateTotal();
}

function updateQuantity(id, delta) {
    const product = selectedProducts.find(p => p.id === id);
    if (product) {
        product.quantity += delta;
        if (product.quantity <= 0) { removeProduct(id); }
        else { renderProductList(); calculateTotal(); }
    }
}

function removeProduct(id) {
    selectedProducts = selectedProducts.filter(p => p.id !== id);
    renderProductList();
    calculateTotal();
}

function renderProductList() {
    const container = document.getElementById('selectedProductsList');
    if (!container) return;
    if (selectedProducts.length === 0) {
        container.innerHTML = `<div class="text-center py-4 text-muted small">No products added yet</div>`;
        return;
    }
    container.innerHTML = selectedProducts.map(p => `
        <div class="selected-item p-3 mb-2 rounded bg-white shadow-sm border">
            <div class="d-flex justify-content-between mb-2">
                <div class="fw-bold small">${p.name}</div>
                <i class="fa-solid fa-trash-can text-danger cursor-pointer" onclick="removeProduct('${p.id}')"></i>
            </div>
            <div class="d-flex justify-content-between align-items-center">
                <div class="d-flex align-items-center bg-light rounded p-1">
                    <button type="button" class="btn btn-sm py-0" onclick="updateQuantity('${p.id}', -1)">-</button>
                    <input type="text" class="text-center border-0 bg-transparent" value="${p.quantity}" readonly style="width:30px">
                    <button type="button" class="btn btn-sm py-0" onclick="updateQuantity('${p.id}', 1)">+</button>
                </div>
                <div class="text-primary fw-bold">${(p.price * p.quantity).toLocaleString()}đ</div>
            </div>
            <input type="hidden" name="productIds" value="${p.id}">
            <input type="hidden" name="quantities" value="${p.quantity}">
        </div>
    `).join('');
}

function calculateTotal() {
    const originalPriceInput = document.getElementById('originalPrice');
    const sellingPriceInput = document.getElementById('sellingPrice');
    if (!originalPriceInput) return;
    const total = selectedProducts.reduce((sum, p) => sum + (p.price * p.quantity), 0);
    originalPriceInput.value = total;
    const isUpdate = document.getElementById('combo-data-bridge')?.getAttribute('data-is-update') === 'true';
    if (!isUpdate || total === 0) { if(sellingPriceInput) sellingPriceInput.value = total; }
}

// --- 4. Bộ lọc bảng Manage (Client-side) ---
function initStatusFilter() {
    const checkboxes = document.querySelectorAll('.status-cb');
    if (checkboxes.length === 0) return;

    // Ngăn đóng dropdown khi chọn
    document.querySelectorAll('.dropdown-menu').forEach(menu => {
        menu.addEventListener('click', (e) => e.stopPropagation());
    });

    checkboxes.forEach(cb => {
        cb.addEventListener('change', applyAllFilters);
    });
}

function initTableSearch() {
    const searchInput = document.getElementById('comboSearchInput');
    if (searchInput) {
        searchInput.addEventListener('input', applyAllFilters);
    }
}

function applyAllFilters() {
    const searchInput = document.getElementById('comboSearchInput');
    const keyword = searchInput ? searchInput.value.toLowerCase().trim() : "";
    const selectedStatuses = Array.from(document.querySelectorAll('.status-cb:checked')).map(cb => cb.value);

    const rows = document.querySelectorAll('tbody tr');
    rows.forEach(row => {
        const comboName = row.querySelector('.product-name').textContent.toLowerCase();
        const comboId = row.querySelector('td:first-child').textContent.toLowerCase();

        // Lấy từ data-status mà mình đã sửa ở JSP
        const statusBadge = row.querySelector('.status-text');
        const rowStatus = statusBadge ? statusBadge.getAttribute('data-status') : '';

        const matchesSearch = comboName.includes(keyword) || comboId.includes(keyword);
        const matchesStatus = selectedStatuses.length === 0 || selectedStatuses.includes(rowStatus);

        row.style.display = (matchesSearch && matchesStatus) ? '' : 'none';
    });
}

// --- 5. Global Functions ---
window.addProductToCombo = addProductToCombo;
window.updateQuantity = updateQuantity;
window.removeProduct = removeProduct;
window.confirmDelete = function(id, url) {
    if(confirm("Are you sure you want to delete combo " + id + "?")) window.location.href = url;
};

// Thêm vào trong document.addEventListener('DOMContentLoaded', ...) hoặc bên ngoài
// --- Hàm xử lý hiện Modal Chi tiết Combo ---
function initViewComboModal() {
    const viewButtons = document.querySelectorAll('.btn-view-combo');
    const modalBody = document.getElementById('comboModalBody');
    // Khởi tạo instance của Bootstrap Modal
    const modalElement = document.getElementById('comboDetailModal');
    if (!modalElement) return;
    const myModal = new bootstrap.Modal(modalElement);

    viewButtons.forEach(btn => {
        btn.addEventListener('click', function(e) {
            e.preventDefault();
            const comboId = this.getAttribute('data-id');

            // 1. Hiển thị trạng thái loading trong khi chờ server
            modalBody.innerHTML = `
                <div class="text-center py-5">
                    <div class="spinner-border text-primary" role="status"></div>
                    <p class="mt-2 text-muted">Đang tải dữ liệu...</p>
                </div>`;

            // 2. Mở Modal
            myModal.show();

            // 3. Fetch dữ liệu từ Controller (đảm bảo đúng URL bạn đã định nghĩa ở Controller)
            fetch(`/combos/detail-fragment/${comboId}`)
                .then(response => {
                    if (!response.ok) throw new Error("Không thể tải dữ liệu combo");
                    return response.text();
                })
                .then(html => {
                    // 4. Đổ nội dung HTML vào Modal Body
                    modalBody.innerHTML = html;
                })
                .catch(err => {
                    modalBody.innerHTML = `
                        <div class="alert alert-danger m-3">
                            <i class="fa-solid fa-triangle-exclamation me-2"></i>
                            Lỗi: ${err.message}
                        </div>`;
                    console.error("Fetch error:", err);
                });
        });
    });
}

// --- 6. Khởi tạo ---
document.addEventListener('DOMContentLoaded', function() {
    initImagePreview();
    initProductSearch();
    initStatusFilter();
    initTableSearch();
    initViewComboModal();

    const dataBridge = document.getElementById('combo-data-bridge');
    if (dataBridge && dataBridge.getAttribute('data-is-update') === 'true') {
        try {
            selectedProducts = JSON.parse(dataBridge.getAttribute('data-details'));
            renderProductList();
        } catch (e) { console.error("Parse error", e); }
    }
});