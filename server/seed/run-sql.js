/* 시드 러너 — .sql 파일을 DATABASE_URL로 실행. psql 없이도 돌도록 pg 사용. CJS. */
const { readFileSync } = require('node:fs');
const { Client } = require('pg');

const file = process.argv[2];
if (!file) {
  console.error('사용법: node seed/run-sql.js <path-to.sql>');
  process.exit(1);
}

(async () => {
  const sql = readFileSync(file, 'utf8');
  const client = new Client({ connectionString: process.env.DATABASE_URL });
  await client.connect();
  await client.query(sql);
  await client.end();
  console.log(`시드 적용 완료: ${file}`);
})().catch((err) => {
  console.error(err);
  process.exit(1);
});
