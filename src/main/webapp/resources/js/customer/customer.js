
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

const formatter = new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' });

function openDetailModal(id, name, phone, point, spending, lastDate) {
    // 1. Điền thông tin TAB 1 & 2 (Dữ liệu có sẵn trên bảng)
    document.getElementById('detailCode').innerText = "KH00" + id;
    document.getElementById('detailName').innerText = name;
    document.getElementById('detailPhone').innerText = phone;
    document.getElementById('detailPoint').innerText = point;

    let amount = (spending && spending !== 'null') ? spending : 0;
    document.getElementById('detailSpending').innerText = formatter.format(amount);

    if (lastDate && lastDate !== 'null' && lastDate.length >= 10) {
        document.getElementById('detailLastDate').innerText = lastDate.substring(0, 10);
    } else {
        document.getElementById('detailLastDate').innerText = "-";
    }

    // 2. Load lịch sử TAB 3 (Gọi API)
    const historyTableBody = document.querySelector('#history-info tbody');
    historyTableBody.innerHTML = '<tr><td colspan="4" class="text-center text-muted py-3">Loading history...</td></tr>';

    fetch('/customers/' + id + '/history')
        .then(response => response.json())
        .then(data => {
            historyTableBody.innerHTML = '';

            if (!data || data.length === 0) {
                historyTableBody.innerHTML = '<tr><td colspan="4" class="text-center text-muted py-3">No transaction history found.</td></tr>';
            } else {
                data.forEach(item => {
                    // Date
                    let dateStr = item.createdAt ? new Date(item.createdAt).toLocaleString('vi-VN') : '-';

                    // Point Color
                    let pointClass = item.pointAmount >= 0 ? 'text-success' : 'text-danger';
                    let pointSign = item.pointAmount > 0 ? '+' : '';

                    // Order Info (Kiểm tra null)
                    let orderAmount = 0;
                    let descDisplay = item.description || item.actionType;

                    if (item.order) {
                        // SỬA CHỖ NÀY: Thay 'totalAmount' bằng tên field thật trong Entity Order của bạn
                        orderAmount = item.order.totalAmount || 0;
                        descDisplay = 'Order #' + (item.order.orderId || '');
                    }

                    let row = `
                        <tr class="border-bottom">
                            <td>${descDisplay}</td>
                            <td>${dateStr}</td>
                            <td class="${pointClass} fw-bold">${pointSign}${item.pointAmount}</td>
                            <td class="text-end">${formatter.format(orderAmount)}</td>
                        </tr>
                    `;
                    historyTableBody.insertAdjacentHTML('beforeend', row);
                });
            }
            document.querySelector('#history-info h6').innerText = `Transaction history (${data.length})`;
        })
        .catch(error => {
            console.error(error);
            historyTableBody.innerHTML = '<tr><td colspan="4" class="text-center text-danger">Failed to load history.</td></tr>';
        });

    // 3. Hiện Modal
    new bootstrap.Modal(document.getElementById('detailCustomerModal')).show();
}