# FIXED iPad Navigation Split View

If you are anything like me, when something doesn't work like it should, then it can be infuriating to work with. This is how I feel about the default implementation of the split screen NavigationView in SwiftUI.

First, it doesnt work when landscape. Which is ridiculous. Second, when using the built in .sideView style, it does not default select the first view you pass to it so you are doomed to always open your app with over 70% of the screen just plain black (100% if landscape).

I tinkered around with the built in options and I could not get the behavior I expected without using UIViewRepresentables. Considering the notes app is the functionality I was going for, this made me upset.

So, I decided to build my own little version:

### PUT VIDEOS HERE


I recreated the side view list style to allow for default views, and auto list selection. As you can see, this also works well in landscape. So how did I do it? I am going to show you, free of charge :)

## Needed Extra Views

First, to make this possible we are going to need some custom views. First, one to hold the icon and title data for your side list, and another to allow for Tuple Views to be passed in the body of the view function to make the use more natural.

```swift
struct LabelItem {
    let title: String
    let icon: String?
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
```

## View Builder

Next, I built this in a view builder so it can be easily used without any modification or having to understand exactly what I am doing to achieve this affect.

```swift
struct DoubleColumnNavView: View {
    let content: [AnyView]
    let labels: [LabelItem]
    
    let menuTitle: String
    
    init<Views>(labels: [LabelItem], menuTitle: String, @ViewBuilder content: @escaping () -> TupleView<Views>) {
        if content().getViews.count < 2 || labels.count < 2 {
            fatalError("!!! Need at least 2 views and 2 labels !!!")
        }
        if content().getViews.count != labels.count {
            fatalError("!!! The amount of views and the amount of labels need to match !!!")
        }
        self.content = content().getViews
        self.labels = labels
        self.menuTitle = menuTitle
    }
    
    @State private var _selectedIndex: Int = 0
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    ForEach(labels.indices) { index in
                        SideBarListItem(label: labels[index], index: index, selectedIndex: $_selectedIndex)
                    }
                    Spacer(minLength: 0)
                }
            }
            .navigationTitle(menuTitle)
            content[_selectedIndex]
        }
    }
}

struct SideBarListItem: View {
    @Environment(\.colorScheme) var colorScheme
    
    var label: LabelItem
    var index: Int
    @Binding var selectedIndex: Int
    
    var body: some View {
        Button(action: {
            selectedIndex = index
        }, label: {
            VStack {
                if label.icon == nil {
                    Text(label.title)
                } else {
                    Label(label.title, systemImage: label.icon!)
                }
            }
            .foregroundColor(index == selectedIndex ? Color.white : colorScheme == .light ? Color.black : Color.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(index == selectedIndex ? Color.accentColor : Color.clear))
            .padding(.horizontal)
        })
    }
}
```

## Usage

Lastly, this is how you use it. You need a list of label items (the struct we defined above) to match the order of the views you pass in the body of the custom view. It will make plenty of sense looking at the code. If you have any questions feel free to comment and I will reply ASAP.

```swift
import Foundation
import SwiftUI

struct iPadHome: View {
    @State private var selectedView: String? = "Login"
    
    let labels: [LabelItem] = [
        LabelItem(title: "Login", icon: "person"),
        LabelItem(title: "Create Account", icon: "person.badge.plus")
    ]
    
    var body: some View {
        DoubleColumnNavView(labels: labels, menuTitle: "Puck Norris") {
            iPadLogin()
            iPadLogin(isCreate: true)
        }
    }
}
```

## Source Code

[Github Link]()