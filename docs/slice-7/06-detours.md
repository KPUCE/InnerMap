# 06 막힌 지점·잘못 든 길·되돌린 결정 (Ⅺ·ⅩⅡ장 재료)

지시서 §0: 실패·막힌 지점·되돌린 결정을 지우지 않는다. 그 자리에서 적는다.

## D1 — 마이그레이션 스텁이 ESM으로 나옴 → CJS로 되돌림
- `npx node-pg-migrate create`(v9)가 `export const up = ...` ESM 스텁을 생성.
- 그러나 이 저장소는 CJS다: `package.json`에 `type:module`이 없고, 기존 `server/test/smoke.test.js`·`rehearsal.test.js`가 `require('node:test')`를 쓴다.
- `type:module`을 추가하면 기존 테스트가 깨진다(§7 "기존 파일 깨지 않기"에도 어긋남). 그래서 마이그레이션 파일을 CJS(`exports.up`/`exports.down`)로 바꿔 작성했다.
- 교훈: 도구 기본값(ESM)과 저장소 관례(CJS)가 충돌할 때, 저장소 관례를 따른다. AI가 스텁을 그대로 뒀다면 첫 `migrate up`에서 깨졌을 것.

## D2 — pg_trgm GIN 인덱스가 시드 규모에서 안 쓰임 (설계 허점, 기록만)
- EXPLAIN 결과 19행에서 기본 플래너는 `building_name_trgm`을 무시하고 Seq Scan을 택한다. `enable_seqscan=off`로 강제해야 인덱스를 쓴다.
- 게다가 trigram은 3글자 미만 패턴('공학', '공')을 좁히지 못해, 그런 질의엔 인덱스 이득이 아예 없다(온전한 3-gram 부재).
- 이는 버그가 아니라 ADR-007에 적어 둔 트레이드오프("19건에선 과임")가 실측으로 확인된 것. 되돌리지 않는다 — 운영 척도를 대비한 설계임을 교재에 정직하게 밝힌다.
- 남는 숙제: 한글 대규모 데이터에서 trigram 정밀도·재현성 검증(ADR-007 미검증 항목). 상세 근거는 `02-schema-queries.md`.
