package com.roccia.backend.controller;

import com.roccia.backend.dto.ErrorResponse;
import com.roccia.backend.dto.ScoreResponse;
import com.roccia.backend.dto.UserLoginRequest;
import com.roccia.backend.dto.UserResponse;
import com.roccia.backend.dto.UserUpdateRequest;
import com.roccia.backend.service.ScoreService;
import com.roccia.backend.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@Tag(name = "Users", description = "참가자 입장, 정보 수정, 참가자 점수 조회 API")
@RestController
@RequestMapping(value = "/api/users", produces = MediaType.APPLICATION_JSON_VALUE)
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;
    private final ScoreService scoreService;

    @Operation(summary = "참가자 입장", description = "팀명과 이름으로 입장합니다. 등록되지 않은 참가자는 현장 운영 편의를 위해 새로 등록됩니다.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "입장 성공"),
            @ApiResponse(responseCode = "400", description = "입력값 검증 실패", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
            @ApiResponse(responseCode = "409", description = "중복 데이터 충돌", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("/login")
    public ResponseEntity<UserResponse> login(@Valid @RequestBody UserLoginRequest request) {
        return ResponseEntity.ok(userService.joinOrLogin(request.getTeamName(), request.getUserName(), request.getRole()));
    }

    @Operation(summary = "사용자 정보 수정", description = "사용자 ID를 기준으로 팀명, 이름 또는 역할을 수정합니다.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "정보 수정 성공"),
            @ApiResponse(responseCode = "400", description = "입력값 검증 실패", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
            @ApiResponse(responseCode = "404", description = "수정할 사용자를 찾을 수 없음", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
            @ApiResponse(responseCode = "409", description = "이미 존재하는 팀명과 이름", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PatchMapping("/{userId}")
    public ResponseEntity<UserResponse> updateUser(@PathVariable Long userId,
                                                   @Valid @RequestBody UserUpdateRequest request) {
        return ResponseEntity.ok(userService.updateUser(userId, request));
    }

    @Operation(summary = "특정 사용자의 전체 점수 조회", description = "사용자 ID를 통해 해당 사용자가 제출한 모든 섹터의 점수를 가져옵니다.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "조회 성공"),
            @ApiResponse(responseCode = "404", description = "사용자를 찾을 수 없음", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @GetMapping("/{userId}/scores")
    public ResponseEntity<List<ScoreResponse>> getUserScores(@PathVariable Long userId) {
        return ResponseEntity.ok(scoreService.getScores(userId));
    }
}
