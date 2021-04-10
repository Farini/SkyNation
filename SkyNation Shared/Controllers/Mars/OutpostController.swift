//
//  OutpostController.swift
//  SkyNation
//
//  Created by Carlos Farini on 3/26/21.
//

import Foundation

enum OutpostViewTab:String, Codable, CaseIterable {
    
    case info // String? or Deprecate
    
    case ingredients
    case tanks
    case bioboxes
    case peripherals
    case people
    
    case contributions
    case management
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
    @Published var viewTab:OutpostViewTab = .info
    
    /// A KV pair for the items missing for outpost upgrades
    @Published var remains:[String:Int]
    
    init() {
        guard let player = LocalDatabase.shared.player else { fatalError() }
        self.player = player
        
        // MARK: - FIX THIS BEFORE LAUNCH
        // FIXME: - TEST EXAMPLES
        
        let dbData = DBOutpost.example()
        opData = Outpost.exampleFromDatabase(dbData: dbData)
        self.remains = Outpost.exampleFromDatabase(dbData: dbData).calculateRemaining()
    }
    
    func selected(tab:OutpostViewTab) {
        self.viewTab = tab
    }
    
    func makeContribution(object:Codable) {
        
        guard let pid = LocalDatabase.shared.player?.serverID else {
            print("No player id, or wrong id")
            return
        }
        
        print("Contributing...")
        
        if let box = object as? StorageBox {
            opData.supplied.ingredients.append(box)
        } else if let tank = object as? Tank {
            opData.supplied.tanks.append(tank)
        } else if let peripheral = object as? PeripheralObject {
            opData.supplied.peripherals.append(peripheral)
        } else if let bioBox = object as? BioBox {
            opData.supplied.bioBoxes.append(bioBox)
        } else if let person = object as? Person {
            opData.supplied.skills.append(person)
        } else {
            print("⚠️ REVISE THIS OBJECT: \(object)")
            print("⚠️ ERROR OBJECT INVALID")
        }
        
        // Contribution
        if let _ = opData.contributed[pid] {
            opData.contributed[pid]! += 1
        } else {
            opData.contributed[pid] = 1
        }
        
        // Check if fullfilled
        let remaining = opData.calculateRemaining()
        print("Remaining...")
        for (k, v) in remaining {
            print("\t \(k) \(v)")
        }
        self.remains = remaining
        
        // Save
        
    }
    
    func wantsIngredients() -> [Kevnii] {
        var array:[Kevnii] = []
        if let job = opData.getNextJob() {
            print("Job: \(job.wantedIngredients.count)")
            
            for (k, v) in opData.getNextJob()?.wantedIngredients ?? [:] {
                
                let have = myCity.boxes.filter({ $0.type == k }).compactMap({ $0.current }).reduce(0, +)
                let opHave = opData.supplied.ingredients.filter({ $0.type == k }).compactMap({ $0.current }).reduce(0, +)
                
                print("i need: \(v)")
                print("i have: \(have)")
                print("op has: \(opHave)")
                
                let kev = Kevnii(name: k.rawValue, iNeed: v, iHave: opHave)
                array.append(kev)
            }
        }
        return array
    }
    
    func wantsTanks() -> [Kevnii] {
        var array:[Kevnii] = []
        if let job = opData.getNextJob() {
            print("Job: \(job.wantedTanks?.count ?? 0)")
            
            for (k, v) in opData.getNextJob()?.wantedTanks ?? [:] {
                
                let have = myCity.tanks.filter({ $0.type == k }).compactMap({ $0.current }).reduce(0, +)
                let opHave = opData.supplied.tanks.filter({ $0.type == k }).compactMap({ $0.current }).reduce(0, +)
                
                print("i need: \(v)")
                print("i have: \(have)")
                print("op has: \(opHave)")
                
                let kev = Kevnii(name: k.rawValue, iNeed: v, iHave: opHave)
                array.append(kev)
            }
        }
        return array
    }
    
    func wantsSkills() -> [Kevnii] {
        var array:[Kevnii] = []
        if let job = opData.getNextJob() {
            print("Job: \(job.wantedSkills.count)")
            
            for (k, v) in opData.getNextJob()?.wantedSkills ?? [:] {
                
                let have = myCity.inhabitants.compactMap({$0.levelFor(skill: k)}).reduce(0, +)
                let opHave = opData.supplied.skills.compactMap({$0.levelFor(skill: k)}).reduce(0, +)
                
                print("i need: \(v)")
                print("i have: \(have)")
                print("op has: \(opHave)")
                
                let kev = Kevnii(name: k.rawValue, iNeed: v, iHave: opHave)
                array.append(kev)
            }
        }
        return array
    }
    
    func wantsPeripherals() -> [Kevnii] {
        var array:[Kevnii] = []
        if let job = opData.getNextJob() {
            print("Job: \(job.wantedPeripherals?.count ?? 0)")
            
            for (k, v) in opData.getNextJob()?.wantedPeripherals ?? [:] {
                
                let have = myCity.peripherals.filter({ $0.peripheral == k }).count
                let opHave = opData.supplied.peripherals.filter({ $0.peripheral == k }).count
                
                print("i need: \(v)")
                print("i have: \(have)")
                print("op has: \(opHave)")
                
                let kev = Kevnii(name: k.rawValue, iNeed: v, iHave: opHave)
                array.append(kev)
            }
        }
        return array
    }
    
    func wantsBio() -> [Kevnii] {
        var array:[Kevnii] = []
        if let job = opData.getNextJob() {
            print("Job: \(job.wantedBio?.count ?? 0)")
            
            for (k, v) in opData.getNextJob()?.wantedBio ?? [:] {
                
                let have = myCity.bioBoxes.filter({ $0.perfectDNA == k.rawValue }).count
                let opHave = opData.supplied.bioBoxes.filter({ $0.perfectDNA == k.rawValue }).count
                
                print("i need: \(v)")
                print("i have: \(have)")
                print("op has: \(opHave)")
                
                let kev = Kevnii(name: k.rawValue, iNeed: v, iHave: opHave)
                array.append(kev)
            }
        }
        return array
    }
    
}

extension OutpostViewTab {
    
    /// Name of the `Image` of this tab (systemImage)
    func imageName() -> String {
        switch self {
            case .ingredients: return "archivebox"
            case .people: return "person.2"
            case .bioboxes: return "leaf"
            case .tanks: return "gauge"
            case .peripherals: return "gearshape.2.fill"
            case .info: return "info.circle.fill"
            case .contributions: return "person.fill.checkmark"
            case .management: return "externaldrive"
//            default: return "questionmark"
        }
    }
    
    /// Name to display for help, and others
    func tabName() -> String {
        switch self {
            case .ingredients: return "Ingredients"
            case .people: return "People"
            case .info: return "Info"
            case .contributions: return "Contribution"
            case .management: return "Management"
            default: return self.rawValue.capitalized
        }
    }
    
}
