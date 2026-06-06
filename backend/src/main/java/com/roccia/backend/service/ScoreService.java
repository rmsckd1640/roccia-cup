package com.roccia.backend.service;

import com.roccia.backend.domain.Score;
import com.roccia.backend.domain.User;
import com.roccia.backend.dto.ScoreResponse;
import com.roccia.backend.dto.ScoreSubmitRequest;
import com.roccia.backend.repository.ScoreRepository;
import org.springframework.transaction.annotation.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ScoreService {

    private final ScoreRepository scoreRepository;
    private final UserService userService;

    @Transactional
    public ScoreResponse submitScore(ScoreSubmitRequest request) {
        User user = userService.getValidatedUser(request.getTeamName(), request.getUserName());

        Optional<Score> existingScore = scoreRepository.findByUserAndSector(user, request.getSector());

        if (existingScore.isPresent()) {
            Score scoreEntity = existingScore.get();
            scoreEntity.changePoint(request.getPoint());
            return ScoreResponse.from(scoreEntity);
        }

        Score saved = scoreRepository.save(Score.builder()
                .user(user)
                .sector(request.getSector())
                .point(request.getPoint())
                .build());

        return ScoreResponse.from(saved);
    }


    public List<ScoreResponse> getScores(String teamName, String userName) {
        User user = userService.getValidatedUser(teamName, userName);
        return scoreRepository.findByUser(user).stream()
                .map(ScoreResponse::from)
                .collect(Collectors.toList());
    }

    @Transactional
    public void deleteScore(String teamName, String userName, int sector) {
        User user = userService.getValidatedUser(teamName, userName);
        Optional<Score> scoreOpt = scoreRepository.findByUserAndSector(user, sector);
        scoreOpt.ifPresent(scoreRepository::delete);
    }
}