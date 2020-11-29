# Lists in SwiftUI

Lists are an extremely versitile view used extensively in swiftui. There are many creative ways to leverage the power that they supply.

### To construct a simple list:
<pre><code>
List(0..<20, id: \.self) { i in
    Text("\(i)")
}
</code></pre>

<img src="http://www.jakelanders.com/wp-content/uploads/2020/11/lists_1.png" width="150">

### You can also use a for each loop like:
<pre><code>
List {
    ForEach(0..<20, id: \.self) { i in
        Text("\(i)")
    }
}
</code></pre>

### You can use modifiers on the list to give a more custom look:
<pre><code>
List {
    ForEach(0..<20, id: \.self) { i in
        Text("\(i)")
    }
}
.listStyle(InsetGroupedListStyle())
</code></pre>

<img src="http://www.jakelanders.com/wp-content/uploads/2020/11/lists_2.png" width="150">

### Drag and Drop, Editing, and Deleteing:
If you would like to add drag and drop / delete functionality to a list, you will need to do the following:

- create a delete function
- create a move function
- add those functions to modifiers onto the **FOREACH**
- Add a variable to control the editing function as a modifier on the **LIST**

#### First initialize an array:
<pre><code>
@State var items: [Int] = [1,2,3,4,5,6,7,8,9,10]
</code></pre>

#### Next, create a variable to hold the edit mode:
<pre><code>
@State var edit = EditMode.inactive
</code></pre>

#### Then, write methods for deleting and moving:
<pre><code>
private func onMove(source: IndexSet, destination: Int) {
    // move from source to destination
    items.move(fromOffsets: source, toOffset: destination)
}

private func onDelete(offsets: IndexSet) {
    // remove at offset
    items.remove(atOffsets: offsets)
}
</code></pre>

#### Lastly, add the views as modifiers as views onto the list and foreach:
<pre><code>
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
</code></pre>
*note, you can also just use EditButton() as the navigation button view, but making your own gives you more flexibility over what happens when edit is toggled*

### Selecting:
If you want to implement selection functionality into your list, it is very simple.

#### First, initilize a set to hold the selected items:
<pre><code>
@State var selected = Set<Int>()
</code></pre>

#### Then, add that state variable into the selection field for the list
<pre><code>
List(selection: $selected) {
    ...
}
</code></pre>

Then, you can use that information to show the user what has been selected like:
<pre><code>
Text("\(i)")
    .foregroundColor(selected.contains(i) ? Color.blue : Color.white)
</code></pre>

### Final Product
[Watch Video *(local link)*](http://www.jakelanders.com/wp-content/uploads/2020/11/lists_video.mp4)

### Full Code:
<pre><code>
import SwiftUI

struct Lists: View {
    
    @State var items: [Int] = [1,2,3,4,5,6,7,8,9,10]
    @State var edit = EditMode.inactive
    
    @State var selected = Set<Int>()
    
    var body: some View {
        NavigationView {
            List(selection: $selected) {
                ForEach(items, id: \.self) { i in
                    Text("\(i)")
                        .foregroundColor(selected.contains(i) ? Color.blue : Color.white)
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
    }
    
    private func onMove(source: IndexSet, destination: Int) {
        // move from source to destination
        items.move(fromOffsets: source, toOffset: destination)
    }
    
    private func onDelete(offsets: IndexSet) {
        // remove at offset
        items.remove(atOffsets: offsets)
    }
}
</code></pre>