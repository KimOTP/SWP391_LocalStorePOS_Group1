// Sửa lại file stock-in.js
function submitStockIn() {
    const rows = document.querySelectorAll('#processTable tbody tr');
    const data = [];

    rows.forEach(row => {
        const detailId = row.getAttribute('data-detail-id');
        const actualQty = row.querySelector('.input-actual').value;

        if (detailId) {
            data.push({
                detailId: detailId,
                actualQty: actualQty
            });
        }
    });

    if (data.length === 0) {
        alert("No items found to submit!");
        return;
    }
    document.getElementById('actualDataJson').value = JSON.stringify(data);
    document.getElementById('submitForm').submit();
}