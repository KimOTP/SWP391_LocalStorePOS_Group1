document.addEventListener('DOMContentLoaded', function() {
    // Check for success/error messages from the server upon page load
    checkServerNotifications();
});

window.submitStockIn = function() {
    const rows = document.querySelectorAll('#processTable tbody tr');
    const data = [];

    rows.forEach(row => {
        const detailId = row.getAttribute('data-detail-id');
        const actualQtyInput = row.querySelector('.input-actual');

        if (detailId && actualQtyInput) {
            data.push({
                detailId: detailId,
                actualQty: actualQtyInput.value // Matches your backend variable name
            });
        }
    });

    if (data.length === 0) {
        Swal.fire({
            icon: 'error',
            title: 'Data Error',
            text: 'No items found to submit!',
            confirmButtonColor: '#2563eb'
        });
        return;
    }

    // Step 1: Confirmation Popup
    Swal.fire({
        title: 'Confirm Stock-In?',
        text: "Are you sure you want to verify the actual received quantities?",
        icon: 'question',
        showCancelButton: true,
        confirmButtonColor: '#2563eb',
        cancelButtonColor: '#64748b',
        confirmButtonText: 'Yes, Confirm Stock-In',
        cancelButtonText: 'Review Again'
    }).then((result) => {
        if (result.isConfirmed) {
            // Step 2: Success Animation before redirect
            Swal.fire({
                title: 'Submitting Request...',
                text: 'Updating inventory data, please wait.',
                icon: 'success',
                showConfirmButton: false,
                timer: 1500,
                timerProgressBar: true,
                didOpen: () => {
                    Swal.showLoading();
                    // Pack data into the hidden input
                    document.getElementById('actualDataJson').value = JSON.stringify(data);
                },
                willClose: () => {
                    // Step 3: Final Form Submission
                    document.getElementById('submitForm').submit();
                }
            });
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