package com.roccia.backend.domain;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(
        name = "scores",
        uniqueConstraints = {@UniqueConstraint(columnNames = {"user_id", "sector"})}
)
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Score {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    private int sector;

    private int point;

    @Column(name = "submitted_at")
    private LocalDateTime submittedAt;

    @Builder
    public Score(User user, int sector, int point) {
        validate(user, sector, point);
        this.user = user;
        this.sector = sector;
        this.point = point;
    }

    @PrePersist
    protected void onCreate() {
        this.submittedAt = LocalDateTime.now();
    }

    private void validate(User user, int sector, int point) {
        if (user == null) {
            throw new IllegalArgumentException("사용자 정보는 필수입니다.");
        }
        if (sector < 1 || sector > 6) {
            throw new IllegalArgumentException("섹터 번호는 1 이상 6 이하여야 합니다.");
        }
        if (point < 0) {
            throw new IllegalArgumentException("점수는 0 이상이어야 합니다.");
        }
    }
}
