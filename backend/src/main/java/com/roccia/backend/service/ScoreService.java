package com.roccia.backend.service;

import com.roccia.backend.entity.Score;
import com.roccia.backend.entity.User;
import com.roccia.backend.repository.ScoreRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class ScoreService {

    private final ScoreRepository scoreRepository;

    public Score submitScore(User user, int sector, int score) {
        if (sector == 99 && scoreRepository.existsByUser_TeamNameAndSector(user.getTeamName(), 99)) {
            throw new IllegalArgumentException("이미 이 팀은 지구력 점수를 입력했습니다.");
        }

        if (scoreRepository.findByUserAndSector(user, sector).isPresent()) {
            throw new IllegalArgumentException("이미 이 섹터에 점수를 입력했습니다.");
        }

        return scoreRepository.save(Score.builder()
                .user(user)
                .sector(sector)
                .score(score)
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