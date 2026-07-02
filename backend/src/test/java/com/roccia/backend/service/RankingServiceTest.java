package com.roccia.backend.service;

import com.roccia.backend.IntegrationTestSupport;
import com.roccia.backend.domain.Role;
import com.roccia.backend.domain.Score;
import com.roccia.backend.domain.User;
import com.roccia.backend.dto.response.RankingResponse;
import com.roccia.backend.repository.ScoreRepository;
import com.roccia.backend.repository.UserRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.within;

@Transactional
class RankingServiceTest extends IntegrationTestSupport {

    @Autowired
    private RankingService rankingService;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private ScoreRepository scoreRepository;

    @Test
    void getTeamRankings_includesTeamWithoutScores() {
        userRepository.save(User.builder()
                .teamName("A팀")
                .userName("사용자1")
                .role(Role.MEMBER)
                .build());

        List<RankingResponse> rankings = rankingService.getTeamRankings();

        assertThat(rankings).hasSize(1);
        assertThat(rankings.get(0).getTeamName()).isEqualTo("A팀");
        assertThat(rankings.get(0).getAverageScore()).isEqualTo(0.0);
    }

    @Test
    void getTeamRankings_calculatesAverageScoreAndSortsDescending() {
        User aUser1 = saveUser("A팀", "A-1");
        User aUser2 = saveUser("A팀", "A-2");
        User bUser = saveUser("B팀", "B-1");
        saveUser("C팀", "C-1");

        saveScore(aUser1, 1, 100);
        saveScore(aUser2, 1, 50);
        saveScore(bUser, 1, 90);

        List<RankingResponse> rankings = rankingService.getTeamRankings();

        assertThat(rankings).hasSize(3);

        assertThat(rankings.get(0).getTeamName()).isEqualTo("B팀");
        assertThat(rankings.get(0).getAverageScore()).isCloseTo(90.0, within(0.001));

        assertThat(rankings.get(1).getTeamName()).isEqualTo("A팀");
        assertThat(rankings.get(1).getAverageScore()).isCloseTo(75.0, within(0.001));

        assertThat(rankings.get(2).getTeamName()).isEqualTo("C팀");
        assertThat(rankings.get(2).getAverageScore()).isCloseTo(0.0, within(0.001));
    }

    private User saveUser(String teamName, String userName) {
        return userRepository.save(User.builder()
                .teamName(teamName)
                .userName(userName)
                .role(Role.MEMBER)
                .build());
    }

    private void saveScore(User user, int sector, int point) {
        scoreRepository.save(Score.builder()
                .user(user)
                .sector(sector)
                .point(point)
                .build());
    }
}
