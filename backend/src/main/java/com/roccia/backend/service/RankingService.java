package com.roccia.backend.service;

import com.querydsl.core.types.Projections;
import com.querydsl.jpa.impl.JPAQueryFactory;
import com.roccia.backend.dto.RankingResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

import static com.roccia.backend.domain.QScore.score;
import static com.roccia.backend.domain.QUser.user;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class RankingService {

    private final JPAQueryFactory queryFactory;

    public List<RankingResponse> getTeamRankings() {
        return queryFactory
                .select(Projections.constructor(RankingResponse.class,
                        user.teamName,
                        score.point.avg()
                ))
                .from(score)
                .join(score.user, user)
                .groupBy(user.teamName)
                .orderBy(score.point.avg().desc())
                .fetch();
    }
}
