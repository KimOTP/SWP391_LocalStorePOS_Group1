/**
 * Inventory Logs & Reports Filtering Logic
 * Synchronized with Approval Queue UI Standard
 */

document.addEventListener('DOMContentLoaded', function() {
    // 1. Tự động lấy danh sách nhân viên từ bảng để đưa vào dropdown filter
    initStaffFilter();

    // 2. Kiểm tra thông báo từ Server (SweetAlert2)
    checkServerNotifications();

    // 3. Đăng ký sự kiện thay đổi cho TẤT CẢ các bộ lọc
    const filters = ['dateFilter', 'staffFilter', 'typeFilter', 'statusFilter'];
    filters.forEach(id => {
        const el = document.getElementById(id);
        if (el) el.addEventListener('change', filterTable);
    });
});

/**
 * Tự động quét cột Staff trong bảng để tạo danh sách lọc duy nhất
 */
function initStaffFilter() {
    const staffCells = document.querySelectorAll('.staff-cell');
    const staffSelect = document.getElementById('staffFilter');

    if (!staffSelect) return;

    // QUAN TRỌNG: Làm sạch dropdown trước khi thêm, chỉ giữ lại option "All Staff"
    staffSelect.innerHTML = '<option value="ALL">All Staff</option>';

    const staffList = new Set();

    // Thu thập tên nhân viên không trùng lặp
    staffCells.forEach(cell => {
        const name = cell.innerText.trim();
        if (name) staffList.add(name);
    });

    // Thêm các option vào dropdown
    staffList.forEach(staffName => {
        const option = document.createElement('option');
        option.value = staffName;
        option.innerText = staffName;
        staffSelect.appendChild(option);
    });
}

/**
 * Hàm lọc bảng dựa trên các giá trị đã chọn
 */
function filterTable() {
    const selectedDate = document.getElementById('dateFilter')?.value;
    const selectedStaff = document.getElementById('staffFilter')?.value;
    const selectedType = document.getElementById('typeFilter')?.value;
    const selectedStatus = document.getElementById('statusFilter')?.value;

    const rows = document.querySelectorAll('.request-row');

    rows.forEach(row => {
        const rowDate = row.getAttribute('data-date');
        const rowStaff = row.getAttribute('data-staff');
        const rowType = row.getAttribute('data-type');
        const rowStatus = row.getAttribute('data-status');

        const dateMatch = !selectedDate || rowDate === selectedDate;
        const staffMatch = !selectedStaff || selectedStaff === 'ALL' || rowStaff === selectedStaff;
        const typeMatch = !selectedType || selectedType === 'ALL' || rowType === selectedType;
        const statusMatch = !selectedStatus || selectedStatus === 'ALL' || rowStatus === selectedStatus;

        // Phải khớp cả 4 điều kiện
        if (dateMatch && staffMatch && typeMatch && statusMatch) {
            row.style.display = '';
        } else {
            row.style.display = 'none';
        }
    });
}

/**
 * Làm mới toàn bộ bộ lọc về trạng thái ban đầu
 */
function resetFilters() {
    const dateInput = document.getElementById('dateFilter');
    const staffSelect = document.getElementById('staffFilter');
    const typeSelect = document.getElementById('typeFilter');
    const statusSelect = document.getElementById('statusFilter');

    if (dateInput) dateInput.value = '';
    if (staffSelect) staffSelect.value = 'ALL';
    if (typeSelect) typeSelect.value = 'ALL';
    if (statusSelect) statusSelect.value = 'ALL';

    // Hiển thị lại toàn bộ các hàng
    filterTable();
}

/**
 * Hiển thị thông báo Pop-up (SweetAlert2) nếu có dữ liệu từ Server
 */
function checkServerNotifications() {
    const messageInput = document.getElementById('serverMessage');
    const statusInput = document.getElementById('serverStatus');

    if (messageInput && messageInput.value.trim() !== "") {
        const message = messageInput.value;
        const status = statusInput ? statusInput.value : 'info';

        Swal.fire({
            icon: status === 'success' ? 'success' : 'error',
            title: status === 'success' ? 'Action Completed' : 'Notification',
            text: message,
            confirmButtonColor: '#2563eb',
            borderRadius: '12px'
        });
    }
}