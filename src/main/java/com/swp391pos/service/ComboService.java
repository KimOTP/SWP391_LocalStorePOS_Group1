package com.swp391pos.service;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import com.swp391pos.entity.Combo;
import com.swp391pos.entity.ComboDetail;
import com.swp391pos.entity.Inventory;
import com.swp391pos.entity.Product;
import com.swp391pos.repository.ComboDetailRepository;
import com.swp391pos.repository.ComboRepository;
import com.swp391pos.repository.InventoryRepository;
import com.swp391pos.repository.ProductRepository;
import jakarta.servlet.http.HttpServletResponse;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
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
    @Autowired
    private InventoryRepository inventoryRepository;

    @Transactional
    public boolean addCombo(Combo combo, List<String> productIds, List<Integer> quantities, MultipartFile imageFile) {
        try {
            if (combo.getComboId() == null || combo.getComboId().isEmpty()) {
                combo.setComboId(generateSku());
            }
            // upload ảnh
            if (imageFile != null && !imageFile.isEmpty()) {
                Map uploadResult = cloudinary.uploader().upload(imageFile.getBytes(),
                        ObjectUtils.asMap("folder", "combos"));
                String imageUrl = (String) uploadResult.get("url");
                combo.setImageUrl(imageUrl);
            }

            Combo savedCombo = comboRepository.save(combo);

            // lưu danh sách chi tiết ComboDetail với quantity
            if (productIds != null && !productIds.isEmpty()) {
                for (int i = 0; i < productIds.size(); i++) {
                    String pId = productIds.get(i);
                    // lấy quantity tương ứng từ mảng quantities, nếu lỗi thì mặc định là 1
                    Integer qty = (quantities != null && quantities.size() > i) ? quantities.get(i) : 1;

                    Product product = productRepository.findProductByProductId(pId);
                    if (product != null) {
                        ComboDetail detail = new ComboDetail();
                        detail.setCombo(savedCombo);
                        detail.setProduct(product);
                        detail.setQuantity(qty); // lưu số lượng người dùng đã chọn (+/-)
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
                               MultipartFile imageFile, String existingImageUrl) throws Exception{
            // xử lý hình ảnh
            if (imageFile != null && !imageFile.isEmpty()) {
                Map uploadResult = cloudinary.uploader().upload(imageFile.getBytes(),
                        ObjectUtils.asMap("folder", "combos"));
                combo.setImageUrl((String) uploadResult.get("url"));
            } else {
                // nếu không chọn ảnh mới, giữ lại ảnh cũ từ trường hidden
                combo.setImageUrl(existingImageUrl);
            }

        if (combo.getStatusCombo() == Combo.Status.ACTIVE) {
            for (int i = 0; i < productIds.size(); i++) {
                String productId = productIds.get(i);
                int quantity = quantities.get(i);

              Inventory inv = inventoryRepository.findById(productId)
                      .orElseThrow(() -> new RuntimeException("Inventory not found"));

                if (inv.getCurrentQuantity() < quantity) {
                    Product product = productRepository.findProductByProductId(productId);
                    throw new RuntimeException(
                            "Quantity of " + product.getProductName() + " not enough!"
                    );
                }
            }
        }
            // lưu thông tin Combo
            Combo savedCombo = comboRepository.save(combo);

            // xóa toàn bộ chi tiết sản phẩm cũ của Combo này
            comboDetailRepository.deleteByCombo(savedCombo);

            // lưu lại danh sách mới
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
    }

    public List<Combo> getCombosByStatuses(List<String> statuses) {
        // statuses sẽ là list như ["ACTIVE", "PENDING_APPROVAL"]
        return comboRepository.findByStatusComboIn(statuses);
    }

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
            comboRepository.deleteById(id);
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // export to file exel
    public void exportCombosToExcel(List<Combo> combos, HttpServletResponse response) throws IOException {
        Workbook workbook = new XSSFWorkbook();
        Sheet sheet = workbook.createSheet("Combos");

        // tạo header
        Row headerRow = sheet.createRow(0);
        String[] columns = {"SKU", "Combo Name", "Include Products", "Total Price", "Status"};

        // style cho header
        CellStyle headerStyle = workbook.createCellStyle();
        Font font = workbook.createFont();
        font.setBold(true);
        headerStyle.setFont(font);

        for (int i = 0; i < columns.length; i++) {
            Cell cell = headerRow.createCell(i);
            cell.setCellValue(columns[i]);
            cell.setCellStyle(headerStyle);
        }

        // đổ dữ liệu từ danh sách combos vào các dòng
        int rowIdx = 1;
        for (Combo c : combos) {
            Row row = sheet.createRow(rowIdx++);
            row.createCell(0).setCellValue(c.getComboId());
            row.createCell(1).setCellValue(c.getComboName());

            StringBuilder productsInfo = new StringBuilder();
            for (ComboDetail detail : c.getComboDetails()) {
                if (productsInfo.length() > 0) productsInfo.append(", ");
                productsInfo.append(detail.getProduct().getProductName())
                        .append(" x")
                        .append(detail.getQuantity());
            }
            row.createCell(2).setCellValue(productsInfo.toString());

            row.createCell(3).setCellValue(c.getTotalPrice().toString());
            row.createCell(4).setCellValue(c.getStatusCombo().toString());
        }

        // xuất file
        workbook.write(response.getOutputStream());
        workbook.close();
    }

    public long countTotal() {
        return comboRepository.count();
    }

    public long countByStatus(Combo.Status status) {
        return comboRepository.countByStatusCombo(status);
    }
}