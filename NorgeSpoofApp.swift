import SwiftUI

@main
struct NorgeSpoofApp: App {
    @StateObject private var model = SpoofModel()
    var body: some Scene {
        WindowGroup { ContentView().environmentObject(model) }
    }
}
