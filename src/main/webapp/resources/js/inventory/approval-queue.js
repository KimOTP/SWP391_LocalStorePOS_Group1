document.addEventListener('DOMContentLoaded', function() {
    checkServerNotifications();
    initFilters();

    // Attach listeners to filters
    document.getElementById('dateFilter').addEventListener('change', filterTable);
    document.getElementById('staffFilter').addEventListener('change', filterTable);
    document.getElementById('typeFilter').addEventListener('change', filterTable);
});

window.handleApproval = function(type, id, isApprove) {
    const actionText = isApprove ? "approve" : "reject";
    const actionColor = isApprove ? "#16a34a" : "#dc2626";

    Swal.fire({
        title: `Confirm ${actionText.toUpperCase()}?`,
        text: `Are you sure you want to ${actionText} this ${type} request (#${id})?`,
        icon: 'question',
        showCancelButton: true,
        confirmButtonColor: actionColor,
        cancelButtonColor: '#64748b',
        confirmButtonText: `Yes, ${actionText} it!`,
        cancelButtonText: 'Cancel'
    }).then((result) => {
        if (result.isConfirmed) {
            // Show loading animation
            Swal.fire({
                title: 'Processing...',
                allowOutsideClick: false,
                didOpen: () => { Swal.showLoading(); }
            });

            // Populate form and submit
            document.getElementById('actionType').value = type;
            document.getElementById('actionId').value = id;
            document.getElementById('isApprove').value = isApprove;
            document.getElementById('actionForm').submit();
        }
    });
};

function filterTable() {
    const dateVal = document.getElementById('dateFilter').value;
    const staffVal = document.getElementById('staffFilter').value;
    const typeVal = document.getElementById('typeFilter').value;

    const rows = document.querySelectorAll('.request-row');

    rows.forEach(row => {
        const rowDate = row.getAttribute('data-date');
        const rowStaff = row.getAttribute('data-staff');
        const rowType = row.getAttribute('data-type');

        const dateMatch = !dateVal || rowDate === dateVal;
        const staffMatch = staffVal === 'ALL' || rowStaff === staffVal;
        const typeMatch = typeVal === 'ALL' || rowType === typeVal;

        row.style.display = (dateMatch && staffMatch && typeMatch) ? '' : 'none';
    });
}

function initFilters() {
    const staffSet = new Set();
    document.querySelectorAll('.staff-cell').forEach(cell => staffSet.add(cell.innerText.trim()));

    const staffSelect = document.getElementById('staffFilter');
    staffSet.forEach(name => {
        const opt = document.createElement('option');
        opt.value = name;
        opt.innerText = name;
        staffSelect.appendChild(opt);
    });
}

function resetFilters() {
    document.getElementById('dateFilter').value = '';
    document.getElementById('staffFilter').value = 'ALL';
    document.getElementById('typeFilter').value = 'ALL';
    filterTable();
}

function checkServerNotifications() {
    const message = document.getElementById('serverMessage')?.value;
    const status = document.getElementById('serverStatus')?.value;

    if (message && message.trim() !== "") {
        Swal.fire({
            icon: status === 'success' ? 'success' : 'error',
            title: status === 'success' ? 'Action Completed' : 'Process Failed',
            text: message,
            confirmButtonColor: '#2563eb'
        });
    }
}