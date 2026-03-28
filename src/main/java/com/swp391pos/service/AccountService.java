package com.swp391pos.service;

import com.swp391pos.entity.Account;
import com.swp391pos.entity.Employee;
import com.swp391pos.repository.AccountRepository;
import com.swp391pos.repository.EmployeeRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AccountService {

    private final EmployeeRepository employeeRepository;
    private final AccountRepository accountRepository;

    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    public String createAccount(String fullName,
                                String username,
                                String email,
                                String role,
                                String password,
                                String confirmPassword) {

        // 1. Check password match
        if (!password.equals(confirmPassword)) {
            return "Password does not match!";
        }

        // 2. Check username tồn tại
        if (accountRepository.findByUsername(username).isPresent()) {
            return "Username already exists!";
        }

        // 3. Check email tồn tại
        if (employeeRepository.findByEmail(email).isPresent()) {
            return "Email already exists!";
        }

        //4. Check password length
        if (password.length() < 6) {
            return "Password must be at least 6 characters!";
        }

        //5. Check username length
        if (fullName.length() > 100) {
            return "Full name must not exceed 100 characters!";
        }

        // 6. Tạo Employee
        Employee employee = new Employee();
        employee.setFullName(fullName);
        employee.setEmail(email);
        employee.setRole(role);
        employee.setStatus(true);

        employeeRepository.save(employee);

        // 7. Tạo Account
        Account account = new Account();
        account.setEmployee(employee);
        account.setUsername(username);
        account.setPasswordHash(passwordEncoder.encode(password));

        accountRepository.save(account);

        return "success";
    }
}