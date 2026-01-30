package entity;

@Entity
@Data
@Table(name = "SystemSetting")
public class SystemSetting {
    @Id
    @Column(length = 50)
    private String settingKey;
    private String settingValue;
    private String description;
    @ManyToOne
    @JoinColumn(name = "updated_by")
    private Employee updatedBy;
    private LocalDateTime updatedAt;
}
