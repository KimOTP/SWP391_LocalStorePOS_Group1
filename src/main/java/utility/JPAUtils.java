package utility;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.Persistence;
import org.hibernate.Session;

import java.sql.Connection;

public class JPAUtils {
    private static EntityManagerFactory factory;

    static {
        // Khởi tạo factory một lần duy nhất khi ứng dụng chạy
        factory = Persistence.createEntityManagerFactory("fuSWP391_G1");
    }
    public static EntityManager getEntityManager() {
        return factory.createEntityManager();
    }
    public static Connection getConnectionFromJPA() {
        EntityManager em = getEntityManager();
        // Unwrap để lấy Session của Hibernate
        Session session = em.unwrap(Session.class);
        // Trả về connection đang được JPA quản lý
        return session.doReturningWork(conn -> conn);
    }
}
