-- 사용자 테이블
CREATE TABLE `user` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `team_name` VARCHAR(50) NOT NULL,
  `user_name` VARCHAR(50) NOT NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `role` VARCHAR(20) NOT NULL DEFAULT 'MEMBER',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 점수 기록 테이블
CREATE TABLE `score_record` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT NOT NULL,
  `sector` VARCHAR(10) NOT NULL,
  `score` INT NOT NULL,
  `submitted_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  CONSTRAINT `fk_score_record_user`
    FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
