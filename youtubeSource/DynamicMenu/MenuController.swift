//
//  MenuController.swift
//  Dynamic Menu
//
//  Created by Jake Landers on 7/2/21.
//

import Foundation
import SwiftUI

class MenuController: ObservableObject {
    let openPercent = 0.5
    
    @Published var offset: CGFloat = 0
    @Published var isOpen: Bool = false
    @Published var selectedPage: Int = 0
    
    func open() {
        withAnimation(.spring()) {
            offset = UIScreen.main.bounds.width * openPercent
        }
        isOpen = true
    }
    
    func close() {
        withAnimation(.spring()) {
            offset = 0
        }
        isOpen = false
    }
    
    var button: some View {
        Button(action: {
            if self.isOpen {
                self.close()
            } else {
                self.open()
            }
        }, label: {
            Image(systemName: isOpen ? "xmark" : "text.justify")
        })
    }
}
