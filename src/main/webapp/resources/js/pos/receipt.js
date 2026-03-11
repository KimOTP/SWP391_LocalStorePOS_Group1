/* ============================================================
   RECEIPT.JS – Manage Receipt page logic
   ============================================================ */

/* ============================================================
   3-DOT ACTION MENU
   ============================================================ */
function toggleMenu(btn) {
    const menu     = btn.nextElementSibling;
    const allMenus = document.querySelectorAll('.action-menu');
    const allBtns  = document.querySelectorAll('.btn-dots');

    allMenus.forEach(m => { if (m !== menu) m.classList.remove('open'); });
    allBtns.forEach(b  => { if (b !== btn)  b.classList.remove('active'); });

    menu.classList.toggle('open');
    btn.classList.toggle('active');
}

/* ============================================================
   DETAIL MODAL
   ============================================================ */
function viewDetail(receiptNumber) {
    document.querySelectorAll('.action-menu').forEach(m => m.classList.remove('open'));
    document.querySelectorAll('.btn-dots').forEach(b => b.classList.remove('active'));

    document.getElementById('modalTitle').textContent = 'Invoice details ' + receiptNumber;

    fetch('/pos/receipts/api/detail/' + encodeURIComponent(receiptNumber))
        .then(res => {
            if (!res.ok) throw new Error('not found');
            return res.json();
        })
        .then(data => populateModal(data))
        .catch(() => populateModalFromRow(receiptNumber));

    document.getElementById('detailModal').classList.add('open');
}

function populateModal(data) {
    document.getElementById('detailCode').textContent     = data.receiptNumber || '—';
    document.getElementById('detailDate').textContent     = data.createdAt     || data.printedAt || '—';
    document.getElementById('detailStatus').textContent   = data.statusLabel   || '—';
    document.getElementById('detailCashier').textContent  = data.cashierName   || '—';
    document.getElementById('detailCustomer').textContent = data.customerName  || 'Guest';
    document.getElementById('detailPayment').textContent  = resolvePaymentLabel(data.paymentMethod);
    document.getElementById('detailSubtotal').textContent = formatCurrency(data.subtotal);
    document.getElementById('detailDiscount').textContent = formatCurrency(data.discount);
    document.getElementById('detailPaid').textContent     = data.customerPayment != null
        ? formatCurrency(data.customerPayment) : '—';
    document.getElementById('detailChange').textContent   = data.change != null
        ? formatCurrency(data.change) : '—';

    const tbody = document.getElementById('detailItems');
    if (data.items && data.items.length > 0) {
        tbody.innerHTML = data.items.map(item => `
            <tr>
                <td>${item.productName  || '—'}</td>
                <td>${item.unit         || '—'}</td>
                <td>${formatCurrency(item.unitPrice)}</td>
                <td>${formatCurrency(item.totalAmount)}</td>
                <td>${item.quantity     || '—'}</td>
            </tr>
        `).join('');
    } else {
        tbody.innerHTML =
            '<tr><td colspan="5" style="text-align:center;color:#94a3b8;padding:16px;">No items</td></tr>';
    }
}

function populateModalFromRow(receiptNumber) {
    const row = document.querySelector(`tr[data-code="${receiptNumber}"]`);
    if (!row) return;
    const cells = row.querySelectorAll('td');
    document.getElementById('detailCode').textContent     = receiptNumber;
    document.getElementById('detailDate').textContent     = cells[2]?.textContent.trim() || '—';
    document.getElementById('detailStatus').textContent   = resolveStatusLabel(row.dataset.status);
    document.getElementById('detailCashier').textContent  = row.dataset.cashier   || '—';
    document.getElementById('detailCustomer').textContent = row.dataset.customer  || 'Guest';
    document.getElementById('detailPayment').textContent  = resolvePaymentLabel(row.dataset.payment);
    const amount = cells[5]?.textContent.trim() || '0';
    document.getElementById('detailSubtotal').textContent = amount + ' ₫';
    document.getElementById('detailDiscount').textContent = '0 ₫';
    document.getElementById('detailPaid').textContent     = '—';
    document.getElementById('detailChange').textContent   = '—';
    document.getElementById('detailItems').innerHTML =
        '<tr><td colspan="5" style="text-align:center;color:#94a3b8;padding:16px;">No items data</td></tr>';
}

function closeModal() {
    document.getElementById('detailModal').classList.remove('open');
}

function closeModalOnBg(e) {
    if (e.target === document.getElementById('detailModal')) closeModal();
}

/* ============================================================
   PRINT RECEIPT
   ============================================================ */
function printReceipt(receiptNumber) {
    document.querySelectorAll('.action-menu').forEach(m => m.classList.remove('open'));
    window.location.href = '/pos/receipts/print/' + encodeURIComponent(receiptNumber);
}

/* ============================================================
   FILTER / SEARCH – 1 hàm duy nhất, không duplicate
   ============================================================ */
function filterTable() {
    const search  = document.getElementById('searchInput').value.toLowerCase().trim();
    const payment = (document.getElementById('paymentFilter')?.value || '');
    const from    = (document.getElementById('dateFrom')?.value || '');
    const to      = (document.getElementById('dateTo')?.value   || '');

    document.querySelectorAll('#receiptTableBody tr[data-code]').forEach(row => {
        const code     = (row.dataset.code     || '').toLowerCase();
        const customer = (row.dataset.customer || '').toLowerCase();
        const cashier  = (row.dataset.cashier  || '').toLowerCase();
        const pm       = (row.dataset.payment  || '');
        const dateRaw  = (row.dataset.date     || ''); // dd/MM/yyyy

        const matchSearch  = !search  || code.includes(search) || customer.includes(search) || cashier.includes(search);
        const matchPayment = !payment || pm === payment;

        let matchDate = true;
        if ((from || to) && dateRaw) {
            const parts = dateRaw.split('/');
            if (parts.length === 3) {
                const rowDate = parts[2] + '-' + parts[1] + '-' + parts[0];
                if (from && rowDate < from) matchDate = false;
                if (to   && rowDate > to)   matchDate = false;
            }
        }

        row.style.display = (matchSearch && matchPayment && matchDate) ? '' : 'none';
    });
}

/* ============================================================
   SELECT ALL CHECKBOX
   ============================================================ */
function toggleAll(master) {
    document.querySelectorAll('#receiptTableBody .row-checkbox').forEach(cb => {
        cb.checked = master.checked;
    });
}

/* ============================================================
   REFRESH / EXPORT
   ============================================================ */
function loadReceipts() { location.reload(); }

function exportExcel() {
    window.location.href = '/pos/receipts/export-excel';
}

/* ============================================================
   DATE RANGE PICKER
   ============================================================ */
function toggleDatePicker(e) {
    e.stopPropagation();
    document.querySelectorAll('.pos-dropdown.active').forEach(el => el.classList.remove('active'));
    document.getElementById('datePickerPopup').classList.toggle('open');
}

function applyDateFilter() {
    const from = document.getElementById('dateFrom').value;
    const to   = document.getElementById('dateTo').value;
    if (from || to) {
        const fromLabel = from ? formatDisplayDate(from) : '...';
        const toLabel   = to   ? formatDisplayDate(to)   : '...';
        document.getElementById('dateRangeLabel').textContent = fromLabel + ' – ' + toLabel;
        document.getElementById('dateRangeBtn').style.borderColor = '#2563eb';
        document.getElementById('dateRangeBtn').style.color = '#2563eb';
    }
    document.getElementById('datePickerPopup').classList.remove('open');
    filterTable();
}

function clearDateFilter() {
    document.getElementById('dateFrom').value = '';
    document.getElementById('dateTo').value   = '';
    document.getElementById('dateRangeLabel').textContent = 'Select a time range';
    document.getElementById('dateRangeBtn').style.borderColor = '';
    document.getElementById('dateRangeBtn').style.color = '';
    document.getElementById('datePickerPopup').classList.remove('open');
    filterTable();
}

function formatDisplayDate(dateStr) {
    const [y, m, d] = dateStr.split('-');
    return d + '/' + m + '/' + y;
}

/* ============================================================
   CUSTOM PAYMENT DROPDOWN
   ============================================================ */
function toggleDropdown(id) {
    const dd = document.getElementById(id);
    const isActive = dd.classList.contains('active');
    document.querySelectorAll('.pos-dropdown.active').forEach(el => el.classList.remove('active'));
    document.getElementById('datePickerPopup')?.classList.remove('open');
    if (!isActive) dd.classList.add('active');
}

function selectPayment(value, label) {
    document.getElementById('paymentFilter').value = value;
    document.getElementById('paymentDropdownLabel').textContent = label;
    document.getElementById('paymentDropdown').classList.remove('active');
    filterTable();
}

/* ============================================================
   GLOBAL CLICK – 1 listener duy nhất xử lý tất cả
   ============================================================ */
document.addEventListener('click', function(e) {
    // Đóng action menu 3 chấm
    if (!e.target.closest('.action-wrap')) {
        document.querySelectorAll('.action-menu').forEach(m => m.classList.remove('open'));
        document.querySelectorAll('.btn-dots').forEach(b => b.classList.remove('active'));
    }
    // Đóng payment dropdown
    if (!e.target.closest('.pos-dropdown')) {
        document.querySelectorAll('.pos-dropdown.active').forEach(el => el.classList.remove('active'));
    }
    // Đóng date picker popup
    const popup = document.getElementById('datePickerPopup');
    const wrap  = document.querySelector('.date-range-wrap');
    if (popup && wrap && !wrap.contains(e.target)) {
        popup.classList.remove('open');
    }
});

/* Đóng modal bằng Escape */
document.addEventListener('keydown', e => {
    if (e.key === 'Escape') closeModal();
});

/* ============================================================
   HELPERS
   ============================================================ */
function formatCurrency(val) {
    if (val === null || val === undefined) return '—';
    return new Intl.NumberFormat('vi-VN').format(val) + ' ₫';
}

function resolvePaymentLabel(method) {
    if (!method) return '—';
    const map = { CASH: 'Cashing', BANKING: 'Banking', QR: 'QR' };
    return map[method.toUpperCase()] || method;
}

function resolveStatusLabel(status) {
    if (!status) return '—';
    const map = {
        PAID:            'Đã thanh toán',
        PENDING_PAYMENT: 'Chờ xác nhận',
        CANCELLED:       'Đã huỷ'
    };
    return map[status.toUpperCase()] || status;
}