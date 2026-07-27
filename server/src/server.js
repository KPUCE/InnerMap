/* 기동 진입점 — DATABASE_URL 필수(금칙: 시크릿 코드 포함 금지, 환경변수만) */
const { createApp } = require('./app');

if (!process.env.DATABASE_URL) {
  console.error('DATABASE_URL 환경변수가 필요합니다.');
  process.exit(1);
}

const port = Number(process.env.PORT) || 3000;
createApp().listen(port, () => {
  console.log(`innermap-server listening on :${port}`);
});
