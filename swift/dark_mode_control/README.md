# User Controlled Dark Mode

Some apps look better in dark mode, and some look better in light mode. As a developer, there could be some use to allowing the user to select the color scheme of the app. 

> Dynamically controlled via json perhaps?

Anywho, here is a quick working solution for anyone who is interested in implementing this into their app

## Final solution

[Video link on my website]()

## Define a model

First, a model needs to be used to control this to allow for access to this variable in the app root.

```swift
class DarkModeModel: ObservableObject {
    @Published var isLight: Bool = true
}
```

This is what the root of the SwiftUI app should look like:

```swift
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
```

Then, to allow for control you can use it like so:

```swift
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
```

## Source Code

[Github Link]()