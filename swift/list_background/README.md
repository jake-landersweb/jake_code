# Custom List Background

SwiftUI currently has no way for a user to change the background in a list. This can become a problem when designing an app that has a colorscheme to preserve. But with just a little code, a view modifier, and some UIKit, we can overcome this shortcoming. 

Here is an example of the final product in use:

<img src="http://www.jakelanders.com/wp-content/uploads/2020/12/list_background.png" width="250">

And here is what this implementation looks like in code

```swift
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
```

> Note I use a custom Nav Controller that has less visual issues compared to the native one. The article where I showed how to make that is [here.](http://www.jakelanders.com/swiftui/swiftui-custom-navigation/)

## View Modifier

First, we need to define a view modifier. This is a more simple implementation of a ViewBuilder, which is used to compose more dynamic views.

This view modifier needs four parameters:
1. (REQUIRED) the number of items the entire list contains
2. (REQUIRED) the index of the sepcific cell
3. (optional) the background of the cell, defaults to white
4. (optional) the corner radius of the cell, defaults to 10

```swift
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
```

From the code, you can see that there are certain things about the view that are different based on the index of the cell in relation to the item count. This is because we only want the cells to have rounded corners if it is the first or last in the cell block.

## Custom Shape

This view also used a custom shape to allow for rounding of certain corners as well

```swift
// custom shape for rounding specific corners
struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
```

This custom shape can round any combo of corners on any view. 

And that is it! a list that can have its background change color.

## Source Code

(Github Link)[https://github.com/jake-landersweb/jake_code/blob/main/swift/list_background/ListBackground.swift]
