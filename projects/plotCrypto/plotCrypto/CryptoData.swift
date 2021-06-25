//
//  CryptoData.swift
//  plotCrypto
//
//  Created by Jake Landers on 6/25/21.
//

import Foundation

class CryptoData: Decodable, Identifiable {
    let priceUsd: String
    let time: Int
    let circulatingSupply: String
    let date: String
}

class CryptoResponse: Decodable {
    let data: [CryptoData]
    let timestamp: Int
}
