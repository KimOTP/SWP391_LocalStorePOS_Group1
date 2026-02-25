/**
 * Dashboard Logic for GOAL POS
 */

document.addEventListener('DOMContentLoaded', function() {
    initSearch();
});

/**
 * Xử lý thêm/xóa ứng dụng yêu thích
 */
function toggleFavorite(starBtn) {
    const wrapper = starBtn.closest('.app-wrapper');
    const favGrid = document.getElementById('favorite-grid');
    const favContainer = document.getElementById('favorite-container');
    const appTitle = wrapper.querySelector('.app-title').innerText;

    // Toggle classes cho icon star
    starBtn.classList.toggle('active');
    starBtn.classList.toggle('fa-regular');
    starBtn.classList.toggle('fa-solid');

    if (starBtn.classList.contains('active')) {
        // CLONE: Tạo bản sao để đưa lên vùng Favorite
        const clone = wrapper.cloneNode(true);

        // Gán lại sự kiện click cho nút star trên bản sao
        const cloneStar = clone.querySelector('.star-btn');
        cloneStar.onclick = function() { toggleFavorite(this); };

        favGrid.appendChild(clone);
    } else {
        // REMOVE: Xóa khỏi vùng Favorite
        const favItems = favGrid.querySelectorAll('.app-wrapper');
        favItems.forEach(item => {
            if (item.querySelector('.app-title').innerText === appTitle) {
                item.remove();
            }
        });

        // SYNC: Đảm bảo icon star ở Grid chính cũng quay về trạng thái chưa chọn
        syncMainGridStar(appTitle);
    }

    // Hiển thị/Ẩn vùng Favorite dựa trên số lượng item
    favContainer.style.display = favGrid.children.length > 0 ? 'block' : 'none';
}

/**
 * Đồng bộ trạng thái dấu sao ở lưới ứng dụng chính
 */
function syncMainGridStar(title) {
    const mainItems = document.querySelectorAll('#main-app-grid .app-wrapper');
    mainItems.forEach(item => {
        if (item.querySelector('.app-title').innerText === title) {
            const star = item.querySelector('.star-btn');
            star.className = 'fa-regular fa-star star-btn';
        }
    });
}

/**
 * Logic tìm kiếm ứng dụng
 */
function initSearch() {
    const searchInput = document.querySelector('.search-input');
    if (!searchInput) return;

    searchInput.addEventListener('input', function(e) {
        const term = e.target.value.toLowerCase();
        const appWrappers = document.querySelectorAll('#main-app-grid .app-wrapper');

        appWrappers.forEach(wrapper => {
            const title = wrapper.querySelector('.app-title').innerText.toLowerCase();
            if (title.includes(term)) {
                wrapper.style.display = 'block';
                wrapper.style.opacity = '1';
            } else {
                wrapper.style.display = 'none';
                wrapper.style.opacity = '0';
            }
        });
    });
}

/**
 * Chuyển đổi giữa Grid View và List View
 */
/**
 * Chuyển đổi giữa Grid View và List View
 */
function switchView(viewType) {
    const mainGrid = document.getElementById('main-app-grid');
    const favGrid = document.getElementById('favorite-grid');
    const gridBtn = document.getElementById('gridBtn');
    const listBtn = document.getElementById('listBtn');

    if (viewType === 'list') {
        // Kích hoạt List View
        mainGrid.classList.add('list-view');
        favGrid.classList.add('list-view');

        // Cập nhật trạng thái nút bấm
        listBtn.classList.add('active');
        gridBtn.classList.remove('active');
    } else {
        // Kích hoạt Grid View
        mainGrid.classList.remove('list-view');
        favGrid.classList.remove('list-view');

        // Cập nhật trạng thái nút bấm
        gridBtn.classList.add('active');
        listBtn.classList.remove('active');
    }
}

// Giữ nguyên các hàm toggleFavorite và initSearch của bạn...

// Giữ lại các hàm toggleFavorite và initSearch từ file trước của bạn