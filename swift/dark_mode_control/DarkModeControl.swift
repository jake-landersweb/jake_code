import SwiftUI

@main
struct website_projectApp: App {
    @StateObject var model = DarkModeModel()
    
    var body: some Scene {
        WindowGroup {
            DarkModeControl(model: model)
                .colorScheme(model.isLight ? .light : .dark)
        }
    }
}

class DarkModeModel: ObservableObject {
    @Published var isLight: Bool = true
}

struct DarkModeControl: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var model: DarkModeModel
    
    var body: some View {
        NavigationView {
            Toggle("", isOn: $model.isLight)
                .labelsHidden()
                .navigationTitle(model.isLight ? "Light Mode" : "Dark Mode")
        }
    }
}
