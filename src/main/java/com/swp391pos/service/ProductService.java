package com.swp391pos.service;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import com.swp391pos.entity.Category;
import com.swp391pos.entity.Product;
import com.swp391pos.entity.ProductStatus;
import com.swp391pos.repository.CategoryRepository;
import com.swp391pos.repository.ProductRepository;
import com.swp391pos.repository.ProductStatusRepository;
import jakarta.servlet.http.HttpServletResponse;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
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
    private Cloudinary cloudinary;

    public void saveProduct(Product product) {
        productRepository.save(product);
    }

    public boolean addProduct(Product product, MultipartFile imageFile, Integer statusId, Integer categoryId) {
        try {
            // 1. Tự động tạo mã SKU
            String generatedSku = generateSku();
            product.setProductId(generatedSku);

            // 2. Xử lý Upload ảnh lên Cloudinary
            if (imageFile != null && !imageFile.isEmpty()) {
                Map uploadResult = cloudinary.uploader().upload(imageFile.getBytes(),
                        ObjectUtils.asMap("folder", "products"));
                String imageUrl = (String) uploadResult.get("url");
                product.setImageUrl(imageUrl);
            }

            if(product.getAttribute() == null && product.getAttribute().isEmpty()){
                product.setAttribute("ORIGIN");
            }

            // 3. Thiết lập Category từ ID
            Category cat = new Category();
            cat.setCategoryId(categoryId);
            product.setCategory(cat);

            // 4. Thiết lập Status từ ID
            ProductStatus stat = new ProductStatus();
            stat.setProductStatusId(statusId);
            product.setStatus(stat);

            productRepository.save(product);
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
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

    public boolean updateProduct(String oldId, Product product, MultipartFile imageFile, Integer statusId, Integer categoryId) {
        try {
            Product oldProduct = productRepository.findProductByProductId(oldId);

            if (imageFile != null && !imageFile.isEmpty()) {
                // Upload ảnh mới lên Cloudinary
                Map uploadResult = cloudinary.uploader().upload(imageFile.getBytes(),
                        ObjectUtils.asMap("folder", "products"));
                product.setImageUrl((String) uploadResult.get("url"));
            } else {
                // Nếu không chọn ảnh mới, giữ lại link ảnh cũ
                product.setImageUrl(oldProduct.getImageUrl());
            }

            if(product.getAttribute() == null || product.getAttribute().isEmpty()){
                product.setAttribute("ORIGIN");
            }

            Category cat = new Category();
            cat.setCategoryId(categoryId);
            product.setCategory(cat);

            ProductStatus stat = new ProductStatus();
            stat.setProductStatusId(statusId);
            product.setStatus(stat);

            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean deleteProduct(String id) {
        try {
            Product product = getProductById(id);
            productRepository.delete(product);
            return true;
        }catch (Exception e) {
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
}
