#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${REPO_ROOT}/.env"
COMPOSE_FILE="${REPO_ROOT}/docker-compose-monitor.yml"

# 1. 모니터링 환경변수를 로드한다.
echo "[1/5] Loading environment..."
if [ ! -f "${ENV_FILE}" ]; then
    echo "Missing .env file."
    exit 1
fi

set -a
. "${ENV_FILE}"
set +a

: "${APP_SERVER_PRIVATE_IP:?APP_SERVER_PRIVATE_IP is required}"
: "${MONITORING_SERVER_NAME:?MONITORING_SERVER_NAME is required}"
: "${GRAFANA_ADMIN_USER:?GRAFANA_ADMIN_USER is required}"
: "${GRAFANA_ADMIN_PASSWORD:?GRAFANA_ADMIN_PASSWORD is required}"
echo "[1/5] Environment loaded."

# 2. 새 EC2에 필요한 Docker 패키지가 없으면 설치한다.
echo "[2/5] Checking Docker..."
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
echo "[2/5] Docker is ready."

# 3. Certbot webroot 디렉터리와 Nginx reload hook을 준비한다.
echo "[3/5] Preparing Certbot renewal..."
sudo mkdir -p /var/www/certbot /etc/letsencrypt/renewal-hooks/deploy

printf '%s\n' \
    '#!/usr/bin/env bash' \
    'docker exec monitoring-nginx nginx -s reload >/dev/null 2>&1 || true' \
    | sudo tee /etc/letsencrypt/renewal-hooks/deploy/reload-monitoring-nginx.sh >/dev/null
sudo chmod +x /etc/letsencrypt/renewal-hooks/deploy/reload-monitoring-nginx.sh
echo "[3/5] Certbot renewal is ready."

# 4. Nginx 컨테이너가 사용할 인증서가 준비되어 있는지 확인한다.
echo "[4/5] Checking SSL certificate..."
CERT_DIR="/etc/letsencrypt/live/${MONITORING_SERVER_NAME}"

if ! sudo test -f "${CERT_DIR}/fullchain.pem" || ! sudo test -f "${CERT_DIR}/privkey.pem"; then
    echo "Missing SSL certificate: ${CERT_DIR}"
    exit 1
fi
echo "[4/5] SSL certificate found."

# 5. 모니터링 Docker Compose 스택을 실행한다.
echo "[5/5] Starting monitoring containers..."
sudo docker compose -f "${COMPOSE_FILE}" up --build -d
echo "[5/5] Monitoring containers started."
