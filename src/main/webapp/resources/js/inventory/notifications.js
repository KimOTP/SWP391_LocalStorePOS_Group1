document.addEventListener('DOMContentLoaded', function() {
    // Xử lý thông báo Pop-up từ Server
    const message = document.getElementById('serverMessage').value;
    const status = document.getElementById('serverStatus').value;

    if (message && message.trim() !== "") {
        const Toast = Swal.mixin({
            toast: true,
            position: 'top-end',
            showConfirmButton: false,
            timer: 3000,
            timerProgressBar: true
        });

        Toast.fire({
            icon: status === 'success' ? 'success' : 'error',
            title: message
        });
    }
});
document.addEventListener('DOMContentLoaded', function() {
    initRequesterFilter();

    // Lắng nghe sự kiện thay đổi ngày
    document.getElementById('dateFilter').addEventListener('change', filterTable);

    // Lắng nghe thông báo từ Server
    checkServerMessages();
});

function initRequesterFilter() {
    const rows = document.querySelectorAll('.request-row');
    const requesters = new Set();
    const menu = document.getElementById('requesterFilterMenu');

    // Lấy danh sách duy nhất tên người yêu cầu
    rows.forEach(row => requesters.add(row.getAttribute('data-requester')));

    // Tạo các checkbox trong dropdown
    requesters.forEach(name => {
        const label = document.createElement('label');
        label.className = 'dropdown-item d-flex align-items-center py-2';
        label.innerHTML = `
            <input type="checkbox" class="requester-cb" value="${name}" checked>
            <span class="ms-2">${name}</span>
        `;
        menu.appendChild(label);
    });

    // Lắng nghe sự kiện checkbox
    menu.querySelectorAll('input').forEach(cb => {
        cb.addEventListener('change', filterTable);
    });
}

function filterTable() {
    const selectedDate = document.getElementById('dateFilter').value; // định dạng YYYY-MM-DD
    const selectedRequesters = Array.from(document.querySelectorAll('.requester-cb:checked')).map(cb => cb.value);
    const showAllRequesters = document.querySelector('.filter-cb-all').checked;

    const rows = document.querySelectorAll('.request-row');

    rows.forEach(row => {
        const rowDate = row.getAttribute('data-date'); // YYYY-MM-DD
        const rowRequester = row.getAttribute('data-requester');

        const dateMatch = !selectedDate || rowDate === selectedDate;
        const requesterMatch = showAllRequesters || selectedRequesters.includes(rowRequester);

        if (dateMatch && requesterMatch) {
            row.style.display = '';
        } else {
            row.style.display = 'none';
        }
    });

    updateRequesterLabel();
}

function updateRequesterLabel() {
    const checked = document.querySelectorAll('.requester-cb:checked').length;
    const total = document.querySelectorAll('.requester-cb').length;
    const label = document.getElementById('requesterLabel');

    if (document.querySelector('.filter-cb-all').checked || checked === total) {
        label.innerText = "All Requesters";
    } else {
        label.innerText = `${checked} Selected`;
    }
}

function resetFilters() {
    document.getElementById('dateFilter').value = '';
    document.querySelectorAll('#requesterFilterMenu input').forEach(cb => cb.checked = true);
    filterTable();
}

function checkServerMessages() {
    const message = document.getElementById('serverMessage')?.value;
    const status = document.getElementById('serverStatus')?.value;
    if (message && message.trim() !== "") {
        Swal.fire({
            toast: true, position: 'top-end', icon: status === 'success' ? 'success' : 'error',
            title: message, showConfirmButton: false, timer: 3000
        });
    }
}