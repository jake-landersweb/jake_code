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
