//
//  Client.swift
//  FancySlideMenu
//
//  Created by Jake Landers on 7/19/21.
//

import Foundation


class Client: ObservableObject {
    @Published var shibes: [String]?
    @Published var birds: [String]?
    @Published var cats: [String]?
    
    func fetchShibes() async {
        shibes = await Database.request("/shibes?count=25&urls=true&httpsUrls=true", method: methods.get)
    }
    
    func fetchBirds() async {
        birds = await Database.request("/birds?count=25&urls=true&httpsUrls=true", method: methods.get)
    }
    
    func fetchCats() async {
        cats = await Database.request("/cats?count=25&urls=true&httpsUrls=true", method: methods.get)
    }
    
}


