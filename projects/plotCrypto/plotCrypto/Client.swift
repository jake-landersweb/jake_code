//
//  client.swift
//  plotCrypto
//
//  Created by Jake Landers on 6/25/21.
//

import Foundation
import SwiftUI

class Client: ObservableObject {
    @Published var btcData: [CryptoData] = []
    
    let btcUrl = "https://api.coincap.io/v2/assets/bitcoin/history?interval=m1"
    
    // init the data
    init() {
        async {
            // get data
            let data = await fetchData(url: btcUrl)
            DispatchQueue.main.async {
                // bind data
                withAnimation(.spring()) {
                    self.btcData = data
                }
            }
        }
    }
    
    // fetch the crypto data with a url
    func fetchData(url: String) async -> [CryptoData] {
        do {
            // create url
            let _url = URL(string: url)!
            print("1")
            // fetch
            let (data, _) = try await URLSession.shared.data(from: _url)
            print(data)
            // decode
            let fetchedData: CryptoResponse = try JSONDecoder().decode(CryptoResponse.self, from: data)
            print("successfully found data")
            // slice the list and return
            return fetchedData.data.reversed()
        } catch {
            // handle error
            print("There was an error getting the data")
            return []
        }
    }
}
