-- V1__init.sql
-- Initial schema creation for Users and Scores entities

CREATE TABLE users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    team_name VARCHAR(255),
    user_name VARCHAR(255),
    role VARCHAR(50),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_team_user UNIQUE (team_name, user_name)
);

CREATE TABLE scores (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    sector INT NOT NULL,
    point INT NOT NULL,
    submitted_at DATETIME,
    CONSTRAINT fk_scores_user FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT uk_user_sector UNIQUE (user_id, sector)
);
