//
//  LocalCityController.swift
//  SkyNation
//
//  Created by Carlos Farini on 9/26/21.
//

import Foundation

/// The City Tab
enum CityMenuItem:Int, CaseIterable {
    
    case hab
    case lab
    case bio
    case rss
    case collect
    case rocket
    
    var string:String {
        switch self {
            case .hab: return "🏠"
            case .lab: return "🔬"
            case .bio: return "🧬"
            case .rss: return "♻️"
            case .collect: return "↯"
            case .rocket: return "🚀"
        }
    }
    
    var defaultState:LocalCityViewState {
        switch self {
            case .hab: return .hab(state: .noSelection)
            case .lab: return .lab(state: .NoSelection)
            case .bio: return .bio(state: .notSelected)
            case .rss: return .rss
            case .collect: return .collect
            case .rocket: return .rocket(state: .noSelection)
        }
    }
}

enum PersonActionCall {
    
    /// Boosting Person Activity
    case boost
    
    case study(skill:Skills)
    case workout
    case fire
    case medicate
}

/// A Complete Selection State for a Local `CityData`
enum LocalCityViewState {
    
    case hab(state:HabModuleViewState)
    
    case lab(state:CityLabState)
    
    case bio(state:BioModSelection)
    
    case rss // No Selection
    
    case collect // OutpostModel?
    
    case rocket(state:CityGarageState)
    
    var menuTab:CityMenuItem {
        switch self {
            case .hab(_): return .hab
            case .lab(_): return .lab
            case .bio(_): return .bio
            case .rss: return .rss
            case .collect: return .collect
            case .rocket(_): return .rocket
        }
    }
}

enum CityLabState {
    case NoSelection
    case recipe(name:Recipe)
    case tech(name:CityTech)
    case activity(object:LabActivity)
}

enum CityGarageState {
    case noSelection
    case selected(vehicle:SpaceVehicle)
}

/**
 A City Controller that works ONLY when you have a city
 */
class LocalCityController:ObservableObject, BioController {
    
    @Published var cityData:CityData
//    @Published var cityViewState:LocalCityViewState = LocalCityViewState.hab(state: .noSelection)
    @Published var cityTab:CityMenuItem = .hab
    
    // Hab & People
    
    @Published var availableStaff:[Person] = []
    @Published var selectedStaff:[Person] = []
    @Published var allStaff:[Person] = []
    
    // Lab
    
    /// Selection item for Lab View
    @Published var labActivity:LabActivity?
    
    /// Unlocked Lab Technology
    @Published var unlockedTech:[CityTech] = []
    
    // Bio
    
    @Published var bioboxModel:CityWorkingBioboxModel? = nil
    
    // Outpost Collection
    
    @Published var collectables:[String] = []
    @Published var opCollectArray:[CityCollectOutpostModel] = []
    
    // Vehicles
    
    @Published var arrivedVehicles:[SpaceVehicle] = []
    @Published var travelVehicles:[SpaceVehicle] = []
    @Published var otherVehicles:[SpaceVehicleTicket] = []
    
    // Errors & Warnings
    
    @Published var warnings:[String] = []
    
    init() {
        guard let cityData = LocalDatabase.shared.cityData else {
            fatalError()
        }
        
        self.cityData = cityData
        
        // Post Init
        
        // Lab Activity
        if let activity = cityData.labActivity {
            self.labActivity = activity
        }
        
        // People
        self.allStaff = cityData.inhabitants
        self.availableStaff = cityData.inhabitants.filter({ $0.isBusy() == false })
        self.selectedStaff = []
        
        // OpCollection
        self.updateCityOutpostCollection()
    }
    
    func didSelectTab(tab:CityMenuItem) {
        self.cityTab = tab
    }
    
    // MARK: - HAB
    
    func personalAction(_ paction:PersonActionCall, person:Person) {
        
        guard let savePerson = cityData.inhabitants.first(where:  { $0.id == person.id }) else {
            print("Bad person selection")
            return
        }
        
        // to de-select the person (fire, or dead)
        var shouldDeselect:Bool = false
        
        switch paction {
            case .boost:
                print("Boosting person \(person.name)")
                let player = LocalDatabase.shared.player
                
                // Charge tokens for player
                if let token = player.requestToken() {
                    let spend = player.spendToken(token: token, save: true)
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
                guard let idx = cityData.inhabitants.firstIndex(of: person) else {
                    // self.issues.append("Error: Person doesn't belong here")
                    return
                }
                
                cityData.inhabitants.remove(at: idx)
                self.availableStaff = cityData.inhabitants.filter({ $0.isBusy() == false })
                self.selectedStaff = []
                
                // Deselect
                shouldDeselect = true
                
            case .medicate:
                // Check if there is medication
                var medicine:[DNAOption] = []
                for food in cityData.food {
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
                        if let firstIndex = cityData.food.firstIndex(of: med.rawValue) {
                            cityData.food.remove(at: firstIndex)
                        }
                    }
                }
                
                // Medic
                if let medic = cityData.inhabitants.filter({$0.skills.contains(where: { $0.skill == .Medic }) && $0.isBusy() == false }).first {
                    
                    // Add activity to medic
                    medic.activity = LabActivity(time: 600, name: "Medicating")
                    
                    // Add activity to Person
                    savePerson.activity = LabActivity(time: 600, name: "Healing")
                    savePerson.healthPhysical = min(100, savePerson.healthPhysical + 8)
                    
                } else {
                    // No Medic
                    // issues.append("No medics were found.")
                }
        }
        
        do {
            try LocalDatabase.shared.saveCity(cityData)
            if shouldDeselect {
//                self.cityViewState = .hab(state: .noSelection)
                self.didSelectTab(tab: .hab)
            } else {
//                self.cityViewState = .hab(state: .selected(person: savePerson))
//                self.didSelectTab(tab: .hab)
                print("Not de-selecting")
            }
        } catch {
            print("Error! \(error.localizedDescription)")
        }
        
    }
    
    // MARK: - Lab
    
    func didSelectLab(tech:CityTech?, recipe:Recipe?) {
        self.warnings = []
        
        if let tech:CityTech = tech {
            self.unlockedTech = CityTechTree().unlockedTechAfter(doneTech: cityData.tech)
//            self.cityViewState = .lab(state: .tech(name: tech))
//            self.cityTab = .lab
        } else if let recipe = recipe {
//            self.cityViewState = .lab(state: .recipe(name: recipe))
        }
        
        self.cityTab = .lab
    }
    
    func makeRecipe(recipe:Recipe) -> Bool {
        
        // Reset Warnings
        self.warnings = []
        print("Making recipe: \(recipe.rawValue)")
        
        // Check RSS
        let requiredIngredients:[Ingredient:Int] = recipe.ingredients()
        let requiredSkills:[Skills:Int] = recipe.skillSet()
        
        // Check Problems
        let possibleProblems = self.manageSufficientLack(ingredients: requiredIngredients, skills: requiredSkills)
        if !possibleProblems.isEmpty {
            self.warnings = possibleProblems
            print("Missing required items")
            return false
        }
        
        let workers:[Person] = self.selectedStaff
        
        var timeDiscount:Int = 0
        for person in workers {
            let lacking:Int = (min(100, person.intelligence) + min(100, person.happiness) + min(100, person.teamWork)) / 3
            // lacking will be 100 (best), 0 (worst)
            timeDiscount += lacking / workers.count
        }
        let pctDiscount = Int((Double(timeDiscount) / 100.0) * 0.5 * Double(recipe.getDuration())) // up to 60% discount on time
        
        // Create Activity
        let duration = recipe.getDuration() - pctDiscount
        let delta:TimeInterval = Double(duration)
        
        let activity = LabActivity(time: delta, name: recipe.rawValue)
        cityData.labActivity = activity
        self.labActivity = activity
        
        // Assign activity to workers
        for person in self.selectedStaff {
            person.activity = activity
        }
        
        // Charge
        let chargeResult = cityData.payForResources(ingredients: requiredIngredients)
        if chargeResult == false {
            print("ERROR: Could not charge resources")
            warnings.append("Could not charge resources")
            return false
        } else {
            print("Charged successful: \(requiredIngredients)")
        }
        
        // Save and update view
        do {
            try LocalDatabase.shared.saveCity(cityData)
            // Update View State
//            self.cityViewState = .lab(state: .activity(object: activity))
            self.didSelectTab(tab: .lab)
            print("Activity created")
            return true
            
        } catch {
            print("Error: \(error.localizedDescription)")
            self.warnings = ["Could not save city \(error.localizedDescription)"]
        }
        return false
        
    }
    
    func makeTech(tech:CityTech) {
        
        // Reset Warnings
        self.warnings = []
        print("Making tech: \(tech.rawValue)")
        
        // Check RSS
        let requiredIngredients:[Ingredient:Int] = tech.ingredients
        let requiredSkills:[Skills:Int] = tech.skillSet
        
        // Check Problems
        let possibleProblems = self.manageSufficientLack(ingredients: requiredIngredients, skills: requiredSkills)
        if !possibleProblems.isEmpty {
            self.warnings = possibleProblems
            print("Missing required items")
            return
        }
        
        let workers:[Person] = self.selectedStaff
        
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
        let chargeResult = cityData.payForResources(ingredients: requiredIngredients)
        if chargeResult == false {
            print("ERROR: Could not charge results")
        } else {
            print("Charged successful: \(requiredIngredients)")
        }
        
        // Save and update view
        do {
            try LocalDatabase.shared.saveCity(cityData)
            
            // Update View State
//            self.cityViewState = .lab(state: .activity(object: activity))
            self.didSelectTab(tab: .lab)
            
            // Reset other vars
            selectedStaff = []
            self.warnings = []
            print("Activity created")
        } catch {
            print("Error: \(error.localizedDescription)")
            self.warnings = ["Could not save city \(error.localizedDescription)"]
        }
    }
    
    // Activity
    func collectActivity(activity:LabActivity) {
        print("\n [CTRL] Collecting Activity: \(activity.activityName)")
        print("Start: \(GameFormatters.fullDateFormatter.string(from: activity.dateStarted))")
        print("Finish: \(GameFormatters.fullDateFormatter.string(from: activity.dateEnds))")
        if let recipe = Recipe(rawValue: activity.activityName) {
            print("Recipe: \(recipe.rawValue)")
            
            
//            cityData.unlockedRecipes.append(recipe)
            switch recipe {
                case .Alloy:
                    cityData.boxes.append(StorageBox(ingType: .Alloy, current: Ingredient.Alloy.boxCapacity()))
                case .Condensator:
                    cityData.peripherals.append(PeripheralObject(peripheral: .Condensator))
                case .ScrubberCO2:
                    cityData.peripherals.append(PeripheralObject(peripheral: .ScrubberCO2))
                case .Electrolizer:
                    cityData.peripherals.append(PeripheralObject(peripheral: .Electrolizer))
                case .Methanizer:
                    cityData.peripherals.append(PeripheralObject(peripheral: .Methanizer))
                case .Radiator:
                    cityData.peripherals.append(PeripheralObject(peripheral: .Radiator))
                case .SolarPanel:
                    cityData.peripherals.append(PeripheralObject(peripheral: .solarPanel))
                case .Battery:
                    cityData.batteries.append(Battery(shopped: false))
                case .tank:
                    cityData.tanks.append(Tank(type: .empty, full: false))
                case .WaterFilter:
                    cityData.peripherals.append(PeripheralObject(peripheral: .WaterFilter))
                case .BioSolidifier:
                    cityData.peripherals.append(PeripheralObject(peripheral: .BioSolidifier))
                case .Cement:
                    cityData.boxes.append(StorageBox(ingType: .Cement, current: Ingredient.Cement.boxCapacity()))
                case .ChargedGlass:
                    cityData.boxes.append(StorageBox(ingType: .Glass, current: Ingredient.Glass.boxCapacity()))
                default: print("ERROR - DID NOT UNDERSTAND RECIPE: \(recipe.rawValue)")
            }
            
            
            cityData.labActivity = nil
//            self.cityViewState = .lab(state: .NoSelection)
            self.didSelectTab(tab: .lab)
            self.labActivity = nil
            
            do {
                try LocalDatabase.shared.saveCity(cityData)
            } catch {
                // TODO: - Deal with Error
                // Deal With Error
                print(error.localizedDescription)
            }
            
        } else if let tech = CityTech(rawValue: activity.activityName) {
            print("Tech: \(tech.rawValue)")
            
            cityData.labActivity = nil
            cityData.tech.append(tech)
            
//            self.cityViewState = .lab(state: .NoSelection)
            self.didSelectTab(tab: .lab)
            
            self.labActivity = nil
            
            do {
                try LocalDatabase.shared.saveCity(cityData)
            } catch {
                // TODO: - Deal with Error
                // Deal With Error
                print(error.localizedDescription)
            }
        }
    }
    // - cancelActivity
    // - shortenActivityWithTokens
    
    // MARK: - Bio
    
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
    
    /// Makes the payment needed to Build a `BioBox` object
    func buildBio(box:BioBox, usingTokens:Bool, boxSize:Int) -> Bool {
        print("Needs Implementation")
        if usingTokens {
            // Pay with Tokens
        } else {
            // Pay with Ingredients
            // Consume Energy
            // Make People Busy
        }
        // Update State
        // Success -> state is .bio(selected:box)
        return false
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
                let colModel = CityCollectOutpostModel(dbOutpost: dbOutpost, opCollect: self.cityData.opCollection ?? [:])
                
                self.opCollectArray.append(colModel)
                
            }
        }
    }
    
    /// Collects items from Outpost
    func collectFromOutpost(outpost:DBOutpost) {
        
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
    
    // MARK: - Vehicles
    
    /// Gets all vehicles that arrived
    func updateVehiclesLists() {
        
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
//        LocalDatabase.shared.vehicles = travelling
        // Save
        do {
            try LocalDatabase.shared.saveVehicles(travelling)
        } catch {
            print("‼️ Could not save vehicles.: \(error.localizedDescription)")
        }
//        LocalDatabase.shared.saveVehicles()
        
        // Save the City with the arrived vehicles
        
        if !transferring.isEmpty {
            for vehicle in transferring {
                
                // Don't reccord the same vehicle twice
                if cityData.garage.vehicles.contains(vehicle) {
                    continue
                } else {
                    cityData.garage.vehicles.append(vehicle)
                    
                    // Achievement
                    GameMessageBoard.shared.newAchievement(type: .vehicleLanding(vehicle: vehicle), message: nil)
                    
                    // FIXME: - Create Notification
                    // Let the scene know that there is a new vehicle arriving
                }
            }
            
            do {
                try LocalDatabase.shared.saveCity(cityData)
            } catch {
                print("⚠️ Could not save city in LocalDatabase after getting arrived vehicles")
            }
        }
        
        // Update both Vehicle lists
        self.arrivedVehicles = cityData.garage.vehicles
        self.travelVehicles = travelling
        
        // TODO: - Check Vehicle Registration
        
    }
    
    /// Unloads a `SpaceVehicle` to the city
    func unload(vehicle:SpaceVehicle) {
        
//        guard let city = cityData else { return }
        
        var cityVehicles = cityData.garage.vehicles
        
        guard cityVehicles.contains(vehicle) else { return }
        
        // Transfer Vehicle's Contents
        
        for box in vehicle.boxes {
            cityData.boxes.append(box)
        }
        for tank in vehicle.tanks {
            cityData.tanks.append(tank)
        }
        for person in vehicle.passengers {
            if cityData.checkForRoomsAvailable() > cityData.inhabitants.count {
                cityData.inhabitants.append(person)
            } else {
                print("⚠️ Person doesn't fit! Your city is full!")
            }
        }
        
        // FIXME: - Put a limit on Bioboxes?
        
        for biobox in vehicle.bioBoxes {
            cityData.bioBoxes.append(biobox)
        }
        for peripheral in vehicle.peripherals {
            cityData.peripherals.append(peripheral)
        }
        
        cityVehicles.removeAll(where: { $0.id == vehicle.id })
        
        // Update data
        self.arrivedVehicles = cityVehicles
        
        cityData.garage.vehicles = cityVehicles
        
        // Save
        do {
            try LocalDatabase.shared.saveCity(cityData)
        } catch {
            print("Error Saving City: \(error.localizedDescription)")
        }
        
        // FIXME: - Server Update:
        // Delete vehicles that arrived and has unpacked
        if let registration = vehicle.registration {
            print("Delete vehicle from SErver Dataabase. VID: \(registration)")
        }
    }
    
    // MARK: - Common Use
    
    /// If array is empty, that means it was charged
    private func manageSufficientLack(ingredients:[Ingredient:Int], skills:[Skills:Int]) -> [String] {
        
        var problemArray:[String] = []
        
        // Check Ingredients
        let lacking:[Ingredient] = cityData.validateResources(ingredients: ingredients)
        
        // Add problem message
        if !lacking.isEmpty {
            var problematicMessage:String = "Missing ingredients:"
            for ingredient in lacking {
                problematicMessage += "\n\(ingredient.rawValue) "
            }
            problemArray.append(problematicMessage)
        }
        
        // Check Skills
        let workers:[Person] = self.selectedStaff
        var missingSkills:[Skills] = []
        for (key, value) in skills {
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
        if !missingSkills.isEmpty {
            var problematicMessage:String = "Missing Skills:"
            for mSkill in missingSkills {
                problematicMessage += "\n\(mSkill.rawValue) "
            }
            problemArray.append(problematicMessage)
        }
        
        return problemArray
    }
    
    /// Cancels any Selection, and brings the view state back to the tab origin
    func cancelSelectionOn(tab:CityMenuItem) {
        
        self.selectedStaff = []
        self.warnings = []
        
        self.didSelectTab(tab: tab)
        
        /*
        switch tab {
            case .hab:
                self.cityViewState = .hab(state: .noSelection)
            case .lab:
                if let labActivity = cityData.labActivity {
                    self.cityViewState = .lab(state: .activity(object: labActivity))
                } else {
                    self.cityViewState = .lab(state: .NoSelection)
                }
            case .bio:
                self.cityViewState = .bio(state: .notSelected)
            case .rocket:
                self.cityViewState = .rocket(state: .noSelection)
            default: return
        }
        */
    }
    
    /// Returns how many ingredients of a certain `Ingredient` type is available
    func availabilityOf(ingredient:Ingredient) -> Int {
        return cityData.boxes.filter({ $0.type == ingredient }).compactMap({ $0.current }).reduce(0, +)
    }
    
    /// Spends a Token and Saves the player object. Returns false if can't
    private func spendToken() -> Bool {
        let player = LocalDatabase.shared.player
        if let token = player.requestToken() {
            if player.spendToken(token: token, save: true) == true {
                return true
            }
        }
        return false
    }
    
}

/// A Model used to check Outpost Collection by a `City`
struct CityCollectOutpostModel:Identifiable {
    
    var id:UUID
    var outpost:DBOutpost
    var collected:Date
    
    init(dbOutpost:DBOutpost, opCollect:[UUID:Date]) {
        
        self.id = UUID()
        self.outpost = dbOutpost
        
        let opioid:UUID = dbOutpost.id
        if let col = opCollect[opioid] {
            self.collected = col
        } else {
            self.collected = Date.distantPast
        }
    }
    
    /// Returns whether this can be collected.
    func canCollect() -> Bool {
        let deadline = collected.addingTimeInterval(60.0 * 60.0)
        if outpost.type.productionBase.isEmpty {
            return false
        }
        return Date().compare(deadline) == .orderedDescending
    }
}

/// Helper class for BioBox Views
class CityWorkingBioboxModel {
    
    var bioBox:BioBox
    var population:[String]
    var geneticLoops:Int
    var fittestString:String
    var score:Double = 0
    var generatorRunning:Bool = false
    
    init(bioBox:BioBox) {
        self.bioBox = bioBox
        self.population = bioBox.population
        self.geneticLoops = 0
        self.fittestString = bioBox.getBestFitDNA() ?? ""
    }
    
    func updateWith(generator:DNAGenerator, finished:Bool) {
        self.population = generator.populationStrings
        self.geneticLoops = generator.counter
        self.fittestString = generator.bestFit
        self.score = (1.0 / (Double(generator.bestLevel) + 1.0)) * 100.0
        
        if (finished) {
            self.generatorRunning = false
            bioBox.population = generator.populationStrings
            bioBox.currentGeneration += generator.counter
            self.fittestString = bioBox.getBestFitDNA() ?? ""
        }
    }
    
}
