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
    // Tìm tất cả các nút có class 'btn-view-detail'
    const viewButtons = document.querySelectorAll('.btn-view-detail');
    const modalElement = document.getElementById('productDetailModal');

    if (viewButtons.length > 0 && modalElement) {
        const modal = new bootstrap.Modal(modalElement);
        const modalBody = document.getElementById('modalBodyContent');

        viewButtons.forEach(btn => {
            btn.addEventListener('click', function() {
                const productId = this.getAttribute('data-id');
                const baseUrl = this.getAttribute('data-url'); // Lấy URL từ thuộc tính data-url

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
                        modalBody.innerHTML = `<div class="alert alert-danger"Error: ${err.message}</div>`;
                    });
            });
        });
    }
}

// --- 3. Khởi tạo khi trang tải xong ---
document.addEventListener('DOMContentLoaded', function() {
    initImagePreview();
    initProductDetails();
});