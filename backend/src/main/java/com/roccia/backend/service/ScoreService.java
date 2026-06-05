package com.roccia.backend.service;

import com.roccia.backend.domain.Score;
import com.roccia.backend.domain.User;
import com.roccia.backend.repository.ScoreRepository;
import org.springframework.transaction.annotation.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ScoreService {

    private final ScoreRepository scoreRepository;

    @Transactional
    public Score submitScore(User user, int sector, int point) {
        Optional<Score> existingScore = scoreRepository.findByUserAndSector(user, sector);

        if (existingScore.isPresent()) {
            Score scoreEntity = existingScore.get();
            scoreEntity.changePoint(point);
            return scoreEntity; // @Transactional에 의해 자동 업데이트(Dirty Checking)
        }

        return scoreRepository.save(Score.builder()
                .user(user)
                .sector(sector)
                .point(point)
                .build());
    }


    public List<Score> getScores(User user) {
        return scoreRepository.findByUser(user);
    }

    @Transactional
    public void deleteScore(User user, int sector) {
        Optional<Score> scoreOpt = scoreRepository.findByUserAndSector(user, sector);
        scoreOpt.ifPresent(scoreRepository::delete);
    }

    public void deleteAllByUser(User user) {
        scoreRepository.deleteByUser(user);
    }
}