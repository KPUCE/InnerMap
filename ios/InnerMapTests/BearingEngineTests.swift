import XCTest
@testable import InnerMap

// #9 BearingEngine 단위 테스트 — 구현 전 작성(RED). 명세: docs/slice-9/design.md
// AC: "방위 검증은 단위 테스트 수준" — 센서 없이 값만으로 전수 검증한다.
final class BearingEngineTests: XCTestCase {

    private let origin = (lat: 37.339713, lng: 126.735044) // 공학관E동 앵커

    // ── 방위각(북 기준) ──────────────────────────────

    func test_방위각_정북() {
        let b = BearingEngine.bearing(from: origin, to: (lat: origin.lat + 0.001, lng: origin.lng))
        XCTAssertEqual(b, 0, accuracy: 0.5)
    }

    func test_방위각_정동() {
        let b = BearingEngine.bearing(from: origin, to: (lat: origin.lat, lng: origin.lng + 0.001))
        XCTAssertEqual(b, 90, accuracy: 0.5)
    }

    func test_방위각_정남() {
        let b = BearingEngine.bearing(from: origin, to: (lat: origin.lat - 0.001, lng: origin.lng))
        XCTAssertEqual(b, 180, accuracy: 0.5)
    }

    func test_방위각_정서() {
        let b = BearingEngine.bearing(from: origin, to: (lat: origin.lat, lng: origin.lng - 0.001))
        XCTAssertEqual(b, 270, accuracy: 0.5)
    }

    // ── 시계 환산: hour = [중심-15°, 중심+15°) 반개구간 ──

    func test_정면은_12시() {
        XCTAssertEqual(BearingEngine.clockHour(bearing: 90, heading: 90), 12)
    }

    func test_오른쪽90도는_3시() {
        XCTAssertEqual(BearingEngine.clockHour(bearing: 180, heading: 90), 3)
    }

    func test_경계_14_9도는_12시_15도는_1시() {
        XCTAssertEqual(BearingEngine.clockHour(bearing: 14.9, heading: 0), 12)
        XCTAssertEqual(BearingEngine.clockHour(bearing: 15.0, heading: 0), 1)
    }

    func test_랩어라운드_350도_보고_10도_바라봄() {
        // relative = (350 - 10 + 360) % 360 = 340 → 12시 구간 아님, 11시(330±15)
        XCTAssertEqual(BearingEngine.clockHour(bearing: 350, heading: 10), 11)
    }

    func test_랩어라운드_5도_보고_355도_바라봄() {
        // relative = (5 - 355 + 360) % 360 = 10 → 12시
        XCTAssertEqual(BearingEngine.clockHour(bearing: 5, heading: 355), 12)
    }

    // ── 정확도 게이트: ±30°(N-04), 무효값 < 0 ──────────

    func test_정확도_30도는_안내() {
        XCTAssertEqual(
            BearingEngine.clockBearing(bearing: 90, heading: 0, headingAccuracy: 30), .hour(3))
    }

    func test_정확도_30도초과는_unavailable() {
        XCTAssertEqual(
            BearingEngine.clockBearing(bearing: 90, heading: 0, headingAccuracy: 30.1), .unavailable)
    }

    func test_정확도_무효값_음수는_unavailable() {
        XCTAssertEqual(
            BearingEngine.clockBearing(bearing: 90, heading: 0, headingAccuracy: -1), .unavailable)
    }
}
