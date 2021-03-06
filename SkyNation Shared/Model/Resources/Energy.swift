//
//  Energy.swift
//  SkyNation
//
//  Created by Carlos Farini on 1/31/21.
//

import Foundation

/// Stores energy
class Battery:Codable, Identifiable, Hashable {
    
    var id:UUID = UUID()
    var type:String = "Battery"
    var capacity:Int
    var current:Int
    
    /// A  battery has 100 capacity. When shooped comes full. When made recipe, empty
    init(shopped:Bool) {
        self.capacity = GameLogic.batteryCapacity
        if shopped {
            self.current = GameLogic.batteryCapacity
        }else{
            self.current = 0
        }
    }
    
    init(capacity:Int, current:Int) {
        self.capacity = capacity
        self.current = current
    }
    
    func maxCharge() -> Int {
        return capacity - current
    }
    
    func charge(amount:Int) -> Bool {
        if current == capacity { return false }
        current += amount
        return true
    }
    
    func consume(amt:Int) -> Bool {
        if current >= amt {
            current -= amt
            return true
        }else{
            return false
        }
    }
    
    //    func storageType() -> StorageType { return .Battery }
    
    // Equatable
    static func == (lhs: Battery, rhs: Battery) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        
    }
}

// MARK: - Solar Panel

enum SolarTypeSize:Int, Codable, CaseIterable {
    
    case bigStation
    case smallVehicle
    case bigMars
    
    var name:String {
        switch self {
            case .bigStation: return "Big Station"
            case .smallVehicle: return "Small Vehicle"
            case .bigMars: return "Big Mars"
        }
    }
    
    var size:Int {
        switch self {
            case .bigStation: return 10
            case .smallVehicle: return 4
            case .bigMars: return 16
        }
    }
}

struct SolarPanel:Codable, Identifiable {
    
    var id:UUID = UUID()
    var size:Int        // size of panel
    
    var breakable:Bool
    var isBroken:Bool
    var type:SolarTypeSize
    
    /// Information (Name, Position, Orientation) to build a `SCNNode` in the scene
    var model:Model3D?
    
    init() {
        // Check model
        size = 10
        breakable = false
        isBroken = false
        type = .bigStation
    }
    
    init(with sts:SolarTypeSize) {
        self.type = sts
        self.isBroken = false
        self.breakable = sts == .smallVehicle ? true:false
        self.size = sts.size
    }
    
    /// The energy generated
    func maxCurrent() -> Int {
        return size * 15
    }  // output current
    
}
