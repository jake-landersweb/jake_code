import SwiftUI
 
    struct CustomNav: View {
        var body: some View {
            // to get page functionality
            NavigationView {
                // custom nav bar
                NavController("Test", leading: leading(), trailing: trailing()) {
                    NavigationLink(destination: SecondPage()) {
                        Text("Another Nav Page")
                    }
                    NavigationLink(destination: Text("Third Page")) {
                        Text("No Nav Page")
                    }
                }
            }
        }
 
        // nav buttons
        private func leading() -> AnyView {
            return AnyView(
                Button("Edit") {
                    print("leading")
                }
            )
        }
        private func trailing() -> AnyView {
            return AnyView(
                Button(action: {
                    print("plus")
                }, label: {
                    Image(systemName: "plus")
                })
            )
        }
    }
 
    struct SecondPage: View {
        // get presentation mode
        @Environment(\.presentationMode) var presentationMode
 
        var body: some View {
            NavController("Second Page", leading: back()) {
                Text("This is the second page")
            }
        }
 
        private func back() -> AnyView {
            return AnyView(
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    HStack(spacing: 3) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                })
            )
        }
    }
 
    struct NavController<Content>: View where Content : View {
        // passed content view
        let content: () -> Content
 
        var title: String
        var leading: AnyView?
        var trailing: AnyView?
 
        // for controlling whether the small nav is shown or not
        @State var show = false
 
        // build the content, and fetch all passed variables
        init?(_ title: String, leading: AnyView?=nil, trailing: AnyView?=nil, @ViewBuilder content: @escaping () -> Content) {
            self.content = content
            self.title = title
            // optionals
            self.leading = leading
            self.trailing = trailing
        }
 
        var body: some View {
            ZStack(alignment: .top) {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 15) {
                        LargeNavBar(show: $show, title: title)
                        content()
                    }
                }
                SmallNavBar(show: $show, title: title, leading: leading, trailing: trailing)
            }
            .edgesIgnoringSafeArea(.all)
            .navigationBarHidden(true)
        }
    }
 
    struct LargeNavBar: View {
        // detecting light/dark mode
        @Environment(\.colorScheme) var colorScheme
        // for showing content on the small header
        @Binding var show: Bool
 
        // timer for constantly checking view position
        @State var time = Timer.publish(every: 0.1, on: .current, in: .tracking).autoconnect()
 
        var title: String
 
        var body: some View {
            // get the view size
            GeometryReader { geo in
                // title itself
                VStack {
                    Spacer(minLength: 0)
                    HStack {
                        Text(title)
                            // expand the title size when the user scrolls down, but not when scrolling up
                            .font(.system(size: 35 + (geo.frame(in: .global).minY > 0 ? (geo.frame(in: .global).minY / 30) : 0)))
                            .fontWeight(.bold)
                        Spacer(minLength: 0)
                    }
                }
                .padding([.top, .horizontal])
                // detect when the view goes out of frame
                .onReceive(self.time) { (_) in
                    let y = geo.frame(in: .global).minY
                    // when the title is offscreen
                    if y < -(UIApplication.shared.windows.first?.safeAreaInsets.top == 0 ? 50 : (((UIApplication.shared.windows.first?.safeAreaInsets.top)! + 85) - ((UIApplication.shared.windows.first?.safeAreaInsets.top)! + 35))) + 10 {
                        withAnimation {
                            // show small header title and divider
                            self.show = true
                        }
                    } else {
                        withAnimation {
                            self.show = false
                        }
                    }
                }
            }
            .frame(height: UIApplication.shared.windows.first?.safeAreaInsets.top == 0 ? 100 : ((UIApplication.shared.windows.first?.safeAreaInsets.top)! + 85))
        }
    }
 
    struct SmallNavBar: View {
        // detecting light/dark mode
        @Environment(\.colorScheme) var colorScheme
        // whether it should be shown or not
        @Binding var show: Bool
        // title of the nav bar
        var title: String = ""
        // leading views
        var leading: AnyView?
        // trailing views
        var trailing: AnyView?
 
        // UIKit blur
        let blur = AnyView(VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial)))
 
        var body: some View {
            VStack(spacing: 0) {
                // stack title and buttons
                ZStack {
                    // buttons
                    HStack {
                        leading
                        Spacer(minLength: 0)
                        trailing
                    }
                    // title
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .transition(.opacity)
                        .opacity(show ? 1 : 0)
                }
                // account for different screen shapes (notch)
                .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top == 20 ? 15 : 35)
                .padding(.horizontal)
                // height of the view
                .frame(height: UIApplication.shared.windows.first?.safeAreaInsets.top == 0 ? 50 : ((UIApplication.shared.windows.first?.safeAreaInsets.top)! + 50))
                // blur background if shown, if not, have a see-through neutral color (this helps soften the transition between large nav and small nav)
                .background(show ? blur : colorScheme == .light ? AnyView(Color.white.opacity(0.8)) : AnyView(Color.black.opacity(0.8)))
                // if bar is being shown, add divider for better look
                if show {
                    Divider()
                }
            }
        }
    }
 
    // UIKit blur view
    struct VisualEffectView: UIViewRepresentable {
        var effect: UIVisualEffect?
        func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
        func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
    }
 
    // maintain swipe back functionality on nav bar being hidden
    extension UINavigationController: UIGestureRecognizerDelegate {
        override open func viewDidLoad() {
            super.viewDidLoad()
            interactivePopGestureRecognizer?.delegate = self
        }
 
        public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            return viewControllers.count > 1
        }
    }
