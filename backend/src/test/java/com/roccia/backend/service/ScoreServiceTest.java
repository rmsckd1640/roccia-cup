package com.roccia.backend.service;

import com.roccia.backend.IntegrationTestSupport;
import com.roccia.backend.domain.Role;
import com.roccia.backend.domain.Score;
import com.roccia.backend.domain.Team;
import com.roccia.backend.domain.User;
import com.roccia.backend.dto.request.ScoreSubmitRequest;
import com.roccia.backend.dto.response.ScoreResponse;
import com.roccia.backend.exception.DuplicateResourceException;
import com.roccia.backend.exception.UserNotFoundException;
import com.roccia.backend.repository.ScoreRepository;
import com.roccia.backend.repository.TeamRepository;
import com.roccia.backend.repository.UserRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

@Transactional
class ScoreServiceTest extends IntegrationTestSupport {

    @Autowired
    private ScoreService scoreService;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private TeamRepository teamRepository;

    @Autowired
    private ScoreRepository scoreRepository;

    @Test
    void submitScore_savesScore() {
        User user = saveUser("A팀", "사용자1");

        ScoreResponse response = scoreService.submitScore(
                new ScoreSubmitRequest(user.getId(), 1, 100)
        );

        List<Score> scores = scoreRepository.findByUser(user);

        assertThat(response.getSector()).isEqualTo(1);
        assertThat(response.getPoint()).isEqualTo(100);
        assertThat(scores).hasSize(1);
        assertThat(scores.get(0).getSector()).isEqualTo(1);
        assertThat(scores.get(0).getPoint()).isEqualTo(100);
    }

    @Test
    void submitScore_throwsExceptionWhenSectorAlreadySubmitted() {
        User user = saveUser("A팀", "사용자1");
        ScoreSubmitRequest request = new ScoreSubmitRequest(user.getId(), 1, 100);

        scoreService.submitScore(request);

        assertThatThrownBy(() -> scoreService.submitScore(request))
                .isInstanceOf(DuplicateResourceException.class)
                .hasMessage("이미 제출한 섹터입니다. 삭제 후 다시 제출해주세요.");
    }

    @Test
    void submitScore_throwsExceptionWhenUserDoesNotExist() {
        ScoreSubmitRequest request = new ScoreSubmitRequest(999L, 1, 100);

        assertThatThrownBy(() -> scoreService.submitScore(request))
                .isInstanceOf(UserNotFoundException.class)
                .hasMessage("사용자를 찾을 수 없습니다.");
    }

    private User saveUser(String teamName, String userName) {
        Team team = teamRepository.findByName(teamName)
                .orElseGet(() -> teamRepository.save(Team.builder().name(teamName).build()));
        return userRepository.save(User.builder()
                .team(team)
                .userName(userName)
                .role(Role.MEMBER)
                .build());
    }
}
