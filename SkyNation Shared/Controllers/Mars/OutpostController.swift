//
//  OutpostController.swift
//  SkyNation
//
//  Created by Carlos Farini on 3/26/21.
//

import Foundation

class OutpostController:ObservableObject {
    
    var builder:MarsBuilder = MarsBuilder.shared
    
    @Published var player:SKNPlayer
    
    @Published var myCity:CityData?
    
    init() {
        guard let player = LocalDatabase.shared.player else { fatalError() }
        self.player = player
        self.myCity = MarsBuilder.shared.myCityData
        
    }
    
    
}
