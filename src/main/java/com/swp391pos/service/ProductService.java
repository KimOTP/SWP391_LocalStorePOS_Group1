package com.swp391pos.service;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import com.swp391pos.entity.*;
import com.swp391pos.repository.*;
import jakarta.servlet.http.HttpServletResponse;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@Service
public class ProductService {

    @Autowired
    private ProductRepository productRepository;

    @Autowired
    private ProductStatusRepository productStatusRepository;

    @Autowired
    private CategoryRepository categoryRepository;

    @Autowired
    private InventoryRepository inventoryRepository;

    @Autowired
    private InventoryService inventoryService;

    @Autowired
    private Cloudinary cloudinary;
    @Autowired
    private ComboRepository comboRepository;

    public void saveProduct(Product product) {
        productRepository.save(product);
    }

    @Transactional(rollbackFor = Exception.class) // Đảm bảo rollback nếu có lỗi bất kỳ
    public void addProduct(Product product, MultipartFile imageFile, Integer statusId, Integer categoryId) {
        // 1. Xử lý logic Attribute mặc định
        if (product.getAttribute() == null || product.getAttribute().trim().isEmpty()) {
            product.setAttribute("ORIGIN");
        }

        // 2. Kiểm tra trùng lặp
        boolean isDuplicate = productRepository.existsByProductNameAndCategory_CategoryIdAndAttribute(
                product.getProductName(),
                categoryId,
                product.getAttribute()
        );

        if (isDuplicate) {
            throw new RuntimeException("Product already exists!");
        }

        try {
            // 3. Tự động tạo mã SKU
            product.setProductId(generateSku());

            // 4. Xử lý Upload ảnh
            if (imageFile != null && !imageFile.isEmpty()) {
                Map uploadResult = cloudinary.uploader().upload(imageFile.getBytes(),
                        ObjectUtils.asMap("folder", "products"));
                product.setImageUrl((String) uploadResult.get("url"));
            }

            // 5. Thiết lập Category & Status
            Category cat = new Category();
            cat.setCategoryId(categoryId);
            product.setCategory(cat);

            ProductStatus stat = new ProductStatus();
            stat.setProductStatusId(statusId);
            product.setStatus(stat);

            // 6. Lưu dữ liệu
            Product savedProduct = productRepository.save(product);
            inventoryService.createInventoryWithProduct(savedProduct);

        } catch (IOException e) {
            throw new RuntimeException("Failed to upload image!");
        } catch (Exception e) {
            // Ném các lỗi runtime khác để Controller bắt
            throw new RuntimeException("Failed to add product!");
        }
    }

    // Format: SKU-PROD-00?
    private String generateSku() {
        String lastSku = productRepository.findLastSku();
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
        return String.format("SKU-PROD-%03d", nextNumber);
    }

    public List<Product> getAllProducts() {
        return productRepository.findAll();
    }

    @Transactional
    public boolean updateProduct(String oldId, Product product, MultipartFile imageFile,
                                 Integer statusId, Integer categoryId) throws Exception {

        Product oldProduct = productRepository.findProductByProductId(oldId);
        Inventory inventory = inventoryRepository.findByProductId(oldId);

        if (oldProduct == null) {
            throw new RuntimeException("Product not found");
        }

        // Upload image
        if (imageFile != null && !imageFile.isEmpty()) {
            Map uploadResult = cloudinary.uploader().upload(
                    imageFile.getBytes(),
                    ObjectUtils.asMap("folder", "products")
            );
            product.setImageUrl((String) uploadResult.get("url"));
        } else {
            product.setImageUrl(oldProduct.getImageUrl());
        }

        // Default attribute
        if (product.getAttribute() == null || product.getAttribute().isEmpty()) {
            product.setAttribute("ORIGIN");
        }

        // Set category
        Category cat = new Category();
        cat.setCategoryId(categoryId);
        product.setCategory(cat);

        // Set status
        ProductStatus stat = new ProductStatus();
        stat.setProductStatusId(statusId);

        if (statusId == 1) { // ACTIVE
            if (inventory == null || inventory.getCurrentQuantity() <= 0) {
                throw new RuntimeException("Cannot change status to ACTIVE. " +
                        "Product quantity must > 0");
            }
        }

        product.setStatus(stat);

        productRepository.save(product);


        return true;
    }

    public boolean deleteProduct(String id) {
        try {
            Product product = getProductById(id);
            productRepository.delete(product);
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    public Product getProductById(String id) {
        return productRepository.findProductByProductId(id);
    }

    public List<ProductStatus> getAllProductStatuses() {
        return productStatusRepository.findAll();
    }

    public List<Category> getAllCategories() {
        return categoryRepository.findAll();
    }


    public List<Product> searchProductManager(String kw, List<String> sIds, List<String> cNames, List<String> units, Sort sort) {
        // Xử lý nếu List rỗng thì truyền null vào Repository để bỏ qua điều kiện lọc
        List<String> statuses = (sIds != null && sIds.isEmpty()) ? null : sIds;
        List<String> categories = (cNames != null && cNames.isEmpty()) ? null : cNames;
        List<String> unitList = (units != null && units.isEmpty()) ? null : units;

        return productRepository.searchProductManager(kw, statuses, categories, unitList, sort);
    }

    public List<String> getAllDistinctUnits() {
        return productRepository.findAllDistinctUnits();
    }

    // export to file exel
    public void exportProductsToExcel(List<Product> products, HttpServletResponse response) throws IOException {
        Workbook workbook = new XSSFWorkbook();
        Sheet sheet = workbook.createSheet("Products");

        // 1. Tạo Header (Dòng tiêu đề)
        Row headerRow = sheet.createRow(0);
        String[] columns = {"SKU", "Product Name", "Category", "Attribute", "Unit", "Price", "Status"};

        // Style cho Header
        CellStyle headerStyle = workbook.createCellStyle();
        Font font = workbook.createFont();
        font.setBold(true);
        headerStyle.setFont(font);

        for (int i = 0; i < columns.length; i++) {
            Cell cell = headerRow.createCell(i);
            cell.setCellValue(columns[i]);
            cell.setCellStyle(headerStyle);
        }

        // 2. Đổ dữ liệu từ danh sách products vào các dòng tiếp theo
        int rowIdx = 1;
        for (Product p : products) {
            Row row = sheet.createRow(rowIdx++);
            row.createCell(0).setCellValue(p.getProductId());
            row.createCell(1).setCellValue(p.getProductName());
            row.createCell(2).setCellValue(p.getCategory().getCategoryName());
            row.createCell(3).setCellValue(p.getAttribute());
            row.createCell(4).setCellValue(p.getUnit());
            row.createCell(5).setCellValue(String.valueOf(p.getPrice()));
            row.createCell(6).setCellValue(p.getStatus().getProductStatusName());
        }

        // 3. Xuất file về trình duyệt
        workbook.write(response.getOutputStream());
        workbook.close();
    }

    public void updateStockAndSyncStatus(String productId, int newQuantity) {
        Inventory inventory = inventoryRepository.findById(productId).get();
        List<Combo> listCombo = null;

        // Tự động set OUT_OF_STOCK, không cho phép override
        if (newQuantity <= 0) {
            inventory.getProduct().getStatus().setProductStatusId(3);
            listCombo = comboRepository.findComboByProductId(productId);
            for (Combo combo : listCombo) {
                combo.setStatusCombo(Combo.Status.DISCONTINUED);
            }

        } else {
            // Chỉ đổi lại ACTIVE nếu đang OUT_OF_STOCK, giữ nguyên các status khác
            if (inventory.getProduct().getStatus().getProductStatusId() == 3) {
                inventory.getProduct().getStatus().setProductStatusId(1);
            }
        }
        if (listCombo != null) {
            for (Combo combo : listCombo) {
                comboRepository.save(combo);
            }
        }
    }
}
