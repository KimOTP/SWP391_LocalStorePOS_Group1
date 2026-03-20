document.addEventListener('DOMContentLoaded', function() {
    checkServerNotifications();

    // Logic to restore old values if server returns an error
    const oldDataRaw = document.getElementById('oldActualDataJson')?.value;
    if (oldDataRaw && oldDataRaw !== "") {
        try {
            const oldData = JSON.parse(oldDataRaw);
            oldData.forEach(item => {
                // Find the row by detailId and update the input
                const row = document.querySelector(`tr[data-detail-id="${item.detailId}"]`);
                if (row) {
                    const input = row.querySelector('.input-actual');
                    if (input) input.value = item.actualQty;
                }
            });
        } catch (e) {
            console.error("Error restoring old data:", e);
        }
    }
});

window.submitStockIn = function() {
    const rows = document.querySelectorAll('#processTable tbody tr');
    const data = [];
    let hasError = false;

    rows.forEach(row => {
        const detailId = row.getAttribute('data-detail-id');
        const actualQtyInput = row.querySelector('.input-actual');

        if (detailId && actualQtyInput) {
            const val = parseFloat(actualQtyInput.value);

            // Validate negative value
            if (isNaN(val) || val < 0) {
                hasError = true;
                actualQtyInput.classList.add('is-invalid'); // Add red border
            } else {
                actualQtyInput.classList.remove('is-invalid');
                data.push({
                    detailId: detailId,
                    actualQty: val
                });
            }
        }
    });

    if (hasError) {
        Swal.fire({
            icon: 'error',
            title: 'Import Error',
            text: 'Actual quantity cannot be negative. Please check the highlighted fields.',
            confirmButtonColor: '#dc2626'
        });
        return;
    }

    if (data.length === 0) {
        Swal.fire({ icon: 'error', title: 'Data Error', text: 'No items found to submit!' });
        return;
    }

    Swal.fire({
        title: 'Confirm Stock-In?',
        text: "Are you sure you want to verify the actual received quantities?",
        icon: 'question',
        showCancelButton: true,
        confirmButtonColor: '#2563eb',
        cancelButtonColor: '#64748b',
        confirmButtonText: 'Yes, Confirm',
        cancelButtonText: 'Cancel'
    }).then((result) => {
        if (result.isConfirmed) {
            document.getElementById('actualDataJson').value = JSON.stringify(data);
            document.getElementById('submitForm').submit();
        }
    });
};

function checkServerNotifications() {
    const message = document.getElementById('serverMessage')?.value;
    const status = document.getElementById('serverStatus')?.value;

    if (message && message.trim() !== "") {
        // Displays a centered modal popup for post-redirect feedback
        Swal.fire({
            icon: status === 'success' ? 'success' : 'error',
            title: status === 'success' ? 'Success!' : 'Error Occurred',
            text: message,
            confirmButtonColor: '#2563eb',
            timer: 4000
        });
    }
}