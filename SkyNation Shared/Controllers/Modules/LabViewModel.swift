//
//  LabViewModel.swift
//  SkyTestSceneKit
//
//  Created by Farini on 10/29/20.
//  Copyright © 2020 Farini. All rights reserved.
//

import Foundation

enum LabSelectState {
    case NoSelection
    case recipe(name:Recipe)
    case techTree(name:TechItems)
    case activity
}

class LabViewModel: ObservableObject {
    
    @Published var station:Station
    @Published var unlockedRecipes:[Recipe]
    @Published var labModule:LabModule
    @Published var labActivity:LabActivity?
    
    // View State
    @Published var selection:LabSelectState
    @Published var problems:String?     // Lacking ingredients error message
    
    // People
    @Published var availableStaff:[Person]
    @Published var selectedStaff:[Person] = []
    
    // Tech Tree
    @Published var techTree:TechTree
    @Published var selected:TechTree?
    @Published var unlocked:[TechTree]
    
    @Published var unlockedItems:[TechItems]    // Items that can be researched
    @Published var complete:[TechTree]          // Items that are complete

    // MARK: - Methods
    
    func didSelect(tt:TechTree) {
        self.selected = tt
    }
    
    /// Cancels the selection of TechItem, or Recipe
    func cancelSelection() {
        // Set the selection to none, to update the view
        self.selection = .NoSelection
        self.problems = nil
        // Reset Staff selection
        if !selectedStaff.isEmpty { selectedStaff = [] }
    }
    
    // MARK: - People Management
    
    func togglePersonSelection(person:Person) {
        if let idx = selectedStaff.firstIndex(of: person) {
            selectedStaff.remove(at: idx)
        } else {
            selectedStaff.append(person)
        }
    }
    
    // MARK: - Ingredients
    
    /// Returns how much of an ingredient the station has
    func availabilityOf(ingredient:Ingredient) -> Int {
        
        let allAvailable:[StorageBox] = station.truss.extraBoxes.filter { $0.type == ingredient }
        
        var content:Int = 0
        for box in allAvailable {
            content += box.current
        }
        
        return content
    }
    
    /// Boosts the activity for 1 hour. Removes a time token from player
    func boostActivity() -> Bool {
        
        // 1. Get the player
        let player = LocalDatabase.shared.player
        
        // 2. Tokens
        guard let token = player.requestToken() else {
            print("No tokens")
            return false
        }
        
        // 3. Activity
        guard let activity = labModule.activity else {
            print("No activity")
            return false
        }
        // 4. Reduce Time
        activity.dateEnds.addTimeInterval(-3600)
        labModule.activity = activity
        
        let workers = availableStaff.filter({ $0.activity?.id == activity.id })
        for person in workers {
            person.activity = activity
        }
        
        let spend = player.spendToken(token: token, save: true)
        if spend == false { return false }
        
        // 5. Save
        do {
            try LocalDatabase.shared.saveStation(station)
            
            do {
                try LocalDatabase.shared.savePlayer(player)
                return true
            } catch {
                print("‼️ Could not save player.: \(error.localizedDescription)")
                return false
            }
        } catch {
            print("‼️ Could not save station.: \(error.localizedDescription)")
            return false
        }
        
        
    }
    
    // MARK: - TECH
    
    func makeTech(item:TechItems) {
        self.problems = nil
        
        // Check Ingredients
        let reqIngredients:[Ingredient:Int] = item.ingredients()
        let lacking:[Ingredient] = station.truss.validateResources(ingredients: reqIngredients)
        // Add problem message
        if !lacking.isEmpty {
            var problematicMessage:String = "Missing ingredients"
            for ingredient in lacking {
                problematicMessage += "\n\(ingredient.rawValue) "
            }
            self.problems = problematicMessage
            print("Cannot charge :(")
            return
        } else {
            print("There are enough ingredients!")
        }
        
        // Check Skills
        let reqSkills:[Skills:Int] = item.skillSet()
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
            self.problems = problematicMessage
            print("There aren't enough skills :(")
            return
        }
        
        var bonus:Double = 0.1
        for person in workers {
            let lacking = Double(min(100, person.intelligence) + min(100, person.happiness) + min(100, person.teamWork)) / 3.0
            // lacking will be 100 (best), 0 (worst)
            bonus += lacking / Double(workers.count)
        }
        let timeDiscount = (bonus / 100) * 0.6 * Double(item.getDuration()) // up to 60% discount on time
        
        // Create activity
        let duration = item.getDuration() - Int(timeDiscount)
        let delta:TimeInterval = Double(duration)
        let activity = LabActivity(time: delta, name: item.rawValue)
        labModule.activity = activity
        
        // Assign activity to workers
        for person in self.selectedStaff {
            person.activity = activity
        }
        
        // Charge
        let chargeResult = station.truss.payForResources(ingredients: reqIngredients)
        if chargeResult == false {
            print("ERROR: Could not charge results")
        } else {
            print("Charged successful: \(reqIngredients)")
        }
        
        // Save and update view
        // 5. Save
        do {
            try LocalDatabase.shared.saveStation(station)
        } catch {
            print("‼️ Could not save station.: \(error.localizedDescription)")
        }
        
        
        
        print("Activity created")
        selection = .activity
        
        // Reset other vars
        selectedStaff = []
    }
    
    func collectTech(activity:LabActivity, tech:TechItems) {
        
        if let activity = self.labModule.activity {
            print("Found activity: \(activity.activityName)")
            
            
            
            if let techItem = TechItems(rawValue: activity.activityName) {
                
                // Make sure its not a repeat
                guard !station.unlockedTechItems.contains(techItem) else {
                    print("Already researched this tech...")
                    // Update UI
                    self.unlockedItems = station.unlockedTechItems
                    self.labModule.activity = nil
                    self.selected = nil
                    self.selection = .NoSelection
                    return
                }
                
                GameMessageBoard.shared.newAchievement(type: .tech(item: tech), message: nil)
                print("New Game Message")
//                print("Found tech item")
//                LocalDatabase.shared.builder.upgradeTech(item: techItem)
                // Builder is responsible for saving....
                
                print("Completed Upgrading. Check JSON.")
                
                // Check if this is a recipe
                switch techItem {
                    case .AU1, .AU2, .AU3, .AU4, .AntennaUp:
                        self.station.truss.antenna.level += 1
                    case .recipeMethane:
                        self.station.unlockedRecipes.append(Recipe.Methanizer)
                    case .recipeScrubber:
                        self.station.unlockedRecipes.append(Recipe.ScrubberCO2)
                    case .recipeBioSolidifier:
                        self.station.unlockedRecipes.append(Recipe.BioSolidifier)
                    case .recipeWaterFilter:
                        self.station.unlockedRecipes.append(Recipe.WaterFilter)
                    case .module4:
                        let newDex = ModuleIndex.mod3
                        let newModule = Module(id: UUID(), modex: newDex)
                        station.modules.append(newModule)
                    case .module5:
                        let newDex = ModuleIndex.mod4
                        let newModule = Module(id: UUID(), modex: newDex)
                        station.modules.append(newModule)
                    case .module6:
                        let newDex = ModuleIndex.mod5
                        let newModule = Module(id: UUID(), modex: newDex)
                        station.modules.append(newModule)
                    case .module7:
                        let newDex = ModuleIndex.mod6
                        let newModule = Module(id: UUID(), modex: newDex)
                        station.modules.append(newModule)
                    case .module8:
                        let newDex = ModuleIndex.mod8
                        let newModule = Module(id: UUID(), modex: newDex)
                        station.modules.append(newModule)
                    case .module9:
                        let newDex = ModuleIndex.mod9
                        let newModule = Module(id: UUID(), modex: newDex)
                        station.modules.append(newModule)
                    case .module10:
                        let newDex = ModuleIndex.mod10
                        let newModule = Module(id: UUID(), modex: newDex)
                        station.modules.append(newModule)
                    
                    default:
                        print("Not a recipe")
                }
                
                // Update Scene
                SceneDirector.shared.didCollectTech(tech:techItem, model:techItem.loadToScene())
                
                // Add item
                self.station.unlockedTechItems.append(tech)
                
                // Update UI
                self.unlockedRecipes = station.unlockedRecipes
                
                // Update Tech Tree?
                let tree = TechTree()
                tree.accountForItems(items: station.unlockedTechItems)
                self.techTree = tree
                self.unlocked = tree.showUnlocked() ?? []
                self.complete = tree.getCompletedItemsFrom(node: tree)
                
                self.unlockedItems = []
                // Unlocked Items (Can be researched)
                for item in tree.showUnlocked() ?? [] {
                    self.unlockedItems.append(item.item)
                }
                
                self.labModule.activity = nil
                self.selected = nil
                self.selection = .NoSelection
                
                // Save
                do {
                    try LocalDatabase.shared.saveStation(station)
                } catch {
                    print("‼️ Could not save station.: \(error.localizedDescription)")
                }
            }
            
        }
    }
    
    func throwAwayTech() {
        if let activity = self.labModule.activity {
            print("Throwing away: \(activity.activityName)")
            self.labModule.activity = nil
            // Save
            do {
                try LocalDatabase.shared.saveStation(station)
            } catch {
                print("‼️ Could not save station.: \(error.localizedDescription)")
            }
            self.selection = .NoSelection
        }
    }
    
    func selectedFromDiagram(_ tech:TechItems) {
        self.selection = .techTree(name: tech)
    }
    
    // MARK: - Recipes
    
    /// The disabled state of the button "Make Recipe" for this recipe
    func recipeDisabled(recipe:Recipe) -> Bool {
        return !station.unlockedRecipes.contains(recipe)
    }
    
    /// Begins the LabActivity to make a recipe
    func makeRecipe(recipe:Recipe) {
        
        print("Making recipe: \(recipe.rawValue)")
        
        // Check Ingredients
        let reqIngredients:[Ingredient:Int] = recipe.ingredients()
        let lacking:[Ingredient] = station.truss.validateResources(ingredients: reqIngredients)
        // Add problem message
        if !lacking.isEmpty {
            var problematicMessage:String = "Missing ingredients:"
            for ingredient in lacking {
                problematicMessage += "\n\(ingredient.rawValue) "
            }
            self.problems = problematicMessage
            print("Cannot charge :(")
            return
        } else {
            print("There are enough ingredients!")
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
            print("There are enough skills :)")
            
        } else {
            
            var problematicMessage:String = "Missing Skills"
            for skill in missingSkills {
                problematicMessage += "\n\(skill.rawValue)"
            }
            self.problems = problematicMessage
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
        labModule.activity = activity
        
        // Assign activity to workers
        for person in self.selectedStaff {
            person.activity = activity
        }
        
        // Charge
        let chargeResult = station.truss.payForResources(ingredients: reqIngredients)
        if chargeResult == false {
            print("ERROR: Could not charge results")
        } else {
            print("Charged successful: \(reqIngredients)")
        }
        
        // Save and update view
        // Save
        do {
            try LocalDatabase.shared.saveStation(station)
        } catch {
            print("‼️ Could not save station.: \(error.localizedDescription)")
        }
        print("Activity created")
        selection = .activity
    }
    
    func collectRecipe(recipe:Recipe, from module:LabModule) -> Bool {
        
        switch recipe {
            
            case .Battery:
                print("Collect")
                // This one is easy. C'mon....
                let battery = Battery(shopped: false)
                self.station.truss.batteries.append(battery)
                finishActivity(module: module)
                return true
                
            case .SolarPanel:
                print("Collect")
                let panel = SolarPanel()
                do {
                    try station.truss.addSolar(panel: panel)
                    // Succeeded
                    finishActivity(module: module)
                    return true
                } catch {
                    self.problems = "Could not add Solar Panel. Error \(error.localizedDescription)"
                    return false
                }
                
            case .Electrolizer:
                print("Collect")
                let peripheral = PeripheralObject(peripheral:.Electrolizer)
                self.station.peripherals.append(peripheral)
                finishActivity(module: module)
                return true
                
            case .Methanizer:
                print("Collect")
                let peripheral = PeripheralObject(peripheral:.Methanizer)
                self.station.peripherals.append(peripheral)
                finishActivity(module: module)
                return true
                
            case .Radiator:
                print("Collect")
                let peripheral = PeripheralObject(peripheral:.Radiator)
                self.station.peripherals.append(peripheral)
                if let slot = station.truss.tComponents.filter({ $0.allowedType == .Radiator && $0.itemID == nil }).first {
                    let result = slot.insert(radiator: peripheral)
                    print("Inserted in Truss: \(result)")
                } else {
                    print("ERROR: No room for Radiators")
                }
                finishActivity(module: module)
                return true
                
            case .ScrubberCO2:
                print("Collect")
                let peripheral = PeripheralObject(peripheral:.ScrubberCO2)
                self.station.peripherals.append(peripheral)
                finishActivity(module: module)
                return true
                
            case .Condensator:
                print("Collect Condensator")
                let peripheral = PeripheralObject(peripheral:.Condensator)
                self.station.peripherals.append(peripheral)
                finishActivity(module: module)
                return true
                
            case .Roboarm:
                self.station.unlockedTechItems.append(.Roboarm)
                return true
                
            case .BioSolidifier:
                print("Bio")
                let peripheral = PeripheralObject(peripheral: .BioSolidifier)
                self.station.peripherals.append(peripheral)
                finishActivity(module: module)
                return true
            
            case .WaterFilter:
                print("Filter")
                let peripheral = PeripheralObject(peripheral: .WaterFilter)
                self.station.peripherals.append(peripheral)
                finishActivity(module: module)
                return true
                
            default:
                print("Haven't figured out how to make this yet :(")
        }
        
        return false
    }
    
    /// Finishes (Collect Button) a reccipe or tech tree research actrivity.
    func finishActivity(module:LabModule) {
        
        module.activity = nil
        self.selection = .NoSelection
        
        // Save
        do {
            try LocalDatabase.shared.saveStation(station)
        } catch {
            print("‼️ Could not save station.: \(error.localizedDescription)")
        }
        
    }
    
    // MARK: - Change Module
    // Module
    @objc func changeModuleNotification(_ notification:Notification) {
        
        guard let object = notification.object as? [String:Any] else {
            print("no object passed in this notification")
            return
        }
        
        print("Change Module Notification. Object:\n\(object.description)")
        var shouldCloseView:Bool = false
        
        if let moduleID = object["id"] as? UUID {
            if moduleID == labModule.id {
                
                // id checked
                if let name = object["name"] as? String {
                    self.labModule.name = name
                    station.labModules.first(where: { $0.id == moduleID })!.name = name
                } else
                if let skin = object["skin"] as? String {
                    // Skin
                    if let modSkin = ModuleSkin(rawValue: skin) {
                        print("Change skin to: \(modSkin.displayName)")
                        self.labModule.skin = modSkin
                        let rawModule = station.lookupRawModule(id: self.labModule.id)
                        rawModule.skin = modSkin
                        station.labModules.first(where: { $0.id == moduleID })!.skin = modSkin
                    }
                } else
                if let unbuild = object["unbuild"] as? Bool, unbuild == true {
                    
                    // Unbuild Module.
                    print("Danger! Wants to unbuild module")
                    let idx = station.labModules.firstIndex(where: { $0.id == moduleID })!
                    station.labModules.remove(at: idx)
                    
                    shouldCloseView = true
                }
            }
        } else {
            print("Error: ID doesnt check")
            return
        }
        
        do {
            try LocalDatabase.shared.saveStation(self.station)
            
            // Close the view
            if shouldCloseView == true {
                let closeNotification = Notification(name: .closeView)
                NotificationCenter.default.post(closeNotification)
            }
        } catch {
            // Deal with error
            print("Error saving station: \(error.localizedDescription)")
            self.problems = "Could not save station"
        }
    }
    
    // MARK: - Init
    
    init(lab:LabModule) {
        
        // Load Station
        let station = LocalDatabase.shared.station
        self.station = station
        self.labModule = lab
        self.unlockedRecipes = station.unlockedRecipes
        
        // Good to load file from here
        let tree = TechTree()
        tree.accountForItems(items: station.unlockedTechItems)
        
        self.techTree = tree
        self.unlocked = tree.showUnlocked() ?? []
        self.complete = tree.getCompletedItemsFrom(node: tree)
        
        self.unlockedItems = []
        
        if let activity = lab.activity {
            self.labActivity = activity
            self.selection = .activity
        }else{
            self.selection = .NoSelection
        }
        
        // People
        availableStaff = station.getPeople()
        print("Staff Count: \(station.getPeople().count)")
        
        // After init
        
        // Unlocked Items (Can be researched)
        for item in tree.showUnlocked() ?? [] {
            self.unlockedItems.append(item.item)
        }
        
        // Notification Observer
        NotificationCenter.default.addObserver(self, selector: #selector(changeModuleNotification(_:)), name: .changeModule, object: nil)
    }
    
    /// Initializes an instance for `Previews` only!
    init(demo recipe:Recipe) {
        
        // Load Station
        let station = LocalDatabase.shared.station
        self.station = station
        
        self.labModule = LabModule.example()
        self.unlockedRecipes = station.unlockedRecipes
        
        // Good to load file from here
        let tree = TechTree()
        tree.accountForItems(items: station.unlockedTechItems)
        
        self.techTree = tree
        self.unlocked = tree.showUnlocked() ?? []
        self.complete = tree.getCompletedItemsFrom(node: tree)
        
        self.unlockedItems = []
        
        // People
        availableStaff = station.getPeople()
        print("Staff Count: \(station.getPeople().count)")
        
        // After init
        self.selection = .recipe(name: recipe)
        
        // Unlocked Items (Can be researched)
        for item in tree.showUnlocked() ?? [] {
            self.unlockedItems.append(item.item)
        }
    }
    
    /// Initializes an instance for `Previews` only!
    init(demo tech:TechItems) {
        // Load Station
        let station = LocalDatabase.shared.station
        self.station = station
        
        self.labModule = LabModule.example()
        self.unlockedRecipes = station.unlockedRecipes
        
        // Good to load file from here
        let tree = TechTree()
        tree.accountForItems(items: station.unlockedTechItems)
        
        self.techTree = tree
        self.unlocked = tree.showUnlocked() ?? []
        self.complete = tree.getCompletedItemsFrom(node: tree)
        
        self.unlockedItems = []
        
        // People
        availableStaff = station.getPeople()
        print("Staff Count: \(station.getPeople().count)")
        
        // After init
        self.selection = .techTree(name: tech)
        
        // Unlocked Items (Can be researched)
        for item in tree.showUnlocked() ?? [] {
            self.unlockedItems.append(item.item)
        }
    }
    
    /// Initializes an instance for `Previews` only!
    init(demo activity:LabActivity) {
        // Load Station
        let station = LocalDatabase.shared.station
        self.station = station
        
        self.labModule = LabModule.example()
        self.unlockedRecipes = station.unlockedRecipes
        
        // Good to load file from here
        let tree = TechTree()
        tree.accountForItems(items: station.unlockedTechItems)
        
        self.techTree = tree
        self.unlocked = tree.showUnlocked() ?? []
        self.complete = tree.getCompletedItemsFrom(node: tree)
        
        self.unlockedItems = []
        
        // People
        availableStaff = station.getPeople()
        print("Staff Count: \(station.getPeople().count)")
        
        // After init
        self.selection = .activity
        
        // Unlocked Items (Can be researched)
        for item in tree.showUnlocked() ?? [] {
            self.unlockedItems.append(item.item)
        }
    }
    
}

/// Controls a continuous `LabActivity` updating it every few seconds
class LabActivityViewModel: ObservableObject {
    
    enum ActivityState {
        case running(remaining:Int)
        case finished
    }
    
    @Published var counter:Int = 0
    @Published var totalTime:Double
    @Published var timeRemaining:Int
    @Published var percentage:Double
    
    @Published var activity:LabActivity
    @Published var activityState:ActivityState
    
    init(labActivity:LabActivity) {
        
        self.activity = labActivity
        
        let tr = labActivity.dateEnds.timeIntervalSince(Date())
        self.timeRemaining = Int(tr)
        
        let total = labActivity.dateEnds.timeIntervalSince(labActivity.dateStarted)
        self.totalTime = total
        self.percentage = tr / Double(total)
        
//        if labActivity.dateStarted.compare(Date()) == .orderedDescending {
//            self.activity.dateStarted = Date()
//            self.activity.dateEnds = Date().addingTimeInterval(total)
//            let newTR =
//        }
        
        if tr <= 0 {
            self.activityState = .finished
            return
        } else {
            self.activityState = .running(remaining: Int(tr))
        }
            
        start()
    }
    
    // Timer
    var timer = Timer()
    
    func incrementCounter() {
//        print("Counter going \(counter)")
        self.counter += 1
        let tr = activity.dateEnds.timeIntervalSince(Date())
        self.timeRemaining = Int(tr)
        let total = activity.dateEnds.timeIntervalSince(activity.dateStarted)
        self.totalTime = total
        self.percentage = tr / total
        
        if tr <= 0 {
            timer.invalidate()
            self.activityState = .finished
        } else {
            self.activityState = .running(remaining: Int(tr))
        }
    }
    
    func hourBoost() {
        self.activity.dateEnds.addTimeInterval(-3600)
    }
    
    deinit {
        self.counter = 0
        self.timer.invalidate()
    }
    
    // TIMER
    
    func start() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { timer in
            self.incrementCounter()
        }
    }
    
    func stop() {
        timer.invalidate()
    }
    
    func reset() {
        counter = 0
        timer.invalidate()
    }
    
}
