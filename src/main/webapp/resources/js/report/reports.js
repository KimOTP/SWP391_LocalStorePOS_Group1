// ============================================================
// reports.js  — Located at: /resources/js/report/reports.js
// ============================================================
'use strict';

var CTX = document.getElementById('ctxMeta')
    ? document.getElementById('ctxMeta').getAttribute('content')
    : '';

// ── Set default dates on page load ─────────────────────────
window.addEventListener('DOMContentLoaded', function () {
    var today = getTodayStr();
    var s = document.getElementById('startDate');
    var e = document.getElementById('endDate');
    if (s) s.value = today;
    if (e) e.value = today;
});

// ── Toggle filter Expand / Collapse ────────────────────────
// Uses id="filterToggleBtn" to avoid conflict with sidebar.jsp's id="toggleBtn"
function toggleFilter() {
    var body    = document.getElementById('filterBody');
    var chevron = document.getElementById('filterChevron');
    var label   = document.getElementById('filterToggleLabel');
    if (!body) return;

    var isOpen = body.style.display === 'block';
    body.style.display = isOpen ? 'none' : 'block';

    if (chevron) chevron.classList.toggle('open', !isOpen);
    if (label) label.textContent = isOpen ? 'Expand' : 'Collapse';
}

// ── Apply filter ────────────────────────────────────────────
function applyFilter() {
    var startDate     = document.getElementById('startDate').value;
    var endDate       = document.getElementById('endDate').value;
    var cashierEl     = document.querySelector('input[name="cashierFilter"]:checked');
    var payEl         = document.querySelector('input[name="paymentFilter"]:checked');
    var cashierId     = cashierEl ? cashierEl.value : '';
    var paymentMethod = payEl     ? payEl.value     : '';

    if (!startDate || !endDate) {
        Toast.fire({ icon: 'warning', title: 'Please select a start date and end date.' });
        return;
    }
    if (startDate > endDate) {
        Toast.fire({ icon: 'warning', title: 'Start date cannot be after end date.' });
        return;
    }

    // Update date bar
    var bar = document.getElementById('dateBar');
    if (bar) {
        bar.textContent = (startDate === endDate)
            ? toDisplay(startDate)
            : toDisplay(startDate) + ' — ' + toDisplay(endDate);
    }

    if (cashierId) {
        doPost(CTX + '/reports/api/reports-by-cashier',
            { startDate: startDate, endDate: endDate, cashierId: cashierId });
    } else if (paymentMethod) {
        doPost(CTX + '/reports/api/reports-by-payment-method',
            { startDate: startDate, endDate: endDate, paymentMethod: paymentMethod });
    } else {
        doPost(CTX + '/reports/api/reports-by-date-range',
            { startDate: startDate, endDate: endDate });
    }
}

// ── Reset filter ────────────────────────────────────────────
function resetFilter() {
    var today = getTodayStr();
    var s = document.getElementById('startDate');
    var e = document.getElementById('endDate');
    if (s) s.value = today;
    if (e) e.value = today;

    document.querySelectorAll('input[name="cashierFilter"]').forEach(function (r) {
        r.checked = (r.value === '');
    });
    document.querySelectorAll('input[name="paymentFilter"]').forEach(function (r) {
        r.checked = (r.value === '');
    });

    var bar = document.getElementById('dateBar');
    if (bar) bar.textContent = toDisplay(today);

    doPost(CTX + '/reports/api/reports-by-date-range', { startDate: today, endDate: today });
}

// ── Refresh ─────────────────────────────────────────────────
function refreshReport() {
    applyFilter();
}

// ── Export Excel ─────────────────────────────────────────────
function exportExcel() {
    var s = document.getElementById('startDate').value;
    var e = document.getElementById('endDate').value;
    if (!s || !e) {
        Toast.fire({ icon: 'warning', title: 'Please select a date range before exporting.' });
        return;
    }

    showLoading(true);

    // Create a hidden form to trigger file download from server
    var form = document.createElement('form');
    form.method = 'POST';
    form.action = CTX + '/reports/api/export-excel';
    form.style.display = 'none';

    var inp1 = document.createElement('input');
    inp1.type  = 'hidden';
    inp1.name  = 'startDate';
    inp1.value = s;

    var inp2 = document.createElement('input');
    inp2.type  = 'hidden';
    inp2.name  = 'endDate';
    inp2.value = e;

    // CSRF token if present
    var csrfMeta = document.querySelector('meta[name="_csrf"]');
    if (csrfMeta) {
        var csrfInp = document.createElement('input');
        csrfInp.type  = 'hidden';
        csrfInp.name  = '_csrf';
        csrfInp.value = csrfMeta.getAttribute('content');
        form.appendChild(csrfInp);
    }

    form.appendChild(inp1);
    form.appendChild(inp2);
    document.body.appendChild(form);
    form.submit();
    document.body.removeChild(form);

    setTimeout(function () { showLoading(false); }, 2000);
}

// ── AJAX POST helper ─────────────────────────────────────────
function doPost(url, params) {
    showLoading(true);
    fetch(url, {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: new URLSearchParams(params)
    })
    .then(function (r) { return r.json(); })
    .then(function (json) {
        if (json.success) {
            updateSummary(json.data);
            updateTable(json.data.orders || []);
        } else {
            Toast.fire({ icon: 'error', title: json.errorMessage || 'Failed to load report.' });
        }
    })
    .catch(function () { Toast.fire({ icon: 'error', title: 'Network connection error.' }); })
    .finally(function () { showLoading(false); });
}

// ── Update summary cards ─────────────────────────────────────
function updateSummary(d) {
    setEl('totalSales',           fmtVND(d.totalRevenue));
    setEl('totalOrders',         d.totalOrders != null ? d.totalOrders : 0);
    setEl('averageValuePerUnit', fmtVND(d.averageValuePerUnit));
    setEl('bestSellingProduct',  d.bestSellingProduct || 'N/A');
}

// ── Update order table ───────────────────────────────────────
function updateTable(orders) {
    var tbody = document.getElementById('orderTableBody');
    if (!tbody) return;
    if (!orders || !orders.length) {
        tbody.innerHTML = '<tr><td colspan="7" class="text-center text-muted py-3">No orders found in the selected date range.</td></tr>';
        return;
    }
    tbody.innerHTML = orders.map(function (o, i) {
        // paymentMethod có thể là: string "CASH"/"BANKING", hoặc null
        var pm = o.paymentMethod;
        var pmStr = pm == null ? null
                  : (typeof pm === 'object' ? (pm.name || pm.value || JSON.stringify(pm)) : String(pm));
        return '<tr>' +
            '<td>' + (i + 1) + '</td>' +
            '<td>#' + o.orderId + '</td>' +
            '<td>' + (o.employee && o.employee.fullName ? escHtml(o.employee.fullName) : '—') + '</td>' +
            '<td>' + payLabel(pmStr) + '</td>' +
            '<td>' + fmtVND(o.totalAmount) + '</td>' +
            '<td>' + fmtDT(o.createdAt) + '</td>' +
            '<td>' + statusBadge(o.orderStatus ? (o.orderStatus.orderStatusName || String(o.orderStatus)) : null) + '</td>' +
            '</tr>';
    }).join('');
}

// ── Helpers ──────────────────────────────────────────────────
function getTodayStr() {
    return new Date().toISOString().split('T')[0];
}

function toDisplay(s) {
    var p = s.split('-');
    return p[2] + '/' + p[1] + '/' + p[0];
}

/** Format number as VND currency, e.g. 1,500,000 */
function fmtVND(v) {
    if (v == null) return '0 ₫';
    var n = Math.round(parseFloat(v));
    return n.toLocaleString('vi-VN') + ' ₫';
}

function fmtDT(s) {
    if (!s) return '—';
    return String(s).substring(0, 16).replace('T', ' ');
}

function setEl(id, v) {
    var el = document.getElementById(id);
    if (el) el.textContent = v;
}

function showLoading(show) {
    var el = document.getElementById('loadingOverlay');
    if (!el) return;
    if (show) {
        el.classList.remove('d-none');
    } else {
        el.classList.add('d-none');
    }
}

function payLabel(method) {
    if (!method || method === 'null') return '—';
    if (method === 'CASH')    return 'Cash';
    if (method === 'BANKING') return 'Bank Transfer';
    return method;
}

function escHtml(s) {
    if (!s) return '';
    return String(s)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;');
}

function statusBadge(status) {
    if (!status) return '<span>—</span>';
    var map = {
        'PAID':            { label: 'Paid',            color: '#16a34a', bg: '#f0fdf4', border: '#86efac' },
        'CANCELLED':       { label: 'Cancelled',       color: '#dc2626', bg: '#fef2f2', border: '#fca5a5' },
        'PENDING_PAYMENT': { label: 'Pending Payment', color: '#d97706', bg: '#fffbeb', border: '#fcd34d' },
        'DRAFT':           { label: 'Draft',           color: '#6b7280', bg: '#f9fafb', border: '#d1d5db' }
    };
    var s = map[status.toUpperCase()] || { label: status, color: '#6b7280', bg: '#f9fafb', border: '#d1d5db' };
    return '<span style="display:inline-block;padding:2px 10px;border-radius:20px;font-size:0.75rem;font-weight:600;' +
           'color:' + s.color + ';background:' + s.bg + ';border:1px solid ' + s.border + '">' +
           escHtml(s.label) + '</span>';
}