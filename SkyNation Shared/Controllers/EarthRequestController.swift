//
//  EarthRequestController.swift
//  SkyTestSceneKit
//
//  Created by Carlos Farini on 11/15/20.
//  Copyright © 2020 Farini. All rights reserved.
//

import Foundation

enum EarthViewPicker:String, CaseIterable, Hashable, Equatable {
    case Ingredients
    case Tanks
    case People
}
enum OrderStatus {
    
    case Ordering(items:EarthViewPicker)   // Choosing
    case Reviewing      // Looking at summary
    case OrderPlaced    // Order placed...
    
    case Delivering     // Retrieving
    case Delivered      // Finished
    
}

class EarthRequestController:ObservableObject {
    
    /// The limit of items that can go in an Order
    let orderLimit:Int = GameLogic.earthOrderLimit // = 6
    
    @Published var selectedIngredients:[Ingredient] = []
    @Published var selectedTanks:[TankType] = []
    @Published var selectedPeople:[Person] = []
    
    @Published var currentSelectionType:EarthViewPicker = .Ingredients
    @Published var orderStatus:OrderStatus
    
    // Station
    var station:Station
    @Published var money:Double
    
    // Order
    @Published var currentOrder:PayloadOrder?
    @Published var orderCost:Double = EarthOrder.basePrice
    @Published var errorMessage:String = ""
    
    init() {
        
        let spaceStation = LocalDatabase.shared.station!
        self.station = spaceStation
        self.money = spaceStation.money
        self.currentOrder = spaceStation.earthOrder?.makePayload()
        
        if let previousOrder = spaceStation.earthOrder {
            if previousOrder.delivered == true {
                self.orderStatus = .Reviewing
                //                emptyOrder = false
            }else{
                self.orderStatus = .Delivering
                self.selectedIngredients = previousOrder.ingredients
                self.selectedTanks = previousOrder.tanks
                self.selectedPeople = previousOrder.people
                self.orderCost = previousOrder.calculateTotal()
                //                emptyOrder = false
            }
        } else {
            self.orderStatus = .Ordering(items:EarthViewPicker.Ingredients)
            selectedIngredients = []
            selectedTanks = []
            selectedPeople = []
            //            emptyOrder = true
        }
    }
    
    func canAddToOrder() -> Bool {
        return countOfItems() < orderLimit
    }
    
    private func countOfItems() -> Int {
        return selectedIngredients.count + selectedPeople.count + selectedTanks.count
    }
    
    private func canAffordOrder(newItem:Codable?) -> Bool {
        
        let newOrder = EarthOrder()
        
        newOrder.ingredients = self.selectedIngredients
        newOrder.tanks = self.selectedTanks
        newOrder.people = self.selectedPeople
        
        if let item = newItem {
            if let newIngredient = item as? Ingredient {
                newOrder.ingredients.append(newIngredient)
            }else if let newTank = item as? TankType {
                newOrder.tanks.append(newTank)
            }else if let newPerson = item as? Person {
                newOrder.people.append(newPerson)
            }
        }
        
        let orderTotal = newOrder.calculateTotal()
        
        return station.money >= orderTotal
    }
    
    //    func isOrderEmpty() -> Bool {
    //        return selectedIngredients.isEmpty && selectedTanks.isEmpty && selectedPeople.isEmpty
    //    }
    
    // MARK: - Adding Stuff
    
    func order(ingredient:Ingredient) {
        if canAddToOrder() {
            if canAffordOrder(newItem:ingredient) {
                selectedIngredients.append(ingredient)
                
                // TODO: - Review This Order Cost
                self.orderCost += 10
            }else{
                errorMessage = "Cannot afford"
            }
            
        } else {
            // Can't add to order
            errorMessage = "Limit reached"
        }
    }
    
    func order(tankType:TankType) {
        if canAddToOrder() {
            if canAffordOrder(newItem:tankType) {
                selectedTanks.append(tankType)
            }else{
                errorMessage = "Cannot afford"
            }
            
        } else {
            // Can't add to order
            errorMessage = "Limit reached"
        }
    }
    
    func hire(person:Person) {
        if canAddToOrder() {
            if canAffordOrder(newItem:person) {
                selectedPeople.append(person)
            }else{
                errorMessage = "Cannot afford"
            }
        }else{
            errorMessage = "Limit reached"
        }
    }
    
    // Control
    
    func placeOrder() {
        
        let newOrder = EarthOrder()
        
        newOrder.ingredients = self.selectedIngredients
        newOrder.tanks = self.selectedTanks
        newOrder.people = self.selectedPeople
        newOrder.delivered = false
        
        let orderCost = newOrder.calculateTotal()
        
        if canAffordOrder(newItem: nil) == true {
            // Order went through
            station.money -= orderCost
            station.earthOrder = newOrder
            
            // Save
            LocalDatabase.shared.saveStation(station: station)
            self.orderStatus = .OrderPlaced
            
            SceneDirector.shared.didFinishPlacingOrder()
            
        }else{
            errorMessage = "Cannot afford"
        }
    }
    
    func reviewOrder() {
        self.orderStatus = .Reviewing
    }
    
    func resumeOrder() {
        self.orderStatus = .Ordering(items: .Ingredients)
    }
    
    func clearOrder() {
        self.selectedIngredients = []
        self.selectedTanks = []
        self.selectedPeople = []
        self.orderStatus = .Ordering(items: .Ingredients)
        
        SceneDirector.shared.didFinishDeliveryOrder(order: station.earthOrder)
        station.earthOrder = nil
        LocalDatabase.shared.saveStation(station: station)
        
    }
    
    /// When order is complete, this is a chance to order more
    func orderMore() {
        self.orderStatus = .Ordering(items: .Ingredients)
    }
    
    func acceptDelivery() {
        
        for ingredient in selectedIngredients {
            if ingredient == .Battery {
                station.truss.batteries.append(Battery(shopped: true))
            } else if ingredient == .Food {
                for _ in 0...ingredient.boxCapacity() {
                    let dna = PerfectDNAOption.allCases.randomElement()!
                    station.food.append(dna.rawValue)
                }
            } else{
                station.truss.extraBoxes.append(StorageBox(ingType: ingredient, current: ingredient.boxCapacity()))
            }
        }
        
        for tank in selectedTanks {
            station.truss.tanks.append(Tank(type: tank, full: true))
        }
        
        for person in selectedPeople {
            let result = station.addToStaff(person: person)
            if result == false {
                self.errorMessage = "No Room for more people"
            }else{
                if let idx = selectedPeople.firstIndex(of: person) {
                    self.selectedPeople.remove(at: idx)
                }
            }
        }
        
        station.earthOrder?.delivered = true
        
        SceneDirector.shared.didFinishDeliveryOrder(order: station.earthOrder)
        station.earthOrder = nil
        
        // Save
        LocalDatabase.shared.saveStation(station: station)
        
        // Erase previous
        self.selectedPeople = []
        self.selectedTanks = []
        self.selectedIngredients = []
        
        self.orderStatus = .OrderPlaced
        
        
    }
    
}


