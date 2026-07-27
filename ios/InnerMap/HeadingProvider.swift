import CoreLocation

// 나침반 heading의 얇은 어댑터 — 화면은 (heading, accuracy) 값만 본다.
// 자북(magneticHeading)만 사용: 진북은 위치 권한이 필요해 범위 밖(E2).
// 편각(한국 서편 약 8°)은 N-04 한 칸(±30°) 안 — 근거·미결: docs/slice-9/01-design-notes.md
final class HeadingProvider: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published private(set) var heading: Double = 0
    @Published private(set) var accuracy: Double = -1  // 무효로 시작 — 시뮬레이터에선 유지됨(→ 거리만 안내)

    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
    }

    func start() {
        guard CLLocationManager.headingAvailable() else { return }
        manager.startUpdatingHeading()
    }

    func stop() { manager.stopUpdatingHeading() }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        heading = newHeading.magneticHeading
        accuracy = newHeading.headingAccuracy
    }
}
