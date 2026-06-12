package com.roccia.backend.service;

import com.roccia.backend.domain.Score;
import com.roccia.backend.domain.User;
import com.roccia.backend.dto.ScoreResponse;
import com.roccia.backend.dto.ScoreSubmitRequest;
import com.roccia.backend.exception.DuplicateResourceException;
import com.roccia.backend.exception.ScoreNotFoundException;
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
        User user = userService.getValidatedUser(request.getUserId());

        Optional<Score> existingScore = scoreRepository.findByUserAndSector(user, request.getSector());

        if (existingScore.isPresent()) {
            throw new DuplicateResourceException("이미 제출한 섹터입니다. 삭제 후 다시 제출해주세요.");
        }

        Score saved = scoreRepository.save(Score.builder()
                .user(user)
                .sector(request.getSector())
                .point(request.getPoint())
                .build());

        return ScoreResponse.from(saved);
    }


    public List<ScoreResponse> getScores(Long userId) {
        User user = userService.getValidatedUser(userId);
        return scoreRepository.findByUser(user).stream()
                .map(ScoreResponse::from)
                .collect(Collectors.toList());
    }

    @Transactional
    public void deleteScore(Long scoreId) {
        Score score = scoreRepository.findById(scoreId)
                .orElseThrow(ScoreNotFoundException::new);
        scoreRepository.delete(score);
    }
}
