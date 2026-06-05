package com.roccia.backend.controller;

import com.roccia.backend.domain.User;
import com.roccia.backend.dto.UserLoginRequest;
import com.roccia.backend.dto.UserResponse;
import com.roccia.backend.dto.UserUpdateRequest;
import com.roccia.backend.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    // 로그인 (있으면 반환, 없으면 생성)
    @PostMapping("/login")
    public ResponseEntity<UserResponse> login(@Valid @RequestBody UserLoginRequest request) {
        User user = userService.loginOrCreateUser(request.getTeamName(), request.getUserName(), request.getRole());
        return ResponseEntity.ok(UserResponse.from(user));
    }

    // 정보 수정
    @PatchMapping
    public ResponseEntity<UserResponse> updateUser(@Valid @RequestBody UserUpdateRequest request) {
        User updatedUser = userService.updateUser(request);
        return ResponseEntity.ok(UserResponse.from(updatedUser));
    }
}