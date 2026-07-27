# 슬라이스 #7·#8 — 진행 상태 (세션 핸드오프)

지시서 §9에 따른 상태 기록. 다음 세션은 `docs/slice-7-plan.md`와 이 파일, `docs/slice-7/seed-buildings.md`를 먼저 읽는다.

- 갱신 시각: 2026-07-27
- 브랜치: `feature/7-search-api` (기반: `docs/slice-7-plan`)

## 완료된 단계

**0단계 현황 파악 — 완료.** 서버는 빈 골격이었고, iOS는 플레이스홀더(Xcode 프로젝트 없음 → `ios-build` 잡은 아직 못 돎). 문서 불일치 발견: 지시서의 `docs/SETUP-RUNBOOK.md`는 루트에 있고 `docs/definition-of-done.md`는 없음.

**로컬 환경 — 완료.** `docs/dev-setup.md`. Node 26(주의: CI는 20)·PostgreSQL 16.14·gh 2.96(⚠️ 미로그인)·Xcode 16.2.

**1단계 결정 — 완료.** ① 시드: 실제 19건(OSM/ODbL, `seed-buildings.md` 원본, 주변 2건 제외) ② 별칭: 전부 저자 확인(16개 — 공학관 7개동 'X동', 본부·행정관·도서관(종합교육관)·보육센터·산학융합관·비즈니스센터·실내체육관·기숙사·티아이피, 창조 3관은 별칭 없음. "제2기숙사 (TIP)"→표시명 TIP) ③ Ⅺ장 예제를 #7로 교체 확정.

**2단계 설계 — 완료(저자 확정).** `docs/slice-7/design.md`(ERD·OpenAPI·시퀀스), `docs/adr/ADR-007-search-implementation.md`(pg_trgm GIN + 하버사인, PostGIS 배제). 범위 정정: #7은 "거리순 최대 10건" — 반경 밴드·"외 N개"는 브리핑 E2(제외 범위)의 것.

**3단계 마이그레이션·시드 — 완료.** `server/migrations/…initial-schema.js`(CJS — ESM 스텁 충돌은 `06-detours.md` D1), `server/seed/seed.sql`+`run-sql.js`. 로컬 `innermap_dev`에 적용, 대표 질의·EXPLAIN은 `02-schema-queries.md`. 발견: 19행에선 플래너가 GIN 무시(Seq Scan), trigram은 3글자 미만 패턴 못 좁힘(D2).

**4단계 테스트 먼저 — 완료.** `server/test/search-api.test.js` 15개(정상 5·경계 4·오류 6). RED 증거 `03-red.txt`(구현 부재 MODULE_NOT_FOUND). CI `server-test`에 postgres:16 서비스+migrate+seed 추가(A안, 저자 승인).

**5단계 서버 구현 — 완료.** `server/src/app.js`(81줄)·`server/src/server.js`. GREEN 증거 `04-green.txt`(17/17, 첫 실행 통과 — RED→GREEN 사이 시행착오 없음도 기록). express@5 추가.

## 지금 하는 중 — 6단계 서버 PR (#7)

- 브랜치 `feature/7-search-api`에 커밋 완료. **푸시·PR 대기: `gh auth login` 필요(저자).**
- ⚠️ **PR이 300줄 상한 초과 예정** — `package-lock.json` +1283줄. 분할 불가(lockfile). `size:exempt` 라벨(PO 승인 통로) 필요 — 저자 승인 대기.
- PR 후: CI 실행 링크·잡 결과를 `07-ci-runs.md`에 기록. 머지는 저자 승인+보호 규칙 절차(§7 — 규칙 80789141 일시 해제는 저자만, 머지 후 원복 보고).

## 다음 차례

1. 6단계 마무리: 푸시 → PR(템플릿 성실 기재) → CI 확인 → `07-ci-runs.md` → 저자 리뷰·머지.
2. iOS #8: Xcode 프로젝트 생성부터(플레이스홀더 상태). 검색 화면·API 연동·VoiceOver AC 3개·`feature/8-search-screen` PR.

## 미결 질문
- `size:exempt` 라벨 사용 승인(PO=저자).
- L1~L4 위임 수준 정의가 저장소에 없음 — `05-prompt-log.md`의 표기는 잠정, 교재 용어집과 대조 필요.
- 한글 trigram 정밀도·재현성 대규모 검증(ADR-007 미검증 항목) — 이번 슬라이스 범위 밖.
