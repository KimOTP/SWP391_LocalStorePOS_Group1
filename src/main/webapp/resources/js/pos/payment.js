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
let discountAmt   = parseFloat(window.summaryData?.totalDiscount || 0);
let loyaltyUsed   = 0;
let loyaltyAvail  = 0;   // will be populated from customer lookup
let currentMethod = 'cash';

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

    // Reset QR status badge nếu chuyển phương thức
    stopQrPolling();
    const badge = document.getElementById('qrStatusBadge');
    if (badge) badge.style.display = 'none';

    // Reset nút Pay
    const btn = document.querySelector('.pay-btn-pay');
    if (btn) { btn.disabled = false; btn.innerHTML = '<i class="fa-solid fa-check me-1"></i> Pay'; }

    updateQR();
}

/* ── Customer lookup state machine ── */
// States: 'idle' | 'found' | 'notfound' | 'adding'
let currentCustomer = null;

function setCustState(state) {
    ['custStateIdle','custStateFound','custStateNotFound','custAddForm'].forEach(id => {
        const el = document.getElementById(id);
        if (el) el.style.display = 'none';
    });
    const map = {
        idle     : 'custStateIdle',
        found    : 'custStateFound',
        notfound : 'custStateNotFound',
        adding   : 'custAddForm'
    };
    const target = document.getElementById(map[state]);
    if (target) target.style.display = '';
}

let lookupTimer;
function lookupCustomer(phone) {
    clearTimeout(lookupTimer);
    const spinner  = document.getElementById('phoneSpinner');
    const phoneIcon = document.getElementById('phoneIcon');

    // Reset nếu xoá hết số
    if (!phone || phone.length < 10) {
        currentCustomer = null;
        loyaltyAvail = 0;
        loyaltyUsed  = 0;
        updateTotals();
        setCustState('idle');
        return;
    }

    // Show spinner
    if (spinner)   spinner.style.display   = '';
    if (phoneIcon) phoneIcon.style.display = 'none';

    lookupTimer = setTimeout(async () => {
        try {
            const res  = await fetch((window.contextPath || '') + '/pos/api/customer?phone=' + encodeURIComponent(phone));
            const data = await res.json();

            if (data.found && data.customer) {
                const c = data.customer;
                currentCustomer = c;

                // Điền thông tin vào state FOUND
                document.getElementById('custFoundName').textContent   = c.fullName   || '–';
                document.getElementById('custFoundPhone').textContent  = c.phoneNumber || phone;
                document.getElementById('custFoundPoints').textContent = c.currentPoint ?? 0;
                document.getElementById('custAvatar').textContent      = (c.fullName || 'K').charAt(0).toUpperCase();
                document.getElementById('customerName').value          = c.fullName   || '';
                document.getElementById('customerId').value            = c.customerId || '';

                loyaltyAvail = parseInt(c.currentPoint || 0);
                document.getElementById('loyaltyPoints') && (document.getElementById('loyaltyPoints').value = loyaltyAvail + ' pts');
                document.getElementById('usePoints').max               = loyaltyAvail;

                populateCustomerPoints();
                setCustState('found');
            } else {
                currentCustomer = null;
                document.getElementById('customerId').value = '';
                loyaltyAvail = 0;
                loyaltyUsed  = 0;
                updateTotals();
                setCustState('notfound');
            }
        } catch(_) {
            setCustState('idle');
        } finally {
            if (spinner)   spinner.style.display   = 'none';
            if (phoneIcon) phoneIcon.style.display = '';
        }
    }, 500);
}

function clearCustomer() {
    currentCustomer = null;
    document.getElementById('customerPhone').value = '';
    document.getElementById('customerId').value    = '';
    const nameEl = document.getElementById('customerName');
    if (nameEl) nameEl.value = '';
    const useEl = document.getElementById('usePoints');
    if (useEl) { useEl.value = ''; useEl.disabled = false; }
    const availEl = document.getElementById('loyaltyAvail');
    if (availEl) availEl.textContent = '= 0đ';
    const warnEl = document.getElementById('custPointWarn');
    if (warnEl) warnEl.style.display = 'none';
    loyaltyAvail = 0;
    loyaltyUsed  = 0;
    updateTotals();
    setCustState('idle');
}

function openAddCustomer() {
    const phone = document.getElementById('customerPhone').value.trim();
    document.getElementById('newCustPhone').value = phone;
    document.getElementById('newCustName').value  = '';
    setCustState('adding');
}

function cancelAddCustomer() {
    setCustState('notfound');
}

async function saveNewCustomer() {
    const phone    = document.getElementById('newCustPhone').value.trim();
    const fullName = document.getElementById('newCustName').value.trim();

    if (!fullName) {
        showToast('Please enter customer name', 'error');
        return;
    }

    const saveBtn = document.querySelector('.cust-save-btn');
    saveBtn.disabled = true;
    saveBtn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Saving...';

    try {
        const res  = await fetch((window.contextPath || '') + '/pos/api/customer/quick-add', {
            method : 'POST',
            headers: { 'Content-Type': 'application/json' },
            body   : JSON.stringify({ phone, fullName })
        });
        const data = await res.json();

        if (data.success && data.customer) {
            const c = data.customer;
            currentCustomer = c;

            document.getElementById('custFoundName').textContent   = c.fullName   || '–';
            document.getElementById('custFoundPhone').textContent  = c.phoneNumber || phone;
            document.getElementById('custAvatar').textContent      = (c.fullName || 'K').charAt(0).toUpperCase();
            document.getElementById('customerName').value          = c.fullName   || '';
            document.getElementById('customerId').value            = c.customerId || '';

            loyaltyAvail = 0;
            loyaltyUsed  = 0;
            populateCustomerPoints();
            updateTotals();

            setCustState('found');
            showToast('Customer added successfully!', 'success');
        } else {
            showToast(data.message || 'Failed to add customer', 'error');
        }
    } catch(e) {
        showToast('Error: ' + e.message, 'error');
    } finally {
        saveBtn.disabled = false;
        saveBtn.innerHTML = '<i class="fa-solid fa-floppy-disk"></i> Save';
    }
}

/* ── Loyalty points ── */
/* ── Point config helpers ── */
function getPointConfig() {
    return window.pointConfig || {
        earningRate: 10000, redemptionValue: 1000,
        maxRedeemPercent: 30, minPointToRedeem: 100
    };
}

// Tính số điểm tối đa được phép dùng trong đơn này
function calcMaxRedeemPoints() {
    const cfg    = getPointConfig();
    const net    = Math.max(0, grandTotal - discountAmt);           // trước khi trừ điểm
    const maxVND = net * (cfg.maxRedeemPercent / 100);              // VNĐ tối đa được trừ
    const maxByPercent = Math.floor(maxVND / cfg.redemptionValue);  // quy ra điểm
    return Math.min(loyaltyAvail, maxByPercent);                    // không vượt số điểm có
}

// Render phần thông tin điểm khi tìm thấy khách hàng
function populateCustomerPoints() {
    const cfg      = getPointConfig();
    const maxPts   = calcMaxRedeemPoints();
    const canRedeem = loyaltyAvail >= cfg.minPointToRedeem;

    // Badge điểm trên found-card
    const foundPtsEl = document.getElementById('custFoundPoints');
    if (foundPtsEl) foundPtsEl.textContent = loyaltyAvail.toLocaleString('vi-VN');

    // Summary panel
    const pointDisplayEl   = document.getElementById('custPointDisplay');
    const maxRedeemEl      = document.getElementById('custMaxRedeemDisplay');
    const configHintEl     = document.getElementById('custPointConfigHint');
    const usePointsEl      = document.getElementById('usePoints');

    if (pointDisplayEl) {
        pointDisplayEl.textContent = loyaltyAvail.toLocaleString('vi-VN') + ' pts';
    }

    if (maxRedeemEl) {
        if (!canRedeem) {
            maxRedeemEl.textContent = '0 pts (min ' + cfg.minPointToRedeem + ' pts required)';
            maxRedeemEl.style.color = '#94a3b8';
        } else {
            maxRedeemEl.textContent = maxPts.toLocaleString('vi-VN') + ' pts = ' + formatVND(maxPts * cfg.redemptionValue);
            maxRedeemEl.style.color = '#2563eb';
        }
    }

    if (configHintEl) {
        configHintEl.innerHTML =
            '<i class="fa-solid fa-circle-info"></i> ' +
            '1 pt = <strong>' + formatVND(cfg.redemptionValue) + '</strong>' +
            ' &nbsp;·&nbsp; Max <strong>' + cfg.maxRedeemPercent + '%</strong> of bill' +
            ' &nbsp;·&nbsp; Min <strong>' + cfg.minPointToRedeem + ' pts</strong> to redeem';
    }

    if (usePointsEl) {
        usePointsEl.max = maxPts;
        usePointsEl.disabled = !canRedeem;
        if (!canRedeem) {
            usePointsEl.value       = '';
            usePointsEl.placeholder = 'Need ' + cfg.minPointToRedeem + '+ pts';
        } else {
            usePointsEl.placeholder = '0 – ' + maxPts;
        }
    }
}

function applyLoyaltyPoints(val) {
    const cfg    = getPointConfig();
    const maxPts = calcMaxRedeemPoints();
    let   pts    = Math.max(0, Math.min(parseInt(val) || 0, maxPts));

    // Clamp input
    const usePointsEl = document.getElementById('usePoints');
    if (usePointsEl && pts !== (parseInt(val) || 0)) usePointsEl.value = pts;

    const vnd = pts * cfg.redemptionValue;
    loyaltyUsed = vnd;

    // Cập nhật label "= Xđ"
    const availEl = document.getElementById('loyaltyAvail');
    if (availEl) availEl.textContent = pts > 0 ? '= ' + formatVND(vnd) : '= 0đ';

    // Cảnh báo nếu nhập quá max
    const warnEl = document.getElementById('custPointWarn');
    if (warnEl) {
        if ((parseInt(val) || 0) > maxPts && maxPts > 0) {
            warnEl.style.display = '';
            warnEl.textContent   = 'Max redeemable: ' + maxPts.toLocaleString('vi-VN') + ' pts';
        } else {
            warnEl.style.display = 'none';
        }
    }

    updateTotals();
}

/* ── QR state machine ── */
function setQrState(state) {
    ['qrStateIdle','qrStateLoading','qrStateReady'].forEach(id => {
        const el = document.getElementById(id);
        if (el) el.style.display = 'none';
    });
    const target = document.getElementById('qrState' + state.charAt(0).toUpperCase() + state.slice(1));
    if (target) target.style.display = '';
}

function updateQR() {
    if (currentMethod !== 'bank') {
        setQrState('idle');
        return;
    }
    // Chỉ hiện idle khi chưa bấm Pay
    // Loading/Ready được set bởi confirmBankingPayment
    const bank = window.bankSettings || {};
    const el = document.getElementById('qrAccNumber');
    if (el) el.textContent = bank.accNumber || '–';
    const nameEl = document.getElementById('qrAccName');
    if (nameEl) nameEl.textContent = bank.accName || '–';
    const bankEl = document.getElementById('qrBankLabel');
    if (bankEl) bankEl.textContent = bank.bankName || '–';
    setQrState('idle');
}

/* ── Cancel order ── */
async function cancelOrder() {
    const result = await Swal.fire({
        title: 'Cancel this order?',
        text: 'This action cannot be undone.',
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#ef4444',
        cancelButtonColor: '#6c757d',
        confirmButtonText: '<i class="fa-solid fa-xmark me-1"></i> Yes, cancel it',
        cancelButtonText: 'Go back',
        reverseButtons: true,
        focusCancel: true,
        customClass: {
            popup:         'swal-pay-popup',
            confirmButton: 'swal-pay-confirm',
            cancelButton:  'swal-pay-back'
        }
    });

    if (!result.isConfirmed) return;

    stopQrPolling();
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
    const method = currentMethod;

    if (method === 'bank') {
        await confirmBankingPayment();
    } else {
        await confirmCashPayment();
    }
}

/* ── CASH payment ── */
async function confirmCashPayment() {
    const btn  = document.querySelector('.pay-btn-pay');
    btn.disabled = true;
    btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin me-1"></i> Processing...';

    const paid   = parseVND(document.getElementById('customerPaid')?.value || '0');
    const net    = Math.max(0, grandTotal - discountAmt - loyaltyUsed);
    const change = Math.max(0, paid - net);

    if (paid < net) {
        showToast('Số tiền khách đưa chưa đủ!', 'error');
        btn.disabled = false;
        btn.innerHTML = '<i class="fa-solid fa-check me-1"></i> Pay';
        return;
    }

    const payload = buildPayload('CASH', paid, net, change);

    try {
        const res  = await fetch((window.contextPath || '') + '/pos/payment/confirm', {
            method : 'POST',
            headers: { 'Content-Type': 'application/json' },
            body   : JSON.stringify(payload)
        });
        const data = await res.json();
        if (data.success) {
            showToast('Payment successful!', 'success');
            setTimeout(() => { window.location.href = (window.contextPath || '') + '/pos'; }, 1200);
        } else {
            throw new Error(data.message || 'Payment failed');
        }
    } catch (err) {
        showToast('Error: ' + err.message, 'error');
        btn.disabled = false;
        btn.innerHTML = '<i class="fa-solid fa-check me-1"></i> Pay';
    }
}

/* ── BANKING / QR payment ── */
let qrPollingTimer = null;
let qrSessionId    = null;   // paymentSessionId từ /pos/payment/qr

async function confirmBankingPayment() {
    const net  = Math.max(0, grandTotal - discountAmt - loyaltyUsed);
    const btn  = document.querySelector('.pay-btn-pay');
    const bank = window.bankSettings || {};

    if (!bank.accNumber) {
        showToast('Please configure bank account first', 'error');
        return;
    }

    btn.disabled  = true;
    btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin me-1"></i> Waiting for payment...';

    // Chuyển sang loading state ngay lập tức
    setQrState('loading');

    // ── Bước 1: Tạo Payment session (PENDING) + lấy QR thật từ PayOS ──
    try {
        const qrRes  = await fetch((window.contextPath || '') + '/pos/payment/qr', {
            method : 'POST',
            headers: { 'Content-Type': 'application/json' },
            body   : JSON.stringify({ orderId: parseInt(window.orderId), amount: net })
        });
        const qrData = await qrRes.json();
        qrSessionId  = qrData.paymentSessionId || null;

        // Dùng checkoutUrl để nhúng trang PayOS vào iframe
        const embedUrl = qrData.checkoutUrl || null;
        if (embedUrl) {
            showPayOSQr(embedUrl);
        } else if (qrData.qrCodeUrl) {
            showPayOSQr(qrData.qrCodeUrl);
        }
    } catch(e) {
        showToast('Cannot create payment session: ' + e.message, 'error');
        btn.disabled  = false;
        btn.innerHTML = '<i class="fa-solid fa-check me-1"></i> Pay';
        showQrStatus('timeout');
        return;
    }

    if (!qrSessionId) {
        showToast('No payment session returned from server', 'error');
        btn.disabled  = false;
        btn.innerHTML = '<i class="fa-solid fa-check me-1"></i> Pay';
        showQrStatus('timeout');
        return;
    }

    // ── Bước 2: Poll /pos/payment/status mỗi 3 giây ───────────────
    let attempts       = 0;
    const MAX_ATTEMPTS = 60; // 3 phút

    qrPollingTimer = setInterval(async () => {
        attempts++;
        try {
            const statusRes  = await fetch(
                (window.contextPath || '') + '/pos/payment/status?paymentSessionId='
                + encodeURIComponent(qrSessionId)
            );
            const statusText = await statusRes.text();
            const status     = statusText.trim().replace(/\"/g, '');

            if (status === 'PAID') {
                // ── Bước 3: Gọi confirm 1 lần duy nhất ──────────────
                stopQrPolling();
                const payload  = buildPayload('BANKING', net, net, 0);
                const confRes  = await fetch((window.contextPath || '') + '/pos/payment/confirm', {
                    method : 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body   : JSON.stringify(payload)
                });
                const confData = await confRes.json();
                if (confData.success) {
                    showQrStatus('success');
                    showToast('Banking payment confirmed!', 'success');
                    setTimeout(() => { window.location.href = (window.contextPath || '') + '/pos'; }, 1500);
                } else {
                    throw new Error(confData.message || 'Confirm failed');
                }
                return;
            }

            if (status === 'CANCELLED' || status === 'FAILED' || status === 'EXPIRED') {
                stopQrPolling();
                showQrStatus('timeout');
                btn.disabled  = false;
                btn.innerHTML = '<i class="fa-solid fa-check me-1"></i> Pay';
                showToast('Payment ' + status.toLowerCase() + ' — please try again', 'error');
                return;
            }
        } catch(e) {
            stopQrPolling();
            showQrStatus('timeout');
            btn.disabled  = false;
            btn.innerHTML = '<i class="fa-solid fa-check me-1"></i> Confirm paid';
            showToast('Error: ' + e.message + ' — click "Confirm paid" manually', 'error');
        }

        if (attempts >= MAX_ATTEMPTS) {
            stopQrPolling();
            showQrStatus('timeout');
            btn.disabled  = false;
            btn.innerHTML = '<i class="fa-solid fa-check me-1"></i> Confirm paid';
            showToast('Timeout — click "Confirm paid" after transfer completes', 'error');
        }
    }, 3000);
}

function stopQrPolling() {
    if (qrPollingTimer) { clearInterval(qrPollingTimer); qrPollingTimer = null; }
    qrSessionId = null;
    const iframe = document.getElementById('qrIframe');
    if (iframe) iframe.src = '';
}

/* ── Show PayOS checkout in iframe ── */
function showPayOSQr(url) {
    // Update amount badge
    const net   = Math.max(0, grandTotal - discountAmt - loyaltyUsed);
    const amtEl = document.getElementById('qrAmount');
    if (amtEl) amtEl.textContent = formatVND(net);

    // Switch to ready state
    setQrState('ready');

    // Load iframe
    const iframe = document.getElementById('qrIframe');
    if (iframe) iframe.src = url;

    // Show waiting status badge
    showQrStatus('waiting');
}

/* ── QR status badge ── */
function showQrStatus(state) {
    const el = document.getElementById('qrStatusBadge');
    if (!el) return;

    const styles = {
        waiting : { bg:'#eff6ff', color:'#2563eb', border:'#bfdbfe', icon:'fa-circle-notch fa-spin', text:'Waiting for transfer...' },
        success : { bg:'#f0fdf4', color:'#16a34a', border:'#86efac', icon:'fa-circle-check',          text:'Payment received!' },
        timeout : { bg:'#fff7ed', color:'#ea580c', border:'#fed7aa', icon:'fa-triangle-exclamation',  text:'Timed out — confirm manually' }
    };
    const s = styles[state] || styles.waiting;
    el.style.cssText = [
        'background:' + s.bg,
        'color:' + s.color,
        'border:1.5px solid ' + s.border,
        'width:100%','text-align:center',
        'font-size:0.8rem','font-weight:600',
        'padding:8px 12px','border-radius:8px',
        'transition:all 0.2s'
    ].join(';');
    el.innerHTML = '<i class="fa-solid ' + s.icon + ' me-1"></i>' + s.text;
    el.style.display = '';
}

/* ── Build payload helper ── */
function buildPayload(method, customerPaid, totalPaid, changeAmount) {
    const pts       = parseInt(document.getElementById('usePoints')?.value || '0');
    const pointsVND = pts * (getPointConfig().redemptionValue || 1000);
    return {
        orderId       : window.orderId,
        paymentMethod : method,                      // 'CASH' hoặc 'BANKING'
        customerPaid  : customerPaid,
        discount      : discountAmt,
        loyaltyUsed   : pointsVND,
        totalPaid     : totalPaid,
        changeAmount  : changeAmount,
        note          : document.getElementById('orderNote')?.value || '',
        customerPhone : document.getElementById('customerPhone')?.value || '',
        customerName  : document.getElementById('customerName')?.value  || '',
        customerId    : document.getElementById('customerId')?.value    || ''
    };
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

/* ── Load order items từ session JSON ── */
async function loadOrderItems() {
    try {
        const res   = await fetch((window.contextPath || '') + '/pos/api/cart-items');
        const items = await res.json();
        const tbody = document.getElementById('orderItemsBody');
        if (!items || items.length === 0) {
            tbody.innerHTML = '<tr><td colspan="2" style="text-align:center;color:#94a3b8;">No items</td></tr>';
            return;
        }
        tbody.innerHTML = items.map(item => {
            const name     = item.productName || item.name || '–';
            const qty      = item.quantity || 1;
            const price    = parseFloat(item.unitPrice || item.price || 0);
            const lineTotal = parseFloat(item.lineTotal || item.subtotal || (price * qty));
            return '<tr>' +
                '<td>' +
                    '<div class="oi-name">' + name + '</div>' +
                    '<div class="oi-meta">' + qty + ' × ' + price.toLocaleString('vi-VN') + 'đ</div>' +
                '</td>' +
                '<td class="text-end oi-total">' + lineTotal.toLocaleString('vi-VN') + 'đ</td>' +
            '</tr>';
        }).join('');
    } catch(e) {
        console.error('Failed to load order items:', e);
    }
}

/* ── INIT ── */
document.addEventListener('DOMContentLoaded', () => {
    updateTotals();
    loadOrderItems();
    setCustState('idle');

    // Show QR if bank method is pre-selected
    onPayMethodChange(document.querySelector('input[name="payMethod"]:checked'));

    // Kiểm tra PayOS gateway có available không
    checkGatewayStatus();
});

/* ── Check PayOS gateway availability ── */
async function checkGatewayStatus() {
    const bankRadio   = document.querySelector('input[name="payMethod"][value="bank"]');
    const bankLabel   = document.getElementById('lbl-bank');
    if (!bankRadio || !bankLabel) return;

    try {
        const res  = await fetch((window.contextPath || '') + '/pos/payment/gateway-status');
        const data = await res.json();

        if (!data.available) {
            // Lock radio banking
            bankRadio.disabled = true;
            bankLabel.style.opacity    = '0.45';
            bankLabel.style.cursor     = 'not-allowed';
            bankLabel.title            = 'PayOS is currently unavailable';

            // Thêm badge "Maintenance"
            const badge = document.createElement('span');
            badge.textContent = '⚠ Maintenance';
            badge.style.cssText = [
                'margin-left:auto','font-size:0.7rem','font-weight:700',
                'color:#dc2626','background:#fee2e2','border:1px solid #fca5a5',
                'border-radius:20px','padding:2px 8px'
            ].join(';');
            badge.id = 'gatewayBadge';
            bankLabel.appendChild(badge);

            // Nếu đang chọn bank → switch về cash
            if (currentMethod === 'bank') {
                const cashRadio = document.querySelector('input[name="payMethod"][value="cash"]');
                if (cashRadio) {
                    cashRadio.checked = true;
                    onPayMethodChange(cashRadio);
                }
            }
        } else {
            // Đảm bảo radio không bị lock từ lần check trước
            bankRadio.disabled      = false;
            bankLabel.style.opacity = '';
            bankLabel.style.cursor  = '';
            bankLabel.title         = '';
            const badge = document.getElementById('gatewayBadge');
            if (badge) badge.remove();
        }
    } catch(_) {
        // Nếu không gọi được API check → không lock, để user tự thử
    }
}