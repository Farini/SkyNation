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

enum ContributionType {
    case box, tank, person, machine, bioBox
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
    
    // DEPRECATE 3 BELOW
    
    /// Current Supplied
    @Published var supply:OutpostSupply?
    
    /// Requirements for next job
    @Published var job:OutpostJob?
    
    @Published var fake:String = ""
    
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
        
        self.job = outPostData.getNextJob()
        self.supply = outPostData.supplied
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
        
        // Post Init
        if let job = outPostData.getNextJob() {
            self.job = job
        }
        self.supply = outPostData.supplied
    }
    
    /// Selecting a Tab
    func selected(tab:OutpostViewTab) {
        self.viewTab = tab
    }
    
    /// Called every time user taps on a resource. Adds it to supplied
    func makeContribution(object:Codable, type:ContributionType) {
        
        guard let pid = LocalDatabase.shared.player?.serverID else {
            print("No player id, or wrong id")
            return
        }
        
        print("Contributing...")
        fake += "Contributing"
        
        // Notes: The idea is to check whether we contributed (with the server)
        // and with the server's response, remove item from city (or make person busy)
        // See the comment on "box" below
        
        switch type {
            case .box:
                
                guard let box = object as? StorageBox else { return }
                print("Contribute a box \(box.type)")
                
                SKNS.contributionRequest(object: box, type: type, outpost: opData)
            
            default:break
        }
        
        if let box = object as? StorageBox {
            fake += " + box"
            
            // SKNS.contributionRequest(box:box) { response in
            opData.supplied.ingredients.append(box)
            opData.supplied.players[pid, default:0] += box.current
            
            myCity.boxes.removeAll(where: { $0.id == box.id })
            
        } else if let tank = object as? Tank {
            
            opData.supplied.tanks.append(tank)
            myCity.tanks.removeAll(where: { $0.id == tank.id })
            
        } else if let peripheral = object as? PeripheralObject {
            
            opData.supplied.peripherals.append(peripheral)
            myCity.peripherals.removeAll(where: { $0.id == peripheral.id })
            
        } else if let bioBox = object as? BioBox {
            
            opData.supplied.bioBoxes.append(bioBox)
            myCity.bioBoxes?.removeAll(where: { $0.id == bioBox.id })
            
        } else if let person = object as? Person {
            
            opData.supplied.skills.append(person)
            if let person = myCity.inhabitants.first(where: { $0.id == person.id }) {
                let newActivity = LabActivity(time: 1000, name: "Working at Outpost")
                person.activity = newActivity
            }
            
        } else {
            print("⚠️ REVISE THIS OBJECT: \(object)")
            print("⚠️ ERROR OBJECT INVALID")
        }
        
        // Contribution
        
            opData.contributed[pid, default:0] += 1
        
            //opData.contributed[pid] = 1
        
        
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
    func checkUpgrades() {
        
        // Outpost State
        // 1. Working (upgradable)
        // 2. NoLevel (not upgradable)
        // 3. Locked (computing)
        // 4. Upgrading
    
    
        let previous = opData.state
        
        let next = opData.eligibleForState()
        switch next {
            case .dateUpgradeShouldBeNil:
                opData.dateUpgrade = nil
                self.checkUpgrades()
            case .needsDateUpgrade:
                print("Needs date upgrade")
            case .level(let level):
                if level == previous {
                    // same level. Do nothing
                } else {
                    // upgraded level
                    // contact server
                }
            case .wrongUpdate:
                // Show error message
            print("Error. Wrong update. This shouldn't happen")
        }
    }
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
