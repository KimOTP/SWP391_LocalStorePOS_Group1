package com.swp391pos.repository;

import com.swp391pos.entity.Combo;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ComboRepository extends JpaRepository<Combo, String> {

    // Tìm kiếm combo theo ID (ID là String)
    Combo findComboByComboId(String comboId);

    // Truy vấn lấy SKU cuối cùng để sinh mã tự động
    // Lưu ý: Nếu dùng Spring Boot cũ hơn 3.2, có thể cần dùng Pageable thay cho LIMIT 1
    @Query("SELECT c.comboId FROM Combo c WHERE c.comboId LIKE 'SKU-COM-%' ORDER BY c.comboId DESC")
    List<String> findLastSkuRaw(Pageable pageable);

    // Cách viết hiện đại cho Spring Boot 3.2+:
    @Query("SELECT c.comboId FROM Combo c WHERE c.comboId LIKE 'SKU-COM-%' ORDER BY c.comboId DESC LIMIT 1")
    String findLastSku();

    // Thêm hàm đếm theo Trạng thái (Enum) để phục vụ các thẻ Stat Cards trên giao diện
    long countByStatusCombo(Combo.Status statusCombo);

    List<Combo> findByStatusComboIn(List<String> statuses);

    @Query("SELECT cd.combo FROM ComboDetail cd WHERE cd.product.productId = :productId")
    List<Combo> findComboByProductId(@Param("productId") String productId);
}