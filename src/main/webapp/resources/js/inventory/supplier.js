document.addEventListener('DOMContentLoaded', () => initLiveSearch());

function prepareAddModal() {
    document.getElementById('addSupplierForm').reset();

    // Sử dụng getOrCreateInstance để ngăn việc tạo ra nhiều modal xếp chồng gây kẹt nền xám
    const modalElement = document.getElementById('addSupplierModal');
    const modal = bootstrap.Modal.getOrCreateInstance(modalElement);
    modal.show();
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

    // Sử dụng getOrCreateInstance để sửa lỗi kẹt nền xám
    const modalElement = document.getElementById('editSupplierModal');
    const modal = bootstrap.Modal.getOrCreateInstance(modalElement);
    modal.show();
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

// Nâng cấp hàm Delete sử dụng SweetAlert2 cho đồng bộ UI
function confirmDelete(id, name) {
    Swal.fire({
        title: 'Delete Supplier?',
        html: `Bạn có chắc chắn muốn xóa nhà cung cấp <b>${name}</b> (#${id})?<br>Hành động này không thể hoàn tác!`,
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#dc2626', // Màu đỏ (Danger)
        cancelButtonColor: '#94a3b8', // Màu xám (Muted)
        confirmButtonText: '<i class="fa-solid fa-trash-can me-2"></i>Yes, delete it',
        cancelButtonText: 'Cancel',
        customClass: {
            confirmButton: 'btn btn-danger px-4 py-2 rounded-3 fw-bold',
            cancelButton: 'btn btn-secondary px-4 py-2 rounded-3 fw-bold ms-2'
        },
        buttonsStyling: false // Tắt style mặc định để dùng class của Bootstrap
    }).then((result) => {
        if (result.isConfirmed) {
            window.location.href = `/suppliers/delete/${id}`;
        }
    });
}