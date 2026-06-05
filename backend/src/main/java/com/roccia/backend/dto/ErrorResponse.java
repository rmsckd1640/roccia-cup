package com.roccia.backend.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;
import java.util.List;

@Getter
@Builder
public class ErrorResponse {
    @Builder.Default // builder에 명시되어있지 않으면 null로 들어가는거 방어
    private final LocalDateTime timestamp = LocalDateTime.now();
    private final int status;
    private final String error;
    private final String message;

    @JsonInclude(JsonInclude.Include.NON_NULL) // null인 필드는 JSON 응답에서 아예 제외 (의미가 헷갈리지 않게)
    private final List<FieldError> errors;

    @Getter
    @Builder
    public static class FieldError {
        private final String field;
        private final String value;
        private final String reason;
    }
}
