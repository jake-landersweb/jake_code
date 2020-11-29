# Lists in SwiftUI

Lists are an extremely versitile view used extensively in swiftui. There are many creative ways to leverage the power that they supply.

## To construct a simple list:
```swift
List(0..<20, id: \.self) { i in
    Text("\(i)")
}
```

<img src="http://www.jakelanders.com/wp-content/uploads/2020/11/lists_1.png" width="150">

## You can also use a for each loop like:
```swift
List {
    ForEach(0..<20, id: \.self) { i in
        Text("\(i)")
    }
}
```

## You can use modifiers on the list to give a more custom look:
```swift
List {
    ForEach(0..<20, id: \.self) { i in
        Text("\(i)")
    }
}
.listStyle(InsetGroupedListStyle())
```

<img src="http://www.jakelanders.com/wp-content/uploads/2020/11/lists_2.png" width="150">

## Drag and Drop, Editing, and Deleteing:
If you would like to add drag and drop / delete functionality to a list, you will need to do the following:

- create a delete function
- create a move function
- add those functions to modifiers onto the **FOREACH**
- Add a variable to control the editing function as a modifier on the **LIST**

### First initialize an array:
```swift
@State var items: [Int] = [1,2,3,4,5,6,7,8,9,10]
```

### Next, create a variable to hold the edit mode:
```swift
@State var edit = EditMode.inactive
```

### Then, write methods for deleting and moving:
```swift
private func onMove(source: IndexSet, destination: Int) {
    // move from source to destination
    items.move(fromOffsets: source, toOffset: destination)
}

private func onDelete(offsets: IndexSet) {
    // remove at offset
    items.remove(atOffsets: offsets)
}
```

### Lastly, add the views as modifiers as views onto the list and foreach:
```swift
NavigationView {
    List {
        ForEach(items, id: \.self) { i in
            Text("\(i)")
        }
        .onMove(perform: onMove)
        .onDelete(perform: onDelete)
    }
    .listStyle(InsetGroupedListStyle())
    .environment(\.editMode, $edit)
    .navigationTitle("Lists")
    .navigationBarItems(leading:
        Button(edit == .inactive ? "Edit" : "Done", action: {
            // toggle the edit button
            withAnimation(.spring()) {
                if edit == .inactive {
                    edit = .active
                } else {
                    edit = .inactive
                }
            }
    }))
}
```
*note, you can also just use EditButton() as the navigation button view, but making your own gives you more flexibility over what happens when edit is toggled*

## Selecting:
If you want to implement selection functionality into your list, it is very simple.

```swift
@State var selected = Set<Int>()
```

### Then, add that state variable into the selection field for the list
```swift
List(selection: $selected) {
    ...
}
```

Then, you can use that information to show the user what has been selected like:
```swift
Text("\(i)")
    .foregroundColor(selected.contains(i) ? Color.blue : Color.white)
```

## Final Product
[Watch Video *(local link)*](http://www.jakelanders.com/wp-content/uploads/2020/11/lists_video.mp4)

### Full Code:
[Github Link](https://github.com/jake-landersweb/jake_code/blob/main/swift/lists/Lists.swift)