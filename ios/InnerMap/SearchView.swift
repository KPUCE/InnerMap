import SwiftUI

// #8 검색 화면 — AC: ① 입력·목록 접근성 요소 노출 ② 0건 시 접근성 알림 ③ VoiceOver 완주
struct SearchView: View {
    @ObservedObject var viewModel: SearchViewModel
    @AccessibilityFocusState private var searchFieldFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                TextField("건물 이름이나 별칭", text: $viewModel.query)
                    .textFieldStyle(.roundedBorder)
                    .submitLabel(.search)
                    .accessibilityLabel("건물 검색")
                    .accessibilityHint("건물 이름이나 별칭을 입력하고 검색을 실행하세요.")
                    .accessibilityFocused($searchFieldFocused)
                    .onSubmit { Task { await viewModel.submit() } }
                    .padding(.horizontal)

                content
                Spacer()
            }
            .navigationTitle("건물 검색")
            .onAppear { runUITestQueryIfNeeded() }
        }
    }

    // UI 테스트 훅(DEBUG 한정) — 시뮬레이터 원격 입력이 한글을 못 넣는 제약 때문에
    // 실행 환경변수로 질의를 주입한다. 근거: docs/slice-7/06-detours.md D6
    private func runUITestQueryIfNeeded() {
        #if DEBUG
        if let q = ProcessInfo.processInfo.environment["UITEST_QUERY"] {
            viewModel.query = q
            Task { await viewModel.submit() }
        }
        #endif
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            Text("캠퍼스 건물을 이름이나 별칭으로 찾습니다.")
                .foregroundStyle(.secondary)
        case .loading:
            ProgressView("검색 중")
                .accessibilityLabel("검색 중")
        case .results(let items):
            // 결과 목록 — 행 단위로 요소를 합쳐 VoiceOver가 한 번에 낭독 (AC ①)
            List(items) { item in
                VStack(alignment: .leading) {
                    Text(item.name).font(.headline)
                    Text(rowSubtitle(item))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(SearchViewModel.spokenLabel(for: item))
            }
            .listStyle(.plain)
            .accessibilityLabel("검색 결과 \(items.count)건")
            .onAppear { announce("검색 결과 \(items.count)건") }
        case .empty(let message), .error(let message):
            // R-10: 사용자 안내는 접근성 알림으로도 전달 (AC ②)
            Text(message)
                .padding(.horizontal)
                .onAppear {
                    announce(message)
                    searchFieldFocused = true   // 재검색 흐름으로 복귀 (AC ③ 완주)
                }
        }
    }

    private func rowSubtitle(_ item: BuildingResult) -> String {
        var text = "약 \(Int(item.distanceM.rounded()))m"
        if let alias = item.matchedAlias { text += " · 별칭 \(alias)" }
        return text
    }

    private func announce(_ message: String) {
        // iOS 17: AccessibilityNotification — VoiceOver 켜져 있을 때 즉시 낭독
        AccessibilityNotification.Announcement(message).post()
    }
}
