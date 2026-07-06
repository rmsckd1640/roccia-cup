<br/>

# Roccia Cup <img src="./frontend/assets/icons/app-icon.png" align="left" width="100">

> 클라이밍 동아리 Roccia901 대회 운영을 위한 점수 제출 및 팀 랭킹 조회 서비스

<br/>

## 개요

Roccia Cup은 클라이밍 동아리 Roccia901에서 진행하는 대회의 점수 제출과 팀 랭킹 조회를 지원하는 PWA(Progressive Web App)입니다.

기존에는 수기로 점수를 제출해야 하는 불편함이 있었고 집계에도 불필요한 시간이 소요되었지만, Roccia Cup을 통해 각자의 모바일 기기에서 점수를 제출하고 팀 랭킹을 바로 확인할 수 있습니다.

- [화면 구성](./frontend/README.md)
- [API 명세서](http://localhost:8080/swagger-ui/index.html) (로컬 서버 실행 후 확인)
- [개발 기록: EC2 메모리 부족 장애 대응과 모니터링 기반 운영 안정성 검증](https://velog.io/@rmsckd1640/Roccia-Cup-EC2-%EB%A9%94%EB%AA%A8%EB%A6%AC-%EB%B6%80%EC%A1%B1-%EC%9E%A5%EC%95%A0-%EB%8C%80%EC%9D%91%EA%B3%BC-%EC%9A%B4%EC%98%81-%EC%95%88%EC%A0%95%EC%84%B1-%EA%B2%80%EC%A6%9D)

## 기능

| 기능 | 설명 |
| --- | --- |
| 참가자 입장 | 팀명, 이름, 역할 기반 참가자 생성 및 입장 |
| 참가자 정보 수정 | 참가자 팀명, 이름, 역할 수정 |
| 점수 제출 | 섹터별 점수 제출 |
| 중복 제출 방지 | 동일 참가자의 동일 섹터 중복 제출 제한 |
| 제출 점수 조회/삭제 | 참가자별 제출 점수 조회 및 삭제 |
| 팀 랭킹 조회 | 팀별 평균 점수 기준 랭킹 조회 |

## 기술 스택

### Frontend

<div>
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" />
</div>

### Backend

<div>
  <img src="https://img.shields.io/badge/Java-007396?style=for-the-badge&logo=openjdk&logoColor=white" />
  <img src="https://img.shields.io/badge/Spring_Boot-6DB33F?style=for-the-badge&logo=springboot&logoColor=white" />
  <img src="https://img.shields.io/badge/Spring_Data_JPA-6DB33F?style=for-the-badge&logo=spring&logoColor=white" />
  <img src="https://img.shields.io/badge/QueryDSL-0769AD?style=for-the-badge&logoColor=white" />
  <img src="https://img.shields.io/badge/Flyway-CC0200?style=for-the-badge&logo=flyway&logoColor=white" />
  <img src="https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white" />
  <img src="https://img.shields.io/badge/Swagger_UI-85EA2D?style=for-the-badge&logo=swagger&logoColor=black" />
</div>

### Infra

<div>
  <img src="https://img.shields.io/badge/AWS_EC2-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white" />
  <img src="https://img.shields.io/badge/AWS_Route_53-8C4FFF?style=for-the-badge&logo=amazonaws&logoColor=white" />
  <img src="https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white" />
  <img src="https://img.shields.io/badge/Nginx-009639?style=for-the-badge&logo=nginx&logoColor=white" />
  <img src="https://img.shields.io/badge/Prometheus-E6522C?style=for-the-badge&logo=prometheus&logoColor=white" />
  <img src="https://img.shields.io/badge/Grafana-F46800?style=for-the-badge&logo=grafana&logoColor=white" />
</div>

## 아키텍처

<img width="1200" height="750" alt="아키텍처" src="https://github.com/user-attachments/assets/17694fde-64e6-42ae-a028-8e7c356fdbb3" />

## ERD

<img width="900" height="450" alt="ERD" src="https://github.com/user-attachments/assets/44d8e1c5-df1d-44b5-8f4d-808981e47dbd" />

## 시작 가이드

### 로컬 실행

Backend:

```bash
docker compose -f docker-compose-local.yml up -d

cd backend
./gradlew bootRun
```

Frontend:

```bash
cd frontend
flutter pub get
flutter run -d chrome
```

### 검증

Backend:

```bash
cd backend
./gradlew test
```

Frontend:

```bash
cd frontend
flutter pub get
flutter analyze
```

### 운영 환경변수

```env
NGINX_SERVER_NAME=

MYSQL_DATABASE=
MYSQL_USER=
MYSQL_PASSWORD=
MYSQL_ROOT_PASSWORD=

SPRING_DATASOURCE_URL=
SPRING_DATASOURCE_USERNAME=
SPRING_DATASOURCE_PASSWORD=
CORS_ALLOWED_ORIGIN=

APP_SERVER_PRIVATE_IP=
MONITORING_SERVER_NAME=
GRAFANA_ADMIN_USER=
GRAFANA_ADMIN_PASSWORD=

LOAD_TEST_BASE_URL=
LOAD_TEST_DOCKER_NETWORK=
```

### 운영 배포

Service Server:

```bash
sudo apt-get update
sudo apt-get install -y certbot
sudo certbot certonly --standalone -d <서비스_도메인>

./prod.sh
```

Monitoring Server:

```bash
sudo apt-get update
sudo apt-get install -y certbot
sudo certbot certonly --standalone -d <모니터링_도메인>

./monitor.sh
```
