/* #7 건물 검색 API 테스트 — 구현 전에 작성(4단계). 명세: docs/slice-7/design.md
 * 전제: DATABASE_URL의 DB에 마이그레이션·시드 적용됨(19건, 전부 published).
 * 실행: DATABASE_URL=... npm test */
const test = require('node:test');
const assert = require('node:assert');
const { createApp } = require('../src/app'); // ← 구현 전이므로 여기서 RED

// 현재 위치 = 공학관E동 (docs/slice-7/seed-buildings.md)
const E = { lat: 37.339713, lng: 126.735044 };

let app, server, base;
test.before(async () => {
  app = createApp();
  server = app.listen(0);
  await new Promise((r) => server.once('listening', r));
  base = `http://127.0.0.1:${server.address().port}`;
});
test.after(() => server.close());

const search = (params) => fetch(`${base}/api/buildings/search?${new URLSearchParams(params)}`);

// ── 정상 경로 ──────────────────────────────────────────────

test('이름 부분일치: "공학" → 공학관 7개동, 거리 오름차순', async () => {
  const res = await search({ q: '공학', ...E });
  assert.strictEqual(res.status, 200);
  const body = await res.json();
  assert.strictEqual(body.count, 7);
  assert.strictEqual(body.results.length, 7);
  assert.strictEqual(body.results[0].name, '공학관E동'); // 현위치 = E동
  const dists = body.results.map((r) => r.distance_m);
  assert.deepStrictEqual(dists, [...dists].sort((a, b) => a - b), '거리 오름차순');
});

test('별칭 매칭: "도서관" → 종합교육관, matched_alias 채움 (AC 별칭 합집합)', async () => {
  const res = await search({ q: '도서관', ...E });
  const body = await res.json();
  assert.strictEqual(body.count, 1);
  assert.strictEqual(body.results[0].name, '종합교육관');
  assert.strictEqual(body.results[0].matched_alias, '도서관');
});

test('이름 매칭이면 matched_alias는 null', async () => {
  const res = await search({ q: '체육관', ...E });
  const body = await res.json();
  const gym = body.results.find((r) => r.name === '체육관');
  assert.ok(gym);
  assert.strictEqual(gym.matched_alias, null);
});

test('별칭 "티아이피" → TIP', async () => {
  const res = await search({ q: '티아이피', ...E });
  const body = await res.json();
  assert.strictEqual(body.count, 1);
  assert.strictEqual(body.results[0].name, 'TIP');
});

test('distance_m: 현위치=공학관E동이면 첫 결과 거리 ≈ 0', async () => {
  const res = await search({ q: '공학관E동', ...E });
  const body = await res.json();
  assert.ok(body.results[0].distance_m < 1, `0에 가까워야 함: ${body.results[0].distance_m}`);
});

// ── 경계 ──────────────────────────────────────────────────

test('한 글자 질의 "공" 허용 (오류 아님)', async () => {
  const res = await search({ q: '공', ...E });
  assert.strictEqual(res.status, 200);
  const body = await res.json();
  assert.strictEqual(body.count, 7); // 공학관 7개동 (02-schema-queries.md Q3)
});

test('상한: limit 초과 요청도 최대 10건 (AC 최대 10건)', async () => {
  const res = await search({ q: '관', ...E, limit: 99 });
  assert.strictEqual(res.status, 200);
  const body = await res.json();
  assert.ok(body.count <= 10, `10 이하: ${body.count}`);
});

test('0건: "없는건물" → count 0 + reason_code NO_MATCH (AC 사유 코드)', async () => {
  const res = await search({ q: '없는건물', ...E });
  assert.strictEqual(res.status, 200);
  const body = await res.json();
  assert.strictEqual(body.count, 0);
  assert.deepStrictEqual(body.results, []);
  assert.strictEqual(body.reason_code, 'NO_MATCH');
});

test('게시 필터: draft 건물은 노출 금지 (R-12b)', async () => {
  // 시드는 전부 published — 하나를 draft로 내렸다가 복구하며 검증
  const { Client } = require('pg');
  const c = new Client({ connectionString: process.env.DATABASE_URL });
  await c.connect();
  try {
    await c.query(`UPDATE building SET status='draft' WHERE name='공학관A동'`);
    const res = await search({ q: '공학', ...E });
    const body = await res.json();
    assert.strictEqual(body.count, 6);
    assert.ok(!body.results.some((r) => r.name === '공학관A동'), 'draft 노출 금지');
  } finally {
    await c.query(`UPDATE building SET status='published' WHERE name='공학관A동'`);
    await c.end();
  }
});

// ── 오류 ──────────────────────────────────────────────────

test('빈 질의 → 400 EMPTY_QUERY', async () => {
  const res = await search({ q: '', ...E });
  assert.strictEqual(res.status, 400);
  assert.strictEqual((await res.json()).error_code, 'EMPTY_QUERY');
});

test('공백만 질의 → 400 EMPTY_QUERY', async () => {
  const res = await search({ q: '   ', ...E });
  assert.strictEqual(res.status, 400);
  assert.strictEqual((await res.json()).error_code, 'EMPTY_QUERY');
});

test('lat 누락 → 400 INVALID_LOCATION', async () => {
  const res = await search({ q: '공학', lng: E.lng });
  assert.strictEqual(res.status, 400);
  assert.strictEqual((await res.json()).error_code, 'INVALID_LOCATION');
});

test('lat 범위 밖(91) → 400 INVALID_LOCATION', async () => {
  const res = await search({ q: '공학', lat: 91, lng: E.lng });
  assert.strictEqual(res.status, 400);
  assert.strictEqual((await res.json()).error_code, 'INVALID_LOCATION');
});

test('lng 비수치 → 400 INVALID_LOCATION', async () => {
  const res = await search({ q: '공학', lat: E.lat, lng: 'abc' });
  assert.strictEqual(res.status, 400);
  assert.strictEqual((await res.json()).error_code, 'INVALID_LOCATION');
});

test('limit 비정수 → 400 INVALID_PARAM', async () => {
  const res = await search({ q: '공학', ...E, limit: 'abc' });
  assert.strictEqual(res.status, 400);
  assert.strictEqual((await res.json()).error_code, 'INVALID_PARAM');
});
