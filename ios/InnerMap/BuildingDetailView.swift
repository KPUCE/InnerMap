import SwiftUI

// #9 건물 상세 — 공식명·별칭·시계 방위·거리를 접근성 알림으로 (R-03, R-10)
struct BuildingDetailView: View {
    let buildingId: Int
    let buildingName: String

    @StateObject private var viewModel: DetailViewModel
    @StateObject private var headingProvider = HeadingProvider()

    init(buildingId: Int, buildingName: String, service: BuildingDetailServicing = SearchService()) {
        self.buildingId = buildingId
        self.buildingName = buildingName
        _viewModel = StateObject(wrappedValue: DetailViewModel(service: service))
    }

    var body: some View {
        content
            .navigationTitle(buildingName)
            .task {
                headingProvider.start()
                await viewModel.load(id: buildingId)
                announceIfLoaded()
            }
            .onDisappear { headingProvider.stop() }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView("불러오는 중").accessibilityLabel("불러오는 중")
        case .loaded:
            let text = currentAnnouncement()
            VStack(alignment: .leading, spacing: 16) {
                Text(text).font(.title3)
                Button("다시 듣기") { announce(text) }
                Spacer()
            }
            .padding()
            .accessibilityElement(children: .contain)
        case .error(let message):
            Text(message)
                .padding()
                .onAppear { announce(message) }
        }
    }

    private func currentAnnouncement() -> String {
        viewModel.announcement(heading: headingProvider.heading,
                               headingAccuracy: headingProvider.accuracy)
    }

    private func announceIfLoaded() {
        let text = currentAnnouncement()
        if !text.isEmpty { announce(text) }
    }

    private func announce(_ message: String) {
        AccessibilityNotification.Announcement(message).post()
    }
}
