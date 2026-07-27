# #9 건물 상세 안내 — 방위·거리 상세 설계

이슈 #9(R-03·N-04). 방위 산출 방침은 (c)안: **순수 엔진 + CLHeading + ADR-005 단계 대응** (저자 채택, 2026-07-27). 대안·기각은 `01-design-notes.md`.

## 구성 — 세 조각

```
[서버] GET /api/buildings/{id}      ← 상세 데이터(좌표·별칭)가 현재 API에 없음
[iOS]  BearingEngine (순수 함수)     ← 시계 방위 환산 — 단위 테스트의 대상 (AC)
[iOS]  BuildingDetailView           ← 검색 결과 탭 → 상세, 접근성 알림 (R-10)
```

## 1. 서버 — 상세 조회 엔드포인트

검색 응답(`{id, name, matched_alias, distance_m}`)에는 좌표·별칭 목록이 없어 방위 계산과 "공식명·별칭 안내"(AC)가 불가능하다. CLAUDE.md의 API 예시(`/api/buildings/{id}/aliases`)와 같은 자원 계층으로 상세 엔드포인트를 추가한다.

```
GET /api/buildings/{id}
200 → { id, name, lat, lng, aliases: ["도서관", ...] }
404 → { error_code: "NOT_FOUND" }        # 없는 id 또는 미게시(R-12b — 존재 자체를 숨김)
400 → { error_code: "INVALID_PARAM" }    # id가 양의 정수가 아님
```

미게시 건물을 404로 처리하는 이유: R-12b(게시 전 노출 금지)는 "있다"는 사실도 노출하지 않는 쪽이 안전하다.

## 2. iOS — BearingEngine (순수 함수 모듈)

#14 클록 페이스 정렬 엔진의 선행 조각. 센서 객체를 받지 않고 **값만 받는다** — 시뮬레이터 한계와 무관하게 전수 단위 테스트 가능(AC "방위 검증은 단위 테스트 수준").

```swift
enum ClockBearing: Equatable {
    case hour(Int)                  // 1~12
    case unavailable                // 방위 신뢰 불가 — 거리만 안내 (ADR-005 ③ 축소 적용)
}

struct BearingEngine {
    // 대권 초기 방위각(북 기준 0~360°). 캠퍼스 척도(≤500m)에서 오차 무시 가능 — 출처: 표준 구면 공식
    static func bearing(from: (lat: Double, lng: Double), to: (lat: Double, lng: Double)) -> Double

    // 시계 방위 환산: relative = (bearing - heading + 360) % 360, hour = 반올림(relative / 30°), 0→12
    // 경계 규칙: 각 시(hour)는 [중심-15°, 중심+15°) 반개구간 — 345°≤r<15° → 12시, 15°≤r<45° → 1시 …
    static func clockHour(bearing: Double, heading: Double) -> Int

    // 게이트: headingAccuracy가 유효(≥0)하고 ±30° 이내일 때만 방위 안내 — 문턱 출처: N-04(시계 한 칸=±30°)
    static func clockBearing(bearing: Double, heading: Double, headingAccuracy: Double) -> ClockBearing
}
```

- **문턱 ±30°의 출처는 N-04**(오차 허용 = 시계 한 칸). 정확도가 문턱을 넘으면 `unavailable` → "방위를 확인할 수 없어 거리만 안내합니다" 고지(ADR-005 ③의 문안 원칙 재사용). #9에서는 보정 안내·평활화(ADR-005 ①②)는 구현하지 않는다 — E2(#14·#16) 몫. 이 축소는 교재에 명시.
- heading 공급: `CLLocationManager` heading 콜백을 얇은 어댑터로 — 화면은 `ClockBearing`만 본다.

## 3. iOS — BuildingDetailView

- 진입: 검색 결과 행 탭 → `GET /api/buildings/{id}` → 상세.
- 표시·낭독(접근성 알림, R-10): `"공학관E동. 별칭 E동. 3시 방향, 약 85미터."` / unavailable 시: `"공학관E동. 별칭 E동. 약 85미터. 방위를 확인할 수 없어 거리만 안내합니다."`
- 거리: 미터 정수 반올림(팀 규약 — 기본 단위 미터). 사용자 위치는 #8과 동일하게 캠퍼스 앵커 고정(E2 전까지, `slice-7/01-design-notes.md` 결정 승계).
- 별칭 0개(창조관 등)면 별칭 문구 생략.

## 테스트 목록 (4단계 RED 대상)

**서버(3~4개):** 상세 200(별칭 포함/별칭 없음), 미게시→404, 없는 id→404, 잘못된 id→400
**BearingEngine(8개 이상):** 방위각 기본 4방(N/E/S/W), 시계 환산 — 정면=12시, 90°=3시, 경계 14.9°→12시·15.0°→1시, 랩어라운드 350°/10° 교차, heading 뺄셈 음수 경계, 정확도 게이트(30° 경계·무효값 -1)
**뷰모델(3개):** 상세 로드→낭독 문구 조립(별칭 유/무), unavailable 문구, API 오류

## PR

`feature/9-building-detail` 단일 PR(이슈=커밋 1:1). 300줄 목표, 생성물 없이 코드가 넘치면 size:exempt 대신 **분할을 먼저 검토**(서버 조각 선분리 가능).
