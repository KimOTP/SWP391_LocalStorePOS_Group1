package com.swp391pos.repository;

import com.swp391pos.entity.PosReceipt;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PosReceiptRepository extends JpaRepository<PosReceipt, Long> {
}