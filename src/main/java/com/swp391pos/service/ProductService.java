package com.swp391pos.service;

import com.swp391pos.entity.Product;
import com.swp391pos.repository.ProductRepository;
import com.swp391pos.repository.ProductStatusRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ProductService{

    @Autowired
    private ProductRepository productRepo;

    public List<Product> findAll(){
        return productRepo.findAll();
    }

}
