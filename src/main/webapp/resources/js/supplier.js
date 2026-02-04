/**
 * LocalStorePOS - Supplier Management Module
 * Chịu trách nhiệm điều khiển tương tác người dùng trên trang Supplier List.
 */

document.addEventListener('DOMContentLoaded', function() {
    // 1. Khởi tạo bộ lọc tìm kiếm ngay khi trang tải xong
    initLiveSearch();
});

/**
 * CHỨC NĂNG 1: CHUẨN BỊ MODAL THÊM MỚI (ADD)
 * Giúp xóa sạch dữ liệu cũ trong form trước khi người dùng nhập mới.
 */
function prepareAddModal() {
    const addForm = document.getElementById('addSupplierForm');
    if (addForm) {
        addForm.reset(); // Xóa sạch dữ liệu trong các ô input
    }

    // Hiển thị modal bằng Bootstrap 5 API
    const addModal = new bootstrap.Modal(document.getElementById('addSupplierModal'));
    addModal.show();
}

/**
 * CHỨC NĂNG 2: MỞ MODAL CHỈNH SỬA (EDIT)
 * Lấy dữ liệu từ hàng hiện tại và đổ vào các ô nhập liệu của Modal Edit.
 * @param {HTMLElement} btn - Nút sửa (bút chì) được nhấn
 */
function openEditModal(btn) {
    // Trích xuất dữ liệu từ các thuộc tính data-* của nút
    const id = btn.getAttribute('data-id');
    const name = btn.getAttribute('data-name');
    const contact = btn.getAttribute('data-contact'); // Khớp với contactName trong Entity
    const email = btn.getAttribute('data-email');

    // Đổ dữ liệu vào các trường trong Edit Modal
    const editIdField = document.getElementById('editSupplierId');
    const editNameField = document.getElementById('editSupplierName');
    const editContactField = document.getElementById('editContactName');
    const editEmailField = document.getElementById('editEmail');

    if (editIdField) editIdField.value = id;
    if (editNameField) editNameField.value = name;
    if (editContactField) editContactField.value = contact;
    if (editEmailField) editEmailField.value = email;

    // Hiển thị Modal Chỉnh sửa
    const editModal = new bootstrap.Modal(document.getElementById('editSupplierModal'));
    editModal.show();
}

/**
 * CHỨC NĂNG 3: TÌM KIẾM TRỰC TIẾP (LIVE SEARCH)
 * Lọc danh sách nhà cung cấp ngay lập tức khi người dùng gõ phím.
 */
function initLiveSearch() {
    const searchInput = document.getElementById('searchInput');
    if (!searchInput) return;

    searchInput.addEventListener('input', function() {
        const keyword = this.value.toLowerCase().trim();
        const tableRows = document.querySelectorAll('.supplier-table-body tr');

        tableRows.forEach(row => {
            // Lấy toàn bộ nội dung văn bản của hàng để tìm kiếm
            const rowText = row.innerText.toLowerCase();
            if (rowText.includes(keyword)) {
                row.style.display = ''; // Hiện hàng nếu khớp từ khóa
            } else {
                row.style.display = 'none'; // Ẩn hàng nếu không khớp
            }
        });
    });
}

/**
 * CHỨC NĂNG 4: XÁC NHẬN XÓA (DELETE)
 * Hiển thị cảnh báo trước khi thực hiện xóa vĩnh viễn.
 */
function confirmDelete(id, name) {
    // Sử dụng template string để hiển thị tên nhà cung cấp trong cảnh báo
    if (confirm(`Are you sure you want to delete supplier: ${name} (ID: #${id})?`)) {
        // Điều hướng đến Controller xử lý xóa
        window.location.href = `/admin/suppliers/delete/${id}`;
    }
}