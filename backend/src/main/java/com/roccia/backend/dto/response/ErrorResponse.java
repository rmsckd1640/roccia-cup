package com.roccia.backend.dto.response;

import com.fasterxml.jackson.annotation.JsonInclude;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;
import java.util.List;

@Getter
@Builder
@Schema(description = "에러 응답")
public class ErrorResponse {
    @Schema(description = "에러 발생 시간")
    @Builder.Default
    private final LocalDateTime timestamp = LocalDateTime.now();

    @Schema(description = "HTTP 상태 코드", example = "400")
    private final int status;

    @Schema(description = "HTTP 상태 이름", example = "BAD_REQUEST")
    private final String error;

    @Schema(description = "에러 메시지", example = "입력값 검증에 실패했습니다.")
    private final String message;

    @Schema(description = "필드 검증 실패 목록")
    @JsonInclude(JsonInclude.Include.NON_NULL)
    private final List<FieldError> errors;

    @Getter
    @Builder
    @Schema(description = "필드 검증 실패 상세")
    public static class FieldError {
        @Schema(description = "검증 실패 필드")
        private final String field;

        @Schema(description = "거절된 값")
        private final String value;

        @Schema(description = "검증 실패 사유")
        private final String reason;
    }
}
