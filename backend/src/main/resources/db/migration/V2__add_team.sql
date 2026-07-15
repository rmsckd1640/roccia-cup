-- V2__add_team.sql
-- team_name을 users 테이블에 문자열로 중복 저장하던 것을 teams 테이블로 정규화 (Expand-Contract의 1단계: Expand)
-- team_name 컬럼은 여기서 삭제하지 않는다. 운영에서 team_id 기반 동작이 충분히 검증된 뒤 V3에서 별도로 삭제한다.

CREATE TABLE teams (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_teams_name UNIQUE (name)
);

INSERT INTO teams (name)
SELECT DISTINCT team_name FROM users;

ALTER TABLE users ADD COLUMN team_id BIGINT;

UPDATE users u
JOIN teams t ON t.name = u.team_name
SET u.team_id = t.id;

ALTER TABLE users MODIFY COLUMN team_id BIGINT NOT NULL;

-- 이후 애플리케이션은 team_id만 채우고 team_name은 더 이상 쓰지 않는다.
-- 신규 유저 INSERT가 기존 NOT NULL 제약 때문에 실패하지 않도록 team_name을 nullable로 완화한다.
ALTER TABLE users MODIFY COLUMN team_name VARCHAR(255) NULL;

ALTER TABLE users
    ADD CONSTRAINT fk_users_team FOREIGN KEY (team_id) REFERENCES teams(id),
    ADD CONSTRAINT uk_users_team_id_user_name UNIQUE (team_id, user_name);
