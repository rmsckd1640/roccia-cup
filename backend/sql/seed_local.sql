-- Local-only seed data for manual execution
-- This file is intentionally not part of Flyway migrations.

INSERT INTO users (team_name, user_name, role, created_at) VALUES
    ('1팀', '김민수', 'LEADER', CURRENT_TIMESTAMP),
    ('1팀', '박지수', 'MEMBER', CURRENT_TIMESTAMP),
    ('2팀', '이하나', 'LEADER', CURRENT_TIMESTAMP),
    ('2팀', '최준', 'MEMBER', CURRENT_TIMESTAMP),
    ('3팀', '강대호', 'LEADER', CURRENT_TIMESTAMP),
    ('3팀', '윤서', 'MEMBER', CURRENT_TIMESTAMP),
    ('4팀', '한솔', 'LEADER', CURRENT_TIMESTAMP),
    ('4팀', '오지우', 'MEMBER', CURRENT_TIMESTAMP);

INSERT INTO scores (user_id, sector, point, submitted_at)
SELECT id, 1, 90, CURRENT_TIMESTAMP FROM users WHERE team_name = '1팀' AND user_name = '김민수';
INSERT INTO scores (user_id, sector, point, submitted_at)
SELECT id, 2, 85, CURRENT_TIMESTAMP FROM users WHERE team_name = '1팀' AND user_name = '김민수';
INSERT INTO scores (user_id, sector, point, submitted_at)
SELECT id, 1, 80, CURRENT_TIMESTAMP FROM users WHERE team_name = '1팀' AND user_name = '박지수';
INSERT INTO scores (user_id, sector, point, submitted_at)
SELECT id, 3, 88, CURRENT_TIMESTAMP FROM users WHERE team_name = '1팀' AND user_name = '박지수';

INSERT INTO scores (user_id, sector, point, submitted_at)
SELECT id, 1, 95, CURRENT_TIMESTAMP FROM users WHERE team_name = '2팀' AND user_name = '이하나';
INSERT INTO scores (user_id, sector, point, submitted_at)
SELECT id, 2, 91, CURRENT_TIMESTAMP FROM users WHERE team_name = '2팀' AND user_name = '이하나';
INSERT INTO scores (user_id, sector, point, submitted_at)
SELECT id, 4, 87, CURRENT_TIMESTAMP FROM users WHERE team_name = '2팀' AND user_name = '이하나';
INSERT INTO scores (user_id, sector, point, submitted_at)
SELECT id, 1, 76, CURRENT_TIMESTAMP FROM users WHERE team_name = '2팀' AND user_name = '최준';
INSERT INTO scores (user_id, sector, point, submitted_at)
SELECT id, 5, 82, CURRENT_TIMESTAMP FROM users WHERE team_name = '2팀' AND user_name = '최준';

INSERT INTO scores (user_id, sector, point, submitted_at)
SELECT id, 2, 89, CURRENT_TIMESTAMP FROM users WHERE team_name = '3팀' AND user_name = '강대호';
INSERT INTO scores (user_id, sector, point, submitted_at)
SELECT id, 3, 84, CURRENT_TIMESTAMP FROM users WHERE team_name = '3팀' AND user_name = '강대호';
INSERT INTO scores (user_id, sector, point, submitted_at)
SELECT id, 6, 90, CURRENT_TIMESTAMP FROM users WHERE team_name = '3팀' AND user_name = '강대호';
INSERT INTO scores (user_id, sector, point, submitted_at)
SELECT id, 1, 73, CURRENT_TIMESTAMP FROM users WHERE team_name = '3팀' AND user_name = '윤서';
INSERT INTO scores (user_id, sector, point, submitted_at)
SELECT id, 4, 79, CURRENT_TIMESTAMP FROM users WHERE team_name = '3팀' AND user_name = '윤서';

INSERT INTO scores (user_id, sector, point, submitted_at)
SELECT id, 1, 92, CURRENT_TIMESTAMP FROM users WHERE team_name = '4팀' AND user_name = '한솔';
INSERT INTO scores (user_id, sector, point, submitted_at)
SELECT id, 2, 86, CURRENT_TIMESTAMP FROM users WHERE team_name = '4팀' AND user_name = '한솔';
INSERT INTO scores (user_id, sector, point, submitted_at)
SELECT id, 3, 78, CURRENT_TIMESTAMP FROM users WHERE team_name = '4팀' AND user_name = '오지우';
INSERT INTO scores (user_id, sector, point, submitted_at)
SELECT id, 5, 81, CURRENT_TIMESTAMP FROM users WHERE team_name = '4팀' AND user_name = '오지우';
