//
//  ContentView.swift
//  FancySlideMenu
//
//  Created by Jake Landers on 7/19/21.
//

import SwiftUI

struct ContentView: View {
    @StateObject var client = Client()
    
    var body: some View {
        TabView {
            ImageList(images: $client.shibes, title: "Shibes")
                .tabItem {
                    Label("Shibes", systemImage: "bolt")
                }
                .task {
                    await client.fetchShibes()
                }
            ImageList(images: $client.birds, title: "Birds")
                .tabItem {
                    Label("Birds", systemImage: "flame")
                }
                .task {
                    await client.fetchBirds()
                }
            ImageList(images: $client.cats, title: "Cats")
                .tabItem {
                    Label("Cats", systemImage: "leaf")
                }
                .task {
                    await client.fetchCats()
                }
        }
    }
}

struct ImageList: View {
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var images: [String]?
    var title: String
    
    var body: some View {
        NavigationView {
            Group {
                if images != nil {
                    ScrollView {
                        LazyVStack(spacing: 15) {
                            ForEach(images!, id:\.self) { image in
                                AsyncImage(url: URL(string: image)) { phase in
                                    if let image = phase.image {
                                        image.resizable().aspectRatio(contentMode: .fit)
                                    } else if phase.error != nil {
                                        // error
                                        Color.red
                                    } else {
                                        // placeholder
                                        ImagePlaceHolder()
                                    }
                                }
                                .frame(height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                                .padding(.horizontal)
                            }
                        }
                    }
                    .background(colorScheme == .light ? Color(red: 245/255, green: 245/255, blue: 250/255, opacity: 1) : Color.black)
                } else {
                    ProgressView()
                }
            }
            .navigationTitle(title)
        }
    }
}

struct ImagePlaceHolder: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            colorScheme == .light ? Color.black.opacity(0.3) : Color.white.opacity(0.3)
            ProgressView()
        }
        .opacity(isAnimating ? 0.5 : 1)
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 0.8).repeatForever()) {
                isAnimating = true
            }
        }
        .onDisappear {
            isAnimating = false
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
