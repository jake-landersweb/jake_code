import SwiftUI

@main
struct website_projectApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                SafariBarCopy(tabItems: _tabItems) {
                    VStack {
                        ForEach(0...100, id: \.self) { i in
                            Text("Item \(i)")
                                .frame(height: 50)
                        }
                    }
                    VStack {
                        ForEach((0...100).reversed(), id: \.self) { i in
                            Text("Item \(i)")
                                .frame(height: 50)
                                .foregroundColor(.red)
                        }
                    }
                }
                .navigationTitle("Safari Bar Copy")
            }
        }
    }
    
    private var _tabItems: [TabBarItem] = [
        TabBarItem(title: "view1", icon: "01.circle"),
        TabBarItem(title: "view2", icon: "02.circle")
    ]
}

struct SafariBarCopy: View {
    @Environment(\.colorScheme) var colorScheme
    
    let content: [AnyView]
    
    let tabItems: [TabBarItem]
    
    @State private var _currentIndex: Int = 0
    
    // init all variables
    init<Views>(tabItems: [TabBarItem], @ViewBuilder content: @escaping () -> TupleView<Views>) {
        if content().getViews.count == 0 || tabItems.count == 0 {
            fatalError("!!! This view requires one view and one tab item !!!")
        }
        self.content = content().getViews
        self.tabItems = tabItems
        if self.content.count != self.tabItems.count {
            fatalError("!!! View count needs to equal tab item count !!!")
        }
    }
    
    
    @Namespace private var _namespace
    
    @State private var _scrollOffset: CGFloat = 0
    @State private var _scrollOffsetPrevious: CGFloat = 0
    
    @State private var _velocity: CGFloat = 0
    
    @State private var _scrollingDownCount: Int = 0
    @State private var _isScrollingDown = false
    
    @State private var _defaultHeight: CGFloat = 0
    
    private let _scrollThreshold = 10
    private let _animation = Animation.easeOut(duration: 0.2)
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(.vertical) {
                ZStack {
                    GeometryReader { proxy in
                        let offset = proxy.frame(in: .named("scroll")).minY
                        Color.clear.preference(key: ViewOffsetKey.self, value: offset)
                    }
                    content[_currentIndex]
                }
            }
            .onPreferenceChange(ViewOffsetKey.self) { value in
                _handleScroll(value: value)
            }
            if (_isScrollingDown == false) {
                _topBar
                    
            } else {
                _bottomBar
            }
        }
    }
    
    private var _topBar: some View {
        HStack {
            ForEach(tabItems.indices) { index in
                Button(action: {
                    print(tabItems[index].title)
                    _currentIndex = index
                }) {
                        VStack(spacing: 3) {
                            Image(systemName: tabItems[index].icon)
                            if index == _currentIndex {
                                Text(tabItems[index].title)
                                    .font(.system(.caption))
                                    .matchedGeometryEffect(id: "Text", in: _namespace)
                            } else {
                                Text(tabItems[index].title)
                                    .font(.system(.caption))
                            }
                        }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .foregroundColor(.accentColor)
        .padding(.horizontal, 16)
        .frame(height: 50)
        .background(Material.regular)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .padding(.horizontal, 20)
        .shadow(color: Color.black.opacity(0.3), radius: 10)
        .matchedGeometryEffect(id: "Shape", in: _namespace)
        .padding(.bottom, 18)
    }
    
    private var _bottomBar: some View {
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
            Text(tabItems[_currentIndex].title)
                .font(.system(size: 12))
                .matchedGeometryEffect(id: "Text", in: _namespace)
        }
        .matchedGeometryEffect(id: "Shape", in: _namespace)
        .ignoresSafeArea()
        .frame(height: 15)
    }
    
    private func _handleScroll(value: ViewOffsetKey.Value) {
        if _defaultHeight == 0 {
            _defaultHeight = value
        }
        _scrollOffset = value - _defaultHeight
        _velocity = _scrollOffset - _scrollOffsetPrevious
        if _velocity >= 1 && _scrollingDownCount > -_scrollThreshold {
            _scrollingDownCount -= 1
        } else if _velocity < -1 && _scrollingDownCount < _scrollThreshold {
            _scrollingDownCount += 1
        }
        
        
        if (_scrollingDownCount >= _scrollThreshold || _velocity < -50) && _scrollOffset < 0 {
            withAnimation(_animation) {
                _isScrollingDown = true
            }
        } else if _scrollingDownCount <= -_scrollThreshold / 2 || _velocity > 50 || _scrollOffset >= 0 {
            withAnimation(_animation) {
                _isScrollingDown = false
            }
        }
        _scrollOffsetPrevious = value - _defaultHeight
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

struct TabBarItem {
    var title: String
    var icon: String
}

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

