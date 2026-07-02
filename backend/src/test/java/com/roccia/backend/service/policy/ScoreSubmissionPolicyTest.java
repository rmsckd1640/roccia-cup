package com.roccia.backend.service.policy;

import com.roccia.backend.IntegrationTestSupport;
import com.roccia.backend.domain.Role;
import com.roccia.backend.domain.Score;
import com.roccia.backend.domain.User;
import com.roccia.backend.dto.request.ScoreSubmitRequest;
import com.roccia.backend.exception.DuplicateResourceException;
import com.roccia.backend.repository.ScoreRepository;
import com.roccia.backend.repository.UserRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.transaction.annotation.Transactional;

import static org.assertj.core.api.Assertions.assertThatCode;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

@Transactional
class ScoreSubmissionPolicyTest extends IntegrationTestSupport {

    @Autowired
    private ScoreSubmissionPolicy scoreSubmissionPolicy;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private ScoreRepository scoreRepository;

    @Test
    void validate_doesNotThrowWhenSectorIsNotSubmitted() {
        User user = saveUser("A팀", "사용자1");
        ScoreSubmitRequest request = new ScoreSubmitRequest(user.getId(), 1, 100);

        assertThatCode(() -> scoreSubmissionPolicy.validate(user, request))
                .doesNotThrowAnyException();
    }

    @Test
    void validate_throwsExceptionWhenSectorAlreadySubmitted() {
        User user = saveUser("A팀", "사용자1");
        scoreRepository.save(Score.builder()
                .user(user)
                .sector(1)
                .point(100)
                .build());

        ScoreSubmitRequest request = new ScoreSubmitRequest(user.getId(), 1, 100);

        assertThatThrownBy(() -> scoreSubmissionPolicy.validate(user, request))
                .isInstanceOf(DuplicateResourceException.class)
                .hasMessage("이미 제출한 섹터입니다. 삭제 후 다시 제출해주세요.");
    }

    private User saveUser(String teamName, String userName) {
        return userRepository.save(User.builder()
                .teamName(teamName)
                .userName(userName)
                .role(Role.MEMBER)
                .build());
    }
}
