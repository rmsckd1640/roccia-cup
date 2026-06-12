package com.roccia.backend.exception;

import org.springframework.http.HttpStatus;

public class ScoreNotFoundException extends BaseException {
    public ScoreNotFoundException() {
        super("점수를 찾을 수 없습니다.", HttpStatus.NOT_FOUND);
    }
}
