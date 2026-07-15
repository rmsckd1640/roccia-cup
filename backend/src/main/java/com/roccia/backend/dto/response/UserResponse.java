package com.roccia.backend.dto.response;

import com.roccia.backend.domain.Role;
import com.roccia.backend.domain.User;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserResponse {
    private Long id;
    private String teamName;
    private String userName;
    private Role role;

    public static UserResponse from(User user) {
        return UserResponse.builder()
                .id(user.getId())
                .teamName(user.getTeam().getName())
                .userName(user.getUserName())
                .role(user.getRole())
                .build();
    }
}
