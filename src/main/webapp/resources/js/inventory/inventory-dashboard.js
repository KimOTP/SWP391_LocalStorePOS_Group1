// 1. Tính năng tìm kiếm thời gian thực
document.getElementById('inventorySearch').addEventListener('input', function(e) {
    const keyword = e.target.value.toLowerCase();
    // Lấy giá trị từ input hidden thay vì thẻ select cũ
    const status = document.getElementById('statusFilterValue').value;
    filterTable(keyword, status);
});

// 2. Hàm cập nhật Filter từ Dropdown mới (Thay thế cho sự kiện 'change' của select)
function updateFilter(value, text) {
    const btnSpan = document.querySelector('#statusFilterBtn span');
    if (btnSpan) btnSpan.innerText = text;

    // Cập nhật giá trị vào input hidden
    const hiddenInput = document.getElementById('statusFilterValue');
    hiddenInput.value = value;

    // Xử lý active class trong menu (tùy chọn để giao diện đẹp hơn)
    const items = document.querySelectorAll('.filter-dropdown .dropdown-item');
    items.forEach(item => {
        item.classList.remove('active');
        if (item.innerText === text) item.classList.add('active');
    });

    // Kích hoạt lại việc lọc bảng
    const keyword = document.getElementById('inventorySearch').value.toLowerCase();
    filterTable(keyword, value);
}

// 3. Hàm lọc bảng (Giữ nguyên logic của bạn nhưng tối ưu một chút)
function filterTable(keyword, status) {
    const rows = document.querySelectorAll('tbody tr');
    rows.forEach(row => {
        const text = row.innerText.toLowerCase();
        // Lấy text từ status-badge
        const rowStatus = row.querySelector('.status-badge').innerText.trim();

        const matchesKeyword = text.includes(keyword);
        const matchesStatus = status === "" || rowStatus === status;

        row.style.display = (matchesKeyword && matchesStatus) ? "" : "none";
    });
}

// 4. Hàm chỉnh sửa định mức tồn kho (Đã đồng bộ màu sắc với design mới)
function editMinStock(productId, currentMin) {
    Swal.fire({
        title: 'Edit Minimum Stock',
        html: `<p class="text-muted">Cập nhật định mức tồn kho tối thiểu cho SKU: <b>${productId}</b></p>`,
        input: 'number',
        inputValue: currentMin,
        showCancelButton: true,
        confirmButtonText: 'Update',
        confirmButtonColor: '#2563eb', // Màu Blue đồng bộ design
        cancelButtonText: 'Cancel',
        customClass: {
            confirmButton: 'px-4 py-2',
            cancelButton: 'px-4 py-2'
        },
        preConfirm: (newValue) => {
            if (newValue === "" || newValue < 0) {
                Swal.showValidationMessage('Vui lòng nhập số lượng hợp lệ (>= 0)');
            }
            return newValue;
        }
    }).then((result) => {
        if (result.isConfirmed) {
            const newMin = result.value;

            // Hiển thị loading khi đang fetch
            Swal.showLoading();

            fetch(`/inventory/updateMinStock?productId=${productId}&minThreshold=${newMin}`, {
                method: 'POST',
            })
                .then(response => {
                    if (response.ok) {
                        // Cập nhật UI tại chỗ
                        const row = document.querySelector(`tr:has(td.text-sku:contains('${productId}'))`) ||
                            Array.from(document.querySelectorAll('.text-sku')).find(el => el.innerText.trim() === productId)?.closest('tr');

                        if (row) {
                            // Tìm cell chứa Min Stock (cell thứ 4 trong table refactor trước đó)
                            const minCell = row.cells[3].querySelector('.badge');
                            if (minCell) minCell.innerText = newMin;

                            // Cập nhật lại giá trị trong onclick của dropdown để lần sau mở lên có số mới
                            const actionBtn = row.querySelector('a[onclick*="editMinStock"]');
                            if (actionBtn) {
                                actionBtn.setAttribute('onclick', `editMinStock('${productId}', ${newMin})`);
                            }
                        }

                        Swal.fire({
                            icon: 'success',
                            title: 'Updated!',
                            text: 'Định mức tồn kho đã được cập nhật thành công.',
                            timer: 1500,
                            showConfirmButton: false
                        });
                    } else {
                        Swal.fire('Error!', 'Có lỗi xảy ra khi lưu dữ liệu.', 'error');
                    }
                })
                .catch(error => {
                    Swal.fire('Error!', 'Không thể kết nối đến máy chủ.', 'error');
                });
        }
    });
}