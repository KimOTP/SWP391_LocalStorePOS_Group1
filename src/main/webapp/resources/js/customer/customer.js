
document.addEventListener("DOMContentLoaded", function() {
    // Xử lý Auto Submit cho Form Filter
    const filterForm = document.getElementById('filterForm');

    if (filterForm) {
        // Lấy tất cả các thẻ select và input có trong form
        const inputs = filterForm.querySelectorAll('select, input[name="keyword"]');

        inputs.forEach(input => {
            input.addEventListener('change', function() {
                // Khi người dùng thay đổi giá trị -> Tự động submit form
                filterForm.submit();
            });
        });
    }
});

// Hàm mở Modal Edit và điền dữ liệu cũ vào
function openEditModal(id, name, phone, status, point) {
    // 1. Gán giá trị vào các ô input trong Modal Edit
    document.getElementById('editId').value = id;
    document.getElementById('editName').value = name;
    document.getElementById('editPhone').value = phone;
    document.getElementById('editStatus').value = status;
    document.getElementById('editPoint').value = point;

    // 2. Hiển thị Modal lên
    var editModal = new bootstrap.Modal(document.getElementById('editCustomerModal'));
    editModal.show();
}

// Hàm xác nhận Xóa
function confirmDelete(id, name) {
    // Hiện hộp thoại xác nhận của trình duyệt
    if (confirm("Bạn có chắc chắn muốn xóa khách hàng: " + name + " không?")) {
        // Nếu chọn OK -> Chuyển hướng đến đường dẫn xóa
        window.location.href = "/customers/delete/" + id;
    }
}