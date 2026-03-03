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
                newImg.style.width = '100%';
                newImg.style.height = '100%';
                newImg.style.objectFit = 'cover';
                newImg.style.display = 'block';
                newImg.style.borderRadius = '10px';
                container.appendChild(newImg);

                newImg.onload = () => URL.revokeObjectURL(imgUrl);
            }
        });
    }
}

// --- 2. Logic Thêm/Xóa/Cập nhật số lượng sản phẩm ---
function addProductToCombo(id, name, price) {
    const existing = selectedProducts.find(p => p.id === id);
    if (existing) {
        // Nếu sản phẩm đã có, tăng số lượng lên 1
        existing.quantity += 1;
    } else {
        // Nếu chưa có, thêm mới với quantity = 1
        selectedProducts.push({ id, name, price, quantity: 1 });
    }
    renderProductList();
    calculateTotal();
}

// Hàm tăng giảm số lượng
function updateQuantity(id, delta) {
    const product = selectedProducts.find(p => p.id === id);
    if (product) {
        product.quantity += delta;
        // Nếu số lượng về 0 thì xóa sản phẩm khỏi danh sách
        if (product.quantity <= 0) {
            removeProduct(id);
        } else {
            renderProductList();
            calculateTotal();
        }
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
        container.innerHTML = `
            <div class="empty-state text-center py-4 text-muted small">
                <i class="fa-solid fa-box-open d-block mb-2 fs-4"></i>
                No products added yet
            </div>`;
        return;
    }

    // Render danh sách sản phẩm kèm bộ nút cộng trừ
    container.innerHTML = selectedProducts.map(p => `
        <div class="selected-item p-3 mb-2 rounded bg-white shadow-sm border">
            <div class="d-flex justify-content-between align-items-start mb-2">
                <div class="fw-bold small text-dark" style="max-width: 70%">${p.name}</div>
                <i class="fa-solid fa-trash-can text-danger small cursor-pointer"
                   onclick="removeProduct('${p.id}')" style="cursor: pointer;"></i>
            </div>

            <div class="d-flex justify-content-between align-items-center">
                <div class="quantity-control d-flex align-items-center bg-light rounded-2 p-1" style="border: 1px solid #dee2e6;">
                    <button type="button" class="btn btn-sm btn-light py-0 px-2 fw-bold"
                            onclick="updateQuantity('${p.id}', -1)">-</button>
                    <input type="text" class="qty-input border-0 bg-transparent text-center fw-bold"
                           value="${p.quantity}" readonly style="width: 30px; font-size: 13px;">
                    <button type="button" class="btn btn-sm btn-light py-0 px-2 fw-bold"
                            onclick="updateQuantity('${p.id}', 1)">+</button>
                </div>
                <div class="text-primary fw-bold small">
                    ${(p.price * p.quantity).toLocaleString()}đ
                </div>
            </div>

            <input type="hidden" name="productIds" value="${p.id}">
            <input type="hidden" name="quantities" value="${p.quantity}">
        </div>
    `).join('');
}

function calculateTotal() {
    const originalPriceInput = document.getElementById('originalPrice');
    const sellingPriceInput = document.getElementById('sellingPrice');

    if (!originalPriceInput || !sellingPriceInput) return;

    // Tính tổng dựa trên (đơn giá * số lượng)
    const total = selectedProducts.reduce((sum, p) => sum + (p.price * p.quantity), 0);
    originalPriceInput.value = total;

    // Tự động cập nhật giá bán nếu chưa nhập gì hoặc giá bán cũ bằng giá gốc cũ
    sellingPriceInput.value = total;
}

// --- 3. Xử lý Giảm giá nhanh ---
function applyDiscount(percent) {
    const originalPriceInput = document.getElementById('originalPrice');
    const sellingPriceInput = document.getElementById('sellingPrice');

    const total = parseFloat(originalPriceInput.value) || 0;
    if (total === 0) {
        alert("Please add products first!");
        return;
    }

    const discountedPrice = total * (1 - (percent / 100));
    sellingPriceInput.value = Math.round(discountedPrice);
}

// --- 4. Khởi tạo khi DOM sẵn sàng ---
document.addEventListener('DOMContentLoaded', function() {
    initImagePreview();
    renderProductList();

    const comboForm = document.getElementById('comboForm');
    if(comboForm) comboForm.reset();
});