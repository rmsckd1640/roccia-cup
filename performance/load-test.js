import http from 'k6/http';
import { check } from 'k6';

function requiredEnv(name) {
  const value = __ENV[name];

  if (!value) {
    throw new Error(`${name} is required`);
  }

  return value;
}

const BASE_URL = requiredEnv('BASE_URL');
const TARGET_TPS = Number(requiredEnv('TARGET_TPS'));
const TEST_DURATION = requiredEnv('TEST_DURATION');
const PRE_ALLOCATED_VUS = Number(requiredEnv('PRE_ALLOCATED_VUS'));
const MAX_VUS = Number(requiredEnv('MAX_VUS'));

export const options = {
  scenarios: {
    constant_tps: {
      executor: 'constant-arrival-rate',
      rate: TARGET_TPS,
      timeUnit: '1s',
      duration: TEST_DURATION,
      preAllocatedVUs: PRE_ALLOCATED_VUS,
      maxVUs: MAX_VUS,
    },
  },
  thresholds: {
    http_req_failed: ['rate<0.01'],
    http_req_duration: ['p(95)<500', 'p(99)<1000'],
    checks: ['rate>0.99'],
  },
};

export default function () {
  const res = http.get(`${BASE_URL}/api/rankings`, {
    tags: { api: 'target_api' },
  });

  check(res, {
    'status is 200': (r) => r.status === 200,
    'body is not empty': (r) => r.body && r.body.length > 2,
  });
}
