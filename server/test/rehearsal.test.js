const test = require('node:test');
const assert = require('node:assert');

test('리허설: 일부러 실패하는 테스트 (#24)', () => {
  assert.strictEqual(1 + 1, 3); // 의도적 실패 — 머지 게이트가 잠기는지 확인
});
