package com.roccia.backend.service;

import com.roccia.backend.domain.Role;
import com.roccia.backend.domain.User;
import com.roccia.backend.exception.DuplicateResourceException;
import com.roccia.backend.exception.UserNotFoundException;
import com.roccia.backend.repository.UserRepository;
import com.roccia.backend.dto.UserUpdateRequest;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;

    public User loginOrCreateUser(String teamName, String userName, String role) {
        Role userRole = (role != null) ? Role.valueOf(role.toUpperCase()) : Role.MEMBER;
        return userRepository.findByTeamNameAndUserName(teamName, userName)
                .orElseGet(() -> userRepository.save(User.builder()
                        .teamName(teamName)
                        .userName(userName)
                        .role(userRole)
                        .build()));
    }

    @Transactional
    public User updateUser(UserUpdateRequest request) {
        User currentUser = getValidatedUser(request.getTeamName(), request.getUserName());

        // 본인이 아닌데 같은 팀명 + 이름인 유저가 이미 존재할 경우 예외 처리
        Optional<User> existing = userRepository.findByTeamNameAndUserName(
                request.getNewTeamName(), request.getNewUserName());

        if (existing.isPresent() && !existing.get().getId().equals(currentUser.getId())) {
            throw new DuplicateResourceException("이미 존재하는 팀명과 이름입니다.");
        }

        // 수정 진행
        Role newRole = (request.getNewRole() != null && !request.getNewRole().isBlank()) 
                ? Role.valueOf(request.getNewRole().toUpperCase()) 
                : currentUser.getRole();

        currentUser.updateProfile(request.getNewTeamName(), request.getNewUserName(), newRole);

        return userRepository.save(currentUser);
    }

    public User getValidatedUser(String teamName, String userName) {
        return userRepository.findByTeamNameAndUserName(teamName, userName)
                .orElseThrow(UserNotFoundException::new);
    }

    public Optional<User> find(String teamName, String userName) {
        return userRepository.findByTeamNameAndUserName(teamName, userName);
    }

    public boolean existsByTeamNameAndUserName(String teamName, String userName) {
        return userRepository.findByTeamNameAndUserName(teamName, userName).isPresent();
    }
}