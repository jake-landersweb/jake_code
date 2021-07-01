//
//  DoubleColumnNavView.swift
//
//  Created by Jake Landers on 6/30/21.
//
//  For fixing apple's default implementation of the split view nav view.

import Foundation
import SwiftUI

struct iPadHome: View {
    @EnvironmentObject var dmodel: DataModel
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
