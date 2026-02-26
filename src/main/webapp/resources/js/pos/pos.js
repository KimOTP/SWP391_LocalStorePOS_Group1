/* ============================================================
   POS.JS
   ============================================================ */

let cart = [];

/* ── Format VNĐ ── */
function formatVND(amount) {
    return parseFloat(amount).toLocaleString('vi-VN') + 'đ';
}

function escapeAttr(str) {
    return String(str).replace(/\\/g, '\\\\').replace(/'/g, "\\'").replace(/"/g, '&quot;');
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
    if (item) item.qty++;
    renderCart();
}

function decreaseQty(id) {
    const item = cart.find(i => i.id === id);
    if (!item) return;
    if (item.qty > 1) item.qty--;
    else removeFromCart(id);
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
    const items  = document.getElementById('cartItems');
    list.innerHTML = '';
    let total = 0;

    cart.forEach(i => {
        total += i.price * i.qty;
        list.innerHTML +=
            '<div class="cart-item">' +
                '<div class="item-info">' +
                    '<span class="item-name">' + i.name + '</span>' +
                    '<span class="item-unit">'  + (i.unit || '') + '</span>' +
                '</div>' +
                '<div class="item-qty-controls">' +
                    '<button class="qty-btn" onclick="decreaseQty(\'' + i.id + '\')">−</button>' +
                    '<span  class="qty-num">' + i.qty + '</span>' +
                    '<button class="qty-btn" onclick="increaseQty(\'' + i.id + '\')">+</button>' +
                '</div>' +
                '<span class="item-price">' + formatVND(i.price * i.qty) + '</span>' +
                '<button class="item-remove" onclick="removeFromCart(\'' + i.id + '\')">✕</button>' +
            '</div>';
    });

    document.getElementById('totalPrice').innerText = parseFloat(total).toLocaleString('vi-VN');
    empty.style.display  = cart.length === 0 ? 'block' : 'none';
    items.style.display  = cart.length === 0 ? 'none'  : 'block';
}

/* ============================================================
   PRODUCT GRID
   ============================================================ */
function renderProductGrid(products) {
    const grid = document.querySelector('.product-grid');
    grid.innerHTML = '';
    if (!products || products.length === 0) {
        grid.innerHTML = '<p style="text-align:center;width:100%;padding:20px;color:#94a3b8;">Không tìm thấy sản phẩm</p>';
        return;
    }
    products.forEach(p => {
        const card = document.createElement('div');
        card.className = 'product-card';
        card.setAttribute('onclick', 'addToCart(\'' + p.id + '\',\'' + escapeAttr(p.name) + '\',' + p.price + ',\'' + escapeAttr(p.unit || '') + '\')');
        card.innerHTML =
            '<div class="product-img">' +
                '<img src="' + (p.imageUrl || '/resources/img/no-image.jpg') + '"' +
                ' alt="' + escapeAttr(p.name) + '"' +
                ' onerror="this.src=\'/resources/img/no-image.jpg\'" />' +
            '</div>' +
            '<div class="product-name">' + p.name + '</div>' +
            '<div class="product-unit">' + (p.unit || '') + '</div>' +
            '<div class="product-price">' + formatVND(p.price) + '</div>' +
            '<div class="add-btn">+</div>';
        grid.appendChild(card);
    });
}

async function loadProducts(categoryId = null) {
    try {
        const url = categoryId ? '/pos/api/products?categoryId=' + categoryId : '/pos/api/products';
        const res = await fetch(url);
        renderProductGrid(await res.json());
    } catch (e) { console.error('Error loading products:', e); }
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
    // Toggle tab buttons
    document.getElementById('tab-invoice').classList.toggle('active', tab === 'invoice');
    document.getElementById('tab-report' ).classList.toggle('active', tab === 'report');

    // Toggle form content
    document.getElementById('content-invoice').style.display = tab === 'invoice' ? '' : 'none';
    document.getElementById('content-report' ).style.display = tab === 'report'  ? '' : 'none';

    // Toggle preview
    document.getElementById('preview-invoice').style.display = tab === 'invoice' ? '' : 'none';
    document.getElementById('preview-report' ).style.display = tab === 'report'  ? '' : 'none';

    // Set report date
    if (tab === 'report') {
        const d = document.getElementById('rp-report-date');
        if (d) d.textContent = now();
    }
}

function now() {
    return new Date().toLocaleString('vi-VN');
}

/* Live-update the receipt preview while user types */
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

/* Apply: saves settings (demo: localStorage) then optionally opens print dialog */
function applyTemplate() {
    const settings = {
        paperSize : document.getElementById('inv-paper-size')?.value,
        fontSize  : document.getElementById('inv-font-size')?.value,
        title     : document.getElementById('inv-title')?.value,
        thanks    : document.getElementById('inv-thanks')?.value,
        company   : document.getElementById('inv-company')?.value,
        address   : document.getElementById('inv-address')?.value,
        phone     : document.getElementById('inv-phone')?.value,
        email     : document.getElementById('inv-email')?.value,
    };
    try { localStorage.setItem('posTemplateSettings', JSON.stringify(settings)); } catch(_) {}
    closePrintTemplate();

    // Show success toast
    showToast('Template saved successfully!', 'success');
}

/* ============================================================
   PAY & PRINT  –  builds receipt HTML then calls window.print()
   ============================================================ */
function openPayAndPrint() {
    if (cart.length === 0) { showToast('Cart is empty!', 'error'); return; }

    // Load saved settings
    let s = {};
    try { s = JSON.parse(localStorage.getItem('posTemplateSettings') || '{}'); } catch(_) {}

    const company = s.company || 'Local store POS system';
    const address = s.address || '';
    const phone   = s.phone   || '';
    const email   = s.email   || '';
    const title   = (s.title  || 'SALES INVOICE').toUpperCase();
    const thanks  = s.thanks  || 'Thank you for your purchase.';

    let itemRows = '';
    let total = 0;
    cart.forEach(i => {
        total += i.price * i.qty;
        itemRows +=
            '<tr>' +
            '<td>' + i.name + ' x' + i.qty + '</td>' +
            '<td class="r">' + formatVND(i.price * i.qty) + '</td>' +
            '</tr>';
    });

    const printArea = document.getElementById('printArea');
    printArea.innerHTML =
        '<div class="pr-logo">LOGO</div>' +
        '<div class="pr-company">' + company + '</div>' +
        '<div class="pr-addr">'    + address  + '</div>' +
        '<div class="pr-phone">'   + phone + (email ? ' | ' + email : '') + '</div>' +
        '<div class="pr-dash">- - - - - - - - - - - - - - -</div>' +
        '<div class="pr-title">'   + title + '</div>' +
        '<div class="pr-date">'    + now()  + '</div>' +
        '<div class="pr-dash">- - - - - - - - - - - - - - -</div>' +
        '<table class="pr-items"><tbody>' + itemRows + '</tbody></table>' +
        '<div class="pr-dash">- - - - - - - - - - - - - - -</div>' +
        '<div class="pr-total"><span>Total</span><span>' + formatVND(total) + '</span></div>' +
        '<div class="pr-dash">- - - - - - - - - - - - - - -</div>' +
        '<div class="pr-thanks">' + thanks + '</div>' +
        '<div class="pr-barcode">||| ||||||||||||||||||||||</div>';

    window.print();
}

/* ============================================================
   BANK CONFIG MODAL
   ============================================================ */
function openBankConfig() {
    document.getElementById('bankConfigModal').style.display = 'flex';
}

function closeModal(id) {
    document.getElementById(id).style.display = 'none';
}

/* ============================================================
   TOAST NOTIFICATION
   ============================================================ */
function showToast(msg, type) {
    const t = document.createElement('div');
    t.textContent = msg;
    t.style.cssText = [
        'position:fixed', 'bottom:24px', 'right:24px',
        'padding:10px 20px', 'border-radius:8px',
        'font-family:Inter,sans-serif', 'font-size:.85rem', 'font-weight:600',
        'color:#fff', 'z-index:9999', 'box-shadow:0 4px 14px rgba(0,0,0,.15)',
        'background:' + (type === 'success' ? '#10b981' : '#ef4444'),
        'animation:fadeIn .25s ease'
    ].join(';');
    document.body.appendChild(t);
    setTimeout(() => t.remove(), 3000);
}

/* ============================================================
   EVENT LISTENERS
   ============================================================ */
document.addEventListener('DOMContentLoaded', () => {

    // Category filter
    document.querySelector('.category-select')?.addEventListener('change', e => {
        loadProducts(e.target.value || null);
    });

    // Search
    document.querySelector('.search-box')?.addEventListener('input', async e => {
        const q = e.target.value.trim();
        if (!q) { loadProducts(); return; }
        try {
            const res = await fetch('/pos/api/search?query=' + encodeURIComponent(q));
            renderProductGrid(await res.json());
        } catch(err) { console.error('Search error:', err); }
    });

    // Close modals by clicking overlay
    document.querySelectorAll('.pt-overlay').forEach(overlay => {
        overlay.addEventListener('click', e => {
            if (e.target === overlay) overlay.style.display = 'none';
        });
    });

    // Set today's date in preview on open
    updatePreview();
});