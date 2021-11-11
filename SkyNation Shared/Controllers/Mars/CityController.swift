//
//  CityController.swift
//  SkyNation
//
//  Created by Carlos Farini on 3/20/21.
//

import Foundation

/// The Status of a CityView
enum MarsCityStatus {
    case loading                    // Data not loaded yet
    case unclaimed                  // City has no owner
    case foreign(pid:UUID)          // Belongs to someone else
    case mine(cityData:CityData)    // Belongs to Player
}

/**
    My CityController vs. ForeignCityController
        
        Foreign City - Uses MarsCityStatus
        MyCity - Uses LocalCityState?
*/

class CityController:ObservableObject, BioController {
    
    var builder:MarsBuilder
    @Published var player:SKNPlayer
    @Published var cityTitle:String = "Unclaimed City"
    
    // View States
    @Published var viewState:MarsCityStatus
    
    // City Info
    @Published var city:DBCity?
    @Published var cityData:CityData?
    @Published var ownerID:UUID?
    @Published var isMyCity:Bool = false
    @Published var isClaimedCity:Bool = true
    
    // Guild, and Outpost Collection
    @Published var collectables:[String] = []
    @Published var opCollectArray:[CityCollectOutpostModel] = []
    
    /// Selection item for Lab View
    @Published var labSelection:CityLabState = .NoSelection
    @Published var labActivity:LabActivity?
    
    // Vehicles
    @Published var arrivedVehicles:[SpaceVehicle]
    @Published var travelVehicles:[SpaceVehicle]
    
    // People
    @Published var availableStaff:[Person] = []
    @Published var selectedStaff:[Person] = []
    
    @Published var unlockedTech:[CityTech] = []
    
    // Errors & Warnings
    @Published var warnings:[String] = []
    
    
    init() {
        
        let player = LocalDatabase.shared.player // else { fatalError() }
        self.player = player
        
        self.builder = MarsBuilder.shared
        viewState = .loading
        
        if let cd = LocalDatabase.shared.cityData {
            self.cityData = cd
            
            if let labActivity = cd.labActivity {
                self.labActivity = labActivity
                self.labSelection = .activity(object: labActivity)
            }
            
            self.availableStaff = cd.inhabitants.filter({ $0.isBusy() == false })
            self.arrivedVehicles = cd.garage.vehicles // LocalDatabase.shared.cityData?.garage.vehicles ?? []
        } else {
            self.arrivedVehicles = []
        }
        
        // Vehicles initial state
        let vehicles = LocalDatabase.shared.vehicles
        print("Initting with vehicles.: \(vehicles.count)")
        
        self.travelVehicles = vehicles
        
        
        // Post Init
        
        // Outpost Collectables
        self.updateCityOutpostCollection()
        
    }
    
    /// Loads the city at the correct `Posdex`
    func loadAt(posdex:Posdex) {
        
        if let theCity:DBCity = builder.cities.filter({ $0.posdex == posdex.rawValue }).first {
            
            print("The City: \(theCity.name)")
            self.city = theCity
            self.cityTitle = theCity.name
            
            let cityOwner = theCity.owner ?? [:]
            
            if let ownerID = cityOwner["id"] as? UUID {
                print("Owner ID: \(ownerID)")
                
                // My City
                if player.playerID == ownerID {
                    print("PLAYER OWNS IT !!!!")
                    isMyCity = true
                    
                    // Load City (New Method)
                    if let localCity:CityData = LocalDatabase.shared.cityData {
                        
                        print("Local City Data in")
                        
                        // Update main City Data Object
                        self.cityData = localCity
                        self.viewState = .mine(cityData: localCity)
                        
                        // Update Staff
                        self.availableStaff = localCity.inhabitants.filter({ $0.isBusy() == false })
                        self.unlockedTech = CityTechTree().unlockedTechAfter(doneTech: localCity.tech)
                        
                    } else {
                        
                        print("Try to save city")
                        
                        //                            do {
                        //                                try LocalDatabase.shared.saveCity(cityData)
                        //                            } catch {
                        //                                print("⚠️ ERROR loading city data")
                        //                            }
                    }
                    
                    print("Setting CityData")
                    
                    //                        self.cityData = cityData
                    //                        self.viewState = .mine(cityData: cityData)
                    self.updateVehiclesLists()
                    
                }
            }
        } else {
            // Unclaimed
            print("This is an unclaimed city")
            isMyCity = false
            isClaimedCity = false
            viewState = .unclaimed
        }
        
    }
    
    // MARK: - Claiming
    
    /// Checks if player can claim city
    func isClaimable() -> Bool {
        
        if city?.owner != nil { return false }
        let dbc = builder.cities.compactMap({ $0.id })
        if dbc.contains(self.player.cityID ?? UUID()) {
            return false
        } else {
            return true
        }
    }
    
    /// Claims the city for the Player
    func claimCity(posdex:Posdex) {
        
        // FIXME: - Develop this
        // Save CityData?
        // the self.loadAt might need updates
        
        SKNS.claimCity(posdex: posdex) { (city, error) in
            
            // This request should return a DBCity instead
            if let dbCity = city {
                
                print("We have a new city !!!! \t \(dbCity.id)")
                
                var localCity:CityData!
                
                // First, check if player alread has a city in LocalDatabase
                if let savedCity:CityData = LocalDatabase.shared.cityData {
                    
                    // We have a local city saved. Update ID
                    savedCity.id = dbCity.id
                    localCity = savedCity
                    
                } else {
                    localCity = CityData(dbCity: dbCity)
                }
                
                try? LocalDatabase.shared.saveCity(localCity)
                
                let player = self.player
                player.cityID = dbCity.id
                
                do {
                    try LocalDatabase.shared.savePlayer(player)
                } catch {
                    print("Could not save Player. Error.: \(error.localizedDescription)")
                }
                // let res = LocalDatabase.shared.savePlayer(player: player)
                
                // print("Claim city results Saved. Player:\(res)")
                
                // Get Vehicles from 'Travelling.josn'
                
                // Reload GuildFullContent
                //                ServerManager.shared.inquireFullGuild { fullGuild, error in
                //
                //                }
                
            } else {
                print("No City. Error: \(error?.localizedDescription ?? "n/a")")
            }
        }
    }
    
    // MARK: - Vehicles
    
    /// Gets all vehicles that arrived
    func updateVehiclesLists() {
        
        switch viewState {
            case .loading:
                print("Still loading")
                return
            case .unclaimed:
                print("Unclaimed cities don't need vehicles")
                return
            case .foreign(_):
                print("This city is someone else's")
                return
            default:break
        }
        
        print("Getting Arrived Vehicles")
        
        // Get the list of Vehicles in LocalDatabase - Travelling
        let travelList:[SpaceVehicle] = LocalDatabase.shared.vehicles
        
        // Separate in 2 lists: Travelling, and transferring (arriving)
        var travelling:[SpaceVehicle] = []
        var transferring:[SpaceVehicle] = []
        
        for vehicle in travelList {
            
            // Travel must have started
            guard let travelStart = vehicle.dateTravelStarts else { continue }
            
            let arrival:Date = travelStart.addingTimeInterval(GameLogic.vehicleTravelTime)
            if arrival.compare(Date()) == .orderedAscending {
                // Arrived
                transferring.append(vehicle)
            } else {
                // Still travelling
                travelling.append(vehicle)
            }
        }
        
        // Save the travelling back in LocalDatabase
        LocalDatabase.shared.vehicles = travelling
        do {
            try LocalDatabase.shared.saveVehicles(travelling)
        } catch {
            print("Could not save vehicles.: \(error.localizedDescription)")
        }
        
        
        // Save the City with the arrived vehicles
        
        if let city = cityData, !transferring.isEmpty {
            for vehicle in transferring {
                
                // Don't reccord the same vehicle twice
                if city.garage.vehicles.contains(vehicle) {
                    continue
                } else {
                    city.garage.vehicles.append(vehicle)
                    
                    // Achievement
                    GameMessageBoard.shared.newAchievement(type: .vehicleLanding(vehicle: vehicle), money: 100, message: nil)
                    
                    // FIXME: - Create Scene Notification
                    // Let the scene know that there is a new vehicle arriving
                }
            }
            
            do {
                try LocalDatabase.shared.saveCity(city)
            } catch {
                print("⚠️ Could not save city in LocalDatabase after getting arrived vehicles")
            }
        }
        
        // Update both Vehicle lists
        self.arrivedVehicles = cityData?.garage.vehicles ?? []
        self.travelVehicles = travelling
        
        // TODO: - Check Vehicle Registration
        
    }
    
    /// Unloads a `SpaceVehicle` to the city
    func unload(vehicle:SpaceVehicle) {
        
        guard let city = cityData else { return }
        
        var cityVehicles = city.garage.vehicles
        
        guard cityVehicles.contains(vehicle) else { return }
        
        // Transfer Vehicle's Contents
        
        for box in vehicle.boxes {
            city.boxes.append(box)
        }
        for tank in vehicle.tanks {
            city.tanks.append(tank)
        }
        for person in vehicle.passengers {
            if city.checkForRoomsAvailable() > city.inhabitants.count {
                city.inhabitants.append(person)
            } else {
                print("⚠️ Person doesn't fit! Your city is full!")
            }
        }
        
        // FIXME: - Put a limit on Bioboxes?
        
        for biobox in vehicle.bioBoxes {
            city.bioBoxes.append(biobox)
        }
        for peripheral in vehicle.peripherals {
            city.peripherals.append(peripheral)
        }
        
        cityVehicles.removeAll(where: { $0.id == vehicle.id })
        
        // Update data
        self.arrivedVehicles = cityVehicles
        
        city.garage.vehicles = cityVehicles
        
        // Save
        do {
            try LocalDatabase.shared.saveCity(city)
        } catch {
            print("Error Saving City: \(error.localizedDescription)")
        }
        
        // FIXME: - Server Update:
        // Delete vehicles that arrived and has unpacked
        if let registration = vehicle.registration {
            print("Delete vehicle from SErver Dataabase. VID: \(registration)")
        }
    }
    
    // MARK: - Hab
    
    func personalAction(_ paction:PersonActionCall, person:Person) {
        
        guard let citydata:CityData = self.cityData else {
            print("Co city data")
            return
        }
        guard let savePerson = citydata.inhabitants.first(where:  { $0.id == person.id }) else {
            print("Bad person selection")
            return
        }
        
        switch paction {
            case .boost:
                print("Boosting person \(person.name)")
                // Charge tokens for player
                if let token = LocalDatabase.shared.player.requestToken() {
                    let spend = self.player.spendToken(token: token, save: true)
                    if spend == true {
                        if let activity = savePerson.activity {
                            if activity.dateEnds.timeIntervalSinceNow > (60.0 * 60.0 * 24.0) {
                                savePerson.activity = nil
                            } else {
                                let dateReduced = activity.dateEnds.addingTimeInterval(-60.0 * 60.0)
                                activity.dateEnds = dateReduced
                            }
                        }
                    }
                }
                
                
            case .study(let skill):
                
                savePerson.learnNewSkill(type: skill)
                
                // Add activity to Person
                let studyActivity = LabActivity(time: GameLogic.personStudyTime, name: skill.rawValue)
                savePerson.activity = studyActivity
                
            case .workout:
                let workoutActivity = LabActivity(time: 60, name: "Workout")
                savePerson.activity = workoutActivity
                print("Person working out")
                if savePerson.healthPhysical < 80 {
                    savePerson.healthPhysical += 2
                    if Bool.random() { savePerson.healthPhysical += 1 }
                } else if savePerson.healthPhysical > 95 {
                    savePerson.happiness += 1
                }
            
            case .fire:
                guard let idx = citydata.inhabitants.firstIndex(of: person) else {
                    // self.issues.append("Error: Person doesn't belong here")
                    return
                }
                
                citydata.inhabitants.remove(at: idx)
                self.availableStaff = citydata.inhabitants.filter({ $0.isBusy() == false })
                
            case .medicate:
                // Check if there is medication
                var medicine:[DNAOption] = []
                for food in citydata.food {
                    if let dna = DNAOption(rawValue: food) {
                        if dna.isMedication == true {
                            medicine.append(dna)
                        }
                    }
                }
                
                if medicine.count < 5 {
                    // issues.append("Not enough medicine.")
                    return
                } else {
                    // Remove Medicine from Station (foods)
                    for med in medicine {
                        if let firstIndex = citydata.food.firstIndex(of: med.rawValue) {
                            citydata.food.remove(at: firstIndex)
                        }
                    }
                }
                
                // Medic
                if let medic = citydata.inhabitants.filter({$0.skills.contains(where: { $0.skill == .Medic }) && $0.isBusy() == false }).first {
                    
                    // Add activity to medic
                    medic.activity = LabActivity(time: 600, name: "Medicating")
                    
                    // Add activity to Person
                    savePerson.activity = LabActivity(time: 600, name: "Healing")
                    savePerson.healthPhysical = min(100, savePerson.healthPhysical + 8)
                    
                } else {
                    // No Medic
//                    issues.append("No medics were found.")
                }
        }
        
        do {
            try LocalDatabase.shared.saveCity(citydata)
        } catch {
            print("Error! \(error.localizedDescription)")
        }
        
    }
    
    // MARK: - Lab (Recipes)
    
    /// Called when Player clicks on a Recipe
    func labSelect(recipe:Recipe) {
        self.warnings = []
        self.labSelection = .recipe(name: recipe)
    }
    
    /// The disabled state of the button "Make Recipe" for this recipe
    func recipeDisabled(recipe:Recipe) -> Bool {
        if let city = cityData {
            return !city.unlockedRecipes.contains(recipe)
        } else {
            return true
        }
    }
    
    /// Begins the LabActivity to make a recipe
    func makeRecipe(recipe:Recipe) {
        
        // Reset Warnings
        self.warnings = []
        print("Making recipe: \(recipe.rawValue)")
        
        guard let cityData = cityData else {
            self.warnings = ["You don't have a City"]
            return
        }
        
        // Check Ingredients
        let reqIngredients:[Ingredient:Int] = recipe.ingredients()
        let lacking:[Ingredient] = cityData.validateResources(ingredients: reqIngredients)
        
        // Add problem message
        if !lacking.isEmpty {
            var problematicMessage:String = "Missing ingredients:"
            for ingredient in lacking {
                problematicMessage += "\n\(ingredient.rawValue) "
            }
            self.warnings.append(problematicMessage)
            
            print("Cannot charge :(")
            return
        } else {
            print("Ingredients Check: OK")
        }
        
        // Check Skills
        let reqSkills:[Skills:Int] = recipe.skillSet()
        let workers:[Person] = self.selectedStaff
        var missingSkills:[Skills] = []
        for (key, value) in reqSkills {
            var valueCount:Int = value // The sum of ppl skills
            for p in workers {
                let skset:[SkillSet] = p.skills.filter({ $0.skill == key })
                for sdk in skset {
                    if sdk.skill == key {
                        valueCount -= sdk.level
                    }
                }
            }
            if valueCount > 0 {
                missingSkills.append(key)
            }
        }
        
        // Problems (if any)
        if missingSkills.isEmpty {
            print("Skills Check OK.")
            
        } else {
            
            var problematicMessage:String = "Missing Skills"
            for skill in missingSkills {
                problematicMessage += "\n\(skill.rawValue)"
            }
            self.warnings.append(problematicMessage)
            
            print("There aren't enough skills :(")
            return
        }
        
        var bonus:Double = 0.1
        for person in workers {
            let lacking = Double(min(100, person.intelligence) + min(100, person.happiness) + min(100, person.teamWork)) / 3.0
            // lacking will be 100 (best), 0 (worst)
            bonus += lacking / Double(workers.count)
        }
        let timeDiscount = (bonus / 100) * 0.6 * Double(recipe.getDuration()) // up to 60% discount on time
        
        // Create Activity
        let duration = recipe.getDuration() - Int(timeDiscount)
        let delta:TimeInterval = Double(duration)
        let activity = LabActivity(time: delta, name: recipe.rawValue)
        cityData.labActivity = activity
        
        // Assign activity to workers
        for person in self.selectedStaff {
            person.activity = activity
        }
        
        // Charge
        let chargeResult = cityData.payForResources(ingredients: reqIngredients)
        if chargeResult == false {
            print("ERROR: Could not charge resources")
            warnings.append("Could not charge resources")
            return
        } else {
            print("Charged successful: \(reqIngredients)")
        }
        
        // Save and update view
        do {
            try LocalDatabase.shared.saveCity(cityData) //saveStation(station: station)
            self.labSelection = .activity(object: activity)
            print("Activity created")
        } catch {
            print("Error: \(error.localizedDescription)")
            self.warnings = ["Could not save city \(error.localizedDescription)"]
        }
        
    }
    
    // MARK: - Lab (Tech)
    
    func labSelect(tech:CityTech) {
        
        print("\n\t TECH")
        self.unlockedTech = CityTechTree().unlockedTechAfter(doneTech: cityData!.tech)
        
        self.warnings = []
        self.labSelection = .tech(name: tech)
    }
    
    func makeTech(tech:CityTech) {
        
        // Reset Warnings
        self.warnings = []
        print("Making tech: \(tech.rawValue)")
        
        guard let cityData = cityData else {
            self.warnings = ["You don't have a City"]
            return
        }
        
        // Check Ingredients
        let reqIngredients:[Ingredient:Int] = tech.ingredients
        let lacking:[Ingredient] = cityData.validateResources(ingredients: reqIngredients)
        // Add problem message
        if !lacking.isEmpty {
            var problematicMessage:String = "Missing ingredients"
            for ingredient in lacking {
                problematicMessage += "\n\(ingredient.rawValue) "
            }
            self.warnings.append(problematicMessage)
            
            print("Cannot charge :(")
            return
        } else {
            print("There are enough ingredients!")
        }
        
        // Check Skills
        let reqSkills:[Skills:Int] = tech.skillSet
        let workers:[Person] = self.selectedStaff
        var missingSkills:[Skills] = []
        for (key, value) in reqSkills {
            var valueCount:Int = value // The sum of ppl skills
            for p in workers {
                let skset:[SkillSet] = p.skills.filter({ $0.skill == key })
                for sdk in skset {
                    if sdk.skill == key {
                        valueCount -= sdk.level
                    }
                }
            }
            if valueCount > 0 {
                missingSkills.append(key)
            }
        }
        
        // Problems (if any)
        if missingSkills.isEmpty {
            print("There are enough skills :)")
            
        } else {
            
            var problematicMessage:String = "Missing Skills:"
            // problematicMessage += "\nMissing Skills:"
            for skill in missingSkills {
                problematicMessage += "\n\(skill.rawValue)"
            }
            self.warnings.append(problematicMessage)
            print("There aren't enough skills :(")
            return
        }
        
        var bonus:Double = 0.1
        for person in workers {
            let lacking = Double(max(100, person.intelligence) + max(100, person.happiness) + max(100, person.teamWork)) / 3.0
            // lacking will be 100 (best), 0 (worst)
            bonus += lacking / Double(workers.count)
        }
        let timeDiscount = (bonus / 100) * 0.6 * Double(tech.duration) // up to 60% discount on time
        
        // Create activity
        let duration = tech.duration - Int(timeDiscount)
        let delta:TimeInterval = Double(duration)
        let activity = LabActivity(time: delta, name: tech.rawValue)
        cityData.labActivity = activity
        
        // Assign activity to workers
        for person in self.selectedStaff {
            person.activity = activity
        }
        
        // Charge
        let chargeResult = cityData.payForResources(ingredients: reqIngredients)
        if chargeResult == false {
            print("ERROR: Could not charge results")
        } else {
            print("Charged successful: \(reqIngredients)")
        }
        
        // Save and update view
        do {
            try LocalDatabase.shared.saveCity(cityData) //saveStation(station: station)
            self.labSelection = .activity(object: activity)
            self.warnings = []
            print("Activity created")
        } catch {
            print("Error: \(error.localizedDescription)")
            self.warnings = ["Could not save city \(error.localizedDescription)"]
        }
        
        // Reset other vars
        selectedStaff = []
    }
    
    // MARK: - Lab (General)
    
    /// Checks how much of that recipe the City has.
    func availabilityOf(ingredient:Ingredient) -> Int {
        return cityData?.boxes.filter({ $0.type == ingredient }).compactMap({ $0.current }).reduce(0, +) ?? 0
    }
    
    /// Cancels the selection of TechItem, or Recipe
    func cancelSelection() {
        // Set the selection to none, to update the view
        self.labSelection = .NoSelection
        self.warnings = []
        // Reset Staff selection
        if !selectedStaff.isEmpty { selectedStaff = [] }
    }
    
    // MARK: - Biolab
    
    @Published var bioboxModel:CityWorkingBioboxModel? = nil
    
    func evolveBio(box:BioBox) {
        
        // Check if perfect DNA already found
        let populi = box.population
        let perfect = box.perfectDNA
        if populi.contains(perfect) {
            box.mode = .multiply
            //            self.multiply(box: box)
            print("Perfect DNA Found! Updating box.")
            return
        }
        
        // Get a model
        var currentBioModel:CityWorkingBioboxModel?
        if let currentModel = bioboxModel {
            if currentModel.generatorRunning == true {
                return
            } else {
                currentBioModel = currentModel
            }
        } else {
            let newModel = CityWorkingBioboxModel(bioBox: box)
            currentBioModel = newModel
        }
        guard let currentBioModel = currentBioModel else {
            return
        }
        
        // Use the Generator
        let generator = DNAGenerator(controller: self, box: box)
        let score:Double = (1.0 / (Double(generator.bestLevel) + 1.0)) * 100.0
        currentBioModel.score = score
        currentBioModel.generatorRunning = true
        generator.main()
    }
    
    /// Called by `DNAGenerator`
    func updateGeneticCode(sender:DNAGenerator, finished:Bool = false) {
        print("Updating genetic code. \(sender.counter)")
        
        guard let bbModel = bioboxModel else { return }
        bbModel.updateWith(generator: sender, finished: finished)
        
        /*
        // Update Population
        self.selectedPopulation = sender.populationStrings
        self.geneticLoops = sender.counter
        self.geneticFitString = sender.bestFit
        let score:Double = (1.0 / (Double(sender.bestLevel) + 1.0)) * 100.0
        self.geneticScore = Int(score)
        if (finished) {
            self.geneticRunning = false
            self.selectedBioBox!.population = sender.populationStrings
            self.selectedBioBox!.currentGeneration += sender.counter
            self.geneticFitString = self.selectedBioBox?.getBestFitDNA() ?? ""
//            saveStation()
        }
        */
    }
    
    func validadeTokenPayment(box qtty:Int, tokens:Int) -> [String] {
        
        var problems:[String] = []
        
        let playerTokens = player.countTokens() // { //LocalDatabase.shared.player?.timeTokens {
        if playerTokens.count >= tokens {
            
            // Player Has enough tokens - Check if Skills match
            //                var bioCount:Int = 0
            //                var medCount:Int = 0
            //                for person in selectedStaff {
            //                    for skill in person.skills {
            //                        if skill.skill == .Biologic {
            //                            bioCount += skill.level
            //                        }
            //                        if skill.skill == .Medic {
            //                            medCount += 1
            //                        }
            //                    }
            //                }
            //                if bioCount + medCount < 1 {
            //                    print("Not enough Skills")
            //                    problems.append("Not enough Skills")
            //                } else {
            //                    print("Skills Verified - Charging Tokens")
            
            // Free the people
            self.selectedStaff = []
            
            // Charge Player
            let player = LocalDatabase.shared.player
            //                    player.timeTokens.removeFirst(tokens)
            for _ in 1...tokens {
                if let token = player.requestToken() {
                    let result = player.spendToken(token: token, save: true)
                    print("Spent Token result: \(result)")
                }
            }
            
            // Make people busy
            //                    let activity = LabActivity(time: 3600, name: "Planting life")
            //                    for person in selectedStaff {
            //                        person.activity = activity
            //                    }
            
            // Save
            do {
                try LocalDatabase.shared.savePlayer(player)
            } catch {
                print("Could not save Player \(error.localizedDescription)")
            }
            do {
                try LocalDatabase.shared.saveCity(self.cityData!)
            } catch {
                print("Could not save city.: \(error.localizedDescription)")
            }
            // let pRes =
            // try? LocalDatabase.shared.saveCity(cityData!)
            
            // print("Saved player: \(pRes)")
            //                }
            
        } else {
            problems.append("Not enough tokens")
        }
        
        return problems
    }
    
    // MARK: - Outpost Collection
    
    func updateCityOutpostCollection() {
        
        self.opCollectArray = []
        
        guard let sd = LocalDatabase.shared.serverData else {
            print("<< No server data >>")
            return
        }
        
        if let guild = sd.guildfc {
            for dbOutpost in guild.outposts {
                
                collectables.append("\(dbOutpost.type.rawValue): POS.: \(dbOutpost.posdex)")
                let colModel = CityCollectOutpostModel(dbOutpost: dbOutpost, opCollect: self.cityData?.opCollection ?? [:])
                
                self.opCollectArray.append(colModel)
                
            }
        }
    }
    
    /// Collects items from Outpost
    func collectFromOutpost(outpost:DBOutpost) {
        
        guard let cityData = self.cityData else {
            print("No CityData")
            return
        }
        
        let outpostType = outpost.type
        
        // What to collect?
        if let baseProduce = outpostType.baseProduce() {
            if let ingredient = Ingredient(rawValue: baseProduce.name) {
                switch ingredient {
                    
                    case .Silica:
                        
                        let res = cityData.refillContainers(of: .Silica, amount: baseProduce.quantity)
                        print("CityData refilled Silica: \(res)")
                        if res > 0 {
                            print("Spilling Silica!! QTTY: \(res)")
                        }
                        
                    case .Water:
                        print("Water")
                        let res = cityData.refillContainers(of: .Water, amount: baseProduce.quantity)
                        print("CityData refilled water: \(res)")
                        if res > 0 {
                            print("Spilling water!! QTTY: \(res)")
                        }
                    case .Food:
                        print("Food")
                        // Different levels, different amount, and different type of food
                        var possibleFoods:[DNAOption] = DNAOption.allCases.filter({ $0.isAnimal == false && $0.isMedication == false })
                        if outpost.level > 2 {
                            possibleFoods.append(contentsOf:DNAOption.allCases.filter({ $0.isAnimal == true && $0.isMedication == false }))
                            if outpost.level > 3 {
                                possibleFoods.append(contentsOf:DNAOption.allCases.filter({ $0.isMedication == true }))
                                
                            }
                        }
                        var limit = baseProduce.quantity
                        while limit > 0 {
                            cityData.food.append(possibleFoods.randomElement()!.rawValue)
                            limit -= 1
                        }
                    default:
                        print("! Not a Collectible item")
                }
                
                var newCollection = cityData.opCollection ?? [:]
                newCollection[outpost.id, default:Date()] = Date()
                
                cityData.opCollection = newCollection
                
                do {
                    try LocalDatabase.shared.saveCity(cityData)
                    self.updateCityOutpostCollection()
                } catch {
                    print("Could not save CityData: \(error.localizedDescription)")
                }
                
            } else if baseProduce.name == "Energy" {
                
                print("Energy")
                let res = cityData.refillBatteries(amount: baseProduce.quantity)
                print("CityData refilled energy: \(res)")
                if res > 0 {
                    print("Spilling energy!! QTTY: \(res)")
                }
                
                var newCollection = cityData.opCollection ?? [:]
                newCollection[outpost.id, default:Date()] = Date()
                
                cityData.opCollection = newCollection
                
                do {
                    try LocalDatabase.shared.saveCity(cityData)
                    self.updateCityOutpostCollection()
                } catch {
                    print("Could not save CityData: \(error.localizedDescription)")
                }
            }
        }
    
        // How to collect?
        // Set cityData.opCollection[outpost.id] = Date()
        // Save City
        // Reload - updateCityOutpostCollection
    }
    
}


