package com.swp391pos.configuration.web;

import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class FilterConfig {

    @Bean
    public FilterRegistrationBean<RoleAuthorizationFilter> loggingFilter() {
        FilterRegistrationBean<RoleAuthorizationFilter> registrationBean = new FilterRegistrationBean<>();

        registrationBean.setFilter(new RoleAuthorizationFilter());

        // Cấu hình các đường dẫn cần bảo vệ
        // Chúng ta quét hết /views/* nhưng Filter sẽ có logic loại trừ static
        registrationBean.addUrlPatterns("/*");

        registrationBean.setOrder(1);
        return registrationBean;
    }
}