package com.swp391pos.service;

import com.swp391pos.entity.Product;
import com.swp391pos.entity.Promotion;
import com.swp391pos.entity.PromotionDetail;
import com.swp391pos.repository.ProductRepository;
import com.swp391pos.repository.PromotionDetailRepository;
import com.swp391pos.repository.PromotionRepository;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.aspectj.weaver.ast.Call;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

@Service
public class PromotionDetailService {
    @Autowired
    private PromotionDetailRepository promotionDetailRepository;
    @Autowired
    private PromotionRepository promotionRepository;
    @Autowired
    private ProductRepository productRepository;

    public List<PromotionDetail> searchDetails(Integer promotionId, String keyword, String productName, String discountTypeStr) {
        String pName = (productName != null && !productName.isEmpty()) ? productName : null;

        PromotionDetail.DiscountType discountType = null;
        if (discountTypeStr != null && !discountTypeStr.isEmpty()) {
            try {
                discountType = PromotionDetail.DiscountType.valueOf(discountTypeStr);
            } catch (IllegalArgumentException e) {}
        }

        return promotionDetailRepository.searchDetails(promotionId, keyword, pName, discountType);
    }

    public List<String> getProductNamesInPromotion(Integer promotionId) {
        return promotionDetailRepository.findDistinctProductNamesByPromotionId(promotionId);
    }

    public void savePromotionDetail(PromotionDetail detail) {
        promotionDetailRepository.save(detail);
    }

    public void deletePromotionDetail(Long promoDetailId) {
        promotionDetailRepository.deleteById(promoDetailId);
    }

    public void importPromotionDetails(int promotionId, MultipartFile file) throws Exception {
        Promotion promotion = promotionRepository.findById(promotionId);
        if (promotion == null) {
            throw new RuntimeException("Cannot find promotion");
        }
        try (Workbook workbook = new XSSFWorkbook(file.getInputStream())) {
            Sheet sheet = workbook.getSheetAt(0);
            //Khoi tao list
            List<PromotionDetail> listDetail = new ArrayList<>();
            //Duyet tung row
            for (int i=1; i<= sheet.getLastRowNum();i++) {
                //Lấy dòng đấy ra
                Row row = sheet.getRow(i);
                //Nếu không có dữ liệu nào thì bỏ qua
                if(row == null) continue;
                //Lấy productId
                Cell productIdCell = row.getCell(0);
                //Check exist ?
                if(productIdCell==null) continue;
                //Check loại dữ liệu của ô đấy
                String productId = "";
                if(productIdCell.getCellType() == CellType.STRING) {
                    productId = productIdCell.getStringCellValue();
                } else if (productIdCell.getCellType() == CellType.NUMERIC) {
                    productId = String.valueOf(productIdCell.getNumericCellValue());
                }
                //Lấy product
                Product product = productRepository.findProductByProductId(productId);
                //check exist ?
                if(product==null) continue;
                BigDecimal disCountValue = BigDecimal.valueOf(row.getCell(1).getNumericCellValue());
                String discountType = row.getCell(2).getStringCellValue();
                int minQuantity = (int)row.getCell(3).getNumericCellValue();

                PromotionDetail detail = new PromotionDetail();
                detail.setPromotion(promotion);
                detail.setProduct(product);
                detail.setDiscountValue(disCountValue);
                detail.setDiscountType(PromotionDetail.DiscountType.valueOf(discountType));
                detail.setMinQuantity(minQuantity);

                listDetail.add(detail);
            }
            promotionDetailRepository.saveAll(listDetail);
        }

    }
}
