package com.swp391pos.service;

import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class AttendanceJobService {

    private final AttendanceService attendanceService;

    // chạy 23:00 mỗi ngày
    @Scheduled(cron = "0 0 23 * * ?")
    public void autoClose() {
        attendanceService.autoMarkAbsent();
    }

    @Scheduled(cron = "0 5 0 * * ?") // 00:05 mỗi ngày
    public void autoGenerate7Days() {
        attendanceService.generateNext7DaysForAllEmployees();
    }
}
