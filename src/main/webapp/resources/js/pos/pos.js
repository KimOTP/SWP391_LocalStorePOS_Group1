/* ============================================================
   POS.JS
   ============================================================ */

let cart = [];

/* ── Utilities ── */
function formatVND(amount) {
    return parseFloat(amount).toLocaleString('vi-VN') + 'đ';
}
function escapeAttr(str) {
    return String(str).replace(/\\/g, '\\\\').replace(/'/g, "\\'").replace(/"/g, '&quot;');
}
function now() {
    return new Date().toLocaleString('vi-VN');
}

/* ============================================================
   CART
   ============================================================ */
function addToCart(id, name, price, unit) {
    price = parseFloat(price);
    const item = cart.find(i => i.id === id);
    if (item) item.qty++;
    else cart.push({ id, name, price, unit: unit || '', qty: 1 });
    renderCart();
}

function increaseQty(id) {
    const item = cart.find(i => i.id === id);
    if (item) { item.qty++; renderCart(); }
}

function decreaseQty(id) {
    const item = cart.find(i => i.id === id);
    if (!item) return;
    if (item.qty > 1) item.qty--;
    else cart = cart.filter(i => i.id !== id);
    renderCart();
}

function removeFromCart(id) {
    cart = cart.filter(i => i.id !== id);
    renderCart();
}

function clearCart() {
    cart = [];
    renderCart();
}

function renderCart() {
    const list   = document.getElementById('itemList');
    const empty  = document.getElementById('emptyCart');
    const wrap   = document.getElementById('cartItems');
    const footer = document.getElementById('cartFooter');

    list.innerHTML = '';
    let total = 0;

    cart.forEach(i => {
        total += i.price * i.qty;
        list.innerHTML +=
            '<div class="cart-item">' +
                '<div class="item-info">' +
                    '<span class="item-name">' + i.name + '</span>' +
                    '<span class="item-unit">' + (i.unit || '') + '</span>' +
                '</div>' +
                '<div class="item-qty-controls">' +
                    '<button class="qty-btn" onclick="decreaseQty(\'' + i.id + '\')">−</button>' +
                    '<span class="qty-num">' + i.qty + '</span>' +
                    '<button class="qty-btn" onclick="increaseQty(\'' + i.id + '\')">+</button>' +
                '</div>' +
                '<span class="item-price">' + formatVND(i.price * i.qty) + '</span>' +
                '<button class="item-remove" onclick="removeFromCart(\'' + i.id + '\')">✕</button>' +
            '</div>';
    });

    document.getElementById('totalPrice').innerText = parseFloat(total).toLocaleString('vi-VN');

    const hasItems = cart.length > 0;
    empty.style.display  = hasItems ? 'none'  : 'flex';
    wrap.style.display   = hasItems ? 'block' : 'none';
    footer.style.display = hasItems ? 'block' : 'none';
}

/* ============================================================
   PAY – submit cart as DRAFT order → redirect to /pos/payment
   ============================================================ */
async function goToPayment() {
    if (cart.length === 0) { showToast('Cart is empty!', 'error'); return; }

    const btn = document.querySelector('.btn-pay');
    btn.disabled = true;
    btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin me-2"></i>Processing...';

    try {
        const payload = {
            items: cart.map(i => ({
                productId : i.id,
                productName: i.name,
                price     : i.price,
                quantity  : i.qty,
                unit      : i.unit
            })),
            totalAmount: cart.reduce((s, i) => s + i.price * i.qty, 0)
        };

        const res = await fetch((window.contextPath || '') + '/pos/api/checkout', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload)
        });

        if (!res.ok) throw new Error('Server error ' + res.status);

        const data = await res.json();
        if (data.success && data.orderId) {
            // Redirect to payment page with orderId
            window.location.href = (window.contextPath || '') + '/pos/payment?orderId=' + data.orderId;
        } else {
            throw new Error(data.message || 'Failed to create order');
        }
    } catch (err) {
        console.error('Checkout error:', err);
        showToast('Error: ' + err.message, 'error');
        btn.disabled = false;
        btn.innerHTML = '<i class="fa-solid fa-credit-card me-2"></i>PAY';
    }
}

/* ============================================================
   PRODUCT GRID
   ============================================================ */
function renderProductGrid(products) {
    const grid = document.getElementById('productGrid');
    grid.innerHTML = '';
    if (!products || products.length === 0) {
        grid.innerHTML = '<p style="text-align:center;width:100%;padding:20px;color:#94a3b8;grid-column:1/-1;">No products found.</p>';
        return;
    }
    products.forEach(p => {
        const card = document.createElement('div');
        card.className = 'product-card';
        card.dataset.price = p.price;
        card.setAttribute('onclick', 'addToCart(\'' + p.id + '\',\'' + escapeAttr(p.name) + '\',' + p.price + ',\'' + escapeAttr(p.unit || '') + '\')');
        card.innerHTML =
            '<div class="product-img">' +
                '<img src="' + (p.imageUrl || '/resources/img/no-image.jpg') + '"' +
                ' alt="' + escapeAttr(p.name) + '" onerror="this.src=\'/resources/img/no-image.jpg\'"/>' +
            '</div>' +
            '<div class="product-name">' + p.name + '</div>' +
            '<div class="product-unit">' + (p.unit || '') + '</div>' +
            '<div class="product-price">' + formatVND(p.price) + '</div>' +
            '<div class="add-btn">+</div>';
        grid.appendChild(card);
    });
    applyPriceFilter(); // re-apply price filter after reload
}

async function loadProducts(categoryId = null) {
    try {
        const url = categoryId
            ? (window.contextPath || '') + '/pos/api/products?categoryId=' + categoryId
            : (window.contextPath || '') + '/pos/api/products';
        const res = await fetch(url);
        renderProductGrid(await res.json());
    } catch (e) { console.error('Error loading products:', e); }
}

/* ============================================================
   PRICE RANGE FILTER
   ============================================================ */
let priceMin = 0;
let priceMax = 500000;

function initPriceSlider() {
    const minEl  = document.getElementById('priceMin');
    const maxEl  = document.getElementById('priceMax');
    const fill   = document.getElementById('rangeFill');
    const lblMin = document.getElementById('labelMin');
    const lblMax = document.getElementById('labelMax');
    const reset  = document.getElementById('btnPriceReset');

    function updateFill() {
        const min = parseInt(minEl.value);
        const max = parseInt(maxEl.value);
        const pct = (v) => (v / 500000) * 100;
        fill.style.left  = pct(min) + '%';
        fill.style.width = (pct(max) - pct(min)) + '%';
        lblMin.textContent = parseFloat(min).toLocaleString('vi-VN') + 'đ';
        lblMax.textContent = parseFloat(max).toLocaleString('vi-VN') + 'đ';
        priceMin = min;
        priceMax = max;
        reset.style.display = (min > 0 || max < 500000) ? 'flex' : 'none';
        applyPriceFilter();
    }

    minEl.addEventListener('input', () => {
        if (parseInt(minEl.value) > parseInt(maxEl.value) - 5000)
            minEl.value = parseInt(maxEl.value) - 5000;
        updateFill();
    });

    maxEl.addEventListener('input', () => {
        if (parseInt(maxEl.value) < parseInt(minEl.value) + 5000)
            maxEl.value = parseInt(minEl.value) + 5000;
        updateFill();
    });

    updateFill(); // initial render
}

function applyPriceFilter() {
    document.querySelectorAll('#productGrid .product-card').forEach(card => {
        const price = parseFloat(card.dataset.price) || 0;
        card.classList.toggle('hidden', price < priceMin || price > priceMax);
    });
}

function resetPriceFilter() {
    document.getElementById('priceMin').value = 0;
    document.getElementById('priceMax').value = 500000;
    priceMin = 0; priceMax = 500000;
    const fill   = document.getElementById('rangeFill');
    fill.style.left = '0%'; fill.style.width = '100%';
    document.getElementById('labelMin').textContent = '0đ';
    document.getElementById('labelMax').textContent = '500,000đ';
    document.getElementById('btnPriceReset').style.display = 'none';
    applyPriceFilter();
}

/* ============================================================
   PRINT TEMPLATE MODAL
   ============================================================ */
function openPrintTemplate() {
    updatePreview();
    document.getElementById('printTemplateModal').style.display = 'flex';
}
function closePrintTemplate() {
    document.getElementById('printTemplateModal').style.display = 'none';
}
function switchTab(tab) {
    document.getElementById('tab-invoice').classList.toggle('active', tab === 'invoice');
    document.getElementById('tab-report' ).classList.toggle('active', tab === 'report');
    document.getElementById('content-invoice').style.display = tab === 'invoice' ? '' : 'none';
    document.getElementById('content-report' ).style.display = tab === 'report'  ? '' : 'none';
    document.getElementById('preview-invoice').style.display = tab === 'invoice' ? '' : 'none';
    document.getElementById('preview-report' ).style.display = tab === 'report'  ? '' : 'none';
    if (tab === 'report') setText('rp-report-date', now());
}
function updatePreview() {
    const val = id => (document.getElementById(id) || {}).value || '';
    setText('rp-company', val('inv-company'));
    setText('rp-address', val('inv-address'));
    setText('rp-phone',   val('inv-phone') + ' | ' + val('inv-email'));
    setText('rp-title',   val('inv-title').toUpperCase());
    setText('rp-thanks',  val('inv-thanks'));
    setText('rp-date',    now());
}
function setText(id, text) {
    const el = document.getElementById(id);
    if (el) el.textContent = text;
}
function applyTemplate() {
    const s = {
        paperSize: document.getElementById('inv-paper-size')?.value,
        fontSize : document.getElementById('inv-font-size')?.value,
        title    : document.getElementById('inv-title')?.value,
        thanks   : document.getElementById('inv-thanks')?.value,
        company  : document.getElementById('inv-company')?.value,
        address  : document.getElementById('inv-address')?.value,
        phone    : document.getElementById('inv-phone')?.value,
        email    : document.getElementById('inv-email')?.value,
    };
    try { localStorage.setItem('posTemplateSettings', JSON.stringify(s)); } catch(_) {}

    // Also POST to server
    fetch((window.contextPath || '') + '/pos/api/print-template', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(s)
    }).catch(() => {});

    closePrintTemplate();
    showToast('Template saved!', 'success');
}

/* ============================================================
   BANK CONFIG
   ============================================================ */
function openBankConfig() { document.getElementById('bankConfigModal').style.display = 'flex'; }
function closeModal(id)   { document.getElementById(id).style.display = 'none'; }

/* ============================================================
   TOAST
   ============================================================ */
function showToast(msg, type) {
    const t = document.createElement('div');
    t.textContent = msg;
    t.style.cssText = [
        'position:fixed','bottom:24px','right:24px',
        'padding:10px 20px','border-radius:8px',
        'font-family:Inter,sans-serif','font-size:.85rem','font-weight:600',
        'color:#fff','z-index:9999','box-shadow:0 4px 14px rgba(0,0,0,.15)',
        'background:' + (type === 'success' ? '#10b981' : '#ef4444'),
        'transition:opacity .3s'
    ].join(';');
    document.body.appendChild(t);
    setTimeout(() => { t.style.opacity = '0'; setTimeout(() => t.remove(), 300); }, 2700);
}

/* ============================================================
   EVENT LISTENERS
   ============================================================ */
document.addEventListener('DOMContentLoaded', () => {

    initPriceSlider();

    // Category filter
    document.querySelector('.category-select')?.addEventListener('change', e => {
        loadProducts(e.target.value || null);
    });

    // Search
    document.querySelector('.search-box')?.addEventListener('input', async e => {
        const q = e.target.value.trim();
        if (!q) { loadProducts(); return; }
        try {
            const res = await fetch((window.contextPath || '') + '/pos/api/search?query=' + encodeURIComponent(q));
            renderProductGrid(await res.json());
        } catch(err) { console.error('Search error:', err); }
    });

    // Close modal on overlay click
    document.querySelectorAll('.pt-overlay').forEach(overlay => {
        overlay.addEventListener('click', e => {
            if (e.target === overlay) overlay.style.display = 'none';
        });
    });

    updatePreview();
});

document.getElementById('categorySelect')?.addEventListener('change', function () {
    loadProducts(this.value || null);
});

function toggleCategoryDropdown() {
    const dropdown = document.getElementById('categoryDropdown');
    dropdown.classList.toggle('active');
}

function selectCategory(id, name) {
    const dropdown = document.getElementById('categoryDropdown');
    document.getElementById('selectedCategoryText').innerText = name;
    dropdown.classList.remove('active');
    loadProducts(id || null);
}

// Click ngoài để đóng
document.addEventListener('click', function(e) {
    const dropdown = document.getElementById('categoryDropdown');
    if (!dropdown.contains(e.target)) {
        dropdown.classList.remove('active');
    }
});