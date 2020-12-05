import SwiftUI

struct DynamicPageView: View {
    @State var colors = [Color.red, Color.orange, Color.yellow, Color.green, Color.blue, Color.purple]
    
    var body: some View {
        PageView(viewCount: colors.count) {
            ForEach(colors, id:\.self) { color in
                color.frame(width: UIScreen.main.bounds.width)
            }
        }
    }
}

struct PageView<Content>: View where Content : View {
    
    var content: () -> Content
    
    var viewCount: Int
    
    var darkIndicator: Bool = true
    
    init?(viewCount: Int, darkIndicator: Bool? = true, @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.viewCount = viewCount
        
        self.darkIndicator = darkIndicator!
    }
    
    @State private var offset: CGFloat = .zero
    @State private var c_offset: CGFloat = .zero
    @State private var lastDragPosition: DragGesture.Value?
    @State private var view_index: Int = 0
    
    private let animation = Animation.spring(response: 0.35, dampingFraction: 0.8, blendDuration: 0.85)
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                HStack(spacing: 0) {
                    content()
                        .offset(x: offset)
                        .gesture(
                            // only have gesture if more than one view
                            viewCount > 1 ? DragGesture(minimumDistance: 10, coordinateSpace: .local)
                            .onChanged { value in
                                if value.translation.width > 0 {
                                    if view_index == 0 {
                                        offset = (value.translation.width / 2) + c_offset
                                    } else {
                                        offset = value.translation.width + c_offset
                                    }
                                } else {
                                    if view_index == viewCount - 1 {
                                        offset = (value.translation.width / 2) + c_offset
                                    } else {
                                        offset = value.translation.width + c_offset
                                    }
                                }
                                // track position for determining swipe speed
                                lastDragPosition = value
                            }
                            .onEnded { value in
                                // for getting swipe velocity
                                let timeDiff = value.time.timeIntervalSince(lastDragPosition!.time)
                                let speed = CGFloat(value.translation.width - lastDragPosition!.translation.width) / CGFloat(timeDiff)
                                // screen going right
                                if value.translation.width < 0 {
                                    // if the translation is more than 0.5 screen, or swipe was fast enough, and not at the end
                                    if -(value.translation.width) > UIScreen.main.bounds.width * 0.5 && view_index < viewCount - 1 || -speed > 500 && view_index < viewCount - 1 {
                                        // set the offset to move to next page
                                        withAnimation(animation) {
                                            offset = c_offset - geo.size.width
                                            view_index += 1
                                        }
                                        // cache the offset
                                        c_offset = offset
                                    } else {
                                        // set the offset to the old offset
                                        withAnimation(animation) {
                                            offset = c_offset
                                        }
                                    }
                                }
                                // screen going left
                                else {
                                    // if more than half screen, or fast enough, and not at the end of the screen
                                    if value.translation.width > UIScreen.main.bounds.width * 0.5 && view_index > 0 || speed > 500 && view_index > 0 {
                                        // move the view by a screen
                                        withAnimation(animation) {
                                            offset = c_offset + geo.size.width
                                            view_index -= 1
                                        }
                                        c_offset = offset
                                    } else {
                                        withAnimation(animation) {
                                            offset = c_offset
                                        }
                                    }
                                }
                            }
                            : nil
                        )
                }
                .frame(width: CGFloat(viewCount) * geo.size.width, alignment: .leading)
                .offset(x: geo.size.width * CGFloat((viewCount) / 2) - (viewCount % 2 == 0 ? (geo.size.width / 2) : 0))
                if viewCount > 1 {
                    Group {
                        if viewCount > 9 {
                            custom_view_counter
                        } else {
                            default_view_counter
                        }
                    }
                    .padding(10)
                    .background(darkIndicator ? Color.black.opacity(0.2) : Color.white.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                    .padding(.bottom, 25)
                }
            }
            .frame(width: geo.size.width)
        }
        .edgesIgnoringSafeArea(.all)
    }
    // view for default page counter indicator
    var default_view_counter: some View {
        HStack(spacing: 10) {
            ForEach(0..<viewCount) { i in
                Circle()
                    .frame(width: 8, height: 8)
                    .foregroundColor(view_index == i ? (darkIndicator ? Color.black : Color.white) : (darkIndicator ? Color.black.opacity(0.4) : Color.white.opacity(0.4)))
            }
        }
    }
    
    // custom number based view counter
    var custom_view_counter: some View {
        Text("\(view_index + 1)/\(viewCount)")
            .font(.system(size: 18, weight: .medium, design: .monospaced))
            .foregroundColor(darkIndicator ? Color.black.opacity(0.9) : Color.white.opacity(0.9))
    }
}