# iOS15 Safari Style Tab Bar

iOS15 introduced a new safari style that contains a bottom bar that holds all view control. I decided to implement this myself, but convert the new UI style into a replacement for a TabView in SwiftUI.

Here is what it looks like:

<<Insert images>>

If you would like to watch a video version, you can check it out [here](https://www.youtube.com/watch?v=19ukJV5xRy8)

## Supporting Code

First, there are a few custom views we are going to need to implement.

The first, is a way to retrieve the scroll offset in a scroll view:

```swift
struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}
```

And the other is for access and control over the views passed within {} in SwiftUI:

```swift
extension TupleView {
    var getViews: [AnyView] {
        makeArray(from: value)
    }

    private struct GenericView {
        let body: Any

        var anyView: AnyView? {
            AnyView(_fromValue: body)
        }
    }

    private func makeArray<Tuple>(from tuple: Tuple) -> [AnyView] {
        func convert(child: Mirror.Child) -> AnyView? {
            withUnsafeBytes(of: child.value) { ptr -> AnyView? in
                let binded = ptr.bindMemory(to: GenericView.self)
                return binded.first?.anyView
            }
        }

        let tupleMirror = Mirror(reflecting: tuple)
        return tupleMirror.children.compactMap(convert)
    }
}
```

## View Builder Code

Now, we are going to implement the iOS15 style tab view in a view builder so we can easily reuse this code whenever needed. This also lets you copy and paste this code into your own projects!

```swift
struct iOS15TabBar: View {
    @Environment(\.colorScheme) var colorScheme
    
    let content: [AnyView]
    
    let tabItems: [TabBarItem]
    
    init<Views>(tabItems: [TabBarItem], @ViewBuilder content: @escaping () -> TupleView<Views>) {
        if content().getViews.count == 0 || tabItems.count == 0 {
            fatalError("!!! This view requires one view and one tab item !!!")
        }
        self.content = content().getViews
        self.tabItems = tabItems
    }
    
    @State private var currentIndex: Int = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            NavigationView {
                ScrollView {
                    ZStack {
                        GeometryReader { proxy in
                            let offset = proxy.frame(in: .named("scroll")).minY
                            Color.clear.preference(key: ViewOffsetKey.self, value: offset)
                        }
                        content[currentIndex]
                    }
                }
                .onPreferenceChange(ViewOffsetKey.self) { value in
                    handleScroll(value: value)
                }
                .navigationTitle(tabItems[currentIndex].title)
            }
            if showBar {
                topBar
            } else {
                bottomBar
            }
        }
    }
    
    @Namespace private var _namespace
    
    private var topBar: some View {
            HStack {
                ForEach(tabItems.indices) { index in
                    Button(action: {
                        print(tabItems[index].title)
                        currentIndex = index
                    }) {
                            VStack(spacing: 3) {
                                Image(systemName: tabItems[index].icon)
                                if index == currentIndex {
                                    Text(tabItems[index].title)
                                        .font(.system(.caption))
                                        .matchedGeometryEffect(id: "Text", in: _namespace)
                                } else {
                                    Text(tabItems[index].title)
                                        .font(.system(.caption))
                                }
                            }
                            .foregroundColor(index == currentIndex ? .accentColor : colorScheme == .light ? Color.black.opacity(0.5) : Color.white.opacity(0.5))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 50)
            .background(Material.regular)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .padding(.horizontal, 20)
            .shadow(color: Color.black.opacity(0.3), radius: 10)
            .matchedGeometryEffect(id: "Shape", in: _namespace)
            .padding(.bottom, 18)
        }

        private var bottomBar: some View {
            ZStack {
                VStack(spacing: 0) {
                    Divider()
                    Rectangle()
                        .fill(.ultraThinMaterial)
                }
                HStack {
                    Text("")
                        .padding(.leading, 30)
                        .matchedGeometryEffect(id: "Icon1", in: _namespace)
                    Spacer()
                }
                Text(tabItems[currentIndex].title)
                    .font(.system(size: 12))
                    .matchedGeometryEffect(id: "Text", in: _namespace)
            }
            .matchedGeometryEffect(id: "Shape", in: _namespace)
            .ignoresSafeArea()
            .frame(height: 15)
        }
    
    private let animation = Animation.spring(response: 0.35, dampingFraction: 0.85, blendDuration: 0.4)
    @State private var startingLocation: CGFloat = 0
    @State private var currentLocation: CGFloat = 0
    @State private var lastLocation: CGFloat = 0
    @State private var scrollCount: Int = 0
    @State private var showBar = true
    private let scrollMax = 7
    private let velocityMax = 25
    private func handleScroll(value: ViewOffsetKey.Value) {
        if startingLocation == 0 {
            startingLocation = value
        }
        currentLocation = value
        
        // employ logic about the scroll bar
        if currentLocation < startingLocation {
            if currentLocation < lastLocation {
                if scrollCount > -(scrollMax + 1) {
                    scrollCount -= 1
                }
            } else if currentLocation > lastLocation {
                if scrollCount < (scrollMax + 1) {
                    scrollCount += 1
                }
            }
        }
        
        // handle smaller changes
        if scrollCount > scrollMax {
            withAnimation(animation) {
                showBar = true
            }
        } else if scrollCount < -scrollMax {
            withAnimation(animation) {
                showBar = false
            }
        }
        
        // handle large changes
        let velocity = currentLocation - lastLocation
        if velocity > CGFloat(velocityMax) {
            withAnimation(animation) {
                showBar = true
            }
            scrollCount = (scrollMax + 1)
        } else if velocity < CGFloat(-velocityMax) {
            withAnimation(animation) {
                showBar = false
            }
            scrollCount = -(scrollMax + 1)
        }
        
        lastLocation = value
    }
}
```

## Putting it Together

Lastly, we can use this view as shown below. You need a list of TabBarItems (a struct that contains a title and an icon), and more than one view passed inbetween the {} of the view.

```swift
struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    
    private let tabItems = [
        TabBarItem(title: "Calendar", icon: "calendar"),
        TabBarItem(title: "Contacts", icon: "person")
    ]
    
    var body: some View {
        iOS15TabBar(tabItems: tabItems) {
            LazyVStack {
                ForEach(0..<30, id:\.self) { item in
                    cell(title: "Item: \(item)", color: Color.blue)
                }
            }
            LazyVStack {
                ForEach(30..<70, id:\.self) { item in
                    cell(title: "Item: \(item)", color: Color.green)
                }
            }
        }
    }
    
    private func cell(title: String, color: Color) -> some View {
        return VStack(alignment: .leading) {
            HStack {
                Text(title)
                    .font(.title3)
                Spacer(minLength: 0)
            }
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .background(color)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .padding([.horizontal, .bottom], 10)
    }
}
```

## Source

[Github]()