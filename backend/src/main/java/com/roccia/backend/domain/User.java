package com.roccia.backend.domain;

import jakarta.persistence.*;
import lombok.*;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;

@Entity
@Table(name = "users")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "team_name")
    private String teamName;

    @Column(name = "user_name")
    private String userName;

    @Enumerated(EnumType.STRING)
    private Role role;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Builder
    public User(String teamName, String userName, Role role) {
        validateName(teamName, userName);
        this.teamName = teamName;
        this.userName = userName;
        this.role = role != null ? role : Role.MEMBER;
    }

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
    }

    public void updateProfile(String teamName, String userName, Role role) {
        validateName(teamName, userName);
        this.teamName = teamName;
        this.userName = userName;
        if (role != null) {
            this.role = role;
        }
    }

    private void validateName(String teamName, String userName) {
        if (!StringUtils.hasText(teamName)) {
            throw new IllegalArgumentException("팀 이름은 필수이며 비어있을 수 없습니다.");
        }
        if (!StringUtils.hasText(userName)) {
            throw new IllegalArgumentException("사용자 이름은 필수이며 비어있을 수 없습니다.");
        }
    }
}