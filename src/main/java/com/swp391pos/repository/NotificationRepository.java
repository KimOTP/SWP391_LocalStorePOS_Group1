package com.swp391pos.repository;

import com.swp391pos.entity.Notification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface NotificationRepository extends JpaRepository<Notification, Integer> {

    List<Notification> findByReceiver_EmployeeIdAndIsReadFalse(Integer employeeId);

    List<Notification> findTop10ByReceiver_EmployeeIdOrderByCreatedAtDesc(Integer employeeId);

}