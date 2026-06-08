package com.roccia.backend.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class UserUpdateRequest {
    @NotBlank(message = "현재 팀 이름은 필수입니다.")
    private String teamName;

    @NotBlank(message = "현재 사용자 이름은 필수입니다.")
    private String userName;

    @NotBlank(message = "새로운 팀 이름은 필수입니다.")
    private String newTeamName;

    @NotBlank(message = "새로운 사용자 이름은 필수입니다.")
    private String newUserName;

    @Pattern(regexp = "^(?i)(LEADER|MEMBER)$", message = "역할은 LEADER 또는 MEMBER만 가능합니다.")
    private String newRole; // 선택 사항
}
