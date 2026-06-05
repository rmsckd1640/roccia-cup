package com.roccia.backend.controller;

import com.roccia.backend.dto.RankingResponse;
import com.roccia.backend.service.RankingService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/rankings")
@RequiredArgsConstructor
public class RankingController {

    private final RankingService rankingService;

    @GetMapping
    public ResponseEntity<List<RankingResponse>> getTeamRankings() {
        return ResponseEntity.ok(rankingService.getTeamRankings());
    }
}