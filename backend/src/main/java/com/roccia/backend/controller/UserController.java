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
        return ResponseEntity.ok(userService.joinOrLogin(request.getTeamName(), request.getUserName(), request.getRole()));
    }

    @PatchMapping
    public ResponseEntity<UserResponse> updateUser(@Valid @RequestBody UserUpdateRequest request) {
        return ResponseEntity.ok(userService.updateUser(request));
    }
}