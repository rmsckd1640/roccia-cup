package com.roccia.backend.controller;

import com.roccia.backend.dto.UserLoginRequest;
import com.roccia.backend.dto.UserResponse;
import com.roccia.backend.dto.UserUpdateRequest;
import com.roccia.backend.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import com.roccia.backend.dto.ErrorResponse;

@Tag(name = "User API", description = "사용자 관리 및 인증 관련 API")
@RestController
@RequestMapping(value = "/api/users", produces = MediaType.APPLICATION_JSON_VALUE)
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    // 로그인 (있으면 반환, 없으면 생성)
    @Operation(summary = "로그인 및 회원가입", description = "팀명과 이름을 입력받아 로그인을 진행합니다. 존재하지 않는 유저라면 자동으로 회원가입 처리됩니다.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "로그인 성공"),
            @ApiResponse(responseCode = "400", description = "입력값 검증 실패 (빈칸 또는 역할 오타)", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("/login")
    public ResponseEntity<UserResponse> login(@Valid @RequestBody UserLoginRequest request) {
        return ResponseEntity.ok(userService.joinOrLogin(request.getTeamName(), request.getUserName(), request.getRole()));
    }

    @Operation(summary = "사용자 정보 수정", description = "기존 사용자의 팀명, 이름 또는 역할을 수정합니다.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "정보 수정 성공"),
            @ApiResponse(responseCode = "400", description = "입력값 검증 실패 또는 이미 존재하는 팀명/이름 중복", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
            @ApiResponse(responseCode = "404", description = "수정하려는 기존 유저를 찾을 수 없음", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PatchMapping
    public ResponseEntity<UserResponse> updateUser(@Valid @RequestBody UserUpdateRequest request) {
        return ResponseEntity.ok(userService.updateUser(request));
    }
}