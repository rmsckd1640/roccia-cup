package com.roccia.backend.controller;

import com.roccia.backend.domain.Score;
import com.roccia.backend.domain.User;
import com.roccia.backend.dto.ScoreResponse;
import com.roccia.backend.dto.ScoreSubmitRequest;
import com.roccia.backend.service.ScoreService;
import com.roccia.backend.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;

@Tag(name = "Score API", description = "점수 제출 및 관리 관련 API")
@RestController
@RequestMapping("/api/scores")
@RequiredArgsConstructor
public class ScoreController {

    private final ScoreService scoreService;

    // 점수 제출
    @Operation(summary = "점수 제출 및 수정", description = "특정 섹터의 점수를 제출합니다. 이미 점수가 존재하면 수정 처리됩니다.")
    @PostMapping
    public ResponseEntity<ScoreResponse> submitScore(@Valid @RequestBody ScoreSubmitRequest request) {
        return ResponseEntity.ok(scoreService.submitScore(request));
    }

    // 사용자 점수 조회
    @Operation(summary = "특정 사용자의 전체 점수 조회", description = "팀명과 이름을 통해 해당 사용자가 제출한 모든 섹터의 점수를 가져옵니다.")
    @GetMapping("/user")
    public ResponseEntity<List<ScoreResponse>> getUserScores(@RequestParam String teamName,
                                                           @RequestParam String userName) {
        return ResponseEntity.ok(scoreService.getScores(teamName, userName));
    }


    // 특정 섹터 점수 삭제
    @Operation(summary = "특정 섹터 점수 삭제", description = "사용자의 특정 섹터 점수를 삭제합니다.")
    @DeleteMapping("/{teamName}/{userName}/{sector}")
    public ResponseEntity<Void> deleteScore(@PathVariable String teamName,
                                            @PathVariable String userName,
                                            @PathVariable int sector) {
        scoreService.deleteScore(teamName, userName, sector);
        return ResponseEntity.noContent().build();
    }
}