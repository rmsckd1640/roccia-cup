package com.roccia.backend.exception;

import com.roccia.backend.dto.ErrorResponse;
import org.junit.jupiter.api.Test;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import static org.assertj.core.api.Assertions.assertThat;

class GlobalExceptionHandlerTest {

    private final GlobalExceptionHandler exceptionHandler = new GlobalExceptionHandler();

    @Test
    void handleBaseException_returnsConflictForDuplicateResource() {
        ResponseEntity<ErrorResponse> response = exceptionHandler.handleBaseException(
                new DuplicateResourceException("이미 제출한 섹터입니다.")
        );

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CONFLICT);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().getStatus()).isEqualTo(HttpStatus.CONFLICT.value());
        assertThat(response.getBody().getError()).isEqualTo(HttpStatus.CONFLICT.name());
        assertThat(response.getBody().getMessage()).isEqualTo("이미 제출한 섹터입니다.");
    }

    @Test
    void handleDataIntegrityViolationException_returnsConflict() {
        ResponseEntity<ErrorResponse> response = exceptionHandler.handleDataIntegrityViolationException(
                new DataIntegrityViolationException("duplicate key")
        );

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CONFLICT);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().getStatus()).isEqualTo(HttpStatus.CONFLICT.value());
        assertThat(response.getBody().getError()).isEqualTo(HttpStatus.CONFLICT.name());
        assertThat(response.getBody().getMessage()).isEqualTo("이미 존재하는 데이터입니다.");
    }

    @Test
    void handleBadRequestException_returnsBadRequest() {
        ResponseEntity<ErrorResponse> response = exceptionHandler.handleBadRequestException(
                new IllegalArgumentException("invalid")
        );

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.BAD_REQUEST);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().getStatus()).isEqualTo(HttpStatus.BAD_REQUEST.value());
        assertThat(response.getBody().getError()).isEqualTo(HttpStatus.BAD_REQUEST.name());
        assertThat(response.getBody().getMessage()).isEqualTo("잘못된 요청입니다.");
    }
}
