package com.roccia.backend.repository;

import com.roccia.backend.entity.Score;
import com.roccia.backend.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface ScoreRepository extends JpaRepository<Score, Long> {

    List<Score> findByUser(User user);

    Optional<Score> findByUserAndSector(User user, int sector);

    void deleteByUser(User user);

    boolean existsByUser_TeamNameAndSector(String teamName, int sector);


}