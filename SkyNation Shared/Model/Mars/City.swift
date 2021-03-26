//
//  City.swift
//  SkyNation
//
//  Created by Carlos Farini on 2/27/21.
//

import Foundation

// MARK: - City

/** Server's Database representation of  `CityData` */
struct DBCity:Codable {
    
    var id:UUID
    
    var guild:[String:UUID?]?
    
    var name:String
    
    var accounting:Date
    
    var owner:[String:UUID?]?
    
    var posdex:Int
}


/// The Complete City Data
struct CityData:Codable, Identifiable {
    
    var id:UUID
    var posdex:Posdex
    
    // Modules
    
    // Ingredients
    var boxes:[StorageBox]
    
    // Tanks
    var tanks:[Tank]
    
    // Batteries
    var batteries:[Battery]
    
    // Persons
    var inhabitants:[Person]
    
    // Peripherals
    var peripherals:[PeripheralObject]
    
    // SolarPanels
    var solarPanels:[SolarPanel]
    
    // Robots, or Vehicles
    var vehicles:[String]?
    
    // To add:
    // + accounting + report
    // + airComposition
    // + bioBoxes?
    // + CityTech?
}


//struct CityHab:Codable {
//
//    var id:UUID
//    var capacity:Int            // Limit of people
//    var inhabitants:[Person]    // People
//    var name:String             // any name given
//    var skin:String             // If we decide so...
//    var position:Vector3D
//}

enum CityTech:String, Codable, CaseIterable {
    
    case Gate
    case Elevator
    
    case HQ
    case HQ1
    case HQ2
    
    // Hab
    /*
     Each hab has 9 people (4 + 3 + 2)
     3 habs inside = 27 people.
     2 habs outside = 45 people total */
    case Hab1
    case Hab2
    case Hab3
    case HabOut1
    case HabOut2
    case HabOut3
    
    // case Lab1
    
    case Bio1
    case Bio2
    case BioOut1
    
    case Cement
    case Foundry        // Melt metals found in mines
    case ChargedGlass   // Expose to sunlight, without problems
    case Biocell        // A cell used for Bio Outposts
    
    case OutsideBio
    case OutsidePark
    case OutsideHab
    
}


