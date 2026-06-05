package com.roccia.backend.service;

import com.roccia.backend.domain.Score;
import com.roccia.backend.domain.User;
import com.roccia.backend.dto.RankingResponse;
import com.roccia.backend.repository.ScoreRepository;
import com.roccia.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class RankingService {

    private final UserRepository userRepository;
    private final ScoreRepository scoreRepository;

    public List<RankingResponse> getTeamRankings() {
        List<User> users = userRepository.findAll();

        Map<String, Integer> teamScoreSum = new HashMap<>();
        Map<String, Integer> teamMemberCount = new HashMap<>();

        for (User user : users) {
            String teamName = user.getTeamName();

            List<Score> scores = scoreRepository.findByUser(user);
            int sum = scores.stream().mapToInt(Score::getScore).sum();

            teamScoreSum.merge(teamName, sum, Integer::sum);
            teamMemberCount.merge(teamName, 1, Integer::sum);
        }

        Set<String> allTeams = teamMemberCount.keySet();

        return allTeams.stream()
                .map(team -> {
                    int sum = teamScoreSum.getOrDefault(team, 0);
                    int count = teamMemberCount.getOrDefault(team, 1);
                    double avg = (double) sum / count;

                    return new RankingResponse(team, avg);
                })
                .sorted((a, b) -> Double.compare(b.getAverageScore(), a.getAverageScore()))
                .collect(Collectors.toList());
    }
}
