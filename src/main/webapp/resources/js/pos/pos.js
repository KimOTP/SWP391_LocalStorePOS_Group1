let cart = [];

function addToCart(id, name, price) {
    price = parseFloat(price);
    let item = cart.find(i => i.id === id);
    if (item) item.qty++;
    else cart.push({id, name, price, qty: 1});
    renderCart();
}

function addToCart(id, name, price) {
    price = parseFloat(price);
    let item = cart.find(i => i.id === id);
    if (item) item.qty++;
    else cart.push({id, name, price, qty: 1});
    renderCart();
}

// Bọc tất cả event listeners vào đây
document.addEventListener('DOMContentLoaded', function () {

    // ===== CATEGORY FILTER =====
    document.querySelector('.category-select')?.addEventListener('change', async (e) => {
        const categoryId = e.target.value;
        if (categoryId === '') {
            loadProducts();
        } else {
            loadProducts(categoryId);
        }
    });

    // ===== SEARCH =====
    document.querySelector('.search-box')?.addEventListener('input', async (e) => {
        const query = e.target.value.trim();
        if (query.length === 0) {
            loadProducts();
            return;
        }
        try {
            const response = await fetch('/pos/api/search?query=' + encodeURIComponent(query));
            const products = await response.json();
            const productGrid = document.querySelector('.product-grid');
            productGrid.innerHTML = '';
            if (products.length === 0) {
                productGrid.innerHTML = '<p style="text-align:center;width:100%;padding:20px;">Không tìm thấy sản phẩm</p>';
                return;
            }
            products.forEach(p => {
                const productCard = document.createElement('div');
                productCard.className = 'product-card';
                productCard.innerHTML =
                    '<div class="product-img" style="background-size:cover; background-position:center; background-image: url(\'' + (p.imageUrl || '/resources/img/no-image.jpg') + '\')"></div>' +
                    '<div class="product-name">' + p.name + '</div>' +
                    '<div class="product-price">$' + parseFloat(p.price).toLocaleString() + '</div>' +
                    '<div class="add-btn" onclick="addToCart(\'' + p.id + '\',\'' + p.name + '\',' + p.price + ')">+</div>';
                productGrid.appendChild(productCard);
            });
        } catch (error) {
            console.error('Error Searching Product:', error);
        }
    });

});

// ===== CÁC HÀM CÒN LẠI GIỮ NGUYÊN BÊN NGOÀI =====
async function loadProducts(categoryId = null) {
    try {
        let url = '/pos/api/products';
        if (categoryId) {
            url += '?categoryId=' + categoryId;
        }
        const response = await fetch(url);
        const products = await response.json();
        const productGrid = document.querySelector('.product-grid');
        productGrid.innerHTML = '';
        products.forEach(p => {
            const productCard = document.createElement('div');
            productCard.className = 'product-card';
            productCard.innerHTML =
                '<div class="product-img" style="background-size:cover; background-position:center; background-image: url(\'' + (p.imageUrl || '/resources/img/no-image.jpg') + '\')"></div>' +
                '<div class="product-name">' + p.name + '</div>' +
                '<div class="product-price">$' + parseFloat(p.price).toLocaleString() + '</div>' +
                '<div class="add-btn" onclick="addToCart(\'' + p.id + '\',\'' + p.name + '\',' + p.price + ')">+</div>';
            productGrid.appendChild(productCard);
        });
    } catch (error) {
        console.error('Error Loading Products:', error);
    }
}

async function loadCategories() {
    try {
        const response = await fetch('/pos/api/categories');
        const categories = await response.json();
        const categorySelect = document.querySelector('.category-select');
        categories.forEach(cat => {
            const option = document.createElement('option');
            option.value = cat.categoryId;
            option.textContent = cat.categoryName;
            categorySelect.appendChild(option);
        });
    } catch (error) {
        console.error('Error Loading Category:', error);
    }
}

async function loadProducts(categoryId = null) {
    try {
        let url = '/pos/api/products';
        if (categoryId) {
            url += '?categoryId=' + categoryId;
        }
        const response = await fetch(url);
        const products = await response.json();
        const productGrid = document.querySelector('.product-grid');
        productGrid.innerHTML = '';
        products.forEach(p => {
            const productCard = document.createElement('div');
            productCard.className = 'product-card';
            productCard.innerHTML =
                '<div class="product-img" style="background-size:cover; background-position:center; background-image: url(\'' + (p.imageUrl || '/resources/img/no-image.jpg') + '\')"></div>' +
                '<div class="product-name">' + p.name + '</div>' +
                '<div class="product-price">$' + parseFloat(p.price).toLocaleString() + '</div>' +
                '<div class="add-btn" onclick="addToCart(\'' + p.id + '\',\'' + p.name + '\',' + p.price + ')">+</div>';
            productGrid.appendChild(productCard);
        });
    } catch (error) {
        console.error('Error Loading Products:', error);
    }
}

function increaseQty(id) {
    const item = cart.find(i => i.id === id);
    if (item) item.qty++;
    renderCart();
}

function decreaseQty(id) {
    const item = cart.find(i => i.id === id);
    if (item && item.qty > 1) item.qty--;
    else if (item && item.qty === 1) removeFromCart(id);
    renderCart();
}

function removeFromCart(id) {
    cart = cart.filter(i => i.id !== id);
    renderCart();
}

function renderCart() {
    const list = document.getElementById("itemList");
    const empty = document.getElementById("emptyCart");
    const items = document.getElementById("cartItems");
    list.innerHTML = "";
    let total = 0;
    cart.forEach(i => {
        total += i.price * i.qty;
        list.innerHTML +=
            '<div class="cart-item">' +
                '<span class="item-name">' + i.name + '</span>' +
                '<div class="item-qty-controls">' +
                    '<button class="qty-btn" onclick="decreaseQty(\'' + i.id + '\')">−</button>' +
                    '<span class="qty-num">' + i.qty + '</span>' +
                    '<button class="qty-btn" onclick="increaseQty(\'' + i.id + '\')">+</button>' +
                '</div>' +
                '<span class="item-price">$' + (i.price * i.qty).toLocaleString() + '</span>' +
                '<button class="item-remove" onclick="removeFromCart(\'' + i.id + '\')">✕</button>' +
            '</div>';
    });
    document.getElementById("totalPrice").innerText = total.toLocaleString();
    empty.style.display = cart.length === 0 ? "block" : "none";
    items.style.display = cart.length === 0 ? "none" : "block";
}

function clearCart() {
    cart = [];
    renderCart();
}

function openPrintTemplate() {
    if (window.userRole !== 'MANAGER') return alert('Permission denied');
    document.getElementById('printTemplateModal').style.display = 'flex';
}

function openBankConfig() {
    if (window.userRole !== 'MANAGER') return alert('Permission denied');
    document.getElementById('bankConfigModal').style.display = 'flex';
}

function closeModal(id) {
    document.getElementById(id).style.display = 'none';
}