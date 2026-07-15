package com.roccia.backend.repository;

import com.roccia.backend.domain.Team;
import com.roccia.backend.domain.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByTeamAndUserName(Team team, String userName);
}