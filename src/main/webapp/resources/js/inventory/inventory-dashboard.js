document.getElementById('inventorySearch').addEventListener('input', function(e) {
    const keyword = e.target.value.toLowerCase();
    // Tìm thẻ dropdown item đang có class active để lấy giá trị filter hiện tại
    const activeItem = document.querySelector('.filter-dropdown .dropdown-item.active');
    const status = activeItem && activeItem.innerText !== 'All Status' ? activeItem.innerText.trim() : '';
    filterTable(keyword, status);
});

// 2. Hàm cập nhật Filter từ Dropdown mới
function updateFilter(value, text) {
    const btnSpan = document.querySelector('.filter-dropdown .btn-filter span');
    if (btnSpan) btnSpan.innerText = text;

    // Xử lý active class trong menu để UI đẹp hơn
    const items = document.querySelectorAll('.filter-dropdown .dropdown-item');
    items.forEach(item => {
        item.classList.remove('active');
        if (item.innerText === text) item.classList.add('active');
    });

    // Kích hoạt lại việc lọc bảng
    const keyword = document.getElementById('inventorySearch').value.toLowerCase();
    filterTable(keyword, value);
}

// 3. Hàm lọc bảng
function filterTable(keyword, status) {
    const rows = document.querySelectorAll('tbody tr');
    rows.forEach(row => {
        const text = row.innerText.toLowerCase();
        // Lấy text từ status-badge
        const badge = row.querySelector('.status-badge');
        const rowStatus = badge ? badge.innerText.trim() : '';

        const matchesKeyword = text.includes(keyword);
        const matchesStatus = status === "" || rowStatus === status;

        row.style.display = (matchesKeyword && matchesStatus) ? "" : "none";
    });
}

// 4. Hàm chỉnh sửa định mức tồn kho (Pop-up UI nâng cao & Full Tiếng Anh)
function editMinStock(productId, productName, currentMin) {
    Swal.fire({
        title: 'Edit Minimum Threshold',
        html: `
            <div class="text-start mb-3">
                <label class="form-label text-muted small fw-bold text-uppercase" style="letter-spacing: 0.5px;">Product Information</label>
                <div class="p-3 border rounded-3 bg-light d-flex flex-column gap-1">
                    <span class="fw-bold text-dark" style="font-size: 1.05rem;">${productName}</span>
                    <span class="text-primary fw-bold" style="font-family: monospace;">#${productId}</span>
                </div>
            </div>
            <div class="text-start">
                <label class="form-label text-muted small fw-bold text-uppercase" style="letter-spacing: 0.5px;">New Minimum Quantity</label>
                <input type="number" id="newMinStock" class="form-control form-control-lg fw-bold text-primary text-center" value="${currentMin}" min="0">
            </div>
        `,
        showCancelButton: true,
        confirmButtonColor: '#2563eb',
        cancelButtonColor: '#94a3b8',
        confirmButtonText: '<i class="fa-solid fa-floppy-disk me-2"></i>Save Changes',
        cancelButtonText: 'Cancel',
        borderRadius: '16px',
        preConfirm: () => {
            const newVal = document.getElementById('newMinStock').value;
            if (newVal === "" || newVal < 0) {
                Swal.showValidationMessage('Please enter a valid number (≥ 0)');
                return false;
            }
            return newVal;
        }
    }).then((result) => {
        if (result.isConfirmed) {
            const newMin = result.value;

            Swal.fire({
                title: 'Saving...',
                allowOutsideClick: false,
                didOpen: () => {
                    Swal.showLoading();
                }
            });

            fetch(`/inventory/updateMinStock?productId=${productId}&minThreshold=${newMin}`, {
                method: 'POST',
            })
                .then(response => {
                    if (response.ok) {
                        // Cập nhật giao diện (UI) ngay lập tức mà không cần reload trang
                        const rows = Array.from(document.querySelectorAll('tbody tr'));
                        const row = rows.find(tr => {
                            const skuEl = tr.querySelector('.text-sku');
                            return skuEl && skuEl.innerText.includes(productId);
                        });

                        if (row) {
                            // Cập nhật con số ở cột Min Stock (cột thứ 4)
                            const minCell = row.cells[3].querySelector('.badge');
                            if (minCell) minCell.innerText = newMin;

                            // Cập nhật lại giá trị truyền vào hàm onclick để lần tới mở Pop-up hiển thị số mới nhất
                            const actionBtn = row.querySelector('a[onclick*="editMinStock"]');
                            if (actionBtn) {
                                // Xử lý chống lỗi dấu nháy đơn trong tên sản phẩm
                                const safeName = productName.replace(/'/g, "\\'");
                                actionBtn.setAttribute('onclick', `editMinStock('${productId}', '${safeName}', ${newMin})`);
                            }
                        }

                        Swal.fire({
                            icon: 'success',
                            title: 'Updated!',
                            text: 'Minimum threshold has been updated successfully.',
                            timer: 1500,
                            showConfirmButton: false,
                            borderRadius: '16px'
                        });
                    } else {
                        Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: 'An error occurred while saving data.',
                            confirmButtonColor: '#2563eb',
                            borderRadius: '16px'
                        });
                    }
                })
                .catch(error => {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Cannot connect to the server.',
                        confirmButtonColor: '#2563eb',
                        borderRadius: '16px'
                    });
                });
        }
    });
}