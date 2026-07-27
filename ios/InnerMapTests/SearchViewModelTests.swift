import XCTest
@testable import InnerMap

// #8 단위 테스트 — 서비스를 스텁으로 바꿔 뷰모델 상태 전이를 검증.
// CI ios-build는 컴파일만 확인하므로 이 테스트는 로컬에서 실행해 기록한다(docs/slice-7/08-ios-notes.md).
final class SearchViewModelTests: XCTestCase {

    struct StubService: SearchServicing {
        var result: Result<SearchResponse, SearchError>
        func search(query: String, lat: Double, lng: Double) async throws -> SearchResponse {
            try result.get()
        }
    }

    @MainActor
    func test_결과있음_results상태() async {
        let items = [BuildingResult(id: 1, name: "공학관E동", matchedAlias: nil, distanceM: 0.0)]
        let vm = SearchViewModel(service: StubService(result: .success(
            SearchResponse(count: 1, results: items, reasonCode: nil))))
        vm.query = "공학"
        await vm.submit()
        XCTAssertEqual(vm.state, .results(items))
    }

    @MainActor
    func test_0건_empty상태와_대안안내() async {
        let vm = SearchViewModel(service: StubService(result: .success(
            SearchResponse(count: 0, results: [], reasonCode: "NO_MATCH"))))
        vm.query = "없는건물"
        await vm.submit()
        guard case .empty(let message) = vm.state else {
            return XCTFail("empty 상태여야 함: \(vm.state)")
        }
        XCTAssertTrue(message.contains("다시 검색"), "대안 안내 포함: \(message)")
    }

    @MainActor
    func test_빈검색어_서버호출없이_오류안내() async {
        let vm = SearchViewModel(service: StubService(result: .failure(.network("호출되면 안 됨"))))
        vm.query = "   "
        await vm.submit()
        guard case .error(let message) = vm.state else {
            return XCTFail("error 상태여야 함: \(vm.state)")
        }
        XCTAssertTrue(message.contains("검색어"), message)
    }

    @MainActor
    func test_400오류_서버메시지_그대로안내() async {
        let vm = SearchViewModel(service: StubService(result: .failure(
            .badRequest(code: "INVALID_LOCATION", message: "현재 위치(lat, lng)가 없거나 잘못되었습니다."))))
        vm.query = "공학"
        await vm.submit()
        XCTAssertEqual(vm.state, .error(announcement: "현재 위치(lat, lng)가 없거나 잘못되었습니다."))
    }

    func test_낭독문구_별칭과거리() {
        let item = BuildingResult(id: 13, name: "종합교육관", matchedAlias: "도서관", distanceM: 135.3)
        XCTAssertEqual(SearchViewModel.spokenLabel(for: item), "종합교육관, 약 135미터, 도서관(으)로 일치")
    }
}
