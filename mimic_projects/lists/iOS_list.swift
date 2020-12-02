import SwiftUI

struct Lists: View {
    @State var items: [ListItem] = []
    
    // get light or dark mode
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            List {
                ForEach(items, id: \.id) { i in
                    Text("Row \(i.index)")
                        .frame(height: 50)
                }
                .onMove(perform: onMove)
                .onDelete(perform: onDelete)
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Lists")
            .navigationBarItems(leading: EditButton(), trailing: addItem)
        }
    }
    
    private var addItem: some View {
        Button("Add", action: {
            withAnimation {
                items.append(ListItem(index: items.count))
            }
        })
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

struct ListItem {
    var id = UUID()
    var index: Int
}
