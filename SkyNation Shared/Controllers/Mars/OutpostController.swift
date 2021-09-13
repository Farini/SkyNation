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
    
    // Outpost
    @Published var posdex:Posdex
    @Published var dbOutpost:DBOutpost
    @Published var outpostData:Outpost
    /// Current Supplied
    @Published var supply:OutpostSupply?
    /// Requirements for next job
    @Published var job:OutpostJob?
    /// List of Contributions per Citizen
    @Published var contribList:[ContributionScore] = []
    
    // Guild
    // var Guild
    @Published var citizens:[PlayerContent] = []
    
    // View States
    // outpost state
    // contributions
    // has downloaded
    @Published var isDownloaded:Bool = false
    
    // has modified (contributed)
    @Published var hasContributions:Bool = false
//    @Published var myContributions:OutpostSupply = OutpostSupply()
    
    
    
    // Errors, Alerts & Messages
    @Published var fake:String = ""
    @Published var serverError:String = ""
    @Published var displayError:Bool = false
    
    // Guild
    
    // Player Cards
    
    // Tab
    @Published var viewTab:OutpostViewTab = .info
    
    /// A KV pair for the items missing for outpost upgrades
    @Published var remains:[String:Int]
    
    // MARK: - Methods
    
    /// Change this to generate random data - it needs to stay here, as opposed to GameSettings
    static var connectToServer:Bool = true
    
    init(dbOutpost:DBOutpost) {
        
        guard let player = LocalDatabase.shared.player else { fatalError() }
        self.player = player
        
        
        /*
         0. Contribution Request
         1 - If OutpostData has not been created, make a request for 'createOutpostData'
         2 - If you can't find outpost data from 'ServerManager', initialize outpost from DBOutpost,
         and wait for server response
         3 - Server response may ask you to create it, because not found.
         */
        
//        let opData = Outpost(dbOutpost: dbOutpost)
//        self.outpostData = opData
        
        // Wait for response from server, to make sure it hasn't been created already
        
        
        
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
        
        if !OutpostController.connectToServer {
            
            // No Connection - Random Data
            let outPostData = Outpost.exampleFromDatabase(dbData: dbOutpost)
            outpostData = outPostData
            
            self.remains = outPostData.calculateRemaining()
            self.job = outPostData.getNextJob()
            self.supply = outPostData.supplied
            
        } else {
            
            // Connect to server to update the rest of required data with blank stuff
            let opData = Outpost(dbOutpost: dbOutpost)
            self.outpostData = opData
            
            if let city = LocalDatabase.shared.loadCity() {
                self.myCity = city
            }
            
            /// Simulate data if needed
            if GameSettings.onlineStatus == false {
                // not online (simulating random data)
                self.remains = opData.calculateRemaining()
                self.job = opData.getNextJob()
                self.supply = opData.supplied
                
            } else {
                // online
                self.remains = [:] //opData.calculateRemaining()
                self.job = nil // Needs to wait for server to update
                self.supply = OutpostSupply()
                
                self.verifyOutpostDataUpdate()
            }
        }
    }
    
    /// Initializer for Previews
    init(random:Bool = true) {
        
        guard let player = LocalDatabase.shared.player else { fatalError() }
        self.player = player
        
        let op:DBOutpost = DBOutpost.example()
        self.dbOutpost = op
        
        let outPostData = Outpost.exampleFromDatabase(dbData: op)
        self.posdex = Posdex(rawValue: op.posdex)!
        
        outpostData = outPostData
        self.remains = outPostData.calculateRemaining()
        
        // Post Init
        if let job = outPostData.getNextJob() {
            self.job = job
        }
        self.supply = outPostData.supplied
    }
    
    private var hasReqOutpost:Bool = false
    
    // MARK: - Post init Outpost Data Request
    
    /// Post init method to update the view, that starts with a blank outpost
    private func verifyOutpostDataUpdate() {
        
        print("Fetching Outpost Data")
        // 1. Request Outpost
        // 2. Check outpost, Update here (self.outpostData)
        ServerManager.shared.requestOutpostData(dbOutpost: self.dbOutpost, force:!hasReqOutpost) { opData, error in
            
            DispatchQueue.main.async {
                
                if let opData = opData {
                    self.outpostData = opData
                    self.displayError = false
                    self.serverError = ""
                    self.hasReqOutpost = true
                    self.didUpdateOutpostData(newData: opData)
                    
                } else {
                    let errorString = error?.localizedDescription ?? "Could not retrieve Outpost Data"
                    self.serverError = errorString
                    self.hasReqOutpost = false
                    self.displayError = true
                    
                }
            }
        }
        
        if let servData = ServerManager.shared.serverData,
           let folks = servData.guildfc?.citizens {
            print("\n\n Folks in! \(folks.count) ")
            
            self.citizens = folks
        } else {
            print("\n\n no folks \n")
        }
        
//        ServerManager.shared.inquireFullGuild(force: false) { fullGuild, error in
//            print("Requesting Folks")
//            if let folks = fullGuild?.citizens {
//                print("Found Folks")
//                DispatchQueue.main.async {
//
//                }
//            }
//        }
    }
    
    /// Updates the other variables, dependent on OutpostData
    private func didUpdateOutpostData(newData:Outpost) {
        
        print("\n\n Did update data function")
        
        self.remains = newData.calculateRemaining()
        self.job = newData.getNextJob()
        self.supply = newData.supplied
        
        print("Supply score: \(newData.supplied.supplyScore())")
        
        let newContribList = self.getContributionScoreList(opData: newData)
        self.contribList = newContribList
        print("Contrib List Items Count: \(self.contribList.count)")
        
        self.isDownloaded = true
        
    }
    
    /// Assembles the list of contributions.
    private func getContributionScoreList(opData:Outpost) -> [ContributionScore] {
        
        print("Contrib Score List")
        
        let rawList = outpostData.contributed
        print(rawList.description)
        let citiList = self.citizens
        print("-")
        print(citiList.compactMap({ $0.id }))
        
        for r in citiList.compactMap({ $0.id }) {
            let str = r.uuidString
            if let item = rawList[r] {
                print("!!! \(str) = \(item) !!!")
            }
        }
        
        var list:[ContributionScore] = []
        
        for (pid, score) in rawList {
            if let citizen = citizens.first(where: { $0.id == pid }) {
                let newItem = ContributionScore(citizen: citizen, score: score)
                list.append(newItem)
            }
        }
        return list
    }
    
    /// A public method to update the `OutpostData` variables
    func updateOutpostData() {
        if GameSettings.onlineStatus && OutpostController.connectToServer {
            self.verifyOutpostDataUpdate()
        } else {
            self.didUpdateOutpostData(newData: self.outpostData)
        }
    }
    
//    print("⚠️ REVISE THIS OBJECT: \(object)")
    
    // MARK: - Control
    
    /// Selecting a Tab
    func selected(tab:OutpostViewTab) {
        self.viewTab = tab
    }
    
    /// Makes the contribution, but doesn't charge from City
    func makeContribution(object:Codable, type:ContributionType) {
        
        guard let pid = LocalDatabase.shared.player?.playerID else {
            print("No player id, or wrong id")
            return
        }
        
        if let box = object as? StorageBox {
            fake += " + box"
            
            // SKNS.contributionRequest(box:box) { response in
            outpostData.supplied.ingredients.append(box)
            outpostData.supplied.players[pid, default:0] += box.current
            
//            myCity.boxes.removeAll(where: { $0.id == box.id })
            
        } else if let tank = object as? Tank {
            
            outpostData.supplied.tanks.append(tank)
//            myCity.tanks.removeAll(where: { $0.id == tank.id })
            
        } else if let peripheral = object as? PeripheralObject {
            
            outpostData.supplied.peripherals.append(peripheral)
//            myCity.peripherals.removeAll(where: { $0.id == peripheral.id })
            
        } else if let bioBox = object as? BioBox {
            
            outpostData.supplied.bioBoxes.append(bioBox)
//            myCity.bioBoxes?.removeAll(where: { $0.id == bioBox.id })
            
        } else if let person = object as? Person {
            
            outpostData.supplied.skills.append(person)
            if let person = myCity.inhabitants.first(where: { $0.id == person.id }) {
                let newActivity = LabActivity(time: 1000, name: "Working at Outpost")
                person.activity = newActivity
            }
            
        } else {
            print("⚠️ REVISE THIS OBJECT: \(object)")
            print("⚠️ ERROR OBJECT INVALID")
        }
        
        // Contribution
        let opData:Outpost = self.outpostData
        var lastContributes = opData.contributed
        lastContributes[pid, default:0] += 1
        self.outpostData.contributed = lastContributes
        
        let newContribList = self.getContributionScoreList(opData: opData)
        self.contribList = newContribList
        print("Contrib List Items Count: \(self.contribList.count)")
        
        // Check Remaining
        
        let remaining = outpostData.calculateRemaining()
        self.remains = remaining
        
        // Make the request
        // SKNS.contributionRequest(object: object, type: type, outpost: outpostData)
        
    }
    
    // MARK: - Requirements
    
    func wantsIngredients() -> [KeyvalComparator] {
        var array:[KeyvalComparator] = []
        if let job = outpostData.getNextJob() {
            print("Job: \(job.wantedIngredients.count)")
            
            for (k, v) in outpostData.getNextJob()?.wantedIngredients ?? [:] {
                
                let have = myCity.boxes.filter({ $0.type == k }).compactMap({ $0.current }).reduce(0, +)
                let opHave = outpostData.supplied.ingredients.filter({ $0.type == k }).compactMap({ $0.current }).reduce(0, +)
                
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
        if let job = outpostData.getNextJob() {
            print("Job: \(job.wantedTanks?.count ?? 0)")
            
            for (k, v) in outpostData.getNextJob()?.wantedTanks ?? [:] {
                
                let have = myCity.tanks.filter({ $0.type == k }).compactMap({ $0.current }).reduce(0, +)
                let opHave = outpostData.supplied.tanks.filter({ $0.type == k }).compactMap({ $0.current }).reduce(0, +)
                
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
        if let job = outpostData.getNextJob() {
            print("Job: \(job.wantedSkills.count)")
            
            for (k, v) in outpostData.getNextJob()?.wantedSkills ?? [:] {
                
                let have = myCity.inhabitants.compactMap({$0.levelFor(skill: k)}).reduce(0, +)
                let opHave = outpostData.supplied.skills.compactMap({$0.levelFor(skill: k)}).reduce(0, +)
                
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
        if let job = outpostData.getNextJob() {
            print("Job: \(job.wantedPeripherals?.count ?? 0)")
            
            for (k, v) in outpostData.getNextJob()?.wantedPeripherals ?? [:] {
                
                let have = myCity.peripherals.filter({ $0.peripheral == k }).count
                let opHave = outpostData.supplied.peripherals.filter({ $0.peripheral == k }).count
                
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
        if let job = outpostData.getNextJob() {
            print("Job: \(job.wantedBio?.count ?? 0)")
            
            for (k, v) in outpostData.getNextJob()?.wantedBio ?? [:] {
                
                let have = myCity.bioBoxes.filter({ $0.perfectDNA == k.rawValue }).count
                let opHave = outpostData.supplied.bioBoxes.filter({ $0.perfectDNA == k.rawValue }).count
                
                print("i need: \(v)")
                print("i have: \(have)")
                print("op has: \(opHave)")
                
                let kev = KeyvalComparator(name: k.rawValue, needs: v, supplied: opHave)
                array.append(kev)
            }
        }
        return array
    }
    
    // MARK: - Upgrades and Updates
    
    
    
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
    
    
        let previous = outpostData.state
        print("Previous State: \(previous)")
        
        let upgrade = outpostData.runUpgrade()
        switch upgrade {
            case .noChanges: print("No Changes")
            case .dateUpgradeShouldBeNil, .needsDateUpgrade: print("Error")
            case .nextState(let state): print("Next State: \(state)")
            case .applyForLevelUp(currentLevel: let level): print("Should Apply for level up. Current:\(level), next:\(level + 1)")
            //                default: print("Not ready")
        }
    }
}

struct ContributionScore:Identifiable {
    
    var id:UUID
    var citizen:PlayerContent
    var score:Int
    
    init(citizen:PlayerContent, score:Int) {
        self.id = UUID()
        self.citizen = citizen
        self.score = score
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
