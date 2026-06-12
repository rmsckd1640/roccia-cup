package com.roccia.backend.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class ScoreSubmitRequest {
    @NotNull(message = "사용자 ID는 필수입니다.")
    private Long userId;

    @Min(value = 1, message = "섹터 번호는 1 이상이어야 합니다.")
    @Max(value = 6, message = "섹터 번호는 6 이하여야 합니다.")
    private int sector;

    @Min(value = 0, message = "점수는 0 이상이어야 합니다.")
    private int point;
}
