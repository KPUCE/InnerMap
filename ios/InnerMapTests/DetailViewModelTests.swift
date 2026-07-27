import XCTest
@testable import InnerMap

// #9 상세 뷰모델 테스트 — 구현 전 작성(RED). 낭독 문구 조립·unavailable·오류.
final class DetailViewModelTests: XCTestCase {

    private let detail = BuildingDetail(
        id: 13, name: "종합교육관", lat: 37.340667, lng: 126.734094, aliases: ["도서관"])

    struct StubDetailService: BuildingDetailServicing {
        var result: Result<BuildingDetail, SearchError>
        func detail(id: Int) async throws -> BuildingDetail { try result.get() }
    }

    @MainActor
    func test_낭독문구_별칭과_방위와_거리() async {
        let vm = DetailViewModel(service: StubDetailService(result: .success(detail)))
        await vm.load(id: 13)
        // 앵커(공학관E동)→종합교육관, heading 0°(북) 가정, 정확도 양호 가정의 문구
        let text = vm.announcement(heading: 0, headingAccuracy: 10)
        XCTAssertTrue(text.hasPrefix("종합교육관. 별칭 도서관."), text)
        XCTAssertTrue(text.contains("방향"), "시계 방위 포함: \(text)")
        XCTAssertTrue(text.contains("미터"), "거리 미터 단위: \(text)")
    }

    @MainActor
    func test_낭독문구_정확도불가면_거리만과_고지() async {
        let vm = DetailViewModel(service: StubDetailService(result: .success(detail)))
        await vm.load(id: 13)
        let text = vm.announcement(heading: 0, headingAccuracy: -1)
        XCTAssertFalse(text.contains("방향"), text)
        XCTAssertTrue(text.contains("방위를 확인할 수 없어"), text)
    }

    @MainActor
    func test_별칭없으면_별칭문구_생략() async {
        let noAlias = BuildingDetail(id: 8, name: "창조A관", lat: 37.339128, lng: 126.735897, aliases: [])
        let vm = DetailViewModel(service: StubDetailService(result: .success(noAlias)))
        await vm.load(id: 8)
        let text = vm.announcement(heading: 0, headingAccuracy: 10)
        XCTAssertFalse(text.contains("별칭"), text)
    }

    @MainActor
    func test_API오류_오류상태() async {
        let vm = DetailViewModel(service: StubDetailService(result: .failure(.network("down"))))
        await vm.load(id: 13)
        guard case .error = vm.state else { return XCTFail("error 상태여야 함: \(vm.state)") }
    }
}
