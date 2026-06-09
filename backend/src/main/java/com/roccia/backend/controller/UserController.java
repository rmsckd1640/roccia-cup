package com.roccia.backend.controller;

import com.roccia.backend.dto.UserLoginRequest;
import com.roccia.backend.dto.UserResponse;
import com.roccia.backend.dto.UserUpdateRequest;
import com.roccia.backend.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;

@Tag(name = "User API", description = "사용자 관리 및 인증 관련 API")
@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    // 로그인 (있으면 반환, 없으면 생성)
    @Operation(summary = "로그인 및 회원가입", description = "팀명과 이름을 입력받아 로그인을 진행합니다. 존재하지 않는 유저라면 자동으로 회원가입 처리됩니다.")
    @PostMapping("/login")
    public ResponseEntity<UserResponse> login(@Valid @RequestBody UserLoginRequest request) {
        return ResponseEntity.ok(userService.joinOrLogin(request.getTeamName(), request.getUserName(), request.getRole()));
    }

    @Operation(summary = "사용자 정보 수정", description = "기존 사용자의 팀명, 이름 또는 역할을 수정합니다.")
    @PatchMapping
    public ResponseEntity<UserResponse> updateUser(@Valid @RequestBody UserUpdateRequest request) {
        return ResponseEntity.ok(userService.updateUser(request));
    }
}