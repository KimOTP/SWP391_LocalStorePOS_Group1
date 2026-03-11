package com.swp391pos.controller.hr;

import com.swp391pos.entity.*;
import com.swp391pos.repository.EmployeeRepository;
import com.swp391pos.repository.NotificationRepository;
import com.swp391pos.repository.WorkShiftRepository;
import org.springframework.ui.Model;
import com.swp391pos.repository.NoteRepository;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Controller
@RequestMapping("/hr")
public class NoteController {

    @Autowired
    private NoteRepository noteRepository;

    @Autowired
    private WorkShiftRepository workShiftRepository;

    @Autowired
    private NotificationRepository notificationRepository;

    @Autowired
    private EmployeeRepository employeeRepository;

    @GetMapping("/note")
    public String notePage(Model model) {

        model.addAttribute("shifts", workShiftRepository.findAll());

        return "hr/common/note";
    }

    @GetMapping("/notification/read/{id}")
    public String readNotification(@PathVariable Integer id){

        Notification n = notificationRepository.findById(id).orElse(null);

        if(n != null){

            n.setIsRead(true);
            notificationRepository.save(n);

            if(n.getNote() != null){
                return "redirect:/hr/note/view/" + n.getNote().getNoteId();
            }
        }

        return "redirect:/hr/note";
    }

    @GetMapping("/note/view/{id}")
    public String viewNote(@PathVariable Integer id, Model model){

        Note note = noteRepository.findById(id).orElse(null);

        model.addAttribute("note", note);

        return "hr/common/note_view";
    }

    @PostMapping("/note/send")
    public String sendNote(@RequestParam(required = false) String title,
                           @RequestParam(required = false) String content,
                           @RequestParam(required = false) Integer shiftId,
                           HttpSession session,
                           RedirectAttributes redirect) {

        // CHECK SHIFT
        if (shiftId == null) {
            redirect.addFlashAttribute("error", "Please select shift");
            return "redirect:/hr/note";
        }

        // CHECK TITLE EMPTY
        if (title == null || title.trim().isEmpty()) {
            redirect.addFlashAttribute("error", "Title cannot be empty");
            return "redirect:/hr/note";
        }

        // CHECK CONTENT EMPTY
        if (content == null || content.trim().isEmpty()) {
            redirect.addFlashAttribute("error", "Content cannot be empty");
            return "redirect:/hr/note";
        }

        // CHECK TITLE LENGTH
        if (title.length() > 255) {
            redirect.addFlashAttribute("error", "Title is too long (max 255 characters)");
            return "redirect:/hr/note";
        }

        // CHECK CONTENT LENGTH
        if (content.length() > 255) {
            redirect.addFlashAttribute("error", "Content is too long (max 255 characters)");
            return "redirect:/hr/note";
        }

        Account account = (Account) session.getAttribute("account");

        WorkShift shift = workShiftRepository.findById(shiftId).orElse(null);

        Note note = new Note();
        note.setSender(account.getEmployee());
        note.setContent(content);
        note.setCreatedAt(LocalDateTime.now());
        note.setWorkDate(LocalDate.now());
        note.setWorkShift(shift);

        noteRepository.save(note);

        List<Employee> employees = employeeRepository.findAll();

        for (Employee emp : employees) {

            Notification noti = new Notification();

            noti.setReceiver(emp);
            noti.setTitle(title);
            noti.setMessage(content);
            noti.setType("NOTE");
            noti.setCreatedAt(LocalDateTime.now());
            noti.setIsRead(false);
            noti.setNote(note);

            notificationRepository.save(noti);
        }

        redirect.addFlashAttribute("success", "Send Successfully!");

        return "redirect:/hr/note";
    }
}