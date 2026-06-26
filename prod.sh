#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${REPO_ROOT}/.env"
COMPOSE_FILE="${REPO_ROOT}/docker-compose-prod.yml"

# 1. 운영 환경변수를 로드한다.
echo "[1/4] Loading environment..."
if [ ! -f "${ENV_FILE}" ]; then
    echo "Missing .env file."
    exit 1
fi

set -a
. "${ENV_FILE}"
set +a

: "${NGINX_SERVER_NAME:?NGINX_SERVER_NAME is required}"
echo "[1/4] Environment loaded."

# 2. 새 EC2에 필요한 Docker 패키지가 없으면 설치한다.
echo "[2/4] Checking Docker..."
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

if ! sudo docker compose version >/dev/null 2>&1; then
    sudo apt-get update
    sudo apt-get install -y docker-compose-plugin
fi

if ! sudo docker compose version >/dev/null 2>&1; then
    echo "Missing Docker Compose plugin."
    exit 1
fi
echo "[2/4] Docker is ready."

# 3. Nginx 컨테이너가 사용할 인증서가 준비되어 있는지 확인한다.
echo "[3/4] Checking SSL certificate..."
CERT_DIR="/etc/letsencrypt/live/${NGINX_SERVER_NAME}"

if ! sudo test -f "${CERT_DIR}/fullchain.pem" || ! sudo test -f "${CERT_DIR}/privkey.pem"; then
    echo "Missing SSL certificate: ${CERT_DIR}"
    exit 1
fi
echo "[3/4] SSL certificate found."

# 4. 운영 Docker Compose 스택을 빌드하고 실행한다.
echo "[4/4] Starting production containers..."
sudo docker compose -f "${COMPOSE_FILE}" up --build -d
echo "[4/4] Production containers started."
