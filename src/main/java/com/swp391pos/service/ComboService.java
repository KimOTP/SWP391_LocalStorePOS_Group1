package com.swp391pos.service;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import com.swp391pos.entity.Combo;
import com.swp391pos.entity.ComboDetail;
import com.swp391pos.entity.Product;
import com.swp391pos.repository.ComboDetailRepository;
import com.swp391pos.repository.ComboRepository;
import com.swp391pos.repository.ProductRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Map;

@Service
public class ComboService {

    @Autowired
    private ComboRepository comboRepository;

    @Autowired
    private ProductRepository productRepository;

    @Autowired
    private ComboDetailRepository comboDetailRepository;

    @Autowired
    private Cloudinary cloudinary;

    /**
     * Lưu Combo kèm theo danh sách sản phẩm chi tiết (Giống logic addProduct)
     */
    @Transactional
    public boolean addCombo(Combo combo, List<String> productIds, List<Integer> quantities, MultipartFile imageFile) {
        try {
            // 1. Tự động tạo mã SKU cho Combo (giữ nguyên)
            if (combo.getComboId() == null || combo.getComboId().isEmpty()) {
                combo.setComboId(generateSku());
            }

            // 2. Xử lý Upload ảnh (giữ nguyên)
            if (imageFile != null && !imageFile.isEmpty()) {
                Map uploadResult = cloudinary.uploader().upload(imageFile.getBytes(),
                        ObjectUtils.asMap("folder", "combos"));
                String imageUrl = (String) uploadResult.get("url");
                combo.setImageUrl(imageUrl);
            }

            // 3. Lưu Combo Master
            Combo savedCombo = comboRepository.save(combo);

            // 4. Lưu danh sách chi tiết ComboDetail với Số Lượng thực tế
            if (productIds != null && !productIds.isEmpty()) {
                for (int i = 0; i < productIds.size(); i++) {
                    String pId = productIds.get(i);
                    // Lấy quantity tương ứng từ mảng quantities, nếu lỗi thì mặc định là 1
                    Integer qty = (quantities != null && quantities.size() > i) ? quantities.get(i) : 1;

                    Product product = productRepository.findProductByProductId(pId);
                    if (product != null) {
                        ComboDetail detail = new ComboDetail();
                        detail.setCombo(savedCombo);
                        detail.setProduct(product);
                        detail.setQuantity(qty); // Lưu số lượng người dùng đã chọn (+/-)
                        comboDetailRepository.save(detail);
                    }
                }
            }
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    @Transactional
    public boolean updateCombo(Combo combo, List<String> productIds, List<Integer> quantities,
                               MultipartFile imageFile, String existingImageUrl) {
        try {
            // 1. Xử lý hình ảnh
            if (imageFile != null && !imageFile.isEmpty()) {
                Map uploadResult = cloudinary.uploader().upload(imageFile.getBytes(),
                        ObjectUtils.asMap("folder", "combos"));
                combo.setImageUrl((String) uploadResult.get("url"));
            } else {
                // Nếu không chọn ảnh mới, giữ lại ảnh cũ từ trường hidden
                combo.setImageUrl(existingImageUrl);
            }

            // 2. Lưu thông tin Combo (Master)
            Combo savedCombo = comboRepository.save(combo);

            // 3. Xóa toàn bộ chi tiết sản phẩm cũ của Combo này
            // Bạn cần viết phương thức này trong ComboDetailRepository
            comboDetailRepository.deleteByCombo(savedCombo);

            // 4. Lưu lại danh sách sản phẩm mới
            if (productIds != null && !productIds.isEmpty()) {
                for (int i = 0; i < productIds.size(); i++) {
                    Product product = productRepository.findProductByProductId(productIds.get(i));
                    if (product != null) {
                        ComboDetail detail = new ComboDetail();
                        detail.setCombo(savedCombo);
                        detail.setProduct(product);
                        detail.setQuantity(quantities.get(i));
                        comboDetailRepository.save(detail);
                    }
                }
            }
            return true;
        } catch (Exception e) {
            throw new RuntimeException("Failed to update combo: " + e.getMessage());
        }
    }

    public List<Combo> getCombosByStatuses(List<String> statuses) {
        // statuses sẽ là danh sách như ["ACTIVE", "PENDING_APPROVAL"]
        return comboRepository.findByStatusComboIn(statuses);
    }
    /**
     * Tự động sinh mã SKU: SKU-COM-00?
     */
    public String generateSku() {
        String lastSku = comboRepository.findLastSku();
        int nextNumber = 1;
        if (lastSku != null && lastSku.contains("-")) {
            try {
                String[] parts = lastSku.split("-");
                String lastNumberStr = parts[parts.length - 1];
                nextNumber = Integer.parseInt(lastNumberStr) + 1;
            } catch (NumberFormatException e) {
                nextNumber = 1;
            }
        }
        return String.format("SKU-COM-%03d", nextNumber);
    }

    public List<Combo> getAllCombos() {
        return comboRepository.findAll();
    }

    public Combo getComboById(String id) {
        return comboRepository.findComboByComboId(id);
    }

    @Transactional
    public boolean deleteCombo(String id) {
        try {
            // Xóa chi tiết trước nếu không dùng CascadeType.ALL
            // comboDetailRepository.deleteByComboId(id);
            comboRepository.deleteById(id);
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // --- Các hàm phục vụ thống kê (Stat Cards) ---

    public long countTotal() {
        return comboRepository.count();
    }

    public long countByStatus(Combo.Status status) {
        return comboRepository.countByStatusCombo(status);
    }
}