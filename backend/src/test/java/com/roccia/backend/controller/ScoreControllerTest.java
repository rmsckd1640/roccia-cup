package com.roccia.backend.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.roccia.backend.IntegrationTestSupport;
import com.roccia.backend.domain.Role;
import com.roccia.backend.domain.Score;
import com.roccia.backend.domain.User;
import com.roccia.backend.dto.request.ScoreSubmitRequest;
import com.roccia.backend.repository.ScoreRepository;
import com.roccia.backend.repository.UserRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@AutoConfigureMockMvc
@Transactional
class ScoreControllerTest extends IntegrationTestSupport {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private ScoreRepository scoreRepository;

    @Test
    void submitScore_returnsScoreResponse() throws Exception {
        User user = saveUser("A팀", "사용자1");
        ScoreSubmitRequest request = new ScoreSubmitRequest(user.getId(), 1, 100);

        mockMvc.perform(post("/api/scores")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").exists())
                .andExpect(jsonPath("$.sector").value(1))
                .andExpect(jsonPath("$.point").value(100))
                .andExpect(jsonPath("$.submittedAt").exists());
    }

    @Test
    void submitScore_returnsBadRequestWhenSectorIsInvalid() throws Exception {
        User user = saveUser("A팀", "사용자1");
        ScoreSubmitRequest request = new ScoreSubmitRequest(user.getId(), 99, 100);

        mockMvc.perform(post("/api/scores")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.status").value(400))
                .andExpect(jsonPath("$.error").value("BAD_REQUEST"))
                .andExpect(jsonPath("$.message").value("입력값 검증에 실패했습니다."))
                .andExpect(jsonPath("$.errors[0].field").value("sector"));
    }

    @Test
    void submitScore_returnsConflictWhenSectorAlreadySubmitted() throws Exception {
        User user = saveUser("A팀", "사용자1");
        scoreRepository.save(Score.builder()
                .user(user)
                .sector(1)
                .point(100)
                .build());

        ScoreSubmitRequest request = new ScoreSubmitRequest(user.getId(), 1, 100);

        mockMvc.perform(post("/api/scores")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.status").value(409))
                .andExpect(jsonPath("$.error").value("CONFLICT"))
                .andExpect(jsonPath("$.message").value("이미 제출한 섹터입니다. 삭제 후 다시 제출해주세요."));
    }

    @Test
    void deleteScore_returnsNoContent() throws Exception {
        User user = saveUser("A팀", "사용자1");
        Score score = scoreRepository.save(Score.builder()
                .user(user)
                .sector(1)
                .point(100)
                .build());

        mockMvc.perform(delete("/api/scores/{scoreId}", score.getId()))
                .andExpect(status().isNoContent());
    }

    @Test
    void deleteScore_returnsNotFoundWhenScoreDoesNotExist() throws Exception {
        mockMvc.perform(delete("/api/scores/{scoreId}", 999L))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.status").value(404))
                .andExpect(jsonPath("$.error").value("NOT_FOUND"))
                .andExpect(jsonPath("$.message").value("점수를 찾을 수 없습니다."));
    }

    private User saveUser(String teamName, String userName) {
        return userRepository.save(User.builder()
                .teamName(teamName)
                .userName(userName)
                .role(Role.MEMBER)
                .build());
    }
}
