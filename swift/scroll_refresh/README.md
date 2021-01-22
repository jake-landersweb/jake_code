# Pull Down to Refresh

We are well aware that swiftUI does not contain a native way to allow for pulldown scroll refresh in its native ScrollViews.

I know I am not the first one to come across this issue when designing a modern app, and I will not be the last.

So after tinkering around in swift for a while, I was able to come up with this pretty elegant solution:

[Video on my website](http://www.jakelanders.com/wp-content/uploads/2021/01/scroll_refresh.mp4)

## Usage

This is a view builder, which means that it can be used as any normal view, in this case in the place of a scrollView.

Here is how you use it:

```swift
struct PullToRefresh: View {
    @State var isLoading = false
    var body: some View {
        ScrollActionView(action: { action() }, isLoading: $isLoading) {
            Color.red.frame(height: UIScreen.main.bounds.height * 1.5)
        }
    }

    private func action() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            withAnimation { isLoading = false }
        }
    }
}
```

## Creation

This is the code for the view builder used, with intelligent comments when needed.

This is bassically how it works:

It wraps the content in a ScrollView and a Zstack with the indicator behind the content. Then, there is a custom way for tracking the scroll ammount which gets tied to how much of the indicator to show and the angle to turn the arrow. Lastly, the ProgressView will get shown as long as the supplied loading variable is true, and animate closed when loading is done.

```swift
struct ScrollActionView<Content>: View where Content : View {
    @Environment(\.colorScheme) var colorScheme
    // passed content view
    let content: () -> Content

    // action to be performed when the user scrolls
    var action: () -> Void

    // whether loading is occuring or not
    @Binding var isLoading: Bool

    // init all variables
    init?(action: (() -> Void)? = {}, isLoading: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) {
        self.action = action!
        self._isLoading = isLoading
        self.content = content
    }

    // colors for the background of the scroll indicator
    private let darkColor: Color = Color(red: 40 / 255, green: 40 / 255, blue: 40 / 255)
    private let lightColor: Color = Color(red: 240 / 255, green: 240 / 255, blue: 245 / 255)

    // haptic feedback for when user has pulled enough
    private let haptic = UIImpactFeedbackGenerator(style: .heavy)

    // for reading how much the user has scrolled
    @State private var scrollOffset: CGFloat = 0
    // angle the arrow turns
    @State private var arrowAngle: Double = 0
    // wether the user has pulled enough or not
    @State private var hasPulled: Bool = false

    var body: some View {
        ZStack(alignment: .top) {
            // scroll indicator
            scrollableContent
            ScrollView {
                ZStack {
                    // for determining scroll position
                    GeometryReader { proxy in
                        let offset = proxy.frame(in: .named("scroll")).minY
                        Color.clear.preference(key: ViewOffsetKey.self, value: offset)
                    }
                    VStack {
                        content()
                    }
                    .offset(y: isLoading ? 40 : 0)  // offset the content to allow the progress indicator to show when loading
                }

            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ViewOffsetKey.self) { value in
                // get scroll position
                scrollOffset = value
                // set arrow angle for the user
                if value > 30 {
                    arrowAngle = Double((value - 30) * 1.7)
                }
                // start the loading when the user releases the screen
                if arrowAngle < 180 && hasPulled {
                    // keep show loading indicator
                    // spring animation is very important
                    withAnimation(.spring()) { isLoading = true }
                    hasPulled = false
                }
            }
        }
    }

    // view that is shown when the user scrolls
    private var scrollableContent: some View {
        ZStack(alignment: .top) {
            colorScheme == .light ? lightColor : darkColor
            Group {
                if arrowAngle > 180 || hasPulled || isLoading {
                    ProgressView()
                        .onAppear {
                            // indicate the user has pulled all the way
                            withAnimation { hasPulled = true }
                            // complete the action supplied
                            action()
                            // let user know they have pulled enough with a haptic
                            haptic.impactOccurred()
                        }
                } else {
                    // show an arrow that lets the user know they can drag the view
                    Image(systemName: "arrow.down")
                        .rotationEffect(Angle(degrees: arrowAngle < 180 ? arrowAngle : 180))
                }
            }
            .frame(height: 40)
            .font(.system(size: 18, weight: .bold))
        }
        .frame(height: 50 + (scrollOffset > 0 ? scrollOffset : 0)) // only allow height to increase if the user scrolls down
    }
}

// for retrieving scroll amount
struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}
```

## Source

[Github Link](https://github.com/jake-landersweb/jake_code/tree/main/swift/scrol_refresh/PullToRefresh.swift)
