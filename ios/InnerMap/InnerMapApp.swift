import SwiftUI

@main
struct InnerMapApp: App {
    var body: some Scene {
        WindowGroup {
            SearchView(viewModel: SearchViewModel(service: SearchService()))
        }
    }
}
