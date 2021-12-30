//
//  OutpostController.swift
//  SkyNation
//
//  Created by Carlos Farini on 3/26/21.
//

import Foundation

/**
 A Tab of the Outpost Views.
 */
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
    
    // Tab
    @Published var viewTab:OutpostViewTab = .info
    
    // Player Info
    @Published var player:SKNPlayer
    @Published var myCity:CityData = CityData.example()
    @Published var citizens:[PlayerContent] = []
    
    // MARK: - Outpost
    
    @Published var posdex:Posdex
    @Published var dbOutpost:DBOutpost
    @Published var outpostData:Outpost
    /// Current Supplied
    @Published var supply:OutpostSupply?
    
    // MARK: - Built Data
    
    /// Requirements for next job
    @Published var job:OutpostJob?
    /// List of Contributions per Citizen
    @Published var contribList:[ContributionScore] = []
    /// A KV pair for the items missing for outpost upgrades
    @Published var remains:[String:Int]
    
    // MARK: -  Data State
    
    /// Indicates when server has downloaded the latest version of `OutpostData`
    @Published var isDownloaded:Bool = false
    
    // has modified (contributed)
    @Published var hasContributions:Bool = false
    
    /// Current Round of contributions from this Player
    @Published var contribRound:OutpostSupply = OutpostSupply()
    
    // MARK: - Errors & Alerts
    
    @Published var serverError:String = ""
    @Published var deliveryError:String = ""
    @Published var displayError:Bool = false
    @Published var outpostUpgradeMessage:String = ""
    
    // MARK: - Methods
    
    /// Change this to generate random data - it needs to stay here, as opposed to GameSettings
    static var connectToServer:Bool = true
    
    init(dbOutpost:DBOutpost) {
        
        let player = LocalDatabase.shared.player
        self.player = player
        
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
            
            if let city = LocalDatabase.shared.cityData {
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
        
       
        self.player = LocalDatabase.shared.player
        
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
    
    // MARK: - Post init + Updates
    
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
        
        // Update Citizens
        if let servData = ServerManager.shared.serverData,
           let folks = servData.guildfc?.citizens {
            print("\n\n Folks in! \(folks.count) ")
            
            self.citizens = folks
        } else {
            print("\n\n no folks \n")
        }
        
    }
    
    /// Updates the other variables, dependent on OutpostData
    private func didUpdateOutpostData(newData:Outpost) {
        
        print("Did update data function")
        
        self.remains = newData.calculateRemaining()
        self.job = newData.getNextJob()
        self.supply = newData.supplied
        
        print("Supply score: \(newData.supplied.supplyScore())")
        
        let newContribList = self.getContributionScoreList(opData: newData)
        self.contribList = newContribList
        print("Contrib List Items Count: \(self.contribList.count)")
        
        self.isDownloaded = true
        
        if newData.level > dbOutpost.level {
            dbOutpost.level = newData.level
        }
//        self.dbOutpost.level = newData.level
        
        self.dbOutpost.state = newData.state
        
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
        
        list.sort(by: { $0.score > $1.score })
        
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
    
    // MARK: - Control
    
    /// Selecting a Tab
    func selected(tab:OutpostViewTab) {
        self.viewTab = tab
    }
    
    /// Add an object To `contribRound`
    func addToContribRound(object:Codable) {
        
        guard let pid = LocalDatabase.shared.player.playerID else {
            print("No player id, or wrong id")
            return
        }
        
        let round = OutpostSupply()
        
        if let box = object as? StorageBox {
            if self.contribRound.ingredients.contains(box) {
                self.contribRound.ingredients.removeAll(where: { $0.id == box.id })
            } else {
                round.ingredients.append(box)
            }
            
        } else if let tank = object as? Tank {
            round.tanks.append(tank)
        } else if let machine = object as? PeripheralObject {
            round.peripherals.append(machine)
        } else if let person = object as? Person {
            round.skills.append(person)
        } else if let bio = object as? BioBox {
            round.bioBoxes.append(bio)
        } else {
            print("⚠️ Contribution Object is neither of possible ones.")
        }
        
        guard round.supplyScore() > 0 else {
            print("⚠️ Contribution needs at least one item.")
            return
        }
        
        round.players[pid, default:0] += 1
        
        let oldRound = self.contribRound
        let newRound = OutpostSupply(merging: oldRound, with: round)
        
        self.contribRound = newRound
    }
    
    /// Makes an Outpost Contribution with what is selected (contribRound)
    func prepareDelivery() {
        
        // Get Contrib Round
        let newSupply:OutpostSupply = self.contribRound
        
        // Make sure there is at least one item
        if newSupply.supplyScore() < 1 {
            print("Need to supply something.")
            return
        }
        
        // Make sure outpost state is `.collecting`
        guard outpostData.state == .collecting else {
            print("To Contribute, State must be '.collecting'")
            return
        }
        
        // Make SKNS contribution
        SKNS.outpostContribution(outpost: self.outpostData, newSupply: newSupply) { newOPData, error in
            
            // Check if accepted (server response)
            if let newOPData = newOPData {
                DispatchQueue.main.async {
                    self.outpostData = newOPData
                    self.postDeliverySuccessUpdates(supplied: newSupply)
                }
            } else {
                if let contribError = error as? OPContribError {
                    print("Known Outpost Contribution Error.: \(contribError.localizedDescription)")
                    self.postDeliveryFail(contribError: contribError, error: nil)
                    
                } else if let error = error {
                    print("Unknown Outpost Contribution Error.: \(error.localizedDescription)")
                    self.postDeliveryFail(contribError: nil, error: error)
                } else {
                    print("Worst error possible (no error). Not sure how to recover from here")
                    self.postDeliveryFail(contribError: nil, error: nil)
                }
            }
        }
        
        /*
        Get Contrib Round
        Make sure there is at least one item
        Make sure outpost state is `.collecting`
            [YES]:
                Make SKNS contribution
                Check if accepted (server response)
                    [ACCEPTED]
                        Reset contribRound
                        Charge from city
                        SAVE CITY
                        *Separately* Merge with supply
                        Check if upgradable
                            [YES]:Request Update, Refresh OutpostData
                            [NO]: Refresh OutpostData
                
            [NO]:
                Display Problem
                    [Outdated]: Fetch Data Again
                    [Other]:    Update display
        */
        
    }
    
    // Upgrade Button clicked
    func upgradeButtonTapped() {
        
        print("\n\n [ Checking Upgrades ]")
        let previous = outpostData.state
        print("Previous State: \(previous)")
        
        let upgrade:OutpostUpgradeResult = outpostData.runUpgrade()
        
        switch upgrade {
            case .noChanges:
                print("No Changes \n\n")
                self.outpostUpgradeMessage = "No updates."
                return
                
            case .dateUpgradeShouldBeNil, .needsDateUpgrade:
                print("Error with dates being nil, or whatnot \n\n")
                self.outpostUpgradeMessage = "Internal Error (Dates)"
                return
                
            case .nextState(let state):
                print("Next State: \(state). Applying for upgrades")
                // this will be: .cooldown, or .finished
                self.applyForUpgrade(upgrade)
                
            case .applyForLevelUp(currentLevel: let level):
                print("Should Apply for level up. Current:\(level), next:\(level + 1). Applying for upgrades")
                self.applyForUpgrade(upgrade)
                
        }
    }
    
    // MARK: - Upgrades and Updates
    
    // Only call when you're sure that an upgrade can be done
    private func applyForUpgrade(_ upgrade:OutpostUpgradeResult) {
        
        switch upgrade {
            case .needsDateUpgrade, .dateUpgradeShouldBeNil, .noChanges:
                print("Invalid state for upgrade")
                return
                
            default:break
        }
   
        SKNS.applyForOutpostUpgrades(outpost: self.outpostData, upgrade: upgrade) { newOutpostData, error in
            
            if let newOutpost:Outpost = newOutpostData {
                DispatchQueue.main.async {
                    
                    print("Did receive new Outpost Data")
                    print("Outpost Upgraded")
                    self.serverError = ""
                    self.deliveryError = ""
                    self.displayError = false
                    
                    self.outpostData = newOutpost
                    self.outpostUpgradeMessage = "Outpost Upgraded"
                    
                    // TODO: Needs to update dbOutpost as well.
                    // or at least update properties.
                    // the correct way would be to fetch GuildMap again.
                    // but for now lets just update the dboutpost properties
                    self.didUpdateOutpostData(newData: newOutpost)
                    self.postUpgradeGuildFetch()
                }
            } else {
                
                DispatchQueue.main.async {
                    if let error = error {
                        self.serverError = error.localizedDescription
                        self.deliveryError = ""
                    }
                    self.outpostUpgradeMessage = "Error"
                    self.displayError = true
                }
            }
        }
    }
    
    /// DBOutpost needs to be fetched after upgrading OutpostData.
    private func postUpgradeGuildFetch() {
        
        let outpostID:UUID = self.outpostData.id
        
        // needs to fetch new DBOutpost after upgrades
        ServerManager.shared.requestGuildMap { gMap, error in
            
            if let gMap:GuildMap = gMap,
               let dbo = gMap.outposts.first(where: { $0.id == outpostID }) {
                DispatchQueue.main.async {
                    self.dbOutpost = dbo
                }
                return
            } else {
                // Error: Could not get new Outpost
                if let error = error {
                    DispatchQueue.main.async {
                        self.serverError = "Error. Could not get outpost updates. \(error.localizedDescription)"
                        self.outpostUpgradeMessage = "Error. Could not get outpost updates. \(error.localizedDescription)"
                    }
                }
            }
        }
        
        /*
        // needs to fetch new DBOutpost after upgrades
        ServerManager.shared.inquireFullGuild(force: true) { fullGuild, error in
            if let guild:GuildFullContent = fullGuild {
                let dbo = guild.outposts.first(where: { $0.id == outpostID })!
                self.dbOutpost = dbo
                
            }
        }
        */
    }
    
    /// Delivery success.:
    private func postDeliverySuccessUpdates(supplied:OutpostSupply) {
        
        self.deliveryError = ""
        
        // Charge from City
        for box in supplied.ingredients {
            myCity.boxes.removeAll(where: { $0.id == box.id })
        }
        
        for tank in supplied.tanks {
            myCity.tanks.removeAll(where: { $0.id == tank.id })
        }
        for machine in supplied.peripherals {
            myCity.peripherals.removeAll(where: { $0.id == machine.id })
        }
        
        for bio in supplied.bioBoxes {
            myCity.bioBoxes.removeAll(where: { $0.id == bio.id })
        }
        
        // People (Activity)
        for skp in supplied.skills {
            let person = myCity.inhabitants.first(where: { $0.id == skp.id })
            let activity = LabActivity(time: 60.0 * 60.0 * 24.0, name: "Outpost help")
            person?.activity = activity
        }
        
        // Save City
        do {
            try LocalDatabase.shared.saveCity(myCity)
        } catch {
            print("Error saving City")
        }
        
        // Reset contribRound
        self.contribRound = OutpostSupply()
        
    }
    
    private func postDeliveryFail(contribError:OPContribError?, error:Error?) {
        if let contError = contribError {
            self.deliveryError = contError.localizedDescription
        } else {
            self.deliveryError = error?.localizedDescription ?? "Unknown error"
        }
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
