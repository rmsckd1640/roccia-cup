#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="${REPO_ROOT}/.env"

if [ -f "${ENV_FILE}" ]; then
  set -a
  . "${ENV_FILE}"
  set +a
fi

BASE_URL="${LOAD_TEST_BASE_URL:?LOAD_TEST_BASE_URL is required}"
TEST_DURATION="1m"
COOLDOWN_SECONDS=120
K6_IMAGE="grafana/k6:latest"
DOCKER_NETWORK="${LOAD_TEST_DOCKER_NETWORK:?LOAD_TEST_DOCKER_NETWORK is required}"
PROMETHEUS_RW_URL="http://prometheus:9090/api/v1/write"

run_test() {
  local target_tps="$1"
  local pre_allocated_vus="$2"
  local max_vus="$3"
  local testid="${target_tps}tps"

  echo "Running ${testid}"

  sudo docker run --rm \
    --network "${DOCKER_NETWORK}" \
    -e K6_PROMETHEUS_RW_SERVER_URL="${PROMETHEUS_RW_URL}" \
    -e K6_PROMETHEUS_RW_TREND_STATS='p(50),p(95),p(99),avg,min,max' \
    -e BASE_URL="${BASE_URL}" \
    -e TARGET_TPS="${target_tps}" \
    -e TEST_DURATION="${TEST_DURATION}" \
    -e PRE_ALLOCATED_VUS="${pre_allocated_vus}" \
    -e MAX_VUS="${max_vus}" \
    -v "${REPO_ROOT}/performance:/scripts" \
    "${K6_IMAGE}" run -o experimental-prometheus-rw \
    --tag "testid=${testid}" \
    /scripts/load-test.js
}

cooldown() {
  local next_test="$1"

  if [ "${COOLDOWN_SECONDS}" -le 0 ]; then
    return
  fi

  echo "Cooldown ${COOLDOWN_SECONDS}s before ${next_test}"
  sleep "${COOLDOWN_SECONDS}"
}

run_test 10 50 100
cooldown "50tps"

run_test 50 100 250
cooldown "100tps"

run_test 100 150 300
cooldown "200tps"

run_test 200 250 500

echo "Constant TPS tests completed"
