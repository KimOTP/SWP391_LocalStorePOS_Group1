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

    const isOpen = menu.classList.contains('open');
    menu.classList.toggle('open');
    btn.classList.toggle('active');

    if (!isOpen) {
        // Position the fixed menu below the button
        const rect = btn.getBoundingClientRect();
        menu.style.top  = (rect.bottom + 6) + 'px';
        menu.style.left = (rect.right - menu.offsetWidth || rect.right - 170) + 'px';
        // After rendering, correct position using actual width
        requestAnimationFrame(() => {
            menu.style.left = (rect.right - menu.offsetWidth) + 'px';
        });
    }
}

/* ============================================================
   DETAIL MODAL
   ============================================================ */
function viewDetail(receiptNumber) {
    document.querySelectorAll('.action-menu').forEach(m => m.classList.remove('open'));
    document.querySelectorAll('.btn-dots').forEach(b => b.classList.remove('active'));

    document.getElementById('modalTitle').textContent = receiptNumber;

    // Show loading state in items table
    document.getElementById('detailItems').innerHTML =
        '<tr><td colspan="5" class="detail-items-loading">' +
        '<i class="fa-solid fa-spinner fa-spin" style="margin-right:6px;"></i>Loading...</td></tr>';

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
    // Header subtitle = receipt number
    document.getElementById('modalTitle').textContent  = data.receiptNumber || '';

    document.getElementById('detailCode').textContent     = data.receiptNumber || '—';
    document.getElementById('detailDate').textContent     = data.createdAt     || data.printedAt || '—';
    document.getElementById('detailCashier').textContent  = data.cashierName   || '—';
    document.getElementById('detailCustomer').textContent = data.customerName  || 'Guest';
    document.getElementById('detailPayment').textContent  = resolvePaymentLabel(data.paymentMethod);
    document.getElementById('detailSubtotal').textContent = formatCurrency(data.subtotal);
    document.getElementById('detailDiscount').textContent = formatCurrency(data.discount);

    // Big total = subtotal - discount
    const subtotal = data.subtotal  != null ? Number(data.subtotal)  : 0;
    const discount = data.discount  != null ? Number(data.discount)  : 0;
    document.getElementById('detailTotal').textContent = formatCurrency(subtotal - discount);

    document.getElementById('detailPaid').textContent   = data.customerPayment != null
        ? formatCurrency(data.customerPayment) : '—';
    document.getElementById('detailChange').textContent = data.change != null
        ? formatCurrency(data.change) : '—';

    // Status with dynamic colour
    const statusEl = document.getElementById('detailStatus');
    const statusLabel = data.statusLabel || resolveStatusLabel(data.orderStatus) || '—';
    statusEl.textContent = statusLabel;
    statusEl.className = 'info-val';
    const st = (data.orderStatus || '').toUpperCase();
    if (st === 'PAID')             statusEl.classList.add('status-paid');
    else if (st === 'CANCELLED')   statusEl.classList.add('status-cancelled');
    else if (st === 'PENDING_PAYMENT') statusEl.classList.add('status-pending');

    // Order items
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
            '<tr><td colspan="5" style="text-align:center;color:#94a3b8;padding:20px;">No items</td></tr>';
    }
}

function populateModalFromRow(receiptNumber) {
    const row = document.querySelector(`tr[data-code="${receiptNumber}"]`);
    if (!row) return;
    const cells = row.querySelectorAll('td');
    document.getElementById('modalTitle').textContent    = receiptNumber;
    document.getElementById('detailCode').textContent    = receiptNumber;
    document.getElementById('detailDate').textContent    = cells[1]?.textContent.trim() || '—';
    const statusEl = document.getElementById('detailStatus');
    statusEl.textContent = resolveStatusLabel(row.dataset.status);
    statusEl.className = 'info-val';
    document.getElementById('detailCashier').textContent  = row.dataset.cashier  || '—';
    document.getElementById('detailCustomer').textContent = row.dataset.customer || 'Guest';
    document.getElementById('detailPayment').textContent  = resolvePaymentLabel(row.dataset.payment);
    const amount = cells[4]?.textContent.trim() || '0';
    document.getElementById('detailSubtotal').textContent = amount;
    document.getElementById('detailDiscount').textContent = '0 ₫';
    document.getElementById('detailTotal').textContent    = amount;
    document.getElementById('detailPaid').textContent     = '—';
    document.getElementById('detailChange').textContent   = '—';
    document.getElementById('detailItems').innerHTML =
        '<tr><td colspan="5" style="text-align:center;color:#94a3b8;padding:20px;">No items data</td></tr>';
}

function closeModal() {
    document.getElementById('detailModal').classList.remove('open');
}

function closeModalOnBg(e) {
    if (e.target === document.getElementById('detailModal')) closeModal();
}

/* ============================================================
   PRINT RECEIPT – uses SESSION_PRINT_TEMPLATE config
   ============================================================ */
function printReceipt(receiptNumber) {
    document.querySelectorAll('.action-menu').forEach(m => m.classList.remove('open'));
    document.querySelectorAll('.btn-dots').forEach(b => b.classList.remove('active'));

    fetch('/pos/receipts/api/detail/' + encodeURIComponent(receiptNumber))
        .then(res => res.ok ? res.json() : Promise.reject())
        .then(data => {
            fetch('/pos/receipts/api/print-template')
                .then(r => r.ok ? r.json() : Promise.reject())
                .then(template => openPrintWindow(data, template))
                .catch(() => openPrintWindow(data, null));
        })
        .catch(() => {
            window.location.href = '/pos/receipts/print/' + encodeURIComponent(receiptNumber);
        });
}

function openPrintWindow(data, tpl) {
    const paperWidth  = (tpl && tpl.paperSize === '80mm') ? '80mm' : '58mm';
    const fontSize    = (tpl && tpl.fontSize)    ? tpl.fontSize    : '12px';
    const title       = (tpl && tpl.invoiceTitle) ? tpl.invoiceTitle : 'SALES INVOICE';
    const thanks      = (tpl && tpl.thankMessage) ? tpl.thankMessage : 'Thank you for your purchase.';
    const companyName = (tpl && tpl.companyName)  ? tpl.companyName  : '';
    const address     = (tpl && tpl.address)       ? tpl.address      : '';
    const phone       = (tpl && tpl.phone)         ? tpl.phone        : '';
    const email       = (tpl && tpl.email)         ? tpl.email        : '';

    const itemRows = (data.items && data.items.length > 0)
        ? data.items.map(item =>
            `<tr>
               <td>${item.productName || '—'}</td>
               <td style="text-align:right">${item.quantity || 1}×${formatCurrency(item.unitPrice)}</td>
               <td style="text-align:right">${formatCurrency(item.totalAmount)}</td>
             </tr>`
          ).join('')
        : `<tr><td colspan="3" style="text-align:center;padding:8px 0;color:#888">No items</td></tr>`;

    const now = new Date();
    const dateStr = now.toLocaleTimeString('vi-VN', {hour:'2-digit',minute:'2-digit',second:'2-digit'})
                  + ' ' + now.toLocaleDateString('vi-VN');

    const html = `<!DOCTYPE html>
<html><head>
<meta charset="UTF-8">
<title>${title}</title>
<style>
  @page { margin: 0; size: ${paperWidth} auto; }
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body { font-family: 'Courier New', monospace; font-size: ${fontSize}; width: ${paperWidth}; padding: 8px; }
  .center { text-align: center; }
  .bold   { font-weight: bold; }
  .divider { border: none; border-top: 1px dashed #666; margin: 6px 0; }
  table { width: 100%; border-collapse: collapse; }
  td    { padding: 2px 0; vertical-align: top; font-size: ${fontSize}; }
  .barcode { font-family: monospace; letter-spacing: 4px; font-size: 10px; }
  .logo { font-weight: bold; font-size: 1.1em; }
</style>
</head><body>
  <div class="center logo">${companyName || 'LOGO'}</div>
  ${companyName ? `<div class="center">${companyName}</div>` : ''}
  ${address     ? `<div class="center">${address}</div>` : ''}
  ${(phone || email) ? `<div class="center">${[phone,email].filter(Boolean).join(' | ')}</div>` : ''}
  <hr class="divider">
  <div class="center bold">${title}</div>
  <div class="center">${dateStr}</div>
  <hr class="divider">
  <table>
    <tr>
      <th style="text-align:left">Product</th>
      <th style="text-align:right">Qty×Price</th>
      <th style="text-align:right">Amount</th>
    </tr>
    ${itemRows}
  </table>
  <hr class="divider">
  <table>
    <tr><td>Total</td><td style="text-align:right"><strong>${formatCurrency(data.subtotal)}</strong></td></tr>
    ${data.discount ? `<tr><td>Discount</td><td style="text-align:right">-${formatCurrency(data.discount)}</td></tr>` : ''}
    ${data.customerPayment != null ? `<tr><td>Paid</td><td style="text-align:right">${formatCurrency(data.customerPayment)}</td></tr>` : ''}
    ${data.change != null ? `<tr><td>Change</td><td style="text-align:right">${formatCurrency(data.change)}</td></tr>` : ''}
  </table>
  <hr class="divider">
  <div class="center">${thanks}</div>
  <div class="center barcode">| | |  | | | | | | |  | | | | |</div>
  <div class="center barcode">| | | | | | | | | |</div>
  <br>
</body></html>`;

    const w = window.open('', '_blank', `width=350,height=600,toolbar=0,menubar=0`);
    w.document.write(html);
    w.document.close();
    w.focus();
    w.onload = () => { w.print(); };
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