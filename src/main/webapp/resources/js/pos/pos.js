/* ============================================================
   POS.JS
   ============================================================ */

let cart = [];
let restoredOrderId = null; // set khi user back từ trang payment

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
    // Trả cursor về thanh tìm kiếm
    document.getElementById('mainSearchBox')?.focus();
}

function increaseQty(id) {
    const item = cart.find(i => i.id === id);
    if (!item) return;
    item.qty++;
    // Update in-place (no full re-render)
    const qtyEl   = document.getElementById('qty-num-' + id);
    const priceEl = document.getElementById('item-price-' + id);
    if (qtyEl)   { qtyEl.textContent = item.qty; qtyEl.classList.remove('bump'); void qtyEl.offsetWidth; qtyEl.classList.add('bump'); }
    if (priceEl) { priceEl.textContent = formatVND(item.price * item.qty); priceEl.classList.remove('bump'); void priceEl.offsetWidth; priceEl.classList.add('bump'); }
    // Update total + badge only
    updateCartSummary();
}

function decreaseQty(id) {
    const item = cart.find(i => i.id === id);
    if (!item) return;
    if (item.qty > 1) {
        item.qty--;
        const qtyEl   = document.getElementById('qty-num-' + id);
        const priceEl = document.getElementById('item-price-' + id);
        if (qtyEl)   { qtyEl.textContent = item.qty; qtyEl.classList.remove('bump'); void qtyEl.offsetWidth; qtyEl.classList.add('bump'); }
        if (priceEl) { priceEl.textContent = formatVND(item.price * item.qty); priceEl.classList.remove('bump'); void priceEl.offsetWidth; priceEl.classList.add('bump'); }
        updateCartSummary();
    } else {
        removeFromCart(id);
    }
}

function updateCartSummary() {
    let total = 0, totalQty = 0;
    cart.forEach(i => { total += i.price * i.qty; totalQty += i.qty; });
    document.getElementById('totalPrice').innerText = parseFloat(total).toLocaleString('vi-VN');
    const badge = document.getElementById('cartCountBadge');
    if (badge) {
        if (totalQty > 0) {
            badge.style.display = 'inline-flex';
            badge.textContent = totalQty;
        } else {
            badge.style.display = 'none';
        }
    }
}

function removeFromCart(id) {
    cart = cart.filter(i => i.id !== id);
    renderCart();
}

function clearCart() {
    cart = [];
    restoredOrderId = null;
    renderCart();
}

function renderCart() {
    const list   = document.getElementById('itemList');
    const empty  = document.getElementById('emptyCart');
    const wrap   = document.getElementById('cartItems');
    const footer = document.getElementById('cartFooter');
    const badge  = document.getElementById('cartCountBadge');

    list.innerHTML = '';
    let total = 0;
    let totalQty = 0;

    cart.forEach(i => {
        total += i.price * i.qty;
        totalQty += i.qty;
        list.innerHTML +=
            '<div class="cart-item" id="cart-item-' + i.id + '">' +
                '<div class="item-info">' +
                    '<span class="item-name">' + i.name + '</span>' +
                    '<span class="item-unit">' + (i.unit || '') + '</span>' +
                '</div>' +
                '<div class="item-qty-controls">' +
                    '<button class="qty-btn" onclick="decreaseQty(\'' + i.id + '\')">−</button>' +
                    '<span class="qty-num" id="qty-num-' + i.id + '">' + i.qty + '</span>' +
                    '<button class="qty-btn" onclick="increaseQty(\'' + i.id + '\')">+</button>' +
                '</div>' +
                '<span class="item-price" id="item-price-' + i.id + '">' + formatVND(i.price * i.qty) + '</span>' +
                '<button class="item-remove" onclick="removeFromCart(\'' + i.id + '\')">✕</button>' +
            '</div>';
    });

    document.getElementById('totalPrice').innerText = parseFloat(total).toLocaleString('vi-VN');

    // Update badge
    if (badge) {
        if (totalQty > 0) {
            badge.style.display = 'inline-flex';
            badge.textContent = totalQty;
            badge.style.animation = 'none';
            void badge.offsetWidth;
            badge.style.animation = 'badgePop 0.25s cubic-bezier(0.34,1.56,0.64,1)';
        } else {
            badge.style.display = 'none';
        }
    }

    const hasItems = cart.length > 0;
    empty.style.display  = hasItems ? 'none'  : 'flex';
    wrap.style.display   = hasItems ? 'block' : 'none';
    footer.style.display = hasItems ? 'block' : 'none';
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
        if (p.status && p.status !== 'ACTIVE') return; // only ACTIVE
        const card = document.createElement('div');
        card.className = 'product-card';
        card.dataset.price = p.price;
        card.dataset.sku = p.id; // p.id already contains SKU-PROD-
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
    applyPriceFilter();
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
   PRICE RANGE DROPDOWN
   ============================================================ */
let priceMin = 0;
let priceMax = 0; // 0 means no upper limit

function initPriceDropdown() {
    const menu = document.getElementById('priceMenu');
    if (!menu) return;

    const ranges = [
        { min: 0, max: 0, label: 'All prices' },
        { min: 50000, max: 0, label: '> 50.000đ' },
        { min: 100000, max: 0, label: '> 100.000đ' },
        { min: 250000, max: 0, label: '> 250.000đ' },
        { min: 500000, max: 0, label: '> 500.000đ' }
    ];

    let html = '';
    ranges.forEach(r => {
        html += `<div class="pos-dropdown-item" onclick="selectPriceRange(${r.min}, ${r.max}, '${r.label}')">${r.label}</div>`;
    });
    menu.innerHTML = html;
}

function togglePriceDropdown() {
    const dd = document.getElementById('priceDropdown');
    // Close category dropdown if open
    document.getElementById('categoryDropdown')?.classList.remove('active');
    dd.classList.toggle('active');
}

function selectPriceRange(min, max, label) {
    priceMin = min;
    priceMax = max;
    document.getElementById('selectedPriceText').textContent = label;
    document.getElementById('priceDropdown').classList.remove('active');
    applyPriceFilter();
}

function applyPriceFilter() {
    applyFilters();
}

/* Master filter: combines search query + price range */
function applyFilters() {
    const box = document.getElementById('mainSearchBox') || document.querySelector('.search-box');
    const q   = (box ? box.value.trim().toLowerCase() : '');

    document.querySelectorAll('.product-card, .combo-card').forEach(card => {
        // --- search match ---
        const name = (card.querySelector('.product-name')?.textContent || '').toLowerCase();
        const sku  = (card.dataset.sku || '').toLowerCase();
        const searchOk = !q || name.includes(q) || sku.includes(q);

        // --- price match ---
        const price   = parseFloat(card.dataset.price) || 0;
        let priceOk = true;
        if (priceMin > 0 || priceMax > 0) {
            if (priceMax > 0) {
                priceOk = (price >= priceMin && price <= priceMax);
            } else {
                priceOk = (price >= priceMin);
            }
        }

        card.style.display = (searchOk && priceOk) ? '' : 'none';
    });
}

// legacy stub so old references don't break
function initPriceSlider() { initPriceDropdown(); }
function resetPriceFilter() { selectPriceRange(0, 0, 'All prices'); }

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
    Toast.fire({ icon: 'success', title: 'Template saved!' });
}

/* ============================================================
   BANK CONFIG
   ============================================================ */
function openBankConfig() { document.getElementById('bankConfigModal').style.display = 'flex'; }
function closeModal(id)   { document.getElementById(id).style.display = 'none'; }


/* ============================================================
   CHECKOUT / GO TO PAYMENT
   ============================================================ */
async function goToPayment() {
    if (cart.length === 0) {
        Toast.fire({ icon: 'error', title: 'The shopping cart is empty!' });
        return;
    }

    const btn = document.querySelector('.btn-pay');
    if (btn) {
        btn.disabled = true;
        btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin me-2"></i>Processing...';
    }

    const totalAmount = cart.reduce((sum, i) => sum + i.price * i.qty, 0);

    const payload = {
        items: cart.map(i => ({
            productId  : i.id,
            productName: i.name,
            price      : i.price,
            quantity   : i.qty,
            unit       : i.unit || ''
        })),
        totalAmount: totalAmount
    };

    try {
        // Nếu đang restore từ order cũ → update order đó, không tạo mới
        const endpoint = restoredOrderId
            ? (window.contextPath || '') + '/pos/api/update-order'
            : (window.contextPath || '') + '/pos/api/checkout';

        if (restoredOrderId) payload.orderId = restoredOrderId;

        const res  = await fetch(endpoint, {
            method : 'POST',
            headers: { 'Content-Type': 'application/json' },
            body   : JSON.stringify(payload)
        });
        const data = await res.json();

        if (data.success) {
            restoredOrderId = null;
            window.location.href = (window.contextPath || '') + '/pos/payment?orderId=' + data.orderId;
        } else {
            throw new Error(data.errorMessage || 'Checkout failed');
        }
    } catch (err) {
        Toast.fire({ icon: 'error', title: err.message });
        if (btn) {
            btn.disabled = false;
            btn.innerHTML = '<i class="fa-solid fa-credit-card me-2"></i>PAY';
        }
    }
}

/* ============================================================
   EVENT LISTENERS
   ============================================================ */
document.addEventListener('DOMContentLoaded', () => {

    // ── Restore cart nếu user back từ trang payment ──────────────────
    // Đọc từ <script type="application/json" id="posRestoreData"> — an toàn với mọi ký tự đặc biệt
    try {
        const restoreEl = document.getElementById('posRestoreData');
        if (restoreEl) {
            const restoreData = JSON.parse(restoreEl.textContent || '{}');
            const items = Array.isArray(restoreData.cartJson) ? restoreData.cartJson : [];
            const rawId = (restoreData.orderId || '').trim();

            if (items.length > 0 && rawId) {
                restoredOrderId = rawId;
                items.forEach(item => {
                    const id    = String(item.productId || '');
                    const name  = String(item.productName || '');
                    const price = parseFloat(item.unitPrice) || 0;
                    const qty   = parseInt(item.quantity)    || 1;
                    const unit  = String(item.unit || '');

                    if (!id) return;
                    const existing = cart.find(c => c.id === id);
                    if (existing) { existing.qty = qty; }
                    else { cart.push({ id, name, price, unit, qty }); }
                });
                renderCart();
                setTimeout(() => {
                    Toast.fire({ icon: 'info', title: 'Cart restored — you can edit before paying again.' });
                }, 400);
            }
        }
    } catch(e) {
        console.warn('Cart restore failed:', e);
    }

    initPriceDropdown();

    // Auto-focus search box on page load
    const searchBox = document.getElementById('mainSearchBox') || document.querySelector('.search-box');
    if (searchBox) setTimeout(() => searchBox.focus(), 100);

    // Category filter
    document.querySelector('.category-select')?.addEventListener('change', e => {
        loadProducts(e.target.value || null);
    });

    // Search – tên sản phẩm / tên combo / SKU-PROD-... / SKU-COM-...
    (document.getElementById('mainSearchBox') || document.querySelector('.search-box'))
        ?.addEventListener('input', () => applyFilters());
    // Close modal on overlay click
    document.querySelectorAll('.pt-overlay').forEach(overlay => {
        overlay.addEventListener('click', e => {
            if (e.target === overlay) overlay.style.display = 'none';
        });
    });

    // Close dropdowns on outside click
    document.addEventListener('click', function(e) {
        const categoryDD = document.getElementById('categoryDropdown');
        if (categoryDD && !categoryDD.contains(e.target)) categoryDD.classList.remove('active');
        const priceDD = document.getElementById('priceDropdown');
        if (priceDD && !priceDD.contains(e.target)) priceDD.classList.remove('active');
        const bankDD = document.getElementById('bankDropdown');
        if (bankDD && !bankDD.contains(e.target)) bankDD.classList.remove('active');
    });

    // F1 → focus search
    document.addEventListener('keydown', function(e) {
        if (e.key === 'F1') {
            e.preventDefault();
            document.getElementById('mainSearchBox')?.focus();
        }
    });

    // Enter in search box → add to cart if matching SKU
    document.getElementById('mainSearchBox')?.addEventListener('keydown', function(e) {
        if (e.key === 'Enter') {
            const q = this.value.trim().toUpperCase();
            if (!q) return;

            // Find item with exact match on data-sku OR data-id (case-insensitive)
            const cards = document.querySelectorAll('.product-card, .combo-card');
            let match = null;

            for (let card of cards) {
                const sku = (card.dataset.sku || '').toUpperCase();
                const id  = (card.dataset.id  || '').toUpperCase();
                if (sku === q || id === q) {
                    match = card;
                    break;
                }
            }

            if (match) {
                match.click();
                this.value = '';
                applyFilters();
            }
        }
    });

    updatePreview();
    initBankDropdown();
});

document.getElementById('categorySelect')?.addEventListener('change', function () {
    loadProducts(this.value || null);
});
/* ============================================================
   CATEGORY DROPDOWN HELPERS
   ============================================================ */
function toggleCategoryDropdown() {
    const dd = document.getElementById('categoryDropdown');
    document.getElementById('priceDropdown')?.classList.remove('active');
    dd.classList.toggle('active');
}

function selectCategory(id, name) {
    document.getElementById('selectedCategoryText').innerText = name;
    document.getElementById('categoryDropdown').classList.remove('active');
    loadProducts(id || null);
}

/* ============================================================
   BANK DROPDOWN
   ============================================================ */
const BANKS = [
    { code:'vietinbank', name:'VietinBank', desc:'Ngân hàng TMCP Công thương Việt Nam', logo:'https://api.vietqr.io/img/ICB.png' },
    { code:'vietcombank', name:'Vietcombank', desc:'Ngân hàng TMCP Ngoại Thương Việt Nam', logo:'https://api.vietqr.io/img/VCB.png' },
    { code:'bidv', name:'BIDV', desc:'Ngân hàng TMCP Đầu tư và Phát triển Việt Nam', logo:'https://api.vietqr.io/img/BIDV.png' },
    { code:'agribank', name:'Agribank', desc:'Ngân hàng Nông nghiệp và Phát triển Nông thôn', logo:'https://api.vietqr.io/img/VBA.png' },
    { code:'mbbank', name:'MBBank', desc:'Ngân hàng TMCP Quân đội', logo:'https://api.vietqr.io/img/MB.png' },
    { code:'techcombank', name:'Techcombank', desc:'Ngân hàng TMCP Kỹ thương Việt Nam', logo:'https://api.vietqr.io/img/TCB.png' },
    { code:'vpbank', name:'VPBank', desc:'Ngân hàng TMCP Việt Nam Thịnh Vượng', logo:'https://api.vietqr.io/img/VPB.png' },
    { code:'tpbank', name:'TPBank', desc:'Ngân hàng TMCP Tiên Phong', logo:'https://api.vietqr.io/img/TPB.png' },
    { code:'sacombank', name:'Sacombank', desc:'Ngân hàng TMCP Sài Gòn Thương Tín', logo:'https://api.vietqr.io/img/STB.png' },
    { code:'hdbank', name:'HDBank', desc:'Ngân hàng TMCP Phát triển TP. Hồ Chí Minh', logo:'https://api.vietqr.io/img/HDB.png' },
    { code:'vib', name:'VIB', desc:'Ngân hàng TMCP Quốc tế Việt Nam', logo:'https://api.vietqr.io/img/VIB.png' },
    { code:'shb', name:'SHB', desc:'Ngân hàng TMCP Sài Gòn – Hà Nội', logo:'https://api.vietqr.io/img/SHB.png' },
    { code:'eximbank', name:'Eximbank', desc:'Ngân hàng TMCP Xuất Nhập Khẩu Việt Nam', logo:'https://api.vietqr.io/img/EIB.png' },
    { code:'msb', name:'MSB', desc:'Ngân hàng TMCP Hàng Hải Việt Nam', logo:'https://api.vietqr.io/img/MSB.png' },
    { code:'acb', name:'ACB', desc:'Ngân hàng TMCP Á Châu', logo:'https://api.vietqr.io/img/ACB.png' },
    { code:'ocb', name:'OCB', desc:'Ngân hàng TMCP Phương Đông', logo:'https://api.vietqr.io/img/OCB.png' },
    { code:'seabank', name:'SeABank', desc:'Ngân hàng TMCP Đông Nam Á', logo:'https://api.vietqr.io/img/SEAB.png' },
    { code:'pvcombank', name:'PVcomBank', desc:'Ngân hàng TMCP Đại Chúng Việt Nam', logo:'https://api.vietqr.io/img/PVCB.png' },
    { code:'namabank', name:'Nam A Bank', desc:'Ngân hàng TMCP Nam Á', logo:'https://api.vietqr.io/img/NAB.png' },
    { code:'kienlongbank', name:'KienlongBank', desc:'Ngân hàng TMCP Kiên Long', logo:'https://api.vietqr.io/img/KLB.png' },
];

let selectedBank = null;

function initBankDropdown() {
    renderBankList('');
}

function renderBankList(q) {
    const list = document.getElementById('bankList');
    if (!list) return;
    list.innerHTML = '';
    BANKS.filter(b => !q || b.name.toLowerCase().includes(q.toLowerCase()) || b.desc.toLowerCase().includes(q.toLowerCase()))
        .forEach(b => {
            const div = document.createElement('div');
            div.className = 'bank-item' + (selectedBank && selectedBank.code === b.code ? ' selected' : '');
            div.innerHTML =
                '<img class="bank-item-logo" src="' + b.logo + '" alt="' + b.name +
                '" onerror="this.style.display=\'none\'">' +
                '<div class="bank-item-info">' +
                    '<div class="bank-item-name">' + b.name + '</div>' +
                    '<div class="bank-item-desc">' + b.desc + '</div>' +
                '</div>';
            div.onclick = () => chooseBank(b);
            list.appendChild(div);
        });
}

function chooseBank(b) {
    selectedBank = b;
    const content = document.getElementById('bankSelectedContent');
    content.innerHTML =
        '<img src="' + b.logo + '" alt="' + b.name + '" onerror="this.style.display=\'none\'">' +
        '<div>' +
            '<div class="bank-selected-name">' + b.name + '</div>' +
            '<div class="bank-selected-desc">' + b.desc + '</div>' +
        '</div>';
    document.getElementById('selectedBankCode').value = b.code;
    document.getElementById('bankDropdown').classList.remove('active');
}

function toggleBankDropdown() {
    const dd = document.getElementById('bankDropdown');
    dd.classList.toggle('active');
    if (dd.classList.contains('active')) {
        setTimeout(() => document.getElementById('bankSearchInput')?.focus(), 50);
        renderBankList('');
    }
}

function filterBanks(q) { renderBankList(q); }

function saveBankConfig() {
    const bankCode    = document.getElementById('selectedBankCode')?.value;
    const accountNum  = document.getElementById('bankAccountNumber')?.value?.trim();
    const accountName = document.getElementById('bankAccountName')?.value?.trim();

    if (!bankCode) { Toast.fire({ icon: 'error', title: 'Please choose a bank!' }); return; }
    if (!accountNum) { Toast.fire({ icon: 'error', title: 'Please enter account number!' }); return; }
    if (!accountName) { Toast.fire({ icon: 'error', title: 'Please enter account name!' }); return; }

    const payload = { bankCode, bankName: selectedBank?.name, accountNumber: accountNum, accountName };

    fetch((window.contextPath || '') + '/pos/api/bank-config', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
    }).catch(() => {});

    try { localStorage.setItem('posBankConfig', JSON.stringify(payload)); } catch(_) {}

    closeModal('bankConfigModal');
    Toast.fire({ icon: 'success', title: 'Bank configuration saved!' });
}

/* ============================================================
   PT-DD – Custom dropdown helpers for modal selects
   ============================================================ */
function togglePtDd(id) {
    const dd = document.getElementById(id);
    const isOpen = dd.classList.contains('active');
    // Close all pt-dd dropdowns first
    document.querySelectorAll('.pt-dd.active').forEach(el => el.classList.remove('active'));
    if (!isOpen) dd.classList.add('active');
}

function selectPtDd(ddId, value, label) {
    const dd = document.getElementById(ddId);
    // Update label
    const labelEl = document.getElementById(ddId + '-label');
    if (labelEl) labelEl.textContent = label;
    // Update hidden input
    const hiddenInput = document.getElementById(
        ddId === 'dd-paper-size' ? 'inv-paper-size' : 'inv-font-size'
    );
    if (hiddenInput) hiddenInput.value = value;
    // Mark selected item
    dd.querySelectorAll('.pt-dd-item').forEach(item => {
        item.classList.toggle('selected', item.textContent.trim() === label);
    });
    dd.classList.remove('active');
    updatePreview();
}

// Close pt-dd on outside click (merge with existing outside-click handler)
document.addEventListener('click', function(e) {
    document.querySelectorAll('.pt-dd.active').forEach(dd => {
        if (!dd.contains(e.target)) dd.classList.remove('active');
    });
});