package com.roccia.backend.dto;

import com.roccia.backend.domain.Score;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Getter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ScoreResponse {
    private Long id;
    private int sector;
    private int point;
    private LocalDateTime submittedAt;

    public static ScoreResponse from(Score score) {
        return ScoreResponse.builder()
                .id(score.getId())
                .sector(score.getSector())
                .point(score.getPoint())
                .submittedAt(score.getSubmittedAt())
                .build();
    }
}
