package com.swp391pos.controller.product;

import com.cloudinary.*;
import com.cloudinary.utils.ObjectUtils;
import com.swp391pos.entity.Category;
import com.swp391pos.entity.Product;
import com.swp391pos.entity.ProductStatus;
import com.swp391pos.service.ProductService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/products")
public class ProductController {

    @Autowired
    private ProductService productService;

    @Autowired
    private Cloudinary cloudinary;

    @GetMapping("/manage")
    public String showManagePage(Model model) {
        List<Product> list = productService.getAllProducts();
        model.addAttribute("listProducts", list);

        // Gửi thêm các thông số thống kê nếu cần (Card Stats)
        model.addAttribute("totalCount", list.size());
        return "product/product-manage";
    }

    // 1. Trang hiển thị Form Add (Cần lấy list danh mục và trạng thái)
    @GetMapping("/add")
    public String showAddForm(Model model) {
        model.addAttribute("product", new Product());
        model.addAttribute("categories", productService.getAllCategories());
        model.addAttribute("statuses", productService.getAllProductStatuses());
        return "product/product-add";
    }

    // 2. Xử lý lưu Product
    @PostMapping("/add")
    public String addProduct(@ModelAttribute Product product,
                             @RequestParam("imageFile") MultipartFile imageFile,
                             @RequestParam("status.productStatusId") Integer statusId,
                             @RequestParam("category.categoryId") Integer categoryId) {
        try {
            // Xử lý Upload ảnh lên Cloudinary
            if (imageFile != null && !imageFile.isEmpty()) {
                Map uploadResult = cloudinary.uploader().upload(imageFile.getBytes(),
                        ObjectUtils.asMap("folder", "products"));
                String imageUrl = (String) uploadResult.get("url");
                product.setImageUrl(imageUrl);
            }

            // Thiết lập quan hệ đối tượng từ ID nhận được từ Form
            // Lưu ý: categoryId và statusId được map trực tiếp vào nested object của Product
            Category cat = new Category();
            cat.setCategoryId(categoryId);
            product.setCategory(cat);

            ProductStatus stat = new ProductStatus();
            stat.setProductStatusId(statusId);
            product.setStatus(stat);

            productService.saveProduct(product);
        } catch (Exception e) {
            e.printStackTrace();
            // Có thể thêm thông báo lỗi ở đây
        }
        return "redirect:/products/manage";
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
        // 1. Lấy thông tin sản phẩm cần sửa
        Product product = productService.getProductById(id);
        model.addAttribute("product", product);

        // 2. Lấy danh sách để đổ vào các thẻ <select>
        model.addAttribute("categories", productService.getAllCategories());
        model.addAttribute("statuses", productService.getAllProductStatuses());

        return "product/product-update"; // Tên file JSP mới của bạn
    }

    @PostMapping("/do-update")
    public String processUpdate(@ModelAttribute("product") Product product) {
        // Lưu ý: productId sẽ được gửi về ngầm nhờ trường readonly/hidden
        productService.saveProduct(product);
        return "redirect:/products/manage";
    }


}
