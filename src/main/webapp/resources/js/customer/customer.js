
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
    document.getElementById('detailCode').innerText = id;
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
    // Reset về 0 hoặc Loading trước khi gọi API
    document.getElementById('detailTotalOrder').innerText = "...";
    // Gọi API lấy số lượng đơn hàng
        fetch('/customers/' + id + '/order-count')
            .then(response => response.json())
            .then(count => {
                document.getElementById('detailTotalOrder').innerText = count;
            })
            .catch(error => {
                console.error(error);
                document.getElementById('detailTotalOrder').innerText = "0";
            });

    // 2. Load lịch sử TAB 3 (Gọi API)
    const historyTableBody = document.querySelector('#history-info tbody');
        historyTableBody.innerHTML = '<tr><td colspan="4" class="text-center text-muted py-3">Loading history...</td></tr>';

        fetch('/customers/' + id + '/history')
            .then(response => {
                if (!response.ok) throw new Error('Server error');
                return response.json();
            })
            .then(data => {
                historyTableBody.innerHTML = '';

                if (!data || data.length === 0) {
                    historyTableBody.innerHTML = '<tr><td colspan="4" class="text-center text-muted py-3">No transaction history found.</td></tr>';
                } else {
                    data.forEach(item => {
                        // 1. XỬ LÝ DỮ LIỆU TỪ ORDER (QUAN TRỌNG)
                        let orderIdDisplay = '-';
                        let dateDisplay = '-';
                        let totalAmountDisplay = '-';

                        // Kiểm tra xem bản ghi này có gắn với Order nào không?
                        if (item.order) {
                            // Order ID: Thêm tiền tố HD cho giống ảnh
                            orderIdDisplay =  item.order.orderId;

                            // Date: Lấy ngày tạo của ORDER (item.order.createdAt)
                            if (item.order.createdAt) {
                                dateDisplay = new Date(item.order.createdAt).toLocaleString('vi-VN');
                            }

                            // Total Amount: Lấy tổng tiền của ORDER
                            if (item.order.totalAmount) {
                                totalAmountDisplay = formatter.format(item.order.totalAmount);
                            }
                        } else {
                            // Trường hợp không có Order (ví dụ: Admin cộng điểm tay)
                            orderIdDisplay = 'System';
                            // Lấy ngày tạo của lịch sử nếu không có order
                            dateDisplay = new Date(item.createdAt).toLocaleString('vi-VN');
                        }

                        // 2. XỬ LÝ ĐIỂM (POINT)
                        // Logic: Action EARN hoặc số dương là màu xanh, USE hoặc số âm là màu đỏ
                        let pointClass = item.pointAmount >= 0 ? 'text-success' : 'text-danger';
                        let pointSign = item.pointAmount > 0 ? '+' : '';

                        // 3. VẼ DÒNG HTML (Chuẩn theo 4 cột trong ảnh)
                        let row = `
                            <tr class="border-bottom">
                                <td class="fw-medium">${orderIdDisplay}</td>
                                <td>${dateDisplay}</td>
                                <td class="${pointClass} fw-bold">${pointSign}${item.pointAmount}</td>
                                <td class="text-end text-dark">${totalAmountDisplay}</td>
                            </tr>
                        `;
                        historyTableBody.insertAdjacentHTML('beforeend', row);
                    });
                }

                // Cập nhật số lượng bản ghi
                document.querySelector('#history-info h6').innerText = `Transaction history (${data.length})`;
            })
            .catch(error => {
                console.error(error);
                historyTableBody.innerHTML = '<tr><td colspan="4" class="text-center text-danger">Failed to load history.</td></tr>';
            });

    // 3. Hiện Modal
    new bootstrap.Modal(document.getElementById('detailCustomerModal')).show();
}

// Modal Config Point
function openConfigModal() {
    // 1. Fetch dữ liệu từ API
    fetch('/customers/config')
        .then(response => response.json())
        .then(data => {
            // 2. Điền dữ liệu vào form (Dùng key trong Map trả về)
            if (data) {
                document.getElementById('confEarning').value = data.POINT_EARNING_RATE || 10000;
                document.getElementById('confRedemption').value = data.POINT_REDEMPTION_VALUE || 100;
                document.getElementById('confMaxPercent').value = data.MAX_REDEEM_PERCENT || 50;
                document.getElementById('confMinPoint').value = data.MIN_POINT_TO_REDEEM || 10;
            }
            // 3. Show Modal
            var configModal = new bootstrap.Modal(document.getElementById('configPointModal'));
            configModal.show();
        })
        .catch(error => {
            console.error('Lỗi load config:', error);
            // Vẫn hiện modal dù lỗi để người dùng nhập tay
            var configModal = new bootstrap.Modal(document.getElementById('configPointModal'));
            configModal.show();
        });
}

function openEditPromotionModal(id, name, status, startDate, endDate) {
    // 1. Điền ID, Name, Status
    document.getElementById('editPromoId').value = id;
    document.getElementById('editPromoName').value = name;
    document.getElementById('editStatus').value = status;

    // 2. Xử lý ngày tháng (Cắt chuỗi lấy 10 ký tự đầu: yyyy-MM-dd)
    if (startDate && startDate.length >= 10) {
        document.getElementById('editStartDate').value = startDate.substring(0, 10);
    }
    if (endDate && endDate.length >= 10) {
        document.getElementById('editEndDate').value = endDate.substring(0, 10);
    }

    // 3. Hiện Modal
    var editModal = new bootstrap.Modal(document.getElementById('editPromotionModal'));
    editModal.show();
}
//Logic check startDate và endDate
function validatePromotionForm(form) {
    // Lấy giá trị từ các ô input trong form đang submit
    // form.querySelector để tìm input bên trong form đó (xử lý cho cả Add và Edit)
    let startDateInput = form.querySelector("input[name='startDate']");
    let endDateInput = form.querySelector("input[name='endDate']");

    let startDate = new Date(startDateInput.value);
    let endDate = new Date(endDateInput.value);

    // So sánh ngày
    if (endDate < startDate) {
        alert("Ngày kết thúc phải lớn hơn hoặc bằng ngày bắt đầu!");
        return false; // Chặn không cho submit
    }
    return true; // Cho phép submit
}