//
//  ContentView.swift
//  plotCrypto
//
//  Created by Jake Landers on 6/25/21.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var client = Client()
    
    var body: some View {
        NavigationView {
            List(client.btcData) { item in
                VStack(alignment: .leading) {
                    Text("\(_convertToDouble(item.priceUsd))")
                        .font(.headline)
                    Text(item.date)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("BTC Price")
            .refreshable {
                client.btcData = await client.fetchData(url: client.btcUrl)
            }
        }
    }
    
    private func _convertToDouble(_ input: String) -> Double {
        return Double(input) ?? 0.0
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
