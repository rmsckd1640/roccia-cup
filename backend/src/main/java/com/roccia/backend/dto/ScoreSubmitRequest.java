package com.roccia.backend.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class ScoreSubmitRequest {
    @NotBlank(message = "팀 이름은 필수입니다.")
    private String teamName;

    @NotBlank(message = "사용자 이름은 필수입니다.")
    private String userName;

    @Min(value = 0, message = "섹터 번호는 0 이상이어야 합니다.")
    private int sector;

    @Min(value = 0, message = "점수는 0 이상이어야 합니다.")
    private int score;
}
