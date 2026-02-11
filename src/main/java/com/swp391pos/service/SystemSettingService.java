package com.swp391pos.service;

import com.swp391pos.entity.Employee;
import com.swp391pos.entity.SystemSetting;
import com.swp391pos.repository.EmployeeRepository;
import com.swp391pos.repository.SystemSettingRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class SystemSettingService {

    @Autowired
    private SystemSettingRepository settingRepository;

    @Autowired
    private EmployeeRepository employeeRepository; // Để tìm nhân viên

    // 1. Lấy tất cả setting về dạng Map (Key -> Value)
    public Map<String, String> getAllSettings() {
        List<SystemSetting> list = settingRepository.findAll();
        Map<String, String> map = new HashMap<>();
        for (SystemSetting s : list) {
            map.put(s.getSettingKey(), s.getSettingValue());
        }
        return map;
    }

    // 2. Cập nhật Setting
    public void updateSetting(String key, String value) {
        SystemSetting setting = settingRepository.findById(key).orElse(null);
        if (setting != null) {
            setting.setSettingValue(value);
            setting.setUpdatedAt(LocalDateTime.now());

            // --- XỬ LÝ UPDATE BY (EMPLOYEE) ---
            // Tạm thời lấy Employee ID = 2 (Admin/Manager) như trong SQL mẫu của bạn
            // Sau này bạn thay bằng: employeeRepository.findById(sessionUserId)...
            Employee updater = employeeRepository.findById(2).orElse(null);
            setting.setUpdatedBy(updater);

            settingRepository.save(setting);
        }
    }
}