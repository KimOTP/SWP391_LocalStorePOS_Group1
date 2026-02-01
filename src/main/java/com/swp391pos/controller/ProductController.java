package com.swp391pos.controller;

import com.swp391pos.service.ProductService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class ProductController{

    @Autowired
    private ProductService productService;

    @GetMapping("/product")
    public String product(Model model){
        model.addAttribute("products",productService.findAll());
        return "home";
    }

}