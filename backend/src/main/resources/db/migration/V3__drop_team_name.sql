-- V3__drop_team_name.sql
-- Expand-Contract 패턴의 2단계 (Contract).
-- V2가 운영에 배포되어 team_id 기반 동작이 충분히 검증된 뒤에만 이 파일을 작성/배포한다.
-- 이 마이그레이션이 적용되면 team_name 데이터는 복구할 수 없으니, 실행 전 운영 DB 백업을 먼저 뜬다.

ALTER TABLE users DROP INDEX uk_team_user;

ALTER TABLE users DROP COLUMN team_name;
