import Foundation

// #9 방위 엔진 — 값만 받는 순수 함수. 센서 객체 없음 → 시뮬레이터와 무관하게 전수 단위 테스트.
// 명세: docs/slice-9/design.md · 문턱 ±30° 출처: N-04(시계 한 칸) · #14 정렬 엔진이 재사용 예정.

enum ClockBearing: Equatable {
    case hour(Int)      // 1~12시
    case unavailable    // 방위 신뢰 불가 — 거리만 안내 (ADR-005 ③ 축소 적용)
}

enum BearingEngine {
    /// 대권 초기 방위각(북 기준 0~360°)
    static func bearing(from: (lat: Double, lng: Double), to: (lat: Double, lng: Double)) -> Double {
        let p1 = from.lat * .pi / 180, p2 = to.lat * .pi / 180
        let dl = (to.lng - from.lng) * .pi / 180
        let y = sin(dl) * cos(p2)
        let x = cos(p1) * sin(p2) - sin(p1) * cos(p2) * cos(dl)
        let deg = atan2(y, x) * 180 / .pi
        return (deg + 360).truncatingRemainder(dividingBy: 360)
    }

    /// 하버사인 거리(미터) — 서버 검색과 동일 공식 (docs/slice-7/design.md)
    static func distanceMeters(from: (lat: Double, lng: Double), to: (lat: Double, lng: Double)) -> Double {
        let p1 = from.lat * .pi / 180, p2 = to.lat * .pi / 180
        let dp = (to.lat - from.lat) * .pi / 180
        let dl = (to.lng - from.lng) * .pi / 180
        let a = sin(dp / 2) * sin(dp / 2) + cos(p1) * cos(p2) * sin(dl / 2) * sin(dl / 2)
        return 6_371_000 * 2 * asin(sqrt(a))
    }

    /// 시계 방위 환산 — 각 시는 [중심-15°, 중심+15°) 반개구간
    static func clockHour(bearing: Double, heading: Double) -> Int {
        let relative = (bearing - heading + 360).truncatingRemainder(dividingBy: 360)
        let h = Int((relative + 15) / 30) % 12
        return h == 0 ? 12 : h
    }

    /// 정확도 게이트: 무효(<0) 또는 ±30° 초과면 방위 생략
    static func clockBearing(bearing: Double, heading: Double, headingAccuracy: Double) -> ClockBearing {
        guard headingAccuracy >= 0, headingAccuracy <= 30 else { return .unavailable }
        return .hour(clockHour(bearing: bearing, heading: heading))
    }
}
