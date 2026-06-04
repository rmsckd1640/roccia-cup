package com.roccia.backend.controller;

import com.roccia.backend.dto.RankingDto;
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
    public ResponseEntity<List<RankingDto>> getTeamRankings() {
        return ResponseEntity.ok(rankingService.getTeamRankings());
    }
}