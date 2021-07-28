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
    
    /// Explains what the outpost does
    var explanation:String {
        switch self {
            case .HQ: return "The Headquarters of this Guild."
            case .Water: return "Extracts ice from the soil."
            case .Silica: return "Extracts silica from the soil."
            case .Energy: return "Produces energy."
            case .Biosphere: return "Responsible for producing food from plants and animals."
            case .Titanium: return "Extracts Titanium from the soil."
            case .Observatory: return "Enables scientific experiments."
            case .Antenna: return "Communication."
            case .Launchpad: return "Receives Space Vehicles."
            case .Arena: return "Gives entertainment to people."
            case .ETEC: return "Entertainment center provides entertainment."
//            default: return ""
        }
    }
    
    var validPosDexes:[Posdex] {
        switch self {
            case .HQ: return [Posdex.hq]
            case .Water: return [Posdex.mining1]
            case .Silica: return [Posdex.mining2]
            case .Energy: return [Posdex.power1, Posdex.power2, Posdex.power3, Posdex.power4]
            case .Biosphere: return [Posdex.biosphere1, Posdex.biosphere2]
            case .Titanium: return [Posdex.mining3]
            case .Observatory: return [Posdex.observatory]
            case .Antenna: return [Posdex.antenna]
            case .Launchpad: return [Posdex.launchPad]
            case .Arena: return [Posdex.arena]
            case .ETEC: return [Posdex.arena]
        }
    }
}

enum OutpostState:String, CaseIterable, Codable {
    case Ready      // Can be upgraded
    case Upgrading  // Upgrading (time)
    case Maxed      // No more upgrades
}

// Building up to here, an outpost has an OutpostJob, which sets the Level of the Outpost
// For a job. There is a lineup of people, and materials. Each one tracking back to Players
// When a job is ready to be executed (covered skills and ingredients), each person gets an Activity
// and there should be a trigger for setting the level up of the outpost

class Outpost:Codable {
    
    var id:UUID
    var guild:[String:UUID?]?
    
    var model:String = ""
    var posdex:Posdex
    
    var type:OutpostType
    
    var level:Int = 0
    var collected:Date?
    
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
    
    // MARK: - Production
    
    func production() -> OutpostSupply {
        return OutpostSupply(ingredients: [], tanks: [], peripherals: [], bioBoxes: [])
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
    // The above 2 functions should be private
    
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
    
    // MARK: - Supplied
    
    // DEPRECATE - SUBSTITUTE OUTPOSTSUPPLY
//    var materials:[Ingredient:Int] = [:]
    
    /// Stuff supplied so far
    var supplied:OutpostSupply
    
    /// `Player.id` vs `points`
    var contributed:[UUID:Int] = [:]
    
    // MARK: - Updates
    
    var activity:LabActivity?
    
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
                
            case .antenna: return nil
            case .arena: return nil
            case .launchPad: return nil
                
            case .observatory: return nil
                
                
            default: return nil
        }
    }
    
    /// DEPRECATE -> WORKS HORRIBLY
    /*
    func remaining() -> [Ingredient:Int]? {
        guard let job = getNextJob() else { return nil }
        
        var willRemain:[Ingredient:Int] = [:]
        
        for req in job.wantedIngredients {
            let iWant:Int = req.value
            let iHave:Int = materials[req.key] ?? 0
            if iWant - iHave > 0 {
                willRemain[req.key] = iWant - iHave
            } else {
                willRemain[req.key] = 0
            }
        }
        
        return willRemain
    }
    */
    
    func calculateRemaining() -> [String:Int] {
        
        var missingOut:[String:Int] = [:]
        
        // Ingredients & Boxes
        let iNeedBox:[Ingredient:Int] = getNextJob()?.wantedIngredients ?? [:]
        for (needKey, needVal) in iNeedBox {
            let current = supplied.ingredients.filter({ $0.type == needKey }).compactMap({$0.current}).reduce(0, +)
            if current >= needVal {
                // passed
            } else {
                missingOut[needKey.rawValue] = needVal - current
            }
        }
        
        // Tanks & Tanks
        // Peripherals & Type
        // People & Skills
        // Bioboxes & DNAOption
        
        return missingOut
    }
    
    // MARK: - Init
    
    init(type:OutpostType, posdex:Posdex, guild:UUID?) {
        self.id = UUID()
        self.guild = nil
        self.posdex = posdex
        self.type = type
        self.level = 0
        self.supplied = OutpostSupply()
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

/// Its calculated. Doesn't need to be `Codable` type
struct OutpostJob {
    // Ingredients
    var wantedIngredients:[Ingredient:Int]
    // Skills
    var wantedSkills:[Skills:Int]
    // Tanks
    var wantedTanks:[TankType:Int]?
    // Peripherals
    var wantedPeripherals:[PeripheralType:Int]?
    // Bioboxes
    var wantedBio:[DNAOption:Int]?
    
    /// Sum of all resources needed
    func maxScore() -> Int {
        let ing = wantedIngredients.values.reduce(0, +)
        let ski = wantedSkills.values.reduce(0, +)
        let tan = wantedTanks?.values.reduce(0, +) ?? 0
        let per = wantedPeripherals?.values.reduce(0, +) ?? 0
        let bio = wantedBio?.values.reduce(0, +) ?? 0
        
        return ing + ski + tan + per + bio
    }
}

/// The stuff being supplied to the outpost Job. Notice there are different objects
class OutpostSupply:Codable {
    
    var ingredients:[StorageBox]
    var tanks:[Tank]
    
    var skills:[Person] // Will need a reference later, to make busy
    // Bsides skills (people), everything else is consumable.
    
    var peripherals:[PeripheralObject]
    var bioBoxes:[BioBox]
    
    
    var players:[UUID:Int] // Player ID + Supplied points
    
    // MARK: - Initializers
    
    init() {
        self.ingredients = []
        self.tanks = []
        self.skills = []
        self.peripherals = []
        self.bioBoxes = []
        self.players = [:]
    }
    
    /// For Production use -> No players, no skills(People) are produced
    init(ingredients:[StorageBox], tanks: [Tank], peripherals: [PeripheralObject], bioBoxes: [BioBox]) {
        self.ingredients = ingredients
        self.tanks = tanks
        self.peripherals = peripherals
        self.bioBoxes = bioBoxes
        
        self.skills = []
        self.players = [:]
    }
    
    // MARK: - Contributions
    
    func contrib(box:StorageBox) {
        ingredients.append(box)
    }
    func contrib(tank:Tank) {
        tanks.append(tank)
    }
    
    func contribute(with box:StorageBox, player:SKNPlayer) {
        ingredients.append(box)
        guard let pid = player.serverID else { return }
        var pScore:Int = players[pid, default:0]
        pScore += 1
        players[pid] = pScore
    }
    
    /// Returns the count of all resources
    func supplyScore() -> Int {
        let ing = ingredients.map({ $0.current }).reduce(0, +)
        let tnk = tanks.map({ $0.current }).reduce(0, +)
        let skls = skills.flatMap({ $0.skills })
        let sumskills = skls.map({ $0.level }).reduce(0, +)
        let per = peripherals.count
        let bio = bioBoxes.map({ $0.population.count }).reduce(0, +)
        
        return ing + tnk + sumskills + per + bio
            // ingredients.count + tanks.count + skills.count + peripherals.count + bioBoxes.count
    }
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
        self.accounting = Date().addingTimeInterval(Double.random(in: 20...652))
        self.posdex = posdex.rawValue
    }
}

/**
 Energy, Water, Oxygen, Food
 */
struct Ewolf {
    
    var energy:Int
    var water:Int
    var oxygen:Int
    var food:Int
    
    init?(array:[Int]) {
        
        self.energy = 0
        self.water = 0
        self.food = 0
        self.oxygen = 0
        
        for idx in 0...3 {
            switch idx {
                case 0: self.energy = array[idx]
                case 1: self.water = array[idx]
                case 2: self.oxygen = array[idx]
                case 3: self.food = array[idx]
                default: print("Ewolf array count should be 4")
            }
        }
    }
}

