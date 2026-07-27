import Foundation

@MainActor
final class DetailViewModel: ObservableObject {
    enum State: Equatable {
        case idle
        case loading
        case loaded(BuildingDetail)
        case error(String)
    }

    @Published private(set) var state: State = .idle

    // 사용자 위치: #8과 동일한 캠퍼스 앵커(공학관E동) 승계 — E2 전까지 (docs/slice-7/01-design-notes.md)
    let anchor = (lat: 37.339713, lng: 126.735044)

    private let service: BuildingDetailServicing

    init(service: BuildingDetailServicing) {
        self.service = service
    }

    func load(id: Int) async {
        state = .loading
        do {
            state = .loaded(try await service.detail(id: id))
        } catch let SearchError.badRequest(_, message) {
            state = .error(message)
        } catch {
            state = .error("서버에 연결하지 못했습니다. 잠시 후 다시 시도해 주세요.")
        }
    }

    // 낭독 문구(R-10 접근성 알림용) — "공학관E동. 별칭 E동. 3시 방향, 약 85미터."
    // heading 신뢰 불가 시 방위 생략+사실 고지 (ADR-005 ③ 문안 원칙)
    nonisolated private static func announcement(
        detail d: BuildingDetail, anchor: (lat: Double, lng: Double),
        heading: Double, headingAccuracy: Double
    ) -> String {
        var text = "\(d.name). "
        if !d.aliases.isEmpty {
            text += "별칭 \(d.aliases.joined(separator: ", ")). "
        }
        let meters = Int(BearingEngine.distanceMeters(from: anchor, to: (d.lat, d.lng)).rounded())
        let bearing = BearingEngine.bearing(from: anchor, to: (d.lat, d.lng))
        switch BearingEngine.clockBearing(bearing: bearing, heading: heading, headingAccuracy: headingAccuracy) {
        case .hour(let h):
            text += "\(h)시 방향, 약 \(meters)미터."
        case .unavailable:
            text += "약 \(meters)미터. 방위를 확인할 수 없어 거리만 안내합니다."
        }
        return text
    }

    func announcement(heading: Double, headingAccuracy: Double) -> String {
        guard case .loaded(let d) = state else { return "" }
        return Self.announcement(detail: d, anchor: anchor, heading: heading, headingAccuracy: headingAccuracy)
    }
}
