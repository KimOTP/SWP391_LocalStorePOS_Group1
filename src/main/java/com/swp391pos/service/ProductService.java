package com.swp391pos.service;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import com.swp391pos.entity.Category;
import com.swp391pos.entity.Product;
import com.swp391pos.entity.ProductStatus;
import com.swp391pos.repository.CategoryRepository;
import com.swp391pos.repository.ProductRepository;
import com.swp391pos.repository.ProductStatusRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

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
            String generatedSku = generateSku(product.getProductName(), product.getAttribute());
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

    // Format: SKU_TENSANPHAM_ATTRIBUTE
    private String generateSku(String name, String attribute) {
        String baseName = (name != null)
                ? name.replace(" ", "").toUpperCase()
                : "PRODUCT";

        String attrName = (attribute != null && !attribute.isEmpty())
                ? attribute.replace(" ", "").toUpperCase()
                : "ORIGIN";

        return "SKU_" + baseName + "_" + attrName;
    }

    public List<Product> getAllProducts() {
        return productRepository.findAll();
    }

    public boolean updateProduct(String oldId, Product product, MultipartFile imageFile, Integer statusId, Integer categoryId) {
        try {
            String newSku = generateSku(product.getProductName(), product.getAttribute());
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

            // 5. Kiểm tra nếu SKU thay đổi
            if (!newSku.equals(oldId)) {
                productRepository.delete(oldProduct);
                product.setProductId(newSku);
                productRepository.save(product);
            } else {
                // Nếu SKU không đổi, chỉ cần lưu đè lên ID cũ
                product.setProductId(oldId);
                productRepository.save(product);
            }
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

}
