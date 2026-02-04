/**
 * Hàm mở Modal Chỉnh sửa và điền dữ liệu tự động
 * @param {HTMLElement} btn - Nút Edit được nhấn
 */
function openEditModal(btn) {
    // 1. Lấy dữ liệu từ các thuộc tính data- của nút
    const id = btn.getAttribute('data-id');
    const name = btn.getAttribute('data-name');
    const contact = btn.getAttribute('data-contact');
    const email = btn.getAttribute('data-email');

    // 2. Điền dữ liệu vào các trường trong Edit Modal
    document.getElementById('editSupplierId').value = id;
    document.getElementById('editSupplierName').value = name;
    document.getElementById('editContactName').value = contact;
    document.getElementById('editEmail').value = email;

    // 3. Hiển thị Modal bằng Bootstrap 5 API
    const editModal = new bootstrap.Modal(document.getElementById('editSupplierModal'));
    editModal.show();
}

/**
 * Hàm xác nhận xóa (Optional)
 */
function confirmDelete(id) {
    if (confirm("Are you sure you want to delete supplier #" + id + "?")) {
        window.location.href = "/admin/suppliers/delete/" + id;
    }
}