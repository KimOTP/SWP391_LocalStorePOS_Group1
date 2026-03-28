package com.swp391pos.controller.product;

import com.swp391pos.entity.Product;
import com.swp391pos.repository.CategoryRepository;
import com.swp391pos.repository.ProductRepository;
import com.swp391pos.service.ProductService;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.io.IOException;
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
    public String manageProducts(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) List<String> statusNames,
            @RequestParam(required = false) List<String> categoryNames,
            @RequestParam(required = false) List<String> units,
            @RequestParam(defaultValue = "productId") String sortField,
            @RequestParam(defaultValue = "asc") String sortDir,
            Model model) {

        // Xử lý logic Sắp xếp (Sort)
        Sort sort = sortDir.equalsIgnoreCase("asc")
                ? Sort.by(sortField).ascending()
                : Sort.by(sortField).descending();

        // Gọi Service để lọc và sắp xếp từ Database
        List<Product> list = productService.searchProductManager(keyword, statusNames, categoryNames, units, sort);

        // Đổ dữ liệu sản phẩm ra bảng
        model.addAttribute("listProducts", list);
        model.addAttribute("totalCount", list.size());

        // Gửi ngược lại các giá trị lọc để giữ trạng thái Checkbox/Search trên giao diện
        model.addAttribute("keyword", keyword);
        model.addAttribute("selectedStatuses", statusNames);
        model.addAttribute("selectedCategories", categoryNames);
        model.addAttribute("selectedUnits", units);

        // Gửi thông tin Sort để hiển thị Icon mũi tên trên Header
        model.addAttribute("sortField", sortField);
        model.addAttribute("sortDir", sortDir);
        model.addAttribute("reverseSortDir", sortDir.equals("asc") ? "desc" : "asc");

        // Lấy dữ liệu cho các bộ lọc Checkbox
        model.addAttribute("statuses", productService.getAllProductStatuses());
        model.addAttribute("categories", productService.getAllCategories());
        model.addAttribute("units", productService.getAllDistinctUnits());

        // Thống kê số liệu
        model.addAttribute("totalProducts", productRepository.count());
        model.addAttribute("activeCount", productRepository.countByStatus_ProductStatusName("Active"));
        model.addAttribute("stopCount", productRepository.countByStatus_ProductStatusName("Discontinued"));
        model.addAttribute("outOfStockCount", productRepository.countByStatus_ProductStatusName("Out of Stock"));
        model.addAttribute("pendingCount", productRepository.countByStatus_ProductStatusName("Pending Approval"));
        model.addAttribute("categoryCount", categoryRepository.count());

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
        try {
            productService.addProduct(product, imageFile, statusId, categoryId);
            redirectAttributes.addFlashAttribute("notification", "Product added successfully!");
            return "redirect:/products/manage";

        } catch (RuntimeException e) {
            // lỗi (trùng lặp, lỗi upload...)
            e.printStackTrace();
            redirectAttributes.addFlashAttribute("errorMessage", e.getMessage());
            return "redirect:/products/add";

        } catch (Exception e) {
            // lỗi không xác định khác
            redirectAttributes.addFlashAttribute("errorMessage", "An unexpected error occurred: " + e.getMessage());
            e.printStackTrace();
            return "redirect:/products/add";
        }
    }

    @GetMapping("/view/{id}")
    public String viewProduct(@PathVariable String id, Model model) {
        Product p = productService.getProductById(id);
        model.addAttribute("product", p);
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
                                @RequestParam("categoryId") Integer categoryId,
                                RedirectAttributes redirectAttributes) {

        try {
            product.setProductId(oldId);
            productService.updateProduct(oldId, product, imageFile, statusId, categoryId);
            redirectAttributes.addFlashAttribute("notification", "Updated product successfully!");
            return "redirect:/products/manage";

        } catch (RuntimeException e) {
            redirectAttributes.addFlashAttribute("errorMessage", e.getMessage());
            e.printStackTrace();
            return "redirect:/products/update/" + oldId;
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("errorMessage", "Unexpected error occurred!");
            e.printStackTrace();
            return "redirect:/products/update/" + oldId;
        }
    }

    @GetMapping("/export-excel")
    public void exportToExcel(HttpServletResponse response) throws IOException {
        response.setContentType("application/octet-stream");
        String headerKey = "Content-Disposition";
        String headerValue = "attachment; filename=products_list.xlsx";
        response.setHeader(headerKey, headerValue);

        List<Product> list = productService.getAllProducts();
        productService.exportProductsToExcel(list, response);
    }

}
