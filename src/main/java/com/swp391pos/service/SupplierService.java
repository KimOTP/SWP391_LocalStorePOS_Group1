package com.swp391pos.service;

import com.swp391pos.entity.Supplier;
import com.swp391pos.repository.SupplierRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.*;

@Service
public class SupplierService {
    @Autowired
    private SupplierRepository supplierRepository;

    public List<Map<String, Object>> getSuppliersDashboardData() {
        List<Object[]> results = supplierRepository.findAllSuppliersWithTotalValue();
        List<Map<String, Object>> data = new ArrayList<>();

        for (Object[] row : results) {
            Map<String, Object> map = new HashMap<>();
            map.put("supplierId", row[0]);
            map.put("supplierName", row[1]);
            map.put("contactNumber", row[2]);
            map.put("email", row[3]);
            map.put("totalValue", row[4] != null ? row[4] : 0.0); // Tổng đặt hàng
            data.add(map);
        }
        return data;
    }

    public void saveSupplier(Supplier supplier) {
        supplierRepository.save(supplier);
    }

    public void updateSupplier(Supplier supplier) {
        if (supplierRepository.existsById(supplier.getSupplierId())) {
            supplierRepository.save(supplier);
        }
    }

    public void deleteSupplier(Integer id) {
        supplierRepository.deleteById(id);
    }
}