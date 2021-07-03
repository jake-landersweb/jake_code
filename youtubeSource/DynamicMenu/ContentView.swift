//
//  ContentView.swift
//  Dynamic Menu
//
//  Created by Jake Landers on 7/2/21.
//

import SwiftUI

struct ContentView: View {
    @StateObject var controller = MenuController()
    
    var body: some View {
        ZStack {
            // menu
            HStack {
                Menu(controller: controller)
                Spacer(minLength: 0)
            }
            // presented view
            ZStack {
                switch controller.selectedPage {
                case 0:
                    Page1(controller: controller)
                case 1:
                    Page2(controller: controller)
                case 2:
                    Page3(controller: controller)
                default:
                    Text("")
                }
            }
            // offset...
            .offset(x: controller.offset)
        }
        // gesture time...
        // high priority to prevent choppyness when scrolling...
        .highPriorityGesture(
        DragGesture().onChanged { value in
            if controller.isOpen {
                // when menu is open, let user drag anywhere to close it
                if value.location.x > 0 && controller.offset > 0 {
                    controller.offset = UIScreen.main.bounds.width * controller.openPercent + value.translation.width
                }
            } else {
                // when menu is closed we need to make sure the gesture is a pan gesture and not let the user over open
                if value.startLocation.x <= 20 && value.location.x < UIScreen.main.bounds.width * controller.openPercent {
                    controller.offset = value.translation.width
                }
            }
        }.onEnded { value in
            // need to write code for when gesture ends...
            if controller.offset < UIScreen.main.bounds.width * controller.openPercent / 2 {
                // if the user open/ closes the menu less than half of the width of the menu, close it
                controller.close()
                controller.isOpen = false
            } else {
                // open it
                controller.open()
                controller.isOpen = true
            }
        }
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct Menu: View {
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var controller: MenuController
    
    var body: some View {
        ZStack {
            // for background
            Group {
                colorScheme == .light ? Color.white : Color.white.opacity(0.1)
            }
            .edgesIgnoringSafeArea(.all)
            ScrollView {
                VStack {
                    Button(action: {
                        controller.selectedPage = 0
                        controller.close()
                    }, label: {
                        MenuItem(title: "Page 1", icon: "1.circle", index: 0, selectedIndex: $controller.selectedPage)
                    })
                    Button(action: {
                        controller.selectedPage = 1
                        controller.close()
                    }, label: {
                        MenuItem(title: "Page 2", icon: "2.circle", index: 1, selectedIndex: $controller.selectedPage)
                    })
                    Button(action: {
                        controller.selectedPage = 2
                        controller.close()
                    }, label: {
                        MenuItem(title: "Page 3", icon: "3.circle", index: 2, selectedIndex: $controller.selectedPage)
                    })
                }
            }
        }
        .frame(width: UIScreen.main.bounds.width * controller.openPercent)
    }
}

struct MenuItem: View {
    @Environment(\.colorScheme) var colorScheme
    
    let title: String
    let icon: String
    let index: Int
    @Binding var selectedIndex: Int
    
    var body: some View {
        Label(title, systemImage: icon)
            .foregroundColor(index == selectedIndex ? Color.white : colorScheme == .light ? Color.black : Color.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(index == selectedIndex ? Color.accentColor : Color.clear))
            .padding(.horizontal)
    }
}

// Pages...
// add menu button to all....
struct Page1: View {
    @ObservedObject var controller: MenuController
    var body: some View {
        NavigationView {
            List {
                ForEach(0..<25) { item in
                    Text("\(item)")
                }
            }
            .navigationTitle("Page 1")
            .navigationBarItems(leading: controller.button)
        }
    }
}
struct Page2: View {
    @ObservedObject var controller: MenuController
    var body: some View {
        NavigationView {
            List {
                ForEach(0..<25) { item in
                    Text("\(item)")
                }
            }
            .navigationTitle("Page 2")
            .navigationBarItems(leading: controller.button)
        }
    }
}
struct Page3: View {
    @ObservedObject var controller: MenuController
    var body: some View {
        NavigationView {
            List {
                ForEach(0..<25) { item in
                    Text("\(item)")
                }
            }
            .navigationTitle("Page 3")
            .navigationBarItems(leading: controller.button)
        }
    }
}
