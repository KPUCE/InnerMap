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

## 완료 — #7 서버 PR 머지됨

- [PR #29](https://github.com/KPUCE/InnerMap/pull/29) → main `0ba7c9f`로 Squash 머지(2026-07-27). 이슈 #7 자동 닫힘. CI 기록 `07-ci-runs.md`. `size:exempt` 예외 통로 첫 실전 작동. 보호 규칙(관리자 포함 강제) 원복 확인됨.

## 지금 하는 중 — iOS #8 (`feature/8-search-screen`)

구현·검증 완료, PR 준비 중.
- XcodeGen(A안, 저자 채택): `ios/project.yml` → `InnerMap.xcodeproj`(공유 스킴 `InnerMap` = CI ios-build와 일치).
- 소스: `InnerMapApp` · `Models` · `SearchService`(127.0.0.1:3000) · `SearchViewModel`(상태 전이·낭독 문구) · `SearchView`(AC ①~③: 접근성 레이블·행 합침·0건 접근성 알림·검색 필드 포커스 복귀).
- 현재 위치는 캠퍼스 앵커(공학관E동) 고정 — CoreLocation은 E2 몫(01-design-notes). **저자 사후 확인 필요.**
- 테스트: 유닛 5(뷰모델) + UI 4(XCUITest, `UITEST_QUERY` 훅) 전부 통과 — `08-ios-tests.txt`. 시행착오 4건은 `06-detours.md` D3~D6.
- 시뮬레이터 실물 확인: "도서관" → 종합교육관 · 약 135m · 별칭 도서관 (서버 연동).

## 다음 차례

1. #8 커밋 → 푸시 → PR(`feature/8-search-screen`) → CI(ios-build 첫 실전) → 저자 리뷰·머지(보호 규칙 해제→원복 절차 동일).
2. 슬라이스 마무리: `00-status.md` 최종 갱신, 잔여 미결 정리.

## 미결 질문
- iOS 현재 위치 앵커 고정(공학관E동) — 저자 확인 대기.
- UI 테스트 실행 전제(로컬 서버+시드)가 CI엔 없음 — ios-build는 컴파일만. UI 테스트의 CI 편입 여부는 후속 논의.
- L1~L4 위임 수준 정의가 저장소에 없음 — `05-prompt-log.md` 표기는 잠정.
- 한글 trigram 정밀도·재현성 대규모 검증(ADR-007) — 범위 밖.
- 실기기 VoiceOver 완주(AC ③ 후반) — 시뮬레이터로 절반 검증, 실기기는 사람 몫.
