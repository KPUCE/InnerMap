const test = require('node:test');
const assert = require('node:assert');

test('리허설: 수정 후 통과하는 테스트 (#24)', () => {
  assert.strictEqual(1 + 1, 2); // 수정 완료 — 게이트가 다시 열리는지 확인
});
