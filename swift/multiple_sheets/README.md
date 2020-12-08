# Multiple Sheets in SwiftUI

I find it slightly strange that a view can only have one sheet attached to it at a time. It seems there would be many use cases where having one, two, or even more sheets attached to a single screen would be useful. Let's get into it.

### Final Product

[Website Link](http://www.jakelanders.com/wp-content/uploads/2020/12/multiple_sheets.mp4)

### Create a generic View

```swift
struct MultipleSheets: View {
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            VStack(spacing: 20) {
                Button("Sheet 1") {
                    // open sheet 1
                }
                Button("Sheet 2") {
                    // open sheet 2
                }
                Button("Sheet 3") {
                    // open sheet 3
                }
                Button("Sheet 4") {
                    // open sheet 4
                }
            }
            .foregroundColor(Color.white)
        }
    }
}
```

### Defining an Observable Object class

The way we are going to communicate which sheet should be opening, we will define an Observable Object for the view to subscribe to.

This is denoted by the 'ObservableObject' type

```swift
class MultipleSheetsModel: ObservableObject {
    
}
```

In the class, define an enum with the different values corresponding to the views you want to show.

```swift
enum SheetDestination {
        case none, sheet1, sheet2, sheet3, sheet4
    }
```

> Note: none is to allow for safe initialization

> Also note: You are able to define types you want to pass with this denotion

```swift
sheet4(name: String)
```

### Populating the class

Now, you can define a sheet destination variable,  and a bool whether to show the sheet or not.

```swift
@Published var showSheet = false
@Published var sheetDestination = SheetDestination.none
```

When you think about the functionality we are going for here, it is reasonable to assume you want to sheet open when you set the sheetDestination variable, so lets implement that as well

```swift
@Published var sheetDestination = SheetDestination.none {
    didSet {
        showSheet = true
    }
}
```

### View presentation function

Now we need a function that will return a view based on the sheet selection chosen.

```swift
func currentSheet(destination: SheetDestination) -> AnyView {
    switch destination {
    case .sheet1:
        return AnyView(Sheet1())
    case .sheet2:
        return AnyView(Sheet2())
    case .sheet3:
        return AnyView(Sheet3())
    case .sheet4(name: let name):
        return AnyView(Sheet4(name: name))
    case .none:
        return AnyView(Text("None"))
    }
}
```

> Note: The views have a return type of 'AnyView' and not 'some View' because the views are of different types

### Attach model to view

Lastly, we can attach the model to the view with a StateObject and launch the sheet

```swift
struct MultipleSheets: View {
    
    @StateObject var model = MultipleSheetsModel()
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            VStack(spacing: 20) {
                Button("Model 1") {
                    // open model 1
                    model.sheetDestination = .sheet1
                }
                Button("Model 2") {
                    // open model 2
                    model.sheetDestination = .sheet2
                }
                Button("Model 3") {
                    // open model 3
                    model.sheetDestination = .sheet3
                }
                Button("Model 4") {
                    // open model 4
                    model.sheetDestination = .sheet4(name: "This is model 4")
                }
            }
            .foregroundColor(Color.white)
        }
        .sheet(isPresented: $model.showSheet, content: { model.currentSheet(destination: model.sheetDestination) })
    }
}
```

And thats it! You now have multiple models in your project.

### Source Code

[Github Link](https://github.com/jake-landersweb/jake_code/blob/main/swift/multiple_sheets/MultipleSheets.swift)











