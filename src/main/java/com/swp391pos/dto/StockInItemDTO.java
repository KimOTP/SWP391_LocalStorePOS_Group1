package com.swp391pos.dto;

import lombok.Data;
import java.math.BigDecimal;

@Data
public class StockInItemDTO {

    private String sku;

    private Integer qty;

    private BigDecimal price;
}
