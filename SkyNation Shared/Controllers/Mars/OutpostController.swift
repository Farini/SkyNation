//
//  OutpostController.swift
//  SkyNation
//
//  Created by Carlos Farini on 3/26/21.
//

import Foundation

enum OutpostViewTab:String, Codable, CaseIterable {
    
    case ingredients
    case people
    case other
    case contributions
    case management
    // Images: Box, User, Questionmark?, Arrow, Authority?
}

class OutpostController:ObservableObject {
    
    var builder:MarsBuilder = MarsBuilder.shared
    
    @Published var player:SKNPlayer
    @Published var myCity:CityData = CityData.example()
    
    // DBOutpost
    // OutpostData
    @Published var opData:Outpost
    // Guild
    // GuildData?
    // View State
    @Published var viewTab:OutpostViewTab = .ingredients
    
    init() {
        guard let player = LocalDatabase.shared.player else { fatalError() }
        self.player = player
        
        // self.myCity = MarsBuilder.shared.myCityData
        let dbData = DBOutpost.example()
        opData = Outpost.exampleFromDatabase(dbData: dbData)
        
    }
    
    func selected(tab:OutpostViewTab) {
        self.viewTab = tab
    }
    
    func contributeWith(box:StorageBox) {
        
        print("Contributing with: \(box.type)")
        myCity.takeBox(box: box)
        
        if let prev = opData.materials[box.type] {
            print("Contribution going. Prev: \(prev) + Curr:\(box.current)")
            opData.materials[box.type]! += box.current
        } else {
            opData.materials[box.type] = box.current //= [box.type:box.current]
        }
        
        // Logic Layout
        // Get city
        // Get outpost info
        // if outpost does NOT have updates
        //      Take ingredients from city
        //      Add Ingredients to outpost
        //      Add contribution to outpost
        // if HAS updates
        //      Someone else already contributed
        //      Update outpost (locally)
        
        
        
        // save city
        // save Outpost
    }
    
}

extension OutpostViewTab {
    
    /// Name of the `Image` of this tab (systemImage)
    func imageName() -> String {
        switch self {
            case .ingredients: return "archivebox"
            case .people: return "person.2"
            case .other: return "questionmark.diamond"
            case .contributions: return "control"
            case .management: return "externaldrive"
        }
    }
    
    /// Name to display for help, and others
    func tabName() -> String {
        switch self {
            case .ingredients: return "Ingredients"
            case .people: return "People"
            case .other: return "Unknown"
            case .contributions: return "Contribution"
            case .management: return "Management"
        }
    }
    
}
