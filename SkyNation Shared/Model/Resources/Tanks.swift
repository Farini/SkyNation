//
//  Tanks.swift
//  SkyNation
//
//  Created by Carlos Farini on 1/31/21.
//

import Foundation

/// What a `Tank` holds
enum TankType:String, Codable, CaseIterable, Hashable {
    
    case o2
    case co2
    case n2
    case h2o
    case h2
    case ch4
    case air
    case empty
    
    var capacity:Int {
        switch self {
            case .o2: return 100
            case .co2: return 25
            case .n2: return 50
            case .h2o: return 25
            case .h2: return 10
            case .ch4: return 50
            case .air: return 50
            case .empty: return 0
        }
    }
    
    var name:String {
        switch self {
            case .o2: return "Oxygen"
            case .co2: return "Carbon dioxide"
            case .n2: return "Nitrogen"
            case .h2o: return "Water"
            case .h2: return "Hydrogen"
            case .ch4: return "Methane"
            case .air: return "Breathable air"
            case .empty: return "Empty"
        }
    }
    
    var price:Int {
        switch self {
            case .o2: return 120
            case .co2: return 150
            case .n2: return 180
            case .h2o: return 200
            case .h2: return 100
            case .ch4: return 500
            case .air: return 300
            case .empty: return 150
        }
    }
}

/// A `Tank` that holds gases and liquids `Ingredients`
class Tank:Codable, Identifiable, Hashable {
    
    var id:UUID = UUID()
    var type:TankType
    var capacity:Int
    var current:Int
    
    /// Whether `Tank` should be discarded when empty.
    var discardEmpty:Bool?
    
    init(type:TankType, full:Bool? = false) {
        self.type = type
        self.capacity = type.capacity
        self.current = full == true ? type.capacity:0
    }
    
    /**
     Fills the tank with the input.
     - Parameters:
     - input: The amount to fill
     - Returns: The amount left over, if the tank is full   */
    func fillUp(_ input:Int) -> Int {
        let maxIntake = capacity - current
        if input >= maxIntake {
            self.current = capacity
            return input - maxIntake
        }else {
            self.current += input
            return 0
        }
    }
    
    /**
     Checks how much room there is (capacity - current)
     - Returns: How much  can be added before the tank is full */
    func availabilityToFill() -> Int {
        return capacity - current
    }
    
    static func == (lhs: Tank, rhs: Tank) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Make a class hashable: https://www.hackingwithswift.com/example-code/language/how-to-conform-to-the-hashable-protocol
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
