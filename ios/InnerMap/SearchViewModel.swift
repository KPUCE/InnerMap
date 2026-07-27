import Foundation

@MainActor
final class SearchViewModel: ObservableObject {
    enum State: Equatable {
        case idle
        case loading
        case results([BuildingResult])
        case empty(announcement: String)   // 0건 — 대안 안내 (AC ②)
        case error(announcement: String)
    }

    @Published var query = ""
    @Published private(set) var state: State = .idle

    // 현재 위치: 캠퍼스 앵커(공학관E동) 고정 — 위치 서비스(CoreLocation)는 브리핑 엔진 E2
    // 범위라 이번 슬라이스 제외. 근거: docs/slice-7/01-design-notes.md
    let anchorLat = 37.339713
    let anchorLng = 126.735044

    private let service: SearchServicing

    init(service: SearchServicing) {
        self.service = service
    }

    func submit() async {
        let q = query.trimmingCharacters(in: .whitespaces)
        guard !q.isEmpty else {
            state = .error(announcement: "검색어를 입력해 주세요.")
            return
        }
        state = .loading
        do {
            let res = try await service.search(query: q, lat: anchorLat, lng: anchorLng)
            if res.count == 0 {
                // reason_code NO_MATCH → 대안 안내 (AC ②)
                state = .empty(announcement: "\(q) 검색 결과가 없습니다. 건물 이름의 일부나 다른 이름으로 다시 검색해 보세요.")
            } else {
                state = .results(res.results)
            }
        } catch let SearchError.badRequest(_, message) {
            state = .error(announcement: message)
        } catch {
            state = .error(announcement: "서버에 연결하지 못했습니다. 잠시 후 다시 시도해 주세요.")
        }
    }

    // VoiceOver 낭독 문구 — 거리는 미터 단위(팀 규약), 방위 표현 없음(시계 방위는 브리핑 E2 몫)
    // nonisolated: 상태를 읽지 않는 순수 함수 — MainActor 밖(테스트 등)에서도 호출 가능해야 한다
    nonisolated static func spokenLabel(for item: BuildingResult) -> String {
        var label = "\(item.name), 약 \(Int(item.distanceM.rounded()))미터"
        if let alias = item.matchedAlias {
            label += ", \(alias)(으)로 일치"
        }
        return label
    }
}
