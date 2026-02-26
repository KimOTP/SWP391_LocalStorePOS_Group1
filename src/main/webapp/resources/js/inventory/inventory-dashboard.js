// Tính năng tìm kiếm và lọc trạng thái thời gian thực
document.getElementById('inventorySearch').addEventListener('input', function(e) {
    const keyword = e.target.value.toLowerCase();
    filterTable(keyword, document.getElementById('statusFilter').value);
});

document.getElementById('statusFilter').addEventListener('change', function(e) {
    filterTable(document.getElementById('inventorySearch').value.toLowerCase(), e.target.value);
});

function filterTable(keyword, status) {
    const rows = document.querySelectorAll('tbody tr');
    rows.forEach(row => {
        const text = row.innerText.toLowerCase();
        const rowStatus = row.querySelector('.status-badge').innerText.trim();

        const matchesKeyword = text.includes(keyword);
        const matchesStatus = status === "" || rowStatus === status;

        row.style.display = (matchesKeyword && matchesStatus) ? "" : "none";
    });
}

// Hàm chỉnh sửa định mức tồn kho tối thiểu
function editMinStock(productId, currentMin) {
    Swal.fire({
        title: 'Edit Minimum Stock',
        input: 'number',
        inputValue: currentMin,
        showCancelButton: true,
        confirmButtonText: 'Update',
        confirmButtonColor: '#2563eb',
        preConfirm: (newValue) => {
            // Kiểm tra nếu người dùng không nhập gì hoặc nhập số âm
            if (!newValue || newValue < 0) {
                Swal.showValidationMessage('Vui lòng nhập số lượng hợp lệ');
            }
            return newValue;
        }
    }).then((result) => {
        if (result.isConfirmed) {
            const newMin = result.value;

            fetch(`/inventory/updateMinStock?productId=${productId}&minThreshold=${newMin}`, {
                method: 'POST',
            })
                .then(response => {
                    if (response.ok) {
                        const cell = document.getElementById(`min-stock-${productId}`);
                        if (cell) {
                            cell.innerText = newMin;
                        }

                        Swal.fire('Updated!', 'Định mức tồn kho đã được cập nhật.', 'success');
                    } else {
                        Swal.fire('Error!', 'Có lỗi xảy ra khi lưu dữ liệu.', 'error');
                    }
                    const actionBtn = document.querySelector(`a[onclick*="editMinStock('${productId}'"]`);
                    if (actionBtn) {
                        actionBtn.setAttribute('onclick', `editMinStock('${productId}', ${newMin})`);
                    }
                })
                .catch(error => {
                    Swal.fire('Error!', 'Không thể kết nối đến máy chủ.', 'error');
                });
        }
    });
}