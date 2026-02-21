package com.swp391pos.controller.product;

import com.cloudinary.*;
import com.swp391pos.entity.Product;
import com.swp391pos.repository.CategoryRepository;
import com.swp391pos.repository.ProductRepository;
import com.swp391pos.service.ProductService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;

@Controller
@RequestMapping("/products")
public class ProductController {

    @Autowired
    private ProductService productService;
    @Autowired
    private ProductRepository productRepository;
    @Autowired
    private CategoryRepository categoryRepository;

    // manage page
    @GetMapping("/manage")
    public String manageProducts(Model model) {
        // 1. Lấy danh sách hiển thị bảng
        model.addAttribute("listProducts", productService.getAllProducts());

        // 2. Tính toán các con số thống kê
        long total = productRepository.count();
        long active = productRepository.countByStatus_ProductStatusName("Active");
        long discontinued = productRepository.countByStatus_ProductStatusName("Discontinued");
        long outOfStock = productRepository.countByStatus_ProductStatusName("Out of Stock");
        long pending = productRepository.countByStatus_ProductStatusName("Pending Approval");

        long catCount = categoryRepository.count();

        List<Product> list = productService.getAllProducts();

        // 3. Đẩy dữ liệu ra Model
        model.addAttribute("totalProducts", total);
        model.addAttribute("activeCount", active);
        model.addAttribute("stopCount", discontinued);
        model.addAttribute("categoryCount", catCount);
        model.addAttribute("outOfStockCount", outOfStock);
        model.addAttribute("pendingCount", pending);

        model.addAttribute("listProducts", list);
        model.addAttribute("totalCount", list.size());

        return "product/product-manage";
    }

    // 1. Add
    @GetMapping("/add")
    public String showAddForm(Model model) {
        model.addAttribute("product", new Product());
        model.addAttribute("categories", productService.getAllCategories());
        model.addAttribute("statuses", productService.getAllProductStatuses());
        return "product/product-add";
    }

    // 2. Excecute Add
    @PostMapping("/add")
    public String addProduct(@ModelAttribute Product product,
                             @RequestParam("imageFile") MultipartFile imageFile,
                             @RequestParam("statusId") Integer statusId,
                             @RequestParam("categoryId") Integer categoryId,
                             RedirectAttributes redirectAttributes) {

        boolean success = productService.addProduct(product, imageFile, statusId, categoryId);

        if (success) {
            redirectAttributes.addFlashAttribute("message", "Product added successfully!");
            return "redirect:/products/manage";
        } else {
            redirectAttributes.addFlashAttribute("error", "Failed to add product.");
            return "redirect:/products/add";
        }
    }

    @GetMapping("/view/{id}")
    public String viewProduct(@PathVariable String id, Model model) {
        Product p = productService.getProductById(id);
        model.addAttribute("product", p);
        // Trả về file jsp con chỉ chứa nội dung detail
        return "product/product-detail";
    }

    @GetMapping("/delete/{id}")
    public String deleteProduct(@PathVariable String id) {
        productService.deleteProduct(id);
        return "redirect:/products/manage";
    }

    @GetMapping("/update/{id}")
    public String showUpdatePage(@PathVariable("id") String id, Model model) {
        Product product = productService.getProductById(id);
        model.addAttribute("product", product);
        model.addAttribute("categories", productService.getAllCategories());
        model.addAttribute("statuses", productService.getAllProductStatuses());
        return "product/product-update";
    }

    @PostMapping("/do-update")
    public String processUpdate(@ModelAttribute Product product,
                                @RequestParam("oldId") String oldId,
                                @RequestParam("imageFile") MultipartFile imageFile,
                                @RequestParam("statusId") Integer statusId,
                                @RequestParam("categoryId") Integer categoryId) {

        boolean success = productService.updateProduct(oldId, product, imageFile, statusId, categoryId);

        if(success) {
            return "redirect:/products/manage";
        } else {
            return "redirect:/products/update/" + oldId + "?error";
        }
    }

}
