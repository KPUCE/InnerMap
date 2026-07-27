/* #9 건물 상세 API 테스트 — 구현 전에 작성. 명세: docs/slice-9/design.md
 * 전제: DATABASE_URL의 DB에 마이그레이션·시드 적용됨. */
const test = require('node:test');
const assert = require('node:assert');
const { createApp } = require('../src/app');

let app, server, base;
test.before(async () => {
  app = createApp();
  server = app.listen(0);
  await new Promise((r) => server.once('listening', r));
  base = `http://127.0.0.1:${server.address().port}`;
});
test.after(() => server.close());

const idOf = async (name) => {
  const { Client } = require('pg');
  const c = new Client({ connectionString: process.env.DATABASE_URL });
  await c.connect();
  const { rows } = await c.query('SELECT id FROM building WHERE name=$1', [name]);
  await c.end();
  return rows[0].id;
};

test('상세: 종합교육관 → 좌표·별칭 [도서관] (AC 공식명·별칭)', async () => {
  const id = await idOf('종합교육관');
  const res = await fetch(`${base}/api/buildings/${id}`);
  assert.strictEqual(res.status, 200);
  const body = await res.json();
  assert.strictEqual(body.name, '종합교육관');
  assert.strictEqual(typeof body.lat, 'number');
  assert.strictEqual(typeof body.lng, 'number');
  assert.deepStrictEqual(body.aliases, ['도서관']);
});

test('상세: 창조A관 → 별칭 빈 배열', async () => {
  const id = await idOf('창조A관');
  const res = await fetch(`${base}/api/buildings/${id}`);
  assert.strictEqual(res.status, 200);
  assert.deepStrictEqual((await res.json()).aliases, []);
});

test('미게시 건물 → 404 (R-12b 존재 은닉)', async () => {
  const { Client } = require('pg');
  const c = new Client({ connectionString: process.env.DATABASE_URL });
  await c.connect();
  const id = await idOf('공학관A동');
  try {
    await c.query(`UPDATE building SET status='draft' WHERE id=$1`, [id]);
    const res = await fetch(`${base}/api/buildings/${id}`);
    assert.strictEqual(res.status, 404);
    assert.strictEqual((await res.json()).error_code, 'NOT_FOUND');
  } finally {
    await c.query(`UPDATE building SET status='published' WHERE id=$1`, [id]);
    await c.end();
  }
});

test('없는 id → 404 NOT_FOUND', async () => {
  const res = await fetch(`${base}/api/buildings/999999`);
  assert.strictEqual(res.status, 404);
  assert.strictEqual((await res.json()).error_code, 'NOT_FOUND');
});

test('잘못된 id("abc") → 400 INVALID_PARAM', async () => {
  const res = await fetch(`${base}/api/buildings/abc`);
  assert.strictEqual(res.status, 400);
  assert.strictEqual((await res.json()).error_code, 'INVALID_PARAM');
});
