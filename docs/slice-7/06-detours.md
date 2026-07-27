# 06 막힌 지점·잘못 든 길·되돌린 결정 (Ⅺ·ⅩⅡ장 재료)

지시서 §0: 실패·막힌 지점·되돌린 결정을 지우지 않는다. 그 자리에서 적는다.

## D1 — 마이그레이션 스텁이 ESM으로 나옴 → CJS로 되돌림
- `npx node-pg-migrate create`(v9)가 `export const up = ...` ESM 스텁을 생성.
- 그러나 이 저장소는 CJS다: `package.json`에 `type:module`이 없고, 기존 `server/test/smoke.test.js`·`rehearsal.test.js`가 `require('node:test')`를 쓴다.
- `type:module`을 추가하면 기존 테스트가 깨진다(§7 "기존 파일 깨지 않기"에도 어긋남). 그래서 마이그레이션 파일을 CJS(`exports.up`/`exports.down`)로 바꿔 작성했다.
- 교훈: 도구 기본값(ESM)과 저장소 관례(CJS)가 충돌할 때, 저장소 관례를 따른다. AI가 스텁을 그대로 뒀다면 첫 `migrate up`에서 깨졌을 것.

## D3 — Homebrew 설치가 xcode-select를 CLT로 돌려놓음
- 0단계 확인 때 `xcode-select -p`는 Xcode를 가리켰으나, Homebrew 설치 과정에서 Command Line Tools가 깔리며 활성 개발자 디렉터리가 CLT로 바뀌었다. `xcodebuild`가 "requires Xcode" 오류.
- 우회: 셸에서는 `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer`로 빌드 가능. 시뮬레이터 패널 도구는 시스템 설정을 요구해 저자가 `sudo xcode-select -s ...`로 원복(sudo 구간은 사람 몫).

## D4 — @MainActor static 순수 함수를 테스트에서 못 부름 (컴파일 RED)
- `SearchViewModel.spokenLabel`(순수 함수)이 클래스의 `@MainActor`에 묶여 nonisolated 테스트에서 컴파일 오류. `nonisolated static`으로 선언해 해결.

## D5 — GENERATE_INFOPLIST_FILE만으론 CFBundleVersion이 안 생김 (테스트 RED)
- 시뮬레이터가 "valid CFBundleVersion" 오류로 설치 거부. `CURRENT_PROJECT_VERSION`·`MARKETING_VERSION`을 project.yml에 추가해야 생성된 Info.plist에 버전이 들어간다.

## D6 — 시뮬레이터 원격 입력이 한글을 못 넣음 → UI 테스트 훅으로 전환
- 패널 도구의 텍스트 주입은 ASCII 한정("도서관" 탈락), 필드 포커스도 불안정. 손 조작 데모를 접고 XCUITest로 전환.
- 한글 질의는 실행 환경변수 `UITEST_QUERY`(DEBUG 한정 훅)로 주입. 결과 행은 `.accessibilityElement(children:.ignore)`라 staticText가 아니어서 타입 무관(label 조건) 조회로 검증 — 이것도 한 번 틀리고 고침(UI 테스트 RED 1회).
- 교훈: 자동화 가능한 검증(XCUITest)이 손 조작 데모보다 증거로도 강하다. 단 VoiceOver '완주'(AC ③)는 시뮬레이터+XCUITest로 절반만 — 실기기 검증은 사람 몫으로 남김.

## D7 — CI ios-build 첫 실행 실패: 프로젝트 형식 77 vs 러너 Xcode 15.4
- PR #30 첫 CI에서 ios-build가 9초 만에 실패. `xcodebuild: error: ... future Xcode project file format (77)` — macos-14 러너의 기본 Xcode가 15.4인데 XcodeGen 2.46은 Xcode 16 형식(objectVersion 77)으로만 생성한다.
- 잘못 든 길: project.yml에서 `xcodeVersion: "15.4"` → 여전히 77. `objectVersion: 56` 옵션 → 무시됨. 프로젝트 쪽에서 형식을 내리는 길은 없었다.
- 해결(저자 승인): `ios-build`를 `runs-on: macos-15`(기본 Xcode 16.x)로 올림. 대안이었던 macos-14+xcode-select 스텝은 러너 이미지 구성 의존이라 배제.
- 교훈: 로컬(16.2)과 CI(15.4)의 도구 버전 차이는 로컬 초록으로는 안 드러난다 — CI 첫 실행이 곧 검증이다.

## D2 — pg_trgm GIN 인덱스가 시드 규모에서 안 쓰임 (설계 허점, 기록만)
- EXPLAIN 결과 19행에서 기본 플래너는 `building_name_trgm`을 무시하고 Seq Scan을 택한다. `enable_seqscan=off`로 강제해야 인덱스를 쓴다.
- 게다가 trigram은 3글자 미만 패턴('공학', '공')을 좁히지 못해, 그런 질의엔 인덱스 이득이 아예 없다(온전한 3-gram 부재).
- 이는 버그가 아니라 ADR-007에 적어 둔 트레이드오프("19건에선 과임")가 실측으로 확인된 것. 되돌리지 않는다 — 운영 척도를 대비한 설계임을 교재에 정직하게 밝힌다.
- 남는 숙제: 한글 대규모 데이터에서 trigram 정밀도·재현성 검증(ADR-007 미검증 항목). 상세 근거는 `02-schema-queries.md`.
