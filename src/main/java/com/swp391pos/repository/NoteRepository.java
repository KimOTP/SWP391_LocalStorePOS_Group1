package com.swp391pos.repository;

import com.swp391pos.entity.Note;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface NoteRepository extends JpaRepository<Note, Integer> {
    // Tìm tất cả ghi chú của một ngày, sắp xếp theo thời gian bắt đầu của ca
    List<Note> findByWorkDateOrderByWorkShiftStartTimeAsc(LocalDate date);
}
