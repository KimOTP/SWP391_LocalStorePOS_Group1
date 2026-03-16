package com.swp391pos;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.annotation.EnableScheduling;

@EnableScheduling
@EnableAsync
@SpringBootApplication
public class Swp391PosApplication {

    public static void main(String[] args) {
        SpringApplication.run(Swp391PosApplication.class, args);
    }

}
