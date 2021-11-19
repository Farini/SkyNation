//
//  Outpost.swift
//  SkyNation
//
//  Created by Carlos Farini on 3/12/21.
//

import Foundation

/// Outpost: "a remote part of a country or empire." In this case, the Mars Colony (Guild)
class Outpost:Codable {
    
    var id:UUID
    var guild:UUID
    
    var model:String = ""
    var posdex:Posdex
    
    var type:OutpostType
    var state:OutpostState
    
    var level:Int = 0
    var collected:Date?
    var dateUpgrade:Date?
    
    /// Match the pass for updates
    var pass:String?
    
    /// `Player.id` vs `points`
    var contributed:[UUID:Int] = [:]
    
    /// Stuff supplied so far
    var supplied:OutpostSupply
    
    // MARK: - Production
    
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
    
    /// Upgrades the model, and returns results that may be relevant to upload to the server.
    func runUpgrade() -> OutpostUpgradeResult {
        
        let previous = self.state
        
        switch previous {
            case .collecting:
                let missingOut:[String:Int] = calculateRemaining()
                if missingOut.isEmpty == true {
                    if getNextJob() == nil {
                        self.state = .maxed
                        return .nextState(.maxed)
                    }
                    // Start The Cooldown
                    self.state = .cooldown
                    self.dateUpgrade = Date().addingTimeInterval(TimeInterval.oneDay)
                    return .nextState(.cooldown)
                } else {
                    // return current state (collecting)
                    return .noChanges
                }
                
            case .cooldown:
                guard let upDate = dateUpgrade else { return OutpostUpgradeResult.needsDateUpgrade }
                if Date().compare(upDate) == .orderedDescending {
                    self.dateUpgrade = nil
                    self.state = .finished
                    // Ready for level up -> Call Server
                    return .nextState(.finished)
                }
                return .noChanges
                
            case .finished:
                // Ready for level up. Call Server and apply for next level
                let currentLevel = self.level
                // Ready for level up. Call Server and apply for next level
                return .applyForLevelUp(currentLevel: currentLevel)//.nextState(.collecting)
                // Before ready for collecting, Server should double-check the validity.
                // Only the server will upgrade the level property of this outpost.
            case .maxed:
                print("maxed")
                return .noChanges
        }
    }
    
    /// Returns a K,V pair of Remaining items to fullfill upgrades
    func calculateRemaining() -> [String:Int] {
        
        var missingOut:[String:Int] = [:]
        
        // Ingredients & Boxes
        let iNeedBox:[Ingredient:Int] = getNextJob()?.wantedIngredients ?? [:]
        for (needKey, needVal) in iNeedBox {
            let current = supplied.ingredients.filter({ $0.type == needKey }).compactMap({$0.current}).reduce(0, +)
            if current < needVal {
                missingOut[needKey.rawValue] = needVal - current
            }
        }
        
        // Tanks & Tanks
        let iNeedTank:[TankType:Int] = getNextJob()?.wantedTanks ?? [:]
        for(k, v) in iNeedTank {
            let current = supplied.tanks.filter({ $0.type == k }).compactMap({$0.current}).reduce(0, +)
            if current < v {
                missingOut[k.rawValue] = v - current
            }
        }
        
        // Peripherals & Type
        let iNeedPeri:[PeripheralType:Int] = getNextJob()?.wantedPeripherals ?? [:]
        for(k, v) in iNeedPeri {
            let current = supplied.peripherals.filter({ $0.peripheral == k}).count
            if current < v {
                missingOut[k.rawValue] = v - current
            }
        }
        
        // People & Skills
        let iNeedPeople:[Skills:Int] = getNextJob()?.wantedSkills ?? [:]
        for(k, v) in iNeedPeople {
            let ppl = supplied.skills
            var current = 0
            
            for p in ppl {
                let lvl = p.skills.filter({ $0.skill == k }).first?.level ?? 0
                print("Level for \(k) = \(lvl)")
                current += lvl
            }
            if current < v {
                missingOut[k.rawValue] = v - current
            }
        }
        
        // Bioboxes & DNAOption
        let iNeedBio:[DNAOption:Int] = getNextJob()?.wantedBio ?? [:]
        for(k, v) in iNeedBio {
            let current = supplied.bioBoxes.filter({ $0.perfectDNA == k.rawValue }).map({ $0.population.count}).reduce(0, +) //bioBoxes.map({ $0.perfectDNA == k})
            if current < v {
                missingOut[k.rawValue] = v - current
            } // else passed
        }
        return missingOut
    }
    
    /// Gets the job to perform to level up
    func getNextJob() -> OutpostJob? {
        switch posdex {
            
            case .hq:
                switch level {
                    case 0: return OutpostJob(wantedIngredients: [.Iron:15, .Aluminium:200, .Polimer:20, .Circuitboard:12], wantedSkills: [.SystemOS:3, .Datacomm:2, .Handy:8])
                    case 1: return OutpostJob(wantedIngredients: [.Polimer:600, .Aluminium:200, .Silica:80, .Water:80, .Battery:80], wantedSkills: [.SystemOS:8, .Datacomm:6, .Handy:16])
                    case 2: return OutpostJob(wantedIngredients: [.Polimer:1200, .Aluminium:500, .Silica:260, .Water:120, .Battery:80], wantedSkills: [.SystemOS:20, .Material:12, .Electric:8, .Handy:20])
                    default: return nil
                }
                
            // Mining
            case .mining1:
                switch level {
                    case 0: return OutpostJob(wantedIngredients: [.Iron:5, .Aluminium:2, .DCMotor:12, .Sensor:7], wantedSkills: [.Datacomm:1, .Mechanic:1])
                    case 1: return OutpostJob(wantedIngredients: [.Iron:5, .Aluminium:2, .DCMotor:12, .Sensor:21], wantedSkills: [.Biologic:1, .Mechanic:1])
                    case 2: return OutpostJob(wantedIngredients: [.Iron:5, .Aluminium:2, .DCMotor:12, .Sensor:52], wantedSkills: [.Biologic:1, .Mechanic:1])
                    default: return nil
                }
            case .mining2:
                switch level {
                    case 0: return OutpostJob(wantedIngredients: [.Iron:5, .Aluminium:2, .DCMotor:12, .Sensor:7], wantedSkills: [.Datacomm:1, .Mechanic:1])
                    case 1: return OutpostJob(wantedIngredients: [.Iron:5, .Aluminium:2, .DCMotor:12, .Sensor:21], wantedSkills: [.Biologic:1, .Mechanic:1])
                    case 2: return OutpostJob(wantedIngredients: [.Iron:5, .Aluminium:2, .DCMotor:12, .Sensor:52], wantedSkills: [.Biologic:1, .Mechanic:1])
                    default: return nil
                }
            case .mining3:
                switch level {
                    case 0: return OutpostJob(wantedIngredients: [.Iron:5, .Aluminium:2, .DCMotor:12, .Sensor:7], wantedSkills: [.Datacomm:1, .Mechanic:1])
                    case 1: return OutpostJob(wantedIngredients: [.Iron:5, .Aluminium:2, .DCMotor:12, .Sensor:21], wantedSkills: [.Biologic:1, .Mechanic:1])
                    case 2: return OutpostJob(wantedIngredients: [.Iron:5, .Aluminium:2, .DCMotor:12, .Sensor:52], wantedSkills: [.Biologic:1, .Mechanic:1])
                    default: return nil
                }
                
            // Energy
            case .power1, .power2:
                switch level {
                    case 0: return OutpostJob(wantedIngredients: [.Polimer:20, .SolarCell:60, .Circuitboard:4], wantedSkills: [.Electric:3, .Material:1, .Handy:3])
                    case 1: return OutpostJob(wantedIngredients: [.Polimer:60, .Aluminium:35, .SolarCell:320, .Circuitboard:18, .Sensor:5], wantedSkills: [.Electric:8, .Material:3, .Handy:9])
                    case 2: return OutpostJob(wantedIngredients: [.Polimer:150, .Aluminium:65, .SolarCell:550, .Circuitboard:22, .Sensor:8], wantedSkills: [.Electric:21, .Material:14, .Handy:30, .Mechanic:8])
                    case 3: return OutpostJob(wantedIngredients: [.Polimer:680, .Aluminium:750, .SolarCell:2500, .Circuitboard:64, .Sensor:128], wantedSkills: [.Electric:32, .Material:24, .Handy:32, .Mechanic:18, .SystemOS:8])
                    case 4: return OutpostJob(wantedIngredients: [.Polimer:1200, .Aluminium:600, .SolarCell:4000, .Circuitboard:128, .Sensor:256], wantedSkills: [.Electric:40, .Material:30, .Handy:50, .Mechanic:15, .Datacomm:8, .SystemOS:12])
                    default: return nil
                }
                
            case .power3, .power4:
                switch level {
                    case 0: return OutpostJob(wantedIngredients: [.Polimer:18, .SolarCell:55, .Circuitboard:8], wantedSkills: [.Electric:2, .Material:1, .Handy:3])
                    case 1: return OutpostJob(wantedIngredients: [.Polimer:60, .Aluminium:35, .SolarCell:320, .Circuitboard:18, .Sensor:5], wantedSkills: [.Electric:8, .Material:3, .Handy:9])
                    case 2: return OutpostJob(wantedIngredients: [.Polimer:150, .Aluminium:65, .SolarCell:550, .Circuitboard:22, .Sensor:8], wantedSkills: [.Electric:21, .Material:14, .Handy:30, .Mechanic:8])
                    case 3: return OutpostJob(wantedIngredients: [.Polimer:680, .Aluminium:750, .SolarCell:2500, .Circuitboard:64, .Sensor:128], wantedSkills: [.Electric:32, .Material:24, .Handy:32, .Mechanic:18, .SystemOS:8])
                    case 4: return OutpostJob(wantedIngredients: [.Polimer:1200, .Aluminium:600, .SolarCell:4000, .Circuitboard:128, .Sensor:256], wantedSkills: [.Electric:40, .Material:30, .Handy:50, .Mechanic:15, .Datacomm:8, .SystemOS:12])
                    default: return nil
                }
                
                
            // Bio
            case .biosphere1:
                switch level {
                    case 0: return OutpostJob(wantedIngredients: [.Fertilizer:100, .Aluminium:50, .Polimer:22, .Silica:8, .Battery:4], wantedSkills: [.Biologic:10, .Medic:4, .Handy:10])
                        
                    case 1: return OutpostJob(wantedIngredients: [.Fertilizer:250, .Aluminium:80, .Polimer:32, .Silica:16, .Battery:12, .Circuitboard:5], wantedSkills: [.Biologic:16, .Medic:8, .Handy:20, .SystemOS:3])
                        
                    case 2: return OutpostJob(wantedIngredients: [.Fertilizer:450, .Aluminium:120, .Polimer:80, .Battery:50, .Silica:20, .Circuitboard:15], wantedSkills: [.Biologic:26, .Medic:18, .Handy:22, .SystemOS:6, .Datacomm:2])
                        
                    default: return nil
                }
            case .biosphere2:
                switch level {
                    case 0: return OutpostJob(wantedIngredients: [.Fertilizer:100, .Aluminium:50, .Polimer:22, .Silica:8, .Battery:4], wantedSkills: [.Biologic:10, .Medic:4, .Handy:10])
                        
                    case 1: return OutpostJob(wantedIngredients: [.Fertilizer:250, .Aluminium:80, .Polimer:32, .Silica:16, .Battery:12, .Circuitboard:5], wantedSkills: [.Biologic:16, .Medic:8, .Handy:20, .SystemOS:3])
                        
                    case 2: return OutpostJob(wantedIngredients: [.Fertilizer:450, .Aluminium:120, .Polimer:80, .Battery:50, .Silica:20, .Circuitboard:15], wantedSkills: [.Biologic:26, .Medic:18, .Handy:22, .SystemOS:6, .Datacomm:2])
                        
                    default: return nil
                }
                
            case .antenna: return nil
            case .arena: return nil
            case .launchPad: return nil
                
            case .observatory: return nil
                
                
            default: return nil
        }
    }
    
    // Just prints info
    func debugInfo() {
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
    
    // MARK: - Init
    
    init(dbOutpost:DBOutpost) {
        
        self.id = dbOutpost.id
        
        // Get Guild ID key
        var guildID:UUID?
        if let tGuild:[String:UUID?] = dbOutpost.guild {
            for (_, v) in tGuild {
                if let gid = v {
                    guildID = gid
                }
            }
        }
        
        guard let guildID = guildID else { fatalError("No Guild ID") }
        self.guild = guildID
        
        self.model = dbOutpost.model
        self.posdex = Posdex(rawValue: dbOutpost.posdex)!
        
        self.type = dbOutpost.type
        self.state = dbOutpost.state
        
        self.level = dbOutpost.level
        self.contributed = [:]
        self.supplied = OutpostSupply()
        
    }
    
    /// Makes an example data. **Delete** this upon launch
    init(type:OutpostType, posdex:Posdex, guild:UUID?) {
        self.id = UUID()
        self.guild = UUID()
        self.posdex = posdex
        self.type = type
        self.level = 0
        self.supplied = OutpostSupply()
        self.state = .collecting
    }
    
    /// Makes an example data. **Delete** this upon launch
    static func exampleFromDatabase(dbData:DBOutpost) -> Outpost {
        
        let newOutpost = Outpost(type: dbData.type, posdex: Posdex(rawValue:dbData.posdex)!, guild: nil)
        newOutpost.collected = dbData.accounting
        newOutpost.supplied = OutpostSupply()
        
        // Pre-populate Supplied
        let solcel = StorageBox(ingType: .SolarCell, current: Ingredient.SolarCell.boxCapacity())
        let cirb = StorageBox(ingType: .Circuitboard, current: Ingredient.Circuitboard.boxCapacity())
        let cirb2 = StorageBox(ingType: .Circuitboard, current: Ingredient.Circuitboard.boxCapacity())
        let poli = StorageBox(ingType: .Polimer, current: Ingredient.Polimer.boxCapacity())
        newOutpost.supplied.ingredients = [solcel, cirb, cirb2, poli]
        
        return newOutpost
    }
}

/// Representation of an Outpost in the Server
struct DBOutpost:Codable {
    
    var id:UUID
    var model:String
    var guild:[String:UUID?]?
    var type:OutpostType
    var level:Int
    var accounting:Date
    var posdex:Int
    var state:OutpostState
    
    func getNextJob() -> OutpostJob? {
        
        guard let pdex = Posdex(rawValue: self.posdex) else { return nil }
        
        switch pdex {
            
            case .hq:
                switch level {
                    case 0: return OutpostJob(wantedIngredients: [.Iron:15, .Aluminium:200, .Polimer:20, .Circuitboard:12], wantedSkills: [.SystemOS:3, .Datacomm:2, .Handy:8])
                    case 1: return OutpostJob(wantedIngredients: [.Polimer:600, .Aluminium:200, .Silica:80, .Water:80, .Battery:80], wantedSkills: [.SystemOS:8, .Datacomm:6, .Handy:16])
                    case 2: return OutpostJob(wantedIngredients: [.Polimer:1200, .Aluminium:500, .Silica:260, .Water:120, .Battery:80], wantedSkills: [.SystemOS:20, .Material:12, .Electric:8, .Handy:20])
                    default: return nil
                }
                
            // Mining
            case .mining1:
                switch level {
                    case 0: return OutpostJob(wantedIngredients: [.Iron:5, .Aluminium:2, .DCMotor:12, .Sensor:7], wantedSkills: [.Datacomm:1, .Mechanic:1])
                    case 1: return OutpostJob(wantedIngredients: [.Iron:5, .Aluminium:2, .DCMotor:12, .Sensor:21], wantedSkills: [.Biologic:1, .Mechanic:1])
                    case 2: return OutpostJob(wantedIngredients: [.Iron:5, .Aluminium:2, .DCMotor:12, .Sensor:52], wantedSkills: [.Biologic:1, .Mechanic:1])
                    default: return nil
                }
            case .mining2: return nil
            case .mining3: return nil
                
            // Energy
            case .power1, .power2:
                switch level {
                    case 0: return OutpostJob(wantedIngredients: [.Polimer:50, .Aluminium:20, .SolarCell:200, .Circuitboard:8], wantedSkills: [.Electric:10, .Material:4, .Handy:18])
                    case 1: return OutpostJob(wantedIngredients: [.Polimer:150, .Aluminium:360, .SolarCell:900, .Circuitboard:54, .Sensor:12], wantedSkills: [.Electric:15, .Material:12, .Handy:22])
                    case 2: return OutpostJob(wantedIngredients: [.Polimer:320, .Aluminium:450, .SolarCell:1600, .Circuitboard:32, .Sensor:64], wantedSkills: [.Electric:21, .Material:14, .Handy:30, .Mechanic:8])
                    case 3: return OutpostJob(wantedIngredients: [.Polimer:680, .Aluminium:750, .SolarCell:2500, .Circuitboard:64, .Sensor:128], wantedSkills: [.Electric:32, .Material:24, .Handy:32, .Mechanic:18, .SystemOS:8])
                    case 4: return OutpostJob(wantedIngredients: [.Polimer:1200, .Aluminium:600, .SolarCell:4000, .Circuitboard:128, .Sensor:256], wantedSkills: [.Electric:40, .Material:30, .Handy:50, .Mechanic:15, .Datacomm:8, .SystemOS:12])
                    default: return nil
                }
                
            case .power3, .power4: return nil
                
            // Bio
            case .biosphere1:
                switch level {
                    case 0: return OutpostJob(wantedIngredients: [.Fertilizer:100, .Aluminium:50, .Polimer:22, .Silica:8, .Battery:4], wantedSkills: [.Biologic:10, .Medic:4, .Handy:10])
                        
                    case 1: return OutpostJob(wantedIngredients: [.Fertilizer:250, .Aluminium:80, .Polimer:32, .Silica:16, .Battery:12, .Circuitboard:5], wantedSkills: [.Biologic:16, .Medic:8, .Handy:20, .SystemOS:3])
                        
                    case 2: return OutpostJob(wantedIngredients: [.Fertilizer:450, .Aluminium:120, .Polimer:80, .Battery:50, .Silica:20, .Circuitboard:15], wantedSkills: [.Biologic:26, .Medic:18, .Handy:22, .SystemOS:6, .Datacomm:2])
                        
                    default: return nil
                }
            case .biosphere2: return nil
                
                
                
            case .antenna:
                switch level {
                    case 0:
                        return OutpostJob(wantedIngredients: [.Fertilizer:100, .Aluminium:50, .Polimer:22, .Silica:8, .Battery:4], wantedSkills: [.Biologic:10, .Medic:4, .Handy:10])
                    case 1:
                        return  OutpostJob(wantedIngredients: [.Fertilizer:100, .Aluminium:50, .Polimer:22, .Silica:8, .Battery:4], wantedSkills: [.Biologic:10, .Medic:4, .Handy:10])
                    default: return nil
                }
                
                
            case .arena: return nil
            case .launchPad: return nil
                
            case .observatory: return nil
                
                
            default: return nil
        }
        
    }
    
    /// Random Data
    static func example() -> DBOutpost {
        let randomType = OutpostType.Energy//allCases.randomElement()!
        let vPosdex = randomType.validPosDexes.randomElement()!
        
        return DBOutpost(gid: UUID(), type: randomType, posdex: vPosdex)
    }
    
    /// Random Data
    init(gid:UUID, type:OutpostType, posdex:Posdex) {
        self.id = UUID()
        self.model = "model"
        self.guild = ["guild":gid]
        self.type = type
        self.level = Bool.random() ? 0:1
        self.accounting = Date().addingTimeInterval(Double.random(in: 20...652) * -1)
        self.posdex = posdex.rawValue
        self.state = .collecting
    }
}
