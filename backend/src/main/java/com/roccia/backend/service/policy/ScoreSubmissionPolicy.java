package com.roccia.backend.service.policy;

import com.roccia.backend.domain.User;
import com.roccia.backend.dto.request.ScoreSubmitRequest;
import com.roccia.backend.exception.DuplicateResourceException;
import com.roccia.backend.repository.ScoreRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class ScoreSubmissionPolicy {

    private final ScoreRepository scoreRepository;

    public void validate(User user, ScoreSubmitRequest request) {
        validateDuplicateSubmission(user, request.getSector());
    }

    private void validateDuplicateSubmission(User user, int sector) {
        if (scoreRepository.findByUserAndSector(user, sector).isPresent()) {
            throw new DuplicateResourceException("이미 제출한 섹터입니다. 삭제 후 다시 제출해주세요.");
        }
    }
}
