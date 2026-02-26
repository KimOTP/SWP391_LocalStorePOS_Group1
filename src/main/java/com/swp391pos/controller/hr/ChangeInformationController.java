package com.swp391pos.controller.hr;

import com.swp391pos.entity.Account;
import com.swp391pos.repository.AccountRepository;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.Objects;
import java.util.Optional;

@Controller
@RequestMapping("/hr")
public class ChangeInformationController {

    @Autowired
    private AccountRepository accountRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    // ========================
    // VIEW CHANGE INFO PAGE
    // ========================
    @GetMapping("/change_information")
    public String changeInformation(HttpSession session,
                                    org.springframework.ui.Model model) {

        Account sessionAccount = (Account) session.getAttribute("account");

        Account account = accountRepository
                .findById(sessionAccount.getAccountId())
                .orElse(null);

        model.addAttribute("account", account);

        return "hr/common/change_information";
    }

    // ========================
    // UPDATE INFORMATION
    // ========================
    @PostMapping("/update_information")
    public String updateInformation(@RequestParam String fullName,
                                    @RequestParam String username,
                                    @RequestParam String email,
                                    HttpSession session,
                                    RedirectAttributes redirectAttributes) {

        Account sessionAccount = (Account) session.getAttribute("account");

        Account account = accountRepository
                .findById(sessionAccount.getAccountId())
                .orElse(null);

        if (account == null) {
            redirectAttributes.addFlashAttribute("error", "Account not found!");
            return "redirect:/hr/change_information";
        }

        boolean hasChange = false;

        // ❌ Username trùng
        Optional<Account> existingUsername = accountRepository.findByUsername(username);
        if (existingUsername.isPresent() &&
                !Objects.equals(existingUsername.get().getAccountId(), account.getAccountId())) {

            redirectAttributes.addFlashAttribute("error", "Username already exists!");
            return "redirect:/hr/change_information";
        }

        // ❌ Email trùng
        Optional<Account> existingEmail = accountRepository.findByEmployee_Email(email);
        if (existingEmail.isPresent() &&
                !Objects.equals(existingEmail.get().getAccountId(), account.getAccountId())) {

            redirectAttributes.addFlashAttribute("error", "Email already exists!");
            return "redirect:/hr/change_information";
        }

        if (!account.getEmployee().getFullName().equals(fullName)) {
            account.getEmployee().setFullName(fullName);
            hasChange = true;
        }

        if (!account.getUsername().equals(username)) {
            account.setUsername(username);
            hasChange = true;
        }

        if (!account.getEmployee().getEmail().equals(email)) {
            account.getEmployee().setEmail(email);
            hasChange = true;
        }

        if (!hasChange) {
            redirectAttributes.addFlashAttribute("error", "No changes detected!");
            return "redirect:/hr/change_information";
        }

        accountRepository.save(account);

        redirectAttributes.addFlashAttribute("success", "Update successfully!");
        return "redirect:/hr/change_information";
    }

    // ========================
    // CHANGE PASSWORD
    // ========================
    @PostMapping("/change_password")
    public String changePassword(@RequestParam String oldPassword,
                                 @RequestParam String newPassword,
                                 @RequestParam String confirmPassword,
                                 HttpSession session,
                                 RedirectAttributes redirectAttributes) {

        Account sessionAccount = (Account) session.getAttribute("account");

        Account account = accountRepository
                .findById(sessionAccount.getAccountId())
                .orElse(null);

        if (account == null) {
            redirectAttributes.addFlashAttribute("errorPass", "Account not found!");
            return "redirect:/hr/change_information";
        }

        if (!passwordEncoder.matches(oldPassword, account.getPasswordHash())) {
            redirectAttributes.addFlashAttribute("errorPass", "Old password incorrect!");
            return "redirect:/hr/change_information";
        }

        if (!newPassword.equals(confirmPassword)) {
            redirectAttributes.addFlashAttribute("errorPass", "Confirm password not match!");
            return "redirect:/hr/change_information";
        }

        if (passwordEncoder.matches(newPassword, account.getPasswordHash())) {
            redirectAttributes.addFlashAttribute("errorPass", "New password must be different!");
            return "redirect:/hr/change_information";
        }

        if (newPassword.length() < 6) {
            redirectAttributes.addFlashAttribute("errorPass", "Password must be at least 6 characters!");
            return "redirect:/hr/change_information";
        }

        account.setPasswordHash(passwordEncoder.encode(newPassword));
        accountRepository.save(account);

        redirectAttributes.addFlashAttribute("successPass", "Password changed successfully!");
        return "redirect:/hr/change_information";
    }
}