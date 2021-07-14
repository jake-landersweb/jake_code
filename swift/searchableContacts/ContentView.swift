//
//  ContentView.swift
//  SearchableContacts
//
//  Created by Jake Landers on 7/13/21.
//

import SwiftUI

struct ContentView: View {
    @StateObject var client = Client()
    
    @State private var search = ""
    
    var body: some View {
        NavigationView {
            List {
                switch client.loadingStatus {
                case .loading:
                    ForEach(0..<25) { item in
                        ContactLoadCell()
                    }
                case .success:
                    ForEach(searchResults, id: \.email) { contact in
                        ContactCell(contact: contact)
                    }
                case .error:
                    Text("Error")
                }
            }
            .navigationTitle("Contacts")
            .refreshable {
                await client.fetchData()
            }
            .searchable(text: $search) {
                
            }
        }
        .environmentObject(client)
    }
    
    var searchResults: [Contact] {
        if client.contacts == nil {
            return []
        } else if search.isEmpty {
            return client.contacts!
        } else {
//            return client.contacts!.filter { $0.first.contains(search) || $0.last.contains(search) }
            return client.contacts!.filter { $0.email.contains(search.lowercased()) || $0.phone.contains(search) }
        }
    }
}

struct ContactCell: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var client: Client
    
    var contact: Contact
    
    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(Color.random())
                    .frame(width: 60, height: 60)
                Text("\(String(contact.first.uppercased().prefix(1)))")
                    .font(.system(.title))
                    .foregroundColor(Color.white)
            }
            VStack(alignment: .leading) {
                Text("\(contact.first) \(contact.last)")
                    .font(.system(.headline))
                Group {
                    Text("\(contact.email)")
                        .font(.system(.caption))
                    Text("\(contact.phone)")
                        .font(.system(.caption))
                }
                .foregroundColor(colorScheme == .light ? Color.black.opacity(0.7) : Color.white.opacity(0.7))
            }
        }
    }
}

struct ContactLoadCell: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var client: Client
    
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .frame(width: 60, height: 60)
            VStack(alignment: .leading) {
                Capsule()
                    .frame(height: 10)
                Capsule()
                    .frame(width: UIScreen.main.bounds.width / 3, height: 10)
            }
        }
        .opacity(isAnimating ? 0.5 : 1)
        .foregroundColor(colorScheme == .light ? Color.black.opacity(0.3) : Color.white.opacity(0.3))
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
