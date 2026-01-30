package listener;

import jakarta.persistence.Persistence;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

@WebListener
public class MyContextListener implements ServletContextListener {
    @Override
    public void contextInitialized(ServletContextEvent sce) {
        try {
            Persistence.createEntityManagerFactory("fuSWP391_G1");
            System.out.println(">>> JPA Factory created - Table should be generated now!");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
