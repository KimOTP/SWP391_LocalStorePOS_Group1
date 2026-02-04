package com.swp391pos.controller.product;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Controller
@RequestMapping("/products")
public class ProductController {

    @GetMapping
    public String productManager(Model model) {

        return "/product/product-manage";
    }
}
