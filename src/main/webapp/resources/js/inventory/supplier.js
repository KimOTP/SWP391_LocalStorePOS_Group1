document.addEventListener('DOMContentLoaded', () => initLiveSearch());

function prepareAddModal() {
    document.getElementById('addSupplierForm').reset();
    new bootstrap.Modal(document.getElementById('addSupplierModal')).show();
}

function openEditModal(btn) {
    // Trích xuất dữ liệu từ data attributes
    const id = btn.getAttribute('data-id');
    const name = btn.getAttribute('data-name');
    const address = btn.getAttribute('data-address');
    const email = btn.getAttribute('data-email');

    // Đổ vào modal edit
    document.getElementById('editSupplierId').value = id;
    document.getElementById('editSupplierName').value = name;
    document.getElementById('editAddress').value = address;
    document.getElementById('editEmail').value = email;

    new bootstrap.Modal(document.getElementById('editSupplierModal')).show();
}

function initLiveSearch() {
    const input = document.getElementById('searchInput');
    if (!input) return;
    input.addEventListener('input', function() {
        const keyword = this.value.toLowerCase();
        document.querySelectorAll('.supplier-table-body tr').forEach(row => {
            row.style.display = row.innerText.toLowerCase().includes(keyword) ? '' : 'none';
        });
    });
}

function confirmDelete(id, name) {
    if (confirm(`Delete supplier: ${name} (#${id})?`)) {
        window.location.href = `/admin/suppliers/delete/${id}`;
    }
}