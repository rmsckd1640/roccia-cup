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

    private int score;

    @Column(name = "submitted_at")
    private LocalDateTime submittedAt;

    @Builder
    public Score(User user, int sector, int score) {
        validate(user, sector, score);
        this.user = user;
        this.sector = sector;
        this.score = score;
    }

    @PrePersist
    protected void onCreate() {
        this.submittedAt = LocalDateTime.now();
    }

    public void changeScore(int newScore) {
        if (newScore < 0) {
            throw new IllegalArgumentException("점수는 0 이상이어야 합니다.");
        }
        this.score = newScore;
        this.submittedAt = LocalDateTime.now();
    }

    private void validate(User user, int sector, int score) {
        if (user == null) {
            throw new IllegalArgumentException("사용자 정보는 필수입니다.");
        }
        if (sector < 0) {
            throw new IllegalArgumentException("섹터 번호는 0 이상이어야 합니다.");
        }
        if (score < 0) {
            throw new IllegalArgumentException("점수는 0 이상이어야 합니다.");
        }
    }
}