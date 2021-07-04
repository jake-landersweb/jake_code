//
//  SheetController.swift
//  Multiple Sheets
//
//  Created by Jake Landers on 7/4/21.
//

import Foundation
import SwiftUI

class SheetController: ObservableObject {
    @Published var showSheet: Bool = false
    @Published var showHome: Bool = false
    
    enum Sheet {
        case none
        case login(controller: SheetController)
        case createAccount(controller: SheetController)
    }
    
    var sheet: Sheet = .none {
        didSet {
            // every time this variable is changed, the sheet will open
            showSheet = true
        }
    }
    
    // TODO -- actual sheet view
    func sheetView() -> AnyView {
        switch sheet {
        case .none: return AnyView(EmptyView())
        case .login(controller: let controller): return AnyView(Login(controller: controller, isCreate: false))
        case .createAccount(controller: let controller): return AnyView(Login(controller: controller, isCreate: true))
        }
    }
}
