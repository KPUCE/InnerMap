# 슬라이스 #7·#8 — 진행 상태 (세션 핸드오프)

지시서 §9에 따른 상태 기록. 교재 집필 세션은 이 파일과 `docs/slice-7/` 증거 파일, `docs/slice-7-plan.md`를 읽는다.

- 갱신 시각: 2026-07-27
- 상태: **슬라이스 완주.** 앱(SwiftUI)→서버(Express)→DB(PostgreSQL) 한 실이 관통됨.

## 결과

| | #7 건물 검색 API | #8 iOS 검색 화면 |
|---|---|---|
| PR | [#29](https://github.com/KPUCE/InnerMap/pull/29) → main `0ba7c9f` | [#30](https://github.com/KPUCE/InnerMap/pull/30) → main `ede64a7` |
| 이슈 | 자동 닫힘 | 자동 닫힘 |
| 테스트 | node:test 15개(정상 5·경계 4·오류 6) 17/17 | 유닛 5 + XCUITest 4 전부 통과 |
| CI | postgres:16 서비스 첫 가동, size:exempt 첫 실전 | ios-build 첫 실행=첫 실패(형식 77) → macos-15로 초록 |

머지 절차: 두 PR 모두 Squash(이슈 하나=main 커밋 하나), 보호 규칙 일시 해제→원복 확인 완료.

## 단계별 요약 (상세는 증거 파일)

- 0단계: 서버 빈 골격·ios 플레이스홀더 확인, 로컬 환경 백지에서 구축(`docs/dev-setup.md`)
- 1단계: 시드=실제 19건(OSM/ODbL, `seed-buildings.md`), 별칭=전부 저자 확인 16개, Ⅺ장 예제→#7 교체 확정
- 2단계: `design.md`(ERD·OpenAPI·시퀀스) + ADR-007(pg_trgm GIN+하버사인, PostGIS 배제)
- 3단계: 마이그레이션·시드 적용, psql 대표 질의·EXPLAIN(`02-schema-queries.md`) — 19행에선 플래너가 GIN 무시, 3글자 미만 패턴 못 좁힘(실측)
- 4단계: 테스트 먼저 — RED `03-red.txt` → CI에 postgres 서비스(A안)
- 5단계: 서버 구현 GREEN `04-green.txt`(첫 실행 17/17) → iOS: XcodeGen(A안)·접근성 화면·`08-ios-tests.txt`
- 6단계: PR 2건, CI 기록 `07-ci-runs.md`, 시행착오 7건 `06-detours.md`, 위임 로그 `05-prompt-log.md`

## 증거 파일 (docs/slice-7/)

`01-design-notes` `02-schema-queries` `03-red.txt` `04-green.txt` `05-prompt-log` `06-detours` `07-ci-runs` `08-ios-tests.txt` — 전부 채워짐. 지시서 §6의 01~07 + iOS 테스트 기록(08) 추가.

## 미결 (다음 작업/사람 몫)

- **실기기 VoiceOver 완주**(#8 AC ③ 후반) — 시뮬레이터+XCUITest로 절반 검증. 실기기 검증은 사람 몫(N-01).
- **iOS 현재 위치**: 캠퍼스 앵커(공학관E동) 고정 — CoreLocation 연동은 브리핑 E2 구현 시점에(`01-design-notes.md`).
- 한글 trigram 정밀도·재현성 대규모 검증(ADR-007 미검증 항목).
- L1~L4 위임 수준 정의가 저장소에 없음 — `05-prompt-log.md` 표기는 잠정, 교재 용어집 대조 필요.
- CI 액션들의 Node 20 deprecation 경고(07-ci-runs 관찰) — R-번호 없는 인프라 작업이라 이슈화는 저자 판단.
- UI 테스트는 로컬 전용(서버+시드 전제) — CI 편입 여부는 후속 논의.
