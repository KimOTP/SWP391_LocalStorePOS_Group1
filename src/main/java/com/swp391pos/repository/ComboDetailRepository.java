package com.swp391pos.repository;

import com.swp391pos.entity.Combo;
import com.swp391pos.entity.ComboDetail;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ComboDetailRepository extends JpaRepository<ComboDetail, Long> {

    void deleteByCombo(Combo combo);
}