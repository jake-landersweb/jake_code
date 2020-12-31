import Foundation
import SwiftUI

struct ListBackground: View {
    @State var items = Array(repeating: Date(), count: 10)
    
    let backgroundColor = Color(.sRGB, red: 240 / 255, green: 240 / 255, blue: 245 / 255, opacity: 1)
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundColor.edgesIgnoringSafeArea(.all)
                NavController("Custom Background", color: backgroundColor) {
                    VStack(spacing: 0) {
                        ForEach(items.indices) { item in
                            Text("Item: \(item)")
                                .customCell(itemCount: items.count, index: item, backgroundColor: Color.green)
                        }
                    }
                    .padding(.horizontal, 15)
                }
            }
        }
    }
}

struct CustomListCell: ViewModifier {
    // number of items in collection
    var itemCount: Int
    // index this specific cell is at
    var index: Int
    // color of the cell
    var backgroundColor: Color
    // corner radius
    var cornerRadius: CGFloat
    
    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            content
                .padding()
                .frame(maxWidth: .infinity)
            if index < itemCount - 1 {
                Divider().padding(.leading, 15)
            }
        }
        .background(backgroundColor)
        .clipShape(index == 0 ? RoundedCorner(radius: cornerRadius, corners: [.topLeft, .topRight]) : index >= itemCount - 1 ? RoundedCorner(radius: cornerRadius, corners: [.bottomLeft, .bottomRight]) : RoundedCorner(radius: 0, corners: [.allCorners]))
    }
}

extension View {
    func customCell(itemCount: Int, index: Int, backgroundColor: Color? = Color.white, cornerRadius: CGFloat? = 10) -> some View {
        self.modifier(CustomListCell(itemCount: itemCount, index: index, backgroundColor: backgroundColor!, cornerRadius: cornerRadius!))
    }
}

// custom shape for rounding specific corners
struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
