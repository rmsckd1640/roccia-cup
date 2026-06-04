package com.roccia.backend.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class UserDto {
    @NotBlank(message = "팀 이름은 필수입니다.")
    private String teamName;

    @NotBlank(message = "사용자 이름은 필수입니다.")
    private String userName;

    private String newTeamName;
    private String newUserName;
    private String role; // 옵션
    private String newRole; //역할 수정 시 사용
}