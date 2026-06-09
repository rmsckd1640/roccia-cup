package com.roccia.backend.controller;

import com.roccia.backend.dto.RankingResponse;
import com.roccia.backend.service.RankingService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;

@Tag(name = "Ranking API", description = "팀별 랭킹 산출 관련 API")
@RestController
@RequestMapping("/api/rankings")
@RequiredArgsConstructor
public class RankingController {

    private final RankingService rankingService;

    @Operation(summary = "전체 팀 랭킹 조회", description = "모든 팀의 평균 점수를 계산하여 내림차순 랭킹을 반환합니다.")
    @GetMapping
    public ResponseEntity<List<RankingResponse>> getRankings() {
        return ResponseEntity.ok(rankingService.getTeamRankings());
    }
}