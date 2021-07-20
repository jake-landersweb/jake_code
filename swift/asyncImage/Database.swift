//
//  Database.swift
//  FancySlideMenu
//
//  Created by Jake Landers on 7/19/21.
//

import Foundation

enum methods {
    static let get = "GET"
}

enum Database {
    static let baseUrl = URL(string: "http://shibe.online/api")!
}

extension Database {
    static func request<T: Codable>(_ path: String, method: String) async -> T? {
        guard let url = URL(string: "\(baseUrl)\(path)") else {
            print("failed to create url components")
            return nil
        }
        
        do {
            var request = URLRequest(url: url)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = method
            // if doing a PUT or POST method, add:
            // request.httpBody = (object of type Data) = a object that has been encoded with a JSONEncoder().
            let (response, _) = try await URLSession.shared.data(for: request)
            let decoder = JSONDecoder()
            let data = try decoder.decode(T.self, from: response)
            return data
        } catch {
            print("FATAL -- issue serializing request: \(error)")
            return nil
        }
    }
}
