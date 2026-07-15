package com.roccia.backend.service;

import com.roccia.backend.domain.Role;
import com.roccia.backend.domain.Team;
import com.roccia.backend.domain.User;
import com.roccia.backend.dto.request.UserUpdateRequest;
import com.roccia.backend.dto.response.UserResponse;
import com.roccia.backend.exception.DuplicateResourceException;
import com.roccia.backend.exception.UserNotFoundException;
import com.roccia.backend.repository.TeamRepository;
import com.roccia.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class UserService {

    private final UserRepository userRepository;
    private final TeamRepository teamRepository;

    @Transactional
    public UserResponse enter(String teamName, String userName, String role) {
        Role userRole = (role != null) ? Role.valueOf(role.toUpperCase()) : Role.MEMBER;
        Team team = getOrCreateTeam(teamName);
        User user = userRepository.findByTeamAndUserName(team, userName)
                .orElseGet(() -> userRepository.save(User.builder()
                        .team(team)
                        .userName(userName)
                        .role(userRole)
                        .build()));
        return UserResponse.from(user);
    }

    @Transactional
    public UserResponse updateUser(Long userId, UserUpdateRequest request) {
        User currentUser = getValidatedUser(userId);
        Team newTeam = getOrCreateTeam(request.getNewTeamName());

        // 본인이 아닌데 같은 팀 + 이름인 유저가 이미 존재할 경우 예외 처리
        Optional<User> existing = userRepository.findByTeamAndUserName(
                newTeam, request.getNewUserName());

        if (existing.isPresent() && !existing.get().getId().equals(currentUser.getId())) {
            throw new DuplicateResourceException("이미 존재하는 팀명과 이름입니다.");
        }

        // 수정 진행
        Role newRole = (request.getNewRole() != null && !request.getNewRole().isBlank())
                ? Role.valueOf(request.getNewRole().toUpperCase())
                : currentUser.getRole();

        currentUser.updateProfile(newTeam, request.getNewUserName(), newRole);

        return UserResponse.from(currentUser);
    }

    public User getValidatedUser(Long userId) {
        return userRepository.findById(userId)
                .orElseThrow(UserNotFoundException::new);
    }

    private Team getOrCreateTeam(String teamName) {
        return teamRepository.findByName(teamName)
                .orElseGet(() -> teamRepository.save(Team.builder().name(teamName).build()));
    }
}
