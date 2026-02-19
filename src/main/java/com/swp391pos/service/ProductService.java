package com.swp391pos.service;

import com.swp391pos.entity.Category;
import com.swp391pos.entity.Product;
import com.swp391pos.entity.ProductStatus;
import com.swp391pos.repository.CategoryRepository;
import com.swp391pos.repository.ProductRepository;
import com.swp391pos.repository.ProductStatusRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ProductService {

    @Autowired
    private ProductRepository productRepository;

    @Autowired
    private ProductStatusRepository productStatusRepository;

    @Autowired
    private CategoryRepository categoryRepository;

    public void saveProduct(Product product) {
        productRepository.save(product);
    }
    public boolean addProduct(Product product) {
        try {
            productRepository.save(product);
            return true;
        }catch(Exception e) {
            return false;
        }
    }

    public List<Product> getAllProducts() {
        return productRepository.findAll();
    }

    public boolean updateProduct(Product product) {
        try {
            productRepository.save(product);
            return true;
        }catch(Exception e) {
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
