// ============================================================
// reports.js  — Đặt tại: /resources/js/report/reports.js
// ============================================================
'use strict';

var CTX = document.getElementById('ctxMeta')
    ? document.getElementById('ctxMeta').getAttribute('content')
    : '';

// ── Khởi tạo ngày mặc định khi trang load ──────────────────
window.addEventListener('DOMContentLoaded', function () {
    var today = getTodayStr();
    var s = document.getElementById('startDate');
    var e = document.getElementById('endDate');
    if (s) s.value = today;
    if (e) e.value = today;
});

// ── Toggle filter Extend / Collapse ────────────────────────
function toggleFilter() {
    var body = document.getElementById('filterBody');
    var btn  = document.getElementById('toggleBtn');
    if (!body || !btn) return;
    if (body.style.display === 'none' || body.style.display === '') {
        body.style.display = 'block';
        btn.textContent = 'Thu gọn';
    } else {
        body.style.display = 'none';
        btn.textContent = 'Mở rộng';
    }
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
        alert('Vui lòng chọn ngày bắt đầu và kết thúc.');
        return;
    }
    if (startDate > endDate) {
        alert('Ngày bắt đầu không được sau ngày kết thúc.');
        return;
    }

    // Cập nhật date bar
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
        alert('Vui lòng chọn khoảng ngày trước khi xuất.');
        return;
    }

    showLoading(true);

    // Tạo form ẩn để trigger download file từ server
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

    // CSRF token nếu có
    var csrfMeta = document.querySelector('meta[name="_csrf"]');
    var csrfHeaderMeta = document.querySelector('meta[name="_csrf_header"]');
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
            alert(json.message || 'Lỗi khi tải báo cáo.');
        }
    })
    .catch(function () { alert('Lỗi kết nối mạng.'); })
    .finally(function () { showLoading(false); });
}

// ── Cập nhật summary cards ───────────────────────────────────
function updateSummary(d) {
    setEl('totalRevenue',        fmtVND(d.totalRevenue));
    setEl('totalOrders',         d.totalOrders != null ? d.totalOrders : 0);
    setEl('averageValuePerUnit', fmtVND(d.averageValuePerUnit));
    setEl('bestSellingProduct',  d.bestSellingProduct || 'N/A');
    var b = document.getElementById('orderCountBadge');
    if (b) b.textContent = (d.totalOrders != null ? d.totalOrders : 0) + ' đơn hàng';
}

// ── Cập nhật bảng đơn hàng ───────────────────────────────────
function updateTable(orders) {
    var tbody = document.getElementById('orderTableBody');
    if (!tbody) return;
    if (!orders || !orders.length) {
        tbody.innerHTML = '<tr><td colspan="7" class="text-center text-muted py-3">Không tìm thấy đơn hàng trong khoảng thời gian đã chọn.</td></tr>';
        return;
    }
    tbody.innerHTML = orders.map(function (o, i) {
        return '<tr>' +
            '<td>' + (i + 1) + '</td>' +
            '<td>#' + o.orderId + '</td>' +
            '<td>' + (o.employee && o.employee.fullName ? escHtml(o.employee.fullName) : '—') + '</td>' +
            '<td>' + (o.paymentMethod ? payLabel(o.paymentMethod) : '—') + '</td>' +
            '<td>' + fmtVND(o.totalAmount) + '</td>' +
            '<td>' + fmtDT(o.createdAt) + '</td>' +
            '<td>' + (o.orderStatus ? escHtml(o.orderStatus.orderStatusName) : '') + '</td>' +
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

/** Format số thành VNĐ, ví dụ: 1,500,000 ₫ */
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
    if (!method) return '—';
    if (method === 'CASH')    return 'Tiền mặt';
    if (method === 'BANKING') return 'Chuyển khoản';
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