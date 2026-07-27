import XCTest

// #8 UI 테스트 — 검색 흐름과 접근성 요소 노출(AC ①·②)을 실기 화면에서 검증.
// 전제: 로컬 API 서버 기동(server/src/server.js, :3000) + innermap_dev 시드.
// 한글 질의는 UITEST_QUERY 환경변수로 주입(DEBUG 훅) — 근거: docs/slice-7/06-detours.md D6
final class SearchFlowUITests: XCTestCase {

    private func element(in app: XCUIApplication, withLabel label: String) -> XCUIElement {
        app.descendants(matching: .any)
            .matching(NSPredicate(format: "label == %@", label)).firstMatch
    }

    private func launchApp(query: String) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment["UITEST_QUERY"] = query
        app.launch()
        return app
    }

    func test_별칭검색_도서관_결과행과_접근성레이블() {
        let app = launchApp(query: "도서관")
        // AC ①: 결과 행이 접근성 요소로 노출되고, 낭독 레이블에 이름·거리·별칭이 담긴다.
        // 행은 .accessibilityElement(children: .ignore)로 합쳐져 staticText가 아니므로 타입 무관 조회
        let row = element(in: app, withLabel: "종합교육관, 약 135미터, 도서관(으)로 일치")
        XCTAssertTrue(row.waitForExistence(timeout: 10), "별칭 매칭 결과 행이 보여야 함")
    }

    func test_이름검색_공학_첫행은_현위치건물() {
        let app = launchApp(query: "공학")
        // 현위치(공학관E동 앵커) 기준 첫 행은 공학관E동, 0미터
        let first = element(in: app, withLabel: "공학관E동, 약 0미터")
        XCTAssertTrue(first.waitForExistence(timeout: 10), "공학관E동이 첫 행이어야 함")
    }

    func test_0건_대안안내가_화면에_노출() {
        let app = launchApp(query: "없는건물")
        // AC ②: 0건 시 대안 안내 — 화면 텍스트로 노출되고 접근성 알림으로도 게시된다
        let message = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS %@", "다시 검색")).firstMatch
        XCTAssertTrue(message.waitForExistence(timeout: 10), "0건 대안 안내가 보여야 함")
    }

    func test_상세진입_시뮬레이터는_거리만안내() {
        // #9: 결과 행 탭 → 상세. 시뮬레이터엔 나침반이 없어 정확도 무효(-1) →
        // ADR-005 ③ 축소 경로("방위를 확인할 수 없어 거리만 안내") 검증
        let app = launchApp(query: "도서관")
        let row = element(in: app, withLabel: "종합교육관, 약 135미터, 도서관(으)로 일치")
        XCTAssertTrue(row.waitForExistence(timeout: 10))
        row.tap()
        let announcement = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS %@", "방위를 확인할 수 없어")).firstMatch
        XCTAssertTrue(announcement.waitForExistence(timeout: 10), "거리만 안내 문구가 보여야 함")
    }

    func test_검색입력이_접근성요소로_노출() {
        let app = XCUIApplication()
        app.launch()
        // AC ①: 입력 필드가 '건물 검색' 레이블의 접근성 요소로 노출
        XCTAssertTrue(app.textFields["건물 검색"].waitForExistence(timeout: 10))
    }
}
