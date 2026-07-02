package com.roccia.backend.service;

import com.roccia.backend.domain.Score;
import com.roccia.backend.domain.User;
import com.roccia.backend.dto.request.ScoreSubmitRequest;
import com.roccia.backend.dto.response.ScoreResponse;
import com.roccia.backend.exception.ScoreNotFoundException;
import com.roccia.backend.repository.ScoreRepository;
import com.roccia.backend.service.policy.ScoreSubmissionPolicy;
import org.springframework.transaction.annotation.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ScoreService {

    private final ScoreRepository scoreRepository;
    private final UserService userService;
    private final ScoreSubmissionPolicy scoreSubmissionPolicy;

    @Transactional
    public ScoreResponse submitScore(ScoreSubmitRequest request) {
        User user = userService.getValidatedUser(request.getUserId());

        scoreSubmissionPolicy.validate(user, request);

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
