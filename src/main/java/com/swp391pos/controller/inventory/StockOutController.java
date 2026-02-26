package com.swp391pos.controller.inventory;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.swp391pos.entity.Account;
import com.swp391pos.service.StockOutService;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/stockOut")
public class StockOutController {
    @Autowired
    private StockOutService stockOutService;

    @GetMapping("/add")
    public String showAddPage(Model model) {
        return "inventory/inventoryStaff/stock-out";
    }

    @GetMapping("/search-products")
    @ResponseBody
    public List<Map<String, Object>> searchProducts(@RequestParam(required = false, defaultValue = "") String term) {
        return stockOutService.searchProductsWithStock(term);
    }

    @PostMapping("/submit")
    public String submitStockOut(
            @RequestParam String generalNote,
            @RequestParam String itemsJson,
            HttpSession session, RedirectAttributes ra) {
        try {
            Account account = (Account) session.getAttribute("loggedInAccount");
            ObjectMapper mapper = new ObjectMapper();
            List<Map<String, Object>> items = mapper.readValue(itemsJson, new TypeReference<>(){});

            stockOutService.createStockOut(generalNote, items, account);

            ra.addFlashAttribute("message", "Stock-out request created!");
            ra.addFlashAttribute("status", "success");
        } catch (Exception e) {
            ra.addFlashAttribute("message", "Error: " + e.getMessage());
            ra.addFlashAttribute("status", "danger");
        }
        return "redirect:/stockOut/add";
    }
}
