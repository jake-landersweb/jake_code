//
//  Client.swift
//  DataFetchPlaceHolder
//
//  Created by Jake Landers on 7/7/21.
//

import Foundation
import SwiftUI

class Client: ObservableObject {
    @Published var loadingStatus: LoadingStatus = LoadingStatus.initial
    
    @Published var account: Account?
    private var accountResponse: AccountResponse? {
        didSet {
            if accountResponse != nil {
                if accountResponse!.status == 200 {
                    print("successfully fetched account data!")
                    account = accountResponse!.body
                    loadingStatus = .success
                } else {
                    print(accountResponse!.message)
                    loadingStatus = .failure
                }
            } else {
                print("There was a fatal error fetching account data.")
                loadingStatus = .failure
            }
        }
    }
    
    init() {
        fetchWithDelay()
    }
    
    func fetchWithDelay() {
        loadingStatus = .loading
        // add artificial network lag
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            async {
                await self.fetchData()
            }
        }
    }
    
    func fetchData() async {
        DispatchQueue.main.async {
            self.loadingStatus = .loading
        }
        
        // get the data from the url
        guard let url = Bundle.main.url(forResource: "data.json", withExtension: nil) else {
            DispatchQueue.main.async {
                self.loadingStatus = .failure
            }
            return
        }
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let response = try decoder.decode(AccountResponse.self, from: data)
            DispatchQueue.main.async {
                self.accountResponse = response
            }
        } catch {
            print("There was an error fetching or decoding the data")
            DispatchQueue.main.async {
                self.loadingStatus = .failure
            }
            return
        }
        
        // if fetching from data base use this:
//        guard let url = URL(string: "") else {
//            return
//        }
//        do {
//            let (data, _) = try await URLSession.shared.data(from: url)
//            let decoder = JSONDecoder()
//            let response = try decoder.decode(AccountResponse.self, from: data)
//            accountResponse = response
//        } catch {
//            print("There was an error fetching or decoding the data")
//            loadingStatus = .failure
//            return
//        }
    }
    
    // for generating a color based on the vendor
    func randomColor(seed: String) -> Color {
        
        var total: Int = 0
        for u in seed.unicodeScalars {
            total += Int(UInt32(u))
        }
        
        srand48(total * 200)
        let r = CGFloat(drand48())
        
        srand48(total)
        let g = CGFloat(drand48())
        
        srand48(total / 200)
        let b = CGFloat(drand48())
        
        return Color(red: r, green: g, blue: b)
    }
}

class AccountResponse: Codable {
    let status: Int
    let message: String
    let body: Account?
}

class Account: Codable {
    let name: String
    let currentBalance: Double
    let transactions: [Transaction]
}

class Transaction: Codable {
    let type: Int
    let vendor: String
    let amount: Double
    let date: String
}

enum LoadingStatus {
    case initial
    case loading
    case success
    case failure
}
