#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${REPO_ROOT}/.env"

if [ ! -f "${ENV_FILE}" ]; then
    echo "Missing .env file. Create .env in the project root and fill production values first."
    exit 1
fi

set -a
# shellcheck disable=SC1091
. "${ENV_FILE}"
set +a

: "${NGINX_SERVER_NAME:?NGINX_SERVER_NAME is required}"

require_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "Missing required command: $1"
        exit 1
    fi
}

require_command docker
require_command certbot

if ! docker compose version >/dev/null 2>&1; then
    echo "Missing Docker Compose plugin."
    exit 1
fi

sudo mkdir -p /var/www/certbot

RENEWAL_CONF="/etc/letsencrypt/renewal/${NGINX_SERVER_NAME}.conf"
DEPLOY_HOOK="deploy_hook = docker exec nginx nginx -s reload || true"
WEBROOT_PATH="/var/www/certbot"

set_renewal_param() {
    local key="$1"
    local value="$2"

    if sudo grep -q "^${key} =" "${RENEWAL_CONF}"; then
        sudo sed -i.bak "s|^${key} =.*|${key} = ${value}|" "${RENEWAL_CONF}"
    else
        sudo sed -i.bak "/^\\[renewalparams\\]/a\\${key} = ${value}" "${RENEWAL_CONF}"
    fi
}

configure_webroot_renewal() {
    echo "Configuring certbot renewal as webroot..."

    set_renewal_param "authenticator" "webroot"
    set_renewal_param "webroot_path" "${WEBROOT_PATH}"

    if ! sudo grep -q "^\\[\\[webroot_map\\]\\]" "${RENEWAL_CONF}"; then
        {
            echo ""
            echo "[[webroot_map]]"
        } | sudo tee -a "${RENEWAL_CONF}" >/dev/null
    fi

    if sudo grep -q "^${NGINX_SERVER_NAME} =" "${RENEWAL_CONF}"; then
        sudo sed -i.bak "s|^${NGINX_SERVER_NAME} =.*|${NGINX_SERVER_NAME} = ${WEBROOT_PATH}|" "${RENEWAL_CONF}"
    else
        echo "${NGINX_SERVER_NAME} = ${WEBROOT_PATH}" | sudo tee -a "${RENEWAL_CONF}" >/dev/null
    fi
}

if [ -f "/etc/letsencrypt/live/${NGINX_SERVER_NAME}/fullchain.pem" ]; then
    echo "Certificate already exists: ${NGINX_SERVER_NAME}"
else
    echo "Requesting certificate for ${NGINX_SERVER_NAME}..."
    sudo certbot certonly --standalone -d "${NGINX_SERVER_NAME}"
fi

if [ -f "${RENEWAL_CONF}" ]; then
    configure_webroot_renewal

    echo "Configuring certbot deploy hook..."
    if sudo grep -q "^deploy_hook =" "${RENEWAL_CONF}"; then
        sudo sed -i.bak "s|^deploy_hook =.*|${DEPLOY_HOOK}|" "${RENEWAL_CONF}"
    else
        echo "${DEPLOY_HOOK}" | sudo tee -a "${RENEWAL_CONF}" >/dev/null
    fi
else
    echo "Missing renewal config: ${RENEWAL_CONF}"
    exit 1
fi

if command -v systemctl >/dev/null 2>&1; then
    echo "Enabling certbot timer..."
    sudo systemctl enable --now certbot.timer
else
    echo "systemctl is not available. Configure certbot renew scheduling manually."
fi

echo "Starting production containers..."
sudo docker compose -f "${REPO_ROOT}/docker-compose-prod.yml" up --build -d

echo "Production initialization completed."
