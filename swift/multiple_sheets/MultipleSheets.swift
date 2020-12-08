import SwiftUI

class MultipleSheetsModel: ObservableObject {
    enum SheetDestination {
        case none, sheet1, sheet2, sheet3, sheet4(name: String)
    }
    
    @Published var showSheet = false
    @Published var sheetDestination = SheetDestination.none {
        didSet {
            showSheet = true
        }
    }
    
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
}

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

struct Sheet1: View {
    var body: some View {
        ZStack {
            Color.red.edgesIgnoringSafeArea(.all)
            Text("Sheet 1").foregroundColor(Color.white)
        }
    }
}

struct Sheet2: View {
    var body: some View {
        ZStack {
            Color.yellow.edgesIgnoringSafeArea(.all)
            Text("Sheet 2").foregroundColor(Color.white)
        }
    }
}

struct Sheet3: View {
    var body: some View {
        ZStack {
            Color.green.edgesIgnoringSafeArea(.all)
            Text("Sheet 3").foregroundColor(Color.white)
        }
    }
}

struct Sheet4: View {
    var name: String
    var body: some View {
        ZStack {
            Color.blue.edgesIgnoringSafeArea(.all)
            Text(name).foregroundColor(Color.white)
        }
    }
}
