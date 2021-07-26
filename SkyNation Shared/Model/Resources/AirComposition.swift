//
//  AirComposition.swift
//  SkyNation
//
//  Created by Carlos Farini on 1/4/21.
//

import Foundation

/// General quality of the air, counting with **CO2**, **Oxygen**, and other properties
enum AirQuality:String {
    case Great
    case Good
    case Medium
    case Bad
    case Lethal
    
    func decrease() -> AirQuality {
        switch self {
            case .Great: return .Good
            case .Good: return .Medium
            case .Medium: return .Bad
            case .Bad: return .Lethal
            case .Lethal: return .Lethal
        }
    }
}

/// The air inside the **Station**, **SpaceVehicle**, etc.
class AirComposition:Codable {
    
    
    var o2:Int          // min, max
    var co2:Int         // 0, max
    var n2:Int          // min, max
    
    var h2:Int          // 0, max
    var ch4:Int         // 0, max
    
    var h2o:Int         // min, max (Humidity)
    
    // MARK: - Calculated Properties
    
    // TODO: - Put air requirements in GameLogic
    /// Gets the Air Quality of the station
    func airQuality() -> AirQuality {
        
        let newVolume = o2 + co2 + n2 + h2 + ch4 // (Water vapor doesn't count?)
        var currentQuality:AirQuality = .Great
        
        // CO2
        let percentageCO2 = Double(co2) / Double(newVolume)
        if  percentageCO2 > 0.05 {
            currentQuality = currentQuality.decrease()
            if percentageCO2 > 0.10 {
                currentQuality = .Bad
                if percentageCO2 > 0.2 {
                    return .Lethal
                }
            }
        }
        
        // Oxygen
        let percentageO2 = Double(o2) / Double(newVolume)
        if percentageO2 < 0.2 {
            currentQuality = currentQuality.decrease()
            if percentageO2 < 0.1 {
                return .Lethal
            }
        }
        
        let percentageHydrogen = Double(h2) / Double(newVolume)
        if percentageHydrogen > 0.1 || ch4 > 5 {
            currentQuality = currentQuality.decrease()
            if percentageHydrogen > 0.2 || ch4 > 10 {
                return .Lethal
            }
        }
        
        return currentQuality
        
    }
    
    func getVolume() -> Int {
        return o2 + co2 + n2 + h2 + ch4
    }
    
    /// Adds an amount of air to this air
    func mergeWith(newAirAmount:Int) {
        // 70% nitrogen
        // 30% oxygen
        let nitroAmount = Int(Double(newAirAmount) * 0.7)
        let oxygenAmount = Int(Double(newAirAmount) * 0.3)
        self.n2 += nitroAmount
        self.o2 += oxygenAmount
    }
    
    /// Returns the exact amount of oxygen needed
    func needsOxygen() -> Int {
        let pct:Double = Double(o2) / Double(getVolume())
        if pct < 0.22 {
            let needed = (Double(getVolume()) * 0.22) - Double(o2)
            return Int(needed)
        } else {
            return 0
        }
    }
    
    /// Initializes - pass ammount if a Tank, or nil to start
    init(amount:Int? = GameLogic.airPerModule * 4) {
        let amt = amount ?? GameLogic.airPerModule * 4
        let totalAir = Double(amt)
        self.o2 = Int(totalAir * 0.21)
        if amt <= 300 {
            self.co2 = 1 // Int(totalAir * 0.0003)
        }else{
            self.co2 = 0
        }
        self.n2 = Int(totalAir * 0.78)
        self.h2o = Int(totalAir * 0.01)
        self.h2 = 0
        self.ch4 = 0
    }
    
    init(mars helper:Bool = true) {
        let amt:Int = GameLogic.airPerModule
        let totalAir = Double(amt)
        self.o2 = Int(totalAir * 0.21)
        if amt <= 300 {
            self.co2 = 1 // Int(totalAir * 0.0003)
        }else{
            self.co2 = 0
        }
        self.n2 = Int(totalAir * 0.78)
        self.h2o = Int(totalAir * 0.01)
        self.h2 = 0
        self.ch4 = 0
    }
    
    /// Describes the air, with quality
    func describe() -> String {
        
        var tmp:String = ""
        let newVolume = o2 + co2 + n2 + h2 + ch4 // (Water vapor doesn't count?)
        tmp += "Volume:\(newVolume)\n"
        tmp += "Oxygen: \(o2)\n"
        tmp += "CO2: \(co2)\n"
        tmp += "Nitrogen: \(n2)\n"
        tmp += "H2O Vapor: \(h2o)\n"
        if h2 > 0 || ch4 > 0 {
            tmp += "H2: \(h2), Methane:\(ch4) \n"
        }
        tmp += "\t Quality: \(self.airQuality().rawValue)"
        return tmp
    }
}


