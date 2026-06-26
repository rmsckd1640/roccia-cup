#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${REPO_ROOT}/.env"
COMPOSE_FILE="${REPO_ROOT}/docker-compose-prod.yml"

# 1. 운영 환경변수를 로드한다.
if [ ! -f "${ENV_FILE}" ]; then
    echo "Missing .env file. Create .env in the project root first."
    exit 1
fi

set -a
. "${ENV_FILE}"
set +a

: "${NGINX_SERVER_NAME:?NGINX_SERVER_NAME is required}"

# 2. 새 EC2에 필요한 Docker 패키지가 없으면 설치한다.
install_if_missing() {
    local command_name="$1"
    shift

    if ! command -v "${command_name}" >/dev/null 2>&1; then
        sudo apt-get update
        sudo apt-get install -y "$@"
    fi
}

install_if_missing docker docker.io

if command -v systemctl >/dev/null 2>&1; then
    sudo systemctl enable --now docker
fi

if ! docker compose version >/dev/null 2>&1; then
    sudo apt-get update
    sudo apt-get install -y docker-compose-plugin
fi

if ! docker compose version >/dev/null 2>&1; then
    echo "Missing Docker Compose plugin."
    exit 1
fi

# 3. Nginx 컨테이너가 사용할 인증서가 준비되어 있는지 확인한다.
CERT_DIR="/etc/letsencrypt/live/${NGINX_SERVER_NAME}"

if [ ! -f "${CERT_DIR}/fullchain.pem" ] || [ ! -f "${CERT_DIR}/privkey.pem" ]; then
    echo "Missing SSL certificate for ${NGINX_SERVER_NAME}."
    echo "Issue it on the server first:"
    echo "  sudo certbot certonly --standalone -d ${NGINX_SERVER_NAME}"
    exit 1
fi

# 4. 운영 Docker Compose 스택을 빌드하고 실행한다.
sudo docker compose -f "${COMPOSE_FILE}" up --build -d

echo "Production deployment completed."
