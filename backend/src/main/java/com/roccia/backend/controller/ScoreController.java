package com.roccia.backend.controller;

import com.roccia.backend.dto.request.ScoreSubmitRequest;
import com.roccia.backend.dto.response.ErrorResponse;
import com.roccia.backend.dto.response.ScoreResponse;
import com.roccia.backend.service.ScoreService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "Scores", description = "섹터별 점수 제출 및 삭제 API")
@RestController
@RequestMapping(value = "/api/scores", produces = MediaType.APPLICATION_JSON_VALUE)
@RequiredArgsConstructor
public class ScoreController {

    private final ScoreService scoreService;

    @Operation(summary = "점수 제출", description = "참가자의 섹터 점수를 제출합니다. 이미 제출한 섹터는 삭제 후 다시 제출해야 합니다.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "점수 제출 성공"),
            @ApiResponse(responseCode = "400", description = "입력값 검증 실패", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
            @ApiResponse(responseCode = "404", description = "사용자를 찾을 수 없음", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
            @ApiResponse(responseCode = "409", description = "이미 제출한 섹터", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping
    public ResponseEntity<ScoreResponse> submitScore(@Valid @RequestBody ScoreSubmitRequest request) {
        return ResponseEntity.ok(scoreService.submitScore(request));
    }

    @Operation(summary = "점수 삭제", description = "점수 ID를 기준으로 제출된 점수를 삭제합니다.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "204", description = "점수 삭제 성공"),
            @ApiResponse(responseCode = "404", description = "삭제할 점수를 찾을 수 없음", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @DeleteMapping("/{scoreId}")
    public ResponseEntity<Void> deleteScore(@PathVariable Long scoreId) {
        scoreService.deleteScore(scoreId);
        return ResponseEntity.noContent().build();
    }
}
