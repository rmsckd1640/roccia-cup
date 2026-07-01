package com.roccia.backend.controller;

import com.roccia.backend.dto.RankingResponse;
import com.roccia.backend.service.RankingService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@Tag(name = "Rankings", description = "팀별 랭킹 조회 API")
@RestController
@RequestMapping(value = "/api/rankings", produces = MediaType.APPLICATION_JSON_VALUE)
@RequiredArgsConstructor
public class RankingController {

    private final RankingService rankingService;

    @Operation(summary = "전체 팀 랭킹 조회", description = "모든 팀의 평균 점수를 계산하여 내림차순 랭킹을 반환합니다.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "랭킹 조회 성공")
    })
    @GetMapping
    public ResponseEntity<List<RankingResponse>> getRankings() {
        return ResponseEntity.ok(rankingService.getTeamRankings());
    }
}
