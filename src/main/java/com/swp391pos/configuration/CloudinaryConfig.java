package com.swp391pos.configuration;

import com.cloudinary.Cloudinary;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.HashMap;
import java.util.Map;

@Configuration
public class CloudinaryConfig {
    @Bean
    public Cloudinary cloudinary() {
        Map<String, String> config = new HashMap<>();
        config.put("cloud_name", "dj5rectby");
        config.put("api_key", "188621757551618");
        config.put("api_secret", "_IFGXJHHzO9ACHOcni86R2hWu5M");
        return new Cloudinary(config);
    }
}
