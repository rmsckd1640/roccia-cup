package com.roccia.backend.domain;

import jakarta.persistence.*;
import lombok.*;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;

@Entity
@Table(
        name = "teams",
        uniqueConstraints = {@UniqueConstraint(columnNames = {"name"})}
)
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Team {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "name", nullable = false)
    private String name;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Builder
    public Team(String name) {
        if (!StringUtils.hasText(name)) {
            throw new IllegalArgumentException("팀 이름은 필수이며 비어있을 수 없습니다.");
        }
        this.name = name;
    }

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
    }
}
