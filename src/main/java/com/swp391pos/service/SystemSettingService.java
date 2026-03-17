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

    //  Lấy tất cả setting về dạng Map (Key -> Value)
    public Map<String, String> getAllSettings() {
        List<SystemSetting> list = settingRepository.findAll();
        Map<String, String> map = new HashMap<>();
        for (SystemSetting s : list) {
            map.put(s.getSettingKey(), s.getSettingValue());
        }
        return map;
    }

    //  Cập nhật point config
    public void updateSetting(String key, String value, Employee updater) {
        try {
            if (key.equals("POINT_EARNING_RATE") || key.equals("POINT_REDEMPTION_VALUE") || key.equals("MIN_POINT_TO_REDEEM")) {
                if (Double.parseDouble(value) < 0) {
                    throw new IllegalArgumentException(key + " must >= 0");
                }
            } else if (key.equals("MAX_REDEEM_PERCENT")) {
                double percent = Double.parseDouble(value);
                if (percent < 0 || percent > 100) {
                    throw new IllegalArgumentException(key + " must from 0 to 100");
                }
            }
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException(key + " must is valid digits");
        }

        SystemSetting setting = settingRepository.findById(key).orElse(null);
        if (setting != null) {
            setting.setSettingValue(value);
            setting.setUpdatedAt(LocalDateTime.now());
            setting.setUpdatedBy(updater);
            settingRepository.save(setting);
        }
    }
}