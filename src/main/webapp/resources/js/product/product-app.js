// --- 1. Xử lý Xem trước ảnh (Add/Update) ---
function initImagePreview() {
    const imageInput = document.getElementById('imageInput');
    const container = document.getElementById('previewContainer');

    if (imageInput && container) {
        imageInput.addEventListener('change', function(evt) {
            const file = evt.target.files[0];
            if (file) {
                if (!file.type.startsWith('image/')) {
                    alert("Please select image!");
                    return;
                }
                const imgUrl = URL.createObjectURL(file);
                container.innerHTML = '';
                const newImg = document.createElement('img');
                newImg.src = imgUrl;
                newImg.style.width = '100%';
                newImg.style.height = '100%';
                newImg.style.objectFit = 'cover';
                newImg.style.display = 'block';
                newImg.style.borderRadius = '10px';
                container.appendChild(newImg);

                newImg.onload = () => URL.revokeObjectURL(imgUrl);
            }
        });
    }
}

// --- 2. Xử lý Modal Xem chi tiết (Manage) ---
function initProductDetails() {
    const viewButtons = document.querySelectorAll('.btn-view-detail');
    const modalElement = document.getElementById('productDetailModal');

    if (viewButtons.length > 0 && modalElement) {
        const modal = new bootstrap.Modal(modalElement);
        const modalBody = document.getElementById('modalBodyContent');

        viewButtons.forEach(btn => {
            btn.addEventListener('click', function() {
                const productId = this.getAttribute('data-id');
                const baseUrl = this.getAttribute('data-url');

                modal.show();
                modalBody.innerHTML = '<div class="text-center py-5"><div class="spinner-border text-primary"></div></div>';

                fetch(`${baseUrl}/${productId}`)
                    .then(response => {
                        if (!response.ok) throw new Error('Can not load data!');
                        return response.text();
                    })
                    .then(html => {
                        modalBody.innerHTML = html;
                    })
                    .catch(err => {
                        modalBody.innerHTML = `<div class="alert alert-danger">Error: ${err.message}</div>`;
                    });
            });
        });
    }
}

// --- 3. Xử lý Lọc dữ liệu tại bảng (Client-side Filter) ---
function initTableFilter() {
    const searchInput = document.getElementById('jsSearchInput');
    const checkboxes = document.querySelectorAll('.filter-checkbox');
    const tableRows = document.querySelectorAll('table tbody tr');

    if (!searchInput || tableRows.length === 0) return;

    function filterTable() {
        const searchText = searchInput.value.toLowerCase().trim();

        // 1. Lấy danh sách các giá trị đang được tick (Nếu không tick cái nào, mảng sẽ rỗng)
        const selectedStatuses = Array.from(document.querySelectorAll('.status-cb:checked')).map(cb => cb.value.trim());
        const selectedCategories = Array.from(document.querySelectorAll('.category-cb:checked')).map(cb => cb.value.trim());
        const selectedUnits = Array.from(document.querySelectorAll('.unit-cb:checked')).map(cb => cb.value.trim());

        tableRows.forEach(row => {
            // 2. Lấy dữ liệu text từ các cột
            const name = row.querySelector('.product-name').innerText.toLowerCase();
            const sku = row.querySelector('td:nth-child(1)').innerText.toLowerCase();
            const category = row.querySelector('td:nth-child(4)').innerText.trim();
            const unit = row.querySelector('td:nth-child(5)').innerText.trim();
            const status = row.querySelector('td:nth-child(7)').innerText.trim();

            // 3. Logic kiểm tra Search
            const matchesSearch = name.includes(searchText) || sku.includes(searchText);

            // 4. Logic kiểm tra Checkbox (Nếu mảng rỗng => hiện tất cả)
            const matchesStatus = selectedStatuses.length === 0 || selectedStatuses.includes(status);
            const matchesCategory = selectedCategories.length === 0 || selectedCategories.includes(category);
            const matchesUnit = selectedUnits.length === 0 || selectedUnits.includes(unit);

            // 5. Hiển thị hàng nếu khớp TẤT CẢ các tiêu chí
            if (matchesSearch && matchesStatus && matchesCategory && matchesUnit) {
                row.style.display = "";
            } else {
                row.style.display = "none";
            }
        });
    }

    // Gán sự kiện
    searchInput.addEventListener('input', filterTable);
    checkboxes.forEach(cb => {
        cb.addEventListener('change', filterTable);
    });
}


// --- 4. Khởi tạo tất cả khi trang tải xong ---
document.addEventListener('DOMContentLoaded', function() {
    initImagePreview();
    initProductDetails();
    initTableFilter();
});