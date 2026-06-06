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

@RestController
@RequestMapping("/api/scores")
@RequiredArgsConstructor
public class ScoreController {

    private final ScoreService scoreService;

    // 점수 제출
    @PostMapping
    public ResponseEntity<ScoreResponse> submitScore(@Valid @RequestBody ScoreSubmitRequest request) {
        return ResponseEntity.ok(scoreService.submitScore(request));
    }

    // 사용자 점수 조회
    @GetMapping("/user")
    public ResponseEntity<List<ScoreResponse>> getUserScores(@RequestParam String teamName,
                                                           @RequestParam String userName) {
        return ResponseEntity.ok(scoreService.getScores(teamName, userName));
    }


    // 특정 섹터 점수 삭제
    @DeleteMapping("/{teamName}/{userName}/{sector}")
    public ResponseEntity<Void> deleteScore(@PathVariable String teamName,
                                            @PathVariable String userName,
                                            @PathVariable int sector) {
        scoreService.deleteScore(teamName, userName, sector);
        return ResponseEntity.noContent().build();
    }
}