/* ============================================================
   RECEIPT.JS – Manage Receipt page logic
   Entity mapping:
     PosReceipt  : receiptNumber, printedAt, printedBy (Employee)
     Order       : createdAt, totalAmount, discountAmount,
                   paymentMethod (PaymentMethod enum),
                   orderStatus.orderStatusName (OrderStatusName enum),
                   employee (cashier), customer (nullable)
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

document.addEventListener('click', function (e) {
    if (!e.target.closest('.action-wrap')) {
        document.querySelectorAll('.action-menu').forEach(m => m.classList.remove('open'));
        document.querySelectorAll('.btn-dots').forEach(b => b.classList.remove('active'));
    }
});

/* ============================================================
   DETAIL MODAL
   ============================================================ */
function viewDetail(receiptNumber) {
    document.querySelectorAll('.action-menu').forEach(m => m.classList.remove('open'));
    document.querySelectorAll('.btn-dots').forEach(b => b.classList.remove('active'));

    document.getElementById('modalTitle').textContent = 'Invoice details ' + receiptNumber;

    fetch('/receipt/api/detail/' + encodeURIComponent(receiptNumber))
        .then(res => {
            if (!res.ok) throw new Error('not found');
            return res.json();
        })
        .then(data => populateModal(data))
        .catch(() => populateModalFromRow(receiptNumber));

    document.getElementById('detailModal').classList.add('open');
}

function populateModal(data) {
    // Receipt information section
    document.getElementById('detailCode').textContent    = data.receiptNumber || '—';
    // Use order's createdAt as the creation date shown in modal
    document.getElementById('detailDate').textContent    = data.createdAt     || data.printedAt || '—';
    document.getElementById('detailStatus').textContent  = data.statusLabel   || '—';
    // Cashier = Order.employee (returned as cashierName in the map)
    document.getElementById('detailCashier').textContent = data.cashierName   || '—';

    // Customer information section
    document.getElementById('detailCustomer').textContent = data.customerName  || 'Guest';
    document.getElementById('detailPayment').textContent  = resolvePaymentLabel(data.paymentMethod);

    // Payment summary
    document.getElementById('detailSubtotal').textContent = formatCurrency(data.subtotal);
    document.getElementById('detailDiscount').textContent = formatCurrency(data.discount);

    // customerPayment / change not available in Order entity → show "—"
    document.getElementById('detailPaid').textContent   = data.customerPayment != null
        ? formatCurrency(data.customerPayment) : '—';
    document.getElementById('detailChange').textContent = data.change != null
        ? formatCurrency(data.change) : '—';

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
            '<tr><td colspan="5" style="text-align:center;color:#94a3b8;padding:16px;">No items</td></tr>';
    }
}

// Fallback: read data already rendered in the table row
function populateModalFromRow(receiptNumber) {
    const row = document.querySelector(`tr[data-code="${receiptNumber}"]`);
    if (!row) return;

    const cells = row.querySelectorAll('td');

    document.getElementById('detailCode').textContent     = receiptNumber;
    document.getElementById('detailDate').textContent     = cells[2]?.textContent.trim() || '—';
    document.getElementById('detailStatus').textContent   = resolveStatusLabel(row.dataset.status);
    // cashier stored in data-cashier = r.order.employee.fullName
    document.getElementById('detailCashier').textContent  = row.dataset.cashier   || '—';
    document.getElementById('detailCustomer').textContent = row.dataset.customer  || 'Guest';
    document.getElementById('detailPayment').textContent  =
        resolvePaymentLabel(row.dataset.payment);

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

document.addEventListener('keydown', e => {
    if (e.key === 'Escape') closeModal();
});

/* ============================================================
   PRINT RECEIPT
   ============================================================ */
function printReceipt(receiptNumber) {
    document.querySelectorAll('.action-menu').forEach(m => m.classList.remove('open'));
    window.location.href = '/receipt/print/' + encodeURIComponent(receiptNumber);
}

/* ============================================================
   FILTER / SEARCH
   ============================================================ */
function filterTable() {
    const search  = document.getElementById('searchInput').value.toLowerCase().trim();
    const status  = document.getElementById('statusFilter').value;   // e.g. "COMPLETED"
    const payment = document.getElementById('paymentFilter').value;  // e.g. "CASH"

    document.querySelectorAll('#receiptTableBody tr[data-code]').forEach(row => {
        const code     = (row.dataset.code     || '').toLowerCase();
        const customer = (row.dataset.customer || '').toLowerCase();
        const cashier  = (row.dataset.cashier  || '').toLowerCase();
        // data-status = orderStatus.orderStatusName (enum), data-payment = paymentMethod.name()
        const st       = (row.dataset.status   || '');
        const pm       = (row.dataset.payment  || '');

        const matchSearch  = !search  || code.includes(search) || customer.includes(search) || cashier.includes(search);
        const matchStatus  = !status  || st === status;
        const matchPayment = !payment || pm === payment;

        row.style.display = (matchSearch && matchStatus && matchPayment) ? '' : 'none';
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
    window.location.href = '/receipt/export-excel';
}

/* ============================================================
   DATE RANGE PICKER (placeholder)
   ============================================================ */
function openDatePicker() {
    // TODO: integrate flatpickr or similar
    alert('Date range picker – integrate your preferred date picker here.');
}

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
        COMPLETED: 'Đã thanh toán',
        PENDING:   'Chờ xác nhận',
        CANCELLED: 'Đã huỷ'
    };
    return map[status.toUpperCase()] || status;
}