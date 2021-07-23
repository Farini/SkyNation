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
    case peopleSkills
    
    case contributions
    case management
}

class OutpostController:ObservableObject {
    
    var builder:MarsBuilder = MarsBuilder.shared
    
    @Published var player:SKNPlayer
    @Published var myCity:CityData = CityData.example()
    
    // Posdex
    @Published var posdex:Posdex
    
    // DBOutpost
    @Published var dbOutpost:DBOutpost
    
    // OutpostData
    @Published var opData:Outpost
    
    // Guild
    // Player Cards
    
    // Tab
    @Published var viewTab:OutpostViewTab = .info
    
    /// A KV pair for the items missing for outpost upgrades
    @Published var remains:[String:Int]
    
    init(dbOutpost:DBOutpost) {
        guard let player = LocalDatabase.shared.player else { fatalError() }
        self.player = player
        
        // MARK: - FIX THIS BEFORE LAUNCH
        // FIXME: - TEST EXAMPLES
        
        // Data needed:         Preview Origin          Prod. Origin
        // 1. my CityData       [example]               [json file]
        // 2. DBOutpost         [example]               [server]
        //  a. posdex
        // 3. Outpost object    [example]               [server]
        //  a. supplied
        // 4. Guild Players     [none]                  [server]
        
        self.dbOutpost = dbOutpost
        self.posdex = Posdex(rawValue: dbOutpost.posdex)!
        let outPostData = Outpost.exampleFromDatabase(dbData: dbOutpost)
        
        opData = outPostData
        self.remains = outPostData.calculateRemaining()
    }
    
    /// Initializer for Previews
    init(random:Bool = true) {
        
        guard let player = LocalDatabase.shared.player else { fatalError() }
        self.player = player
        
        let op:DBOutpost = DBOutpost.example()
        self.dbOutpost = op
        
        let outPostData = Outpost.exampleFromDatabase(dbData: op)
        self.posdex = Posdex(rawValue: op.posdex)!
        
        opData = outPostData
        self.remains = outPostData.calculateRemaining()
    }
    
    /// Selecting a Tab
    func selected(tab:OutpostViewTab) {
        self.viewTab = tab
    }
    
    /// Called every time user taps on a resource. Adds it to supplied
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
        
        // Update Server, and Save
        
    }
    
    // MARK: - Requirements
    
    func wantsIngredients() -> [KeyvalComparator] {
        var array:[KeyvalComparator] = []
        if let job = opData.getNextJob() {
            print("Job: \(job.wantedIngredients.count)")
            
            for (k, v) in opData.getNextJob()?.wantedIngredients ?? [:] {
                
                let have = myCity.boxes.filter({ $0.type == k }).compactMap({ $0.current }).reduce(0, +)
                let opHave = opData.supplied.ingredients.filter({ $0.type == k }).compactMap({ $0.current }).reduce(0, +)
                
                print("i need: \(v)")
                print("i have: \(have)")
                print("op has: \(opHave)")
                
                let kev = KeyvalComparator(name: k.rawValue, needs: v, supplied: opHave)
                array.append(kev)
            }
        }
        return array
    }
    
    func wantsTanks() -> [KeyvalComparator] {
        var array:[KeyvalComparator] = []
        if let job = opData.getNextJob() {
            print("Job: \(job.wantedTanks?.count ?? 0)")
            
            for (k, v) in opData.getNextJob()?.wantedTanks ?? [:] {
                
                let have = myCity.tanks.filter({ $0.type == k }).compactMap({ $0.current }).reduce(0, +)
                let opHave = opData.supplied.tanks.filter({ $0.type == k }).compactMap({ $0.current }).reduce(0, +)
                
                print("i need: \(v)")
                print("i have: \(have)")
                print("op has: \(opHave)")
                
                let kev = KeyvalComparator(name: k.rawValue, needs: v, supplied: opHave)
                array.append(kev)
            }
        }
        return array
    }
    
    func wantsSkills() -> [KeyvalComparator] {
        var array:[KeyvalComparator] = []
        if let job = opData.getNextJob() {
            print("Job: \(job.wantedSkills.count)")
            
            for (k, v) in opData.getNextJob()?.wantedSkills ?? [:] {
                
                let have = myCity.inhabitants.compactMap({$0.levelFor(skill: k)}).reduce(0, +)
                let opHave = opData.supplied.skills.compactMap({$0.levelFor(skill: k)}).reduce(0, +)
                
                print("i need: \(v)")
                print("i have: \(have)")
                print("op has: \(opHave)")
                
                let kev = KeyvalComparator(name: k.rawValue, needs: v, supplied: opHave)
                array.append(kev)
            }
        }
        return array
    }
    
    func wantsPeripherals() -> [KeyvalComparator] {
        var array:[KeyvalComparator] = []
        if let job = opData.getNextJob() {
            print("Job: \(job.wantedPeripherals?.count ?? 0)")
            
            for (k, v) in opData.getNextJob()?.wantedPeripherals ?? [:] {
                
                let have = myCity.peripherals.filter({ $0.peripheral == k }).count
                let opHave = opData.supplied.peripherals.filter({ $0.peripheral == k }).count
                
                print("i need: \(v)")
                print("i have: \(have)")
                print("op has: \(opHave)")
                
                let kev = KeyvalComparator(name: k.rawValue, needs: v, supplied: opHave)
                array.append(kev)
            }
        }
        return array
    }
    
    func wantsBio() -> [KeyvalComparator] {
        var array:[KeyvalComparator] = []
        if let job = opData.getNextJob() {
            print("Job: \(job.wantedBio?.count ?? 0)")
            
            for (k, v) in opData.getNextJob()?.wantedBio ?? [:] {
                
                let have = myCity.bioBoxes?.filter({ $0.perfectDNA == k.rawValue }).count ?? 0
                let opHave = opData.supplied.bioBoxes.filter({ $0.perfectDNA == k.rawValue }).count
                
                print("i need: \(v)")
                print("i have: \(have)")
                print("op has: \(opHave)")
                
                let kev = KeyvalComparator(name: k.rawValue, needs: v, supplied: opHave)
                array.append(kev)
            }
        }
        return array
    }
    
    /* Continue... */
    // Notes:
    // Needs more logic when contributing (server request)
    // Check if contribution went through
    
    // Outpost State
    // 1. Working (upgradable)
    // 2. NoLevel (not upgradable)
    // 3. Locked (computing)
    // 4. Upgrading
}

extension OutpostViewTab {
    
    /// Name of the `Image` of this tab (systemImage)
    func imageName() -> String {
        switch self {
            case .ingredients: return "archivebox"
            case .peopleSkills: return "person.2"
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
            case .peopleSkills: return "People"
            case .info: return "Info"
            case .contributions: return "Contribution"
            case .management: return "Management"
            default: return self.rawValue.capitalized
        }
    }
    
}



/**
 Compares Keys and values for requirements vs supplied.
 */
struct KeyvalComparator:Identifiable {
    
    var id = UUID()
    var name:String
    
    /// Amount required
    var needs:Int
    
    /// Amount supplied
    var supplied:Int
    
    var missing:Int {
        return supplied - needs
    }
    
    
}

/*
/// Compares Keys and values for requirements vs supplied.
struct KeyValComparer:Identifiable {
    
    var id = UUID()
    var name:String
    var needs:Int
    var supplied:Int
    
    init(name:String, needs:Int, supplied:Int) {
        self.name = name
        self.needs = needs
        self.supplied = supplied
    }
    
    var missing:Int {
        return supplied - needs
    }
}
*/
