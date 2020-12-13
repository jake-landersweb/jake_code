//
//  CustomListSwipe.swift
//
//  Created by Jake Landers on 12/12/20.
//
//  An example of my Swipable Menu Item in action. Fully self contained code.
//  Lisence: GNU

import Foundation
import SwiftUI

struct CustomListSwipe: View {
    @State var items: [Date] = []
    
    private var backgroundColor = Color.init(red: 240 / 255, green: 240 / 255, blue: 245 / 255, opacity: 1)
    
    var body: some View {
        ZStack {
            backgroundColor.edgesIgnoringSafeArea(.all)
            NavController("Custom List", trailing: AnyView(Button("Add", action: { withAnimation { items.append(Date()) } })), color: backgroundColor) {
                ScrollView {
                    VStack(spacing: 15) {
                        ForEach(items, id:\.self) { i in
                            SwipeableMenuCell(
                                actions: [{ remove(i) }, { print("edit") }, { print("add") }],
                                actionViews: [ deleteView(), editView(), addView()]
                            ) {
                                ZStack {
                                    Color.white
                                    Text("\(i)")
                                }
                                .frame(height: 100)
                            }
                            .transition(AnyTransition.scale)
                        }
                    }
                    .padding([.horizontal, .bottom], 15)
                    .frame(width: UIScreen.main.bounds.width)
                }
            }
        }
    }
    
    private func deleteView() -> AnyView {
        return AnyView(
            ZStack {
                Color.red
                Image(systemName: "xmark").foregroundColor(Color.white)
            }
        )
    }
    
    private func editView() -> AnyView {
        return AnyView(
            ZStack {
                Color.yellow
                Text("Edit").foregroundColor(Color.white)
            }
        )
    }
    
    private func addView() -> AnyView {
        return AnyView(
            ZStack {
                Color.blue
                Image(systemName: "plus").foregroundColor(Color.white)
            }
        )
    }
    
    private func remove(_ item: Date) {
        withAnimation {
            items.removeAll(where: { $0 == item })
        }
    }
}

/*
 A slideable cell meant to be used in a swift ForEach WITHOUT a list. This adds
 the ability to easily add cell context options. It takes two required parameters.
 An array of actions [actions] the menu will perform, and an array of views [actionViews]
 those actions will be represented as. The arrays are reversed and corresponding,
 which means that the first item specified in each array will be the leftmost in
 the menu.
 */
struct SwipeableMenuCell<Content>: View where Content : View {
    
    var content: () -> Content
    
    /*
     An array of the actions you want the menu to perform, from right to left.
     I.E. first action in array is leftmost button.
     This corresponds with the actionView array, so put the actions with
     the buttons in the same order.
     */
    var actions: [() -> Void]
    
    /*
     An Array of views that will represent the clickable buttons
     behind the specified cell. This allows for maximum flexibility.
     The menu will be able to handle infinite views, but realistically
     the maximum will be around 3 - 4. I did not cap this to give
     people more flexibility.
     */
    var actionViews: [Any]
    
    /*
     This view assumes your views are rectangle (and they should be) due
     to the offset this view applies. So, if you want corner radius in your
     views, specify it here. This option defaults to the .continuous style
     for a rounded rectangle, if you want classic rounded corners then
     change it in the two places below.
     */
    var cornerRadius: CGFloat?
    
    /*
     internal variable used for caluclating how far the cell should slide, and how
     far one needs to slide to open / close the menu.
     */
    var menuWidth: CGFloat
    
    init?(actions: [() -> Void], actionViews: [Any], cornerRadius: CGFloat?=20, @ViewBuilder content: @escaping () -> Content) {
        // required
        self.actions = actions.reversed()
        self.actionViews = actionViews.reversed()
        //optional
        self.cornerRadius = cornerRadius
        // content
        self.content = content
        self.menuWidth = CGFloat(actionViews.count) * UIScreen.main.bounds.width / 6
    }
    
    // interal variables used for offset calculation
    @State var offset: CGFloat = 0
    @State var cachedOffset: CGFloat = 0
    @State var isOpen = false
    
    var body: some View {
        ZStack {
            // array of action buttons
            HStack(spacing: 0) {
                Spacer(minLength: 0)
                ForEach(actionViews.indices) { i in
                    Button(action: {
                        actions[i]()
                    }, label: {
                        AnyView(_fromValue: actionViews[i]).lineLimit(1)
                    })
                    .frame(width: -offset >= 0 ? -offset / CGFloat(actionViews.count) : 0)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius!, style: .continuous))
            // content user specifies
            content()
                .clipShape(RoundedRectangle(cornerRadius: -offset >= 0 ? cornerRadius! + offset / 2 : cornerRadius!, style: .continuous))
                .offset(x: offset)
                // dragability
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            // when menu is already open
                            if isOpen {
                                // if trying to open more, dampen the opening effect
                                if value.translation.width < 0 {
                                    offset = value.translation.width / 3 + cachedOffset
                                } else if value.translation.width < -cachedOffset {
                                    offset = value.translation.width + cachedOffset
                                }
                            } else {
                                // if user swiping left
                                if value.translation.width < 0 {
                                    offset = value.translation.width
                                }
                            }
                        }
                        .onEnded { value in
                            if offset < -menuWidth / 2 {
                                open()
                            } else {
                                close()
                            }
                        }
                )
                // allow tap to close
                .onTapGesture {
                    if isOpen {
                        close()
                    }
                }
        }
    }
    
    private func open() {
        withAnimation(.spring()) {
            offset = -menuWidth
        }
        cachedOffset = -menuWidth
        isOpen = true
    }
    
    private func close() {
        withAnimation(.spring()) {
            offset = 0
        }
        isOpen = false
    }
}
