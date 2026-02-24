document.addEventListener('DOMContentLoaded', function() {
    // Hiệu ứng hover cho hàng trong bảng
    const rows = document.querySelectorAll('.table tbody tr');
    rows.forEach(row => {
        row.addEventListener('mouseenter', () => {
            row.style.backgroundColor = 'rgba(255, 255, 255, 0.4)';
        });
        row.addEventListener('mouseleave', () => {
            row.style.backgroundColor = 'transparent';
        });
    });
});