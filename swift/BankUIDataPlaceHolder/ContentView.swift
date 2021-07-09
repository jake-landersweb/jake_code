//
//  ContentView.swift
//  DataFetchPlaceHolder
//
//  Created by Jake Landers on 7/7/21.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject var client = Client()
    var body: some View {
        NavigationView {
            Group {
                switch client.loadingStatus {
                case .loading:
                    loading
                case .success:
                    success
                case .initial:
                    loading
                case .failure:
                    Text("Failure")
                }
            }
            .navigationTitle("Transactions")
        }
    }
    
    private var success: some View {
        Group {
            if client.account != nil {
                List {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(client.account!.name)
                                .fontWeight(.bold)
                                .font(.system(.title2))
                            HStack {
                                Text("Account Balance:")
                                Spacer(minLength: 0)
                                Text("\(client.account!.currentBalance, specifier: "%.2f")")
                            }
                            .foregroundColor(colorScheme == .light ? Color.black.opacity(0.7) : Color.white.opacity(0.7))
                        }
                    }
                    Section {
                        ForEach(client.account!.transactions, id:\.date) { transaction in
                            VStack {
                                transactionCell(transaction: transaction)
                            }
                        }
                    }
                }
                .refreshable {
                    // if fetching data from the internet, use
//                    await client.fetchData()
                }
            } else {
                Text("There was an unknwon issue")
            }
        }
    }
    
    private func transactionCell(transaction: Transaction) -> some View {
        return HStack(spacing: 10) {
            vendorIcon(name: transaction.vendor)
            VStack(alignment: .leading) {
                Text(transaction.vendor)
                    .font(.system(size: 20, weight: .bold))
                Text(dateFormatter(passedDate: transaction.date))
                    .font(.system(.caption))
                    .foregroundColor(colorScheme == .light ? Color.black.opacity(0.5) : Color.white.opacity(0.5))
            }
            Spacer(minLength: 0)
            Text("\(transaction.type == 0 ? "+" : "-") \(transaction.amount, specifier: "%.2f")")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(transaction.type == 0 ? Color.green : Color.red)
        }
    }
    
    private func vendorIcon(name: String) -> some View {
        return ZStack {
            Circle()
                .fill(client.randomColor(seed: name))
                .frame(width: 60, height: 60)
            Text("\(String(name.uppercased().prefix(1)))")
                .fontWeight(.bold)
                .font(.system(.title))
                .foregroundColor(Color.white)
                .shadow(color: colorScheme == .light ? Color.black.opacity(0.1) : Color.white.opacity(0.1), radius: 3)
        }
    }
    
    private func dateFormatter(passedDate: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        let date = formatter.date(from: passedDate)
        formatter.dateFormat = "E, MMM dd"
        return formatter.string(from: date!)
    }
    
    private var loading: some View {
        List {
            ForEach(0..<25, id:\.self) { item in
                LoadingCell()
            }
        }
    }
}

struct LoadingCell: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .frame(width: 60, height: 60)
            VStack(alignment: .leading) {
                Rectangle()
                    .frame(height: 10)
                Rectangle()
                    .frame(width: UIScreen.main.bounds.width / 2, height: 10)
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
