/* ============================================================
   PAYMENT.JS
   ============================================================ */

/* ── Utilities ── */
function formatVND(amount) {
    return parseFloat(amount || 0).toLocaleString('vi-VN') + 'đ';
}
function parseVND(str) {
    return parseFloat(String(str).replace(/[^\d]/g, '')) || 0;
}

/* ── State ── */
let grandTotal    = parseFloat(window.totalAmount || 0);
let discountAmt   = 0;
let loyaltyUsed   = 0;
let loyaltyAvail  = 0;   // will be populated from customer lookup
let currentMethod = 'cash';

/* ── Live clock ── */
function startClock() {
    const el = document.getElementById('liveClock');
    function tick() {
        const now = new Date();
        const days = ['Chủ nhật','Thứ 2','Thứ 3','Thứ 4','Thứ 5','Thứ 6','Thứ 7'];
        el.innerHTML =
            now.toLocaleTimeString('vi-VN') + '<br>' +
            days[now.getDay()] + ', ' +
            now.toLocaleDateString('vi-VN');
    }
    tick();
    setInterval(tick, 1000);
}

/* ── Totals ── */
function updateTotals() {
    const net = Math.max(0, grandTotal - discountAmt - loyaltyUsed);
    document.getElementById('grandTotalVal').textContent = formatVND(net);
    document.getElementById('discountVal').textContent   = '−' + formatVND(discountAmt + loyaltyUsed);
    document.getElementById('qrAmount').textContent      = formatVND(net);
    calcChange(document.getElementById('customerPaid')?.value || '0');
}

/* ── Cash change ── */
function calcChange(paidStr) {
    const paid   = parseVND(paidStr);
    const net    = Math.max(0, grandTotal - discountAmt - loyaltyUsed);
    const change = paid >= net ? paid - net : 0;
    const el = document.getElementById('changeAmount');
    if (el) {
        el.value = parseFloat(change).toLocaleString('vi-VN');
        el.style.color = change > 0 ? '#10b981' : '#1e293b';
    }
}

/* ── Payment method toggle ── */
function onPayMethodChange(radio) {
    currentMethod = radio.value;
    const cashSection = document.getElementById('cashSection');
    cashSection.style.display = currentMethod === 'cash' ? '' : 'none';
    updateQR();
}

/* ── Customer lookup (stub – wire to your API) ── */
let lookupTimer;
function lookupCustomer(phone) {
    clearTimeout(lookupTimer);
    if (phone.length < 9) return;
    lookupTimer = setTimeout(async () => {
        try {
            const res  = await fetch((window.contextPath || '') + '/pos/api/customer?phone=' + encodeURIComponent(phone));
            if (!res.ok) return;
            const data = await res.json();
            if (data.success && data.customer) {
                document.getElementById('customerName').value  = data.customer.name || '';
                loyaltyAvail = parseInt(data.customer.loyaltyPoints || 0);
                document.getElementById('loyaltyPoints').value = loyaltyAvail + ' pts';
                document.getElementById('loyaltyAvail').textContent = 'Available: ' + loyaltyAvail + ' pts';
            }
        } catch(_) {}
    }, 500);
}

/* ── Loyalty points ── */
function applyLoyaltyPoints(val) {
    const pts = Math.min(parseInt(val) || 0, loyaltyAvail);
    // Assume 1 point = 1 VND (adjust ratio per business logic)
    loyaltyUsed = pts;
    updateTotals();
}

/* ── QR Code (VietQR) ── */
function updateQR() {
    if (currentMethod !== 'bank') {
        document.getElementById('qrPlaceholder').style.display = 'flex';
        document.getElementById('qrImg').style.display = 'none';
        return;
    }
    const bank    = window.bankSettings || {};
    const accNum  = bank.accNumber || '';
    const accName = bank.accName   || '';
    const bankId  = bank.bankName  || 'MB';
    const amount  = Math.max(0, grandTotal - discountAmt - loyaltyUsed);

    document.getElementById('qrAccNumber').textContent = accNum  || '–';
    document.getElementById('qrAccName').textContent   = accName || '–';
    document.getElementById('qrBankLabel').textContent = bankId;

    if (!accNum) {
        document.getElementById('qrPlaceholder').style.display = 'flex';
        document.getElementById('qrImg').style.display = 'none';
        return;
    }

    // VietQR API
    const qrUrl = 'https://img.vietqr.io/image/' +
        encodeURIComponent(bankId) + '-' +
        encodeURIComponent(accNum) + '-compact2.png' +
        '?amount=' + amount +
        '&addInfo=' + encodeURIComponent('Thanh toan don hang ' + (window.orderId || '')) +
        '&accountName=' + encodeURIComponent(accName);

    const img = document.getElementById('qrImg');
    img.onload = () => {
        document.getElementById('qrPlaceholder').style.display = 'none';
        img.style.display = 'block';
    };
    img.onerror = () => {
        document.getElementById('qrPlaceholder').style.display = 'flex';
        img.style.display = 'none';
    };
    img.src = qrUrl;
}

/* ── Cancel order ── */
async function cancelOrder() {
    if (!confirm('Cancel this order?')) return;
    try {
        await fetch((window.contextPath || '') + '/pos/api/order/' + window.orderId + '/cancel', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' }
        });
    } catch(_) {}
    window.location.href = (window.contextPath || '') + '/pos';
}

/* ── Confirm payment ── */
async function confirmPayment() {
    const btn = document.querySelector('.pay-btn-pay');
    btn.disabled = true;
    btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin me-1"></i> Processing...';

    const method    = currentMethod;
    const paid      = parseVND(document.getElementById('customerPaid')?.value || '0');
    const note      = document.getElementById('orderNote')?.value || '';
    const custPhone = document.getElementById('customerPhone')?.value || '';
    const custName  = document.getElementById('customerName')?.value  || '';
    const usePoints = parseInt(document.getElementById('usePoints')?.value || '0');
    const net       = Math.max(0, grandTotal - discountAmt - loyaltyUsed);

    if (method === 'cash' && paid < net) {
        showToast('Số tiền khách đưa chưa đủ!', 'error');
        btn.disabled = false;
        btn.innerHTML = '<i class="fa-solid fa-check me-1"></i> Pay';
        return;
    }

    const payload = {
        orderId        : window.orderId,
        paymentMethod  : method,
        customerPaid   : paid,
        discount       : discountAmt,
        loyaltyUsed    : usePoints,
        totalPaid      : net,
        note           : note,
        customerPhone  : custPhone,
        customerName   : custName,
    };

    try {
        const res  = await fetch((window.contextPath || '') + '/pos/api/payment/confirm', {
            method : 'POST',
            headers: { 'Content-Type': 'application/json' },
            body   : JSON.stringify(payload)
        });
        const data = await res.json();

        if (data.success) {
            showToast('Payment successful!', 'success');
            // Optionally trigger print
            setTimeout(() => {
                window.location.href = (window.contextPath || '') + '/pos';
            }, 1200);
        } else {
            throw new Error(data.message || 'Payment failed');
        }
    } catch (err) {
        showToast('Error: ' + err.message, 'error');
        btn.disabled = false;
        btn.innerHTML = '<i class="fa-solid fa-check me-1"></i> Pay';
    }
}

/* ── Toast ── */
function showToast(msg, type) {
    const t = document.createElement('div');
    t.textContent = msg;
    t.style.cssText = [
        'position:fixed','bottom:24px','right:24px',
        'padding:10px 22px','border-radius:9px',
        'font-family:Inter,sans-serif','font-size:.875rem','font-weight:600',
        'color:#fff','z-index:9999','box-shadow:0 4px 14px rgba(0,0,0,.15)',
        'background:' + (type === 'success' ? '#10b981' : '#ef4444'),
        'transition:opacity .3s'
    ].join(';');
    document.body.appendChild(t);
    setTimeout(() => { t.style.opacity = '0'; setTimeout(() => t.remove(), 300); }, 2700);
}

/* ── INIT ── */
document.addEventListener('DOMContentLoaded', () => {
    startClock();
    updateTotals();

    // Show QR if bank method is pre-selected
    onPayMethodChange(document.querySelector('input[name="payMethod"]:checked'));
});