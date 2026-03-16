package com.swp391pos.service;

import com.swp391pos.entity.PointHistory;
import com.swp391pos.repository.PointHistoryRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class PointHistoryService {
    @Autowired
    private PointHistoryRepository pointHistoryRepository;

    public void save(PointHistory pointHistory) {
        pointHistoryRepository.save(pointHistory);
    }
}
