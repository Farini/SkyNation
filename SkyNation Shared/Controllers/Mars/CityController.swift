//
//  CityController.swift
//  SkyNation
//
//  Created by Carlos Farini on 3/20/21.
//

import Foundation

class CityController:ObservableObject {
    
    var builder:MarsBuilder
    
    @Published var city:DBCity?
    @Published var ownerID:UUID?
    
    @Published var player:SKNPlayer
    @Published var isMyCity:Bool = false
    @Published var isClaimedCity:Bool = true
    
    init() {
        guard let player = LocalDatabase.shared.player else { fatalError() }
        self.player = player
        self.builder = MarsBuilder.shared
    }
    
    /// Loads the city at the correct `Posdex`
    func loadAt(posdex:Posdex) {
        if let theCity = builder.cities.filter({ $0.posdex == posdex.rawValue }).first {
            print("The City: \(theCity.name)")
            self.city = theCity
            let cityOwner = theCity.owner ?? [:]
            if let ownerID = cityOwner["id"] as? UUID {
                print("Owner ID: \(ownerID)")
                if player.playerID == ownerID {
                    print("PLAYR OWNS IT !!!!")
                    isMyCity = true
                    
                    // FIXME: - CityData
                    
                    // Continue from here....
                    // Get the CityData from server.
                    // Load City Data ??
                    
                } else {
                    // Also get city data from server (not editable)
                    isMyCity = false
                }
            }
        } else {
            print("This is an unclaimed city")
            isMyCity = false
            isClaimedCity = false
        }
        
    }
    
    
}
