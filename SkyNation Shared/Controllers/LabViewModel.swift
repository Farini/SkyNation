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
    
    // MARK: - TECH
    
    func makeTech(item:TechItems) {
        self.problems = nil
        
        // Check Ingredients
        let reqIngredients:[Ingredient:Int] = item.ingredients()
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
        // Add problem message
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
        
        // Create activity
        let duration = item.getDuration()
        let delta:TimeInterval = Double(duration)
        let activity = LabActivity(time: delta, name: item.rawValue)
        labModule.activity = activity
        
        // Save and update view
        LocalDatabase.shared.saveStation(station: station)
        print("Activity created")
        selection = .activity
    }
    
    func collectTech(activity:LabActivity, tech:TechItems) {
        
        if let activity = self.labModule.activity {
            print("Found activity: \(activity.activityName)")
            
            if let techItem = TechItems(rawValue: activity.activityName) {
                
                print("Found tech item")
                LocalDatabase.shared.builder.upgradeTech(item: techItem)
                // Builder is responsible for saving....
                
                print("Completed Upgrading. Check JSON.")
                
                // Check if this is a recipe
                switch techItem {
                    case .recipeMethane:
                        self.station.unlockedRecipes.append(Recipe.Methanizer)
                    case .recipeScrubber:
                        self.station.unlockedRecipes.append(Recipe.ScrubberCO2)
                    case .recipeBioSolidifier:
                        self.station.unlockedRecipes.append(Recipe.BioSolidifier)
                    case .recipeWaterFilter:
                        self.station.unlockedRecipes.append(Recipe.WaterFilter)
                    default:
                        print("Not a recipe")
                }
                
                // Update Scene
                SceneDirector.shared.didCollectTech(tech:techItem, model:techItem.loadToScene())
                
                // Save
                self.station.unlockedTechItems.append(tech) //LocalDatabase.shared.station!.unlockedTechItems.append(tech)
                LocalDatabase.shared.saveStation(station: self.station) // LocalDatabase.shared.saveStation(station: LocalDatabase.shared.station!)
//                LocalDatabase.shared.saveSerialBuilder(builder: LocalDatabase.shared.builder)
                
                self.labModule.activity = nil
                self.selected = nil
                self.selection = .NoSelection
            }
            
        }
    }
    
    func throwAwayTech() {
        if let activity = self.labModule.activity {
            print("Throwing away: \(activity.activityName)")
            self.labModule.activity = nil
            LocalDatabase.shared.saveStation(station: station)
            self.selection = .NoSelection
        }
    }
    
    // MARK: - Recipes
    
    /// The disabled state of the button "Make Recipe" for this recipe
    func recipeDisabled(recipe:Recipe) -> Bool {
        return !station.unlockedRecipes.contains(recipe)
    }
    
    func makeRecipe(recipe:Recipe) {
        
        print("Making recipe: \(recipe.rawValue)")
        
        // Create Activity
        let duration = recipe.getDuration()
        let delta:TimeInterval = Double(duration)
        let activity = LabActivity(time: delta, name: recipe.rawValue)
        labModule.activity = activity
        
        // Save and update view
        LocalDatabase.shared.saveStation(station: station)
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
                self.station.truss.solarPanels.append(panel)
                finishActivity(module: module)
                return true
                
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
                finishActivity(module: module)
                return true
                
            case .ScrubberCO2:
                print("Collect")
                let peripheral = PeripheralObject(peripheral:.ScrubberCO2)
                self.station.peripherals.append(peripheral)
                finishActivity(module: module)
                return true
                
            case .Condensator:
                print("Collect")
                let peripheral = PeripheralObject(peripheral:.Condensator)
                self.station.peripherals.append(peripheral)
                finishActivity(module: module)
                return true
                
            case .Roboarm:
                self.station.unlockedTechItems.append(.Roboarm)
                return true
                
            default:
                print("Haven't figured out how to make this yet :(")
        }
        
        return false
    }
    
    func finishActivity(module:LabModule) {
        print("Finishing Activity")
        module.activity = nil
        self.selection = .NoSelection
        LocalDatabase.shared.saveStation(station: self.station)
        print("Saved")
    }
    
    // MARK: - Init
    
    init(lab:LabModule) {
        // Load Station
        let station = LocalDatabase.shared.station!
        self.station = station
        self.labModule = lab
        self.unlockedRecipes = station.unlockedRecipes
        //        self.labActivity = lab.activity
        
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
    }
    
    /// Initializes an instance for `Previews` only!
    init(demo recipe:Recipe) {
        
        // Load Station
        let station = LocalDatabase.shared.station!
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
        let station = LocalDatabase.shared.station!
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
        let station = LocalDatabase.shared.station!
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


class LabActivityViewModel: ObservableObject {
    
    @Published var counter:Int = 0
    @Published var totalTime:Double
    @Published var timeRemaining:Int
    @Published var percentage:Double
    
    @Published var activity:LabActivity
    
    init(labActivity:LabActivity) {
        self.activity = labActivity
        let tr = labActivity.dateEnds.timeIntervalSince(Date())
        self.timeRemaining = Int(tr)
        let total = labActivity.dateEnds.timeIntervalSince(labActivity.dateStarted)
        self.totalTime = total
        self.percentage = tr / Double(total)
            
        start()
    }
    
    // Timer
    var timer = Timer()
    
    func incrementCounter() {
        print("Counter going \(counter)")
        self.counter += 1
        let tr = activity.dateEnds.timeIntervalSince(Date())
        self.timeRemaining = Int(tr)
        let total = activity.dateEnds.timeIntervalSince(activity.dateStarted)
        self.totalTime = total
        self.percentage = tr / total
        if tr < 0 {
            timer.invalidate()
        }
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
