package com.swp391pos.controller.product;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/products")
public class ProductController {

    @GetMapping
    public String productManager(Model model) {

        return "/product/product-manage";
    }

    @GetMapping("/add")
    public String showAddProductPage() {

        return "product/product-add";
    }
}
