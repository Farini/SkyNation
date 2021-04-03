//
//  Outpost.swift
//  SkyNation
//
//  Created by Carlos Farini on 3/12/21.
//

import Foundation

// MARK: - Outposts

enum OutpostType:String, CaseIterable, Codable {
    
    case HQ
    case Water          // Produces Water
    case Silica         // OK Produces Silica
    case Energy         // OK Produces Energy
    case Biosphere      // OK Produces Food
    case Titanium       // OK Produces Titanium
    case Observatory    //
    case Antenna        // OK Comm
    case Launchpad      // OK Launch / Receive Vehicles
    case Arena          // Super Center
    case ETEC           // Extraterrestrial Entertainement Center
    
    var productionBase: [Ingredient:Int] {
        switch self {
            case .HQ: return [:]
            case .Water: return [.Water:20]
            case .Silica: return [.Silica:10]
            case .Energy: return [.Battery:20]
            case .Biosphere: return [.Food:25]
            case .Titanium: return [.Iron:5, .Aluminium:10]
            case .Observatory: return [:]
            case .Antenna: return [:]
            case .Launchpad: return [:]
            case .Arena: return [:]
            case .ETEC: return [:]
        }
    }
    
    /// Happiness Production
    var happyDelta:Int {
        switch self {
            case .HQ: return 0
            case .Energy: return 0
            case .Water: return 0
            case .Silica: return -1
            case .Biosphere: return 3
            case .Titanium: return -1
            case .Observatory: return 2
            case .Antenna: return 1
            case .Launchpad: return 0
            case .Arena: return 5
            case .ETEC: return 3
        }
    }
    
    /// Energy production (Consumed as negative)
    var energyDelta:Int {
        switch self {
            case .HQ: return 0
            case .Energy: return 100
            case .Water: return -20
            case .Silica: return -25
            case .Biosphere: return -15
            case .Titanium: return -25
            case .Observatory: return -5
            case .Antenna: return -5
            case .Launchpad: return -10
            case .Arena: return -50
            case .ETEC: return -20
        }
    }
}

class Outpost:Codable {
    
    var id:UUID
    var guild:[String:UUID?]?
    
    var model:String = ""
    var posdex:Posdex
    
    var type:OutpostType
    
    var level:Int = 0
    var collected:Date?
    
    /// Gets the job to perform to level up
    func getNextJob() -> OutpostJob? {
        switch posdex {
            
            case .hq:
                switch level {
                    case 0: return OutpostJob(wantedSkills: [.SystemOS:3, .Datacomm:2, .Handy:8],
                                              wantedIngredients: [.Iron:15, .Aluminium:200, .Polimer:20, .Circuitboard:12])
                    case 1: return OutpostJob(wantedSkills: [.SystemOS:8, .Datacomm:6, .Handy:16],
                                              wantedIngredients: [.Polimer:600, .Aluminium:200, .Silica:80, .Water:80, .Battery:80])
                    case 2: return OutpostJob(wantedSkills: [.SystemOS:20, .Material:12, .Electric:8, .Handy:20],
                                              wantedIngredients: [.Polimer:1200, .Aluminium:500, .Silica:260, .Water:120, .Battery:80])
                    default: return nil
                }
                
            // Mining
            case .mining1:
                switch level {
                    case 0: return OutpostJob(wantedSkills: [.Datacomm:1, .Mechanic:1],
                                              wantedIngredients: [.Iron:5, .Aluminium:2, .DCMotor:12, .Sensor:7])
                    case 1: return OutpostJob(wantedSkills: [.Biologic:1, .Mechanic:1],
                                              wantedIngredients: [.Iron:5, .Aluminium:2, .DCMotor:12, .Sensor:21])
                    case 2: return OutpostJob(wantedSkills: [.Biologic:1, .Mechanic:1],
                                              wantedIngredients: [.Iron:5, .Aluminium:2, .DCMotor:12, .Sensor:52])
                    default: return nil
                }
            case .mining2:
                switch level {
                    case 0: return OutpostJob(wantedSkills: [.Datacomm:1, .Mechanic:1],
                                              wantedIngredients: [.Iron:5, .Aluminium:2, .DCMotor:12, .Sensor:7])
                    case 1: return OutpostJob(wantedSkills: [.Biologic:1, .Mechanic:1],
                                              wantedIngredients: [.Iron:5, .Aluminium:2, .DCMotor:12, .Sensor:21])
                    case 2: return OutpostJob(wantedSkills: [.Biologic:1, .Mechanic:1],
                                              wantedIngredients: [.Iron:5, .Aluminium:2, .DCMotor:12, .Sensor:52])
                    default: return nil
                }
            case .mining3:
                switch level {
                    case 0: return OutpostJob(wantedSkills: [.Datacomm:1, .Mechanic:1],
                                              wantedIngredients: [.Iron:5, .Aluminium:2, .DCMotor:12, .Sensor:7])
                    case 1: return OutpostJob(wantedSkills: [.Biologic:1, .Mechanic:1],
                                              wantedIngredients: [.Iron:5, .Aluminium:2, .DCMotor:12, .Sensor:21])
                    case 2: return OutpostJob(wantedSkills: [.Biologic:1, .Mechanic:1],
                                              wantedIngredients: [.Iron:5, .Aluminium:2, .DCMotor:12, .Sensor:52])
                    default: return nil
                }
                
            // Energy
            case .power1, .power2:
                switch level {
                    case 0: return OutpostJob(wantedSkills: [.Electric:10, .Material:4, .Handy:18],
                                              wantedIngredients: [.Polimer:50, .Aluminium:20, .SolarCell:200, .Circuitboard:8])
                    case 1: return OutpostJob(wantedSkills: [.Electric:15, .Material:12, .Handy:22],
                                              wantedIngredients: [.Polimer:150, .Aluminium:360, .SolarCell:900, .Circuitboard:54, .Sensor:12])
                    case 2: return OutpostJob(wantedSkills: [.Electric:21, .Material:14, .Handy:30, .Mechanic:8],
                                              wantedIngredients: [.Polimer:320, .Aluminium:450, .SolarCell:1600, .Circuitboard:32, .Sensor:64])
                    case 3: return OutpostJob(wantedSkills: [.Electric:32, .Material:24, .Handy:32, .Mechanic:18, .SystemOS:8],
                                              wantedIngredients: [.Polimer:680, .Aluminium:750, .SolarCell:2500, .Circuitboard:64, .Sensor:128])
                    case 4: return OutpostJob(wantedSkills: [.Electric:40, .Material:30, .Handy:50, .Mechanic:15, .Datacomm:8, .SystemOS:12],
                                              wantedIngredients: [.Polimer:1200, .Aluminium:600, .SolarCell:4000, .Circuitboard:128, .Sensor:256])
                    default: return nil
                }
                
            case .power3, .power4: return nil
                
            // Bio
            case .biosphere1:
                switch level {
                    case 0: return OutpostJob(wantedSkills: [.Biologic:10, .Medic:4, .Handy:10],
                                              wantedIngredients: [.Fertilizer:100, .Aluminium:50, .Polimer:22, .Silica:8, .Battery:4])
                        
                    case 1: return OutpostJob(wantedSkills: [.Biologic:16, .Medic:8, .Handy:20, .SystemOS:3],
                                              wantedIngredients: [.Fertilizer:250, .Aluminium:80, .Polimer:32, .Silica:16, .Battery:12, .Circuitboard:5])
                        
                    case 2: return OutpostJob(wantedSkills: [.Biologic:26, .Medic:18, .Handy:22, .SystemOS:6, .Datacomm:2],
                                              wantedIngredients: [.Fertilizer:450, .Aluminium:120, .Polimer:80, .Battery:50, .Silica:20, .Circuitboard:15])
                        
                    default: return nil
                }
            case .biosphere2: return nil
                
                
                
            case .antenna: return nil
            case .arena: return nil
            case .launchPad: return nil
                
            case .observatory: return nil
                
                
            default: return nil
        }
    }
    
    // Just prints info
    func makeModel() {
        switch type {
            case .HQ: print("hq")
            case .Water: print("Make Water")
                switch level {
                    case 0...5: print("Low Level")
                    case 6...10: print("Mid Level")
                    case 11...15: print("Advanced")
                    default:print("ERROR")
                }
            case .Silica: print("Make Silica")
            case .Energy: print("Make Energy")
            case .Biosphere: print("Make Biosphere")
            case .Titanium: print("Make Titanium")
            case .Observatory: print("Make Observatory")
            case .Antenna: print("Make Antenna")
            case .Launchpad: print("Make Launchpad")
            case .Arena: print("Make Arena")
            case .ETEC: print("Make ETEC")
        }
    }
    
    // Outpost type has production base
    func produceIngredients() -> [Ingredient:Int] {
        
        var baseAdjust:[Ingredient:Int] = [:]
        
        for (k, v) in type.productionBase {
            // Level * percentage * fibo * baseValue(v)
            let fiboValue = GameLogic.fibonnaci(index: self.level)
            let fiboMatters:Double = 0.5 // (% influence)
            let calc = v + Int(fiboMatters * Double(fiboValue) * Double(v))
            baseAdjust[k] = calc
        }
        return baseAdjust
    }
    
    func produceTanks() -> [TankType:Int] {
        return [:]
    }
    
    // Happy
    func happy() -> Int {
        return type.happyDelta
    }
    
    // Energy
    func energy() -> Int {
        let fiboValue = GameLogic.fibonnaci(index: self.level + 1)
        let fiboMatters:Double = 0.5
        let calc = Int(fiboMatters * Double(fiboValue) * Double(type.energyDelta))
        return calc
    }
    
    init(type:OutpostType, posdex:Posdex, guild:UUID?) {
        self.id = UUID()
        self.guild = nil
        self.posdex = posdex
        self.type = type
        self.level = 0
    }
    
    /// Makes an example data. **Delete** it upon launch
    static func exampleFromDatabase(dbData:DBOutpost) -> Outpost {
        let newOutpost = Outpost(type: dbData.type, posdex: Posdex(rawValue:dbData.posdex)!, guild: nil)
        newOutpost.collected = dbData.accounting
        return newOutpost
    }
    
    // Lineup
    var lineup:[Person] = []
    var materials:[Ingredient:Int] = [:]
    var contribPPl:[UUID:Int] = [:]        // Player.id vs peopleskills
    var contribIng:[UUID:Int] = [:]        // Player.id vs ingredients
    
    // Building up to here, an outpost has an OutpostJob, which sets the Level of the Outpost
    // For a job. There is a lineup of people, and materials. Each one tracking back to Players
    // When a job is ready to be executed (covered skills and ingredients), each person gets an Activity
    // and there should be a trigger for setting the level up of the outpost
    var activity:LabActivity?
    
    func lockModel() {
        // 1. Check if all ingredients are covered
        // 2. Check if all skills are covered
        // 3. Update 'Contributing'
        // 4. Setup Activity
    }
}

/// Its calculated. Doesn't need to be `Codable` type
struct OutpostJob {
    var wantedSkills:[Skills:Int]
    var wantedIngredients:[Ingredient:Int]
    // Wanted Tanks
    // Wanted Peripherals
    // Time
}

struct DBOutpost:Codable {
    
    var id:UUID
    var model:String
    var guild:[String:UUID?]?
    var type:OutpostType
    var level:Int
    var accounting:Date
    var posdex:Int
    
    func getNextJob() -> OutpostJob? {
        
        guard let pdex = Posdex(rawValue: self.posdex) else { return nil }
        
        switch pdex {
            
            case .hq:
                switch level {
                    case 0: return OutpostJob(wantedSkills: [.SystemOS:3, .Datacomm:2, .Handy:8],
                                              wantedIngredients: [.Iron:15, .Aluminium:200, .Polimer:20, .Circuitboard:12])
                    case 1: return OutpostJob(wantedSkills: [.SystemOS:8, .Datacomm:6, .Handy:16],
                                              wantedIngredients: [.Polimer:600, .Aluminium:200, .Silica:80, .Water:80, .Battery:80])
                    case 2: return OutpostJob(wantedSkills: [.SystemOS:20, .Material:12, .Electric:8, .Handy:20],
                                              wantedIngredients: [.Polimer:1200, .Aluminium:500, .Silica:260, .Water:120, .Battery:80])
                    default: return nil
                }
                
            // Mining
            case .mining1:
                switch level {
                    case 0: return OutpostJob(wantedSkills: [.Datacomm:1, .Mechanic:1],
                                              wantedIngredients: [.Iron:5, .Aluminium:2, .DCMotor:12, .Sensor:7])
                    case 1: return OutpostJob(wantedSkills: [.Biologic:1, .Mechanic:1],
                                              wantedIngredients: [.Iron:5, .Aluminium:2, .DCMotor:12, .Sensor:21])
                    case 2: return OutpostJob(wantedSkills: [.Biologic:1, .Mechanic:1],
                                              wantedIngredients: [.Iron:5, .Aluminium:2, .DCMotor:12, .Sensor:52])
                    default: return nil
                }
            case .mining2: return nil
            case .mining3: return nil
                
            // Energy
            case .power1, .power2:
                switch level {
                    case 0: return OutpostJob(wantedSkills: [.Electric:10, .Material:4, .Handy:18],
                                              wantedIngredients: [.Polimer:50, .Aluminium:20, .SolarCell:200, .Circuitboard:8])
                    case 1: return OutpostJob(wantedSkills: [.Electric:15, .Material:12, .Handy:22],
                                              wantedIngredients: [.Polimer:150, .Aluminium:360, .SolarCell:900, .Circuitboard:54, .Sensor:12])
                    case 2: return OutpostJob(wantedSkills: [.Electric:21, .Material:14, .Handy:30, .Mechanic:8],
                                              wantedIngredients: [.Polimer:320, .Aluminium:450, .SolarCell:1600, .Circuitboard:32, .Sensor:64])
                    case 3: return OutpostJob(wantedSkills: [.Electric:32, .Material:24, .Handy:32, .Mechanic:18, .SystemOS:8],
                                              wantedIngredients: [.Polimer:680, .Aluminium:750, .SolarCell:2500, .Circuitboard:64, .Sensor:128])
                    case 4: return OutpostJob(wantedSkills: [.Electric:40, .Material:30, .Handy:50, .Mechanic:15, .Datacomm:8, .SystemOS:12],
                                              wantedIngredients: [.Polimer:1200, .Aluminium:600, .SolarCell:4000, .Circuitboard:128, .Sensor:256])
                    default: return nil
                }
                
            case .power3, .power4: return nil
                
            // Bio
            case .biosphere1:
                switch level {
                    case 0: return OutpostJob(wantedSkills: [.Biologic:10, .Medic:4, .Handy:10],
                                              wantedIngredients: [.Fertilizer:100, .Aluminium:50, .Polimer:22, .Silica:8, .Battery:4])
                        
                    case 1: return OutpostJob(wantedSkills: [.Biologic:16, .Medic:8, .Handy:20, .SystemOS:3],
                                              wantedIngredients: [.Fertilizer:250, .Aluminium:80, .Polimer:32, .Silica:16, .Battery:12, .Circuitboard:5])
                        
                    case 2: return OutpostJob(wantedSkills: [.Biologic:26, .Medic:18, .Handy:22, .SystemOS:6, .Datacomm:2],
                                              wantedIngredients: [.Fertilizer:450, .Aluminium:120, .Polimer:80, .Battery:50, .Silica:20, .Circuitboard:15])
                        
                    default: return nil
                }
            case .biosphere2: return nil
                
                
                
            case .antenna:
                switch level {
                    case 0:
                        return OutpostJob(wantedSkills: [.Biologic:10, .Medic:4, .Handy:10],
                                          wantedIngredients: [.Fertilizer:100, .Aluminium:50, .Polimer:22, .Silica:8, .Battery:4])
                    case 1:
                        return  OutpostJob(wantedSkills: [.Biologic:10, .Medic:4, .Handy:10],
                                           wantedIngredients: [.Fertilizer:100, .Aluminium:50, .Polimer:22, .Silica:8, .Battery:4])
                    default: return nil
                }
                
                
            case .arena: return nil
            case .launchPad: return nil
                
            case .observatory: return nil
                
                
            default: return nil
        }
        
    }
    
    static func example() -> DBOutpost {
        return DBOutpost(id: UUID(), model: "model", guild: nil, type: .Energy, level: 0, accounting: Date(), posdex: Posdex.power1.rawValue)
    }
}


