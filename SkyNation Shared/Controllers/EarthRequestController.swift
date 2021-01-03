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
    
    case Ordering(order:PayloadOrder)       // Choosing
    case Reviewing(order:PayloadOrder)      // Looking at summary
    
    case OrderPlaced                        // Order placed...
    
    case Delivering(order:PayloadOrder)     // Retrieving
//    case Delivered      // Finished
    
}

class EarthRequestController:ObservableObject {
    
    // Database
    private var station:Station
    private var player:SKNPlayer
    
    /// The limit of items that can go in an Order
    let orderLimit:Int = GameLogic.earthOrderLimit
    
    @Published var orderQuantity:Int = 0
    @Published var currentOrder:PayloadOrder?
    @Published var orderCost:Int = PayloadOrder.basePrice
    @Published var errorMessage:String = ""
    
//    @Published var selectedIngredients:[Ingredient] = []
//    @Published var selectedTanks:[TankType] = []
//    @Published var selectedPeople:[Person] = []
    
    @Published var orderAisle:EarthViewPicker = .Ingredients
    @Published var orderStatus:OrderStatus
    
    @Published var money:Int
    
    init() {
        
        let player = LocalDatabase.shared.player!
        let spaceStation = LocalDatabase.shared.station!
        
        self.station = spaceStation
        self.player = player
        
        self.money = player.money
        self.currentOrder = spaceStation.earthOrder
        
        // Check current Order
        if let oldOrder = spaceStation.earthOrder {
            self.orderStatus = .Ordering(order: oldOrder)
            updatePayload(order: oldOrder)
        } else {
            let newOrder = PayloadOrder()
            self.currentOrder = newOrder
            self.orderStatus = .Ordering(order: newOrder)
        }
    }
    
    /// Updates Variables with the PayloadOrder passed
    private func updatePayload(order:PayloadOrder) {
        if order.delivered == false {
            // Populate
            self.currentOrder = order
            self.orderQuantity = order.calculateWeight()
            self.orderCost = order.calculateTotal()
            self.orderStatus = .Reviewing(order: order)
            
        } else {
            
            // Delivered
            self.currentOrder = order
            self.orderQuantity = order.calculateWeight()
            self.orderCost = order.calculateTotal()
            self.orderStatus = .Delivering(order: order)
        }
    }
    
    // MARK: - Adding Stuff
    
    func addToCart(ingredient:Ingredient) {
        
        guard let currentOrder = currentOrder else {
            errorMessage = "No current order"
            return
        }
        
        // Check Quantity
        if currentOrder.calculateWeight() < GameLogic.earthOrderLimit {
            
            // Check Money
            let subtotal = currentOrder.calculateTotal()
            let total = ingredient.price + subtotal
            
            if player.money >= total {
                self.orderCost = total
                self.errorMessage = ""
                currentOrder.orderNewIngredient(type: ingredient)
                self.orderQuantity = currentOrder.calculateWeight()
                self.orderStatus = .Ordering(order: currentOrder)
            } else {
                self.errorMessage = "Not enough Sky cash."
            }
            
        } else {
            self.errorMessage = "Order is full."
        }
    }
    
    func addToCart(tankType:TankType) {
        guard let currentOrder = currentOrder else {
            errorMessage = "No current order"
            return
        }
        
        // Check Quantity
        if currentOrder.calculateWeight() < GameLogic.earthOrderLimit {
            
            // Check Money
            let subtotal = currentOrder.calculateTotal()
            let total = subtotal + GameLogic.orderTankPrice
            
            if player.money >= total {
                self.orderCost = total
                self.errorMessage = ""
                currentOrder.orderNewTank(type: tankType)
                self.orderQuantity = currentOrder.calculateWeight()
                self.orderStatus = .Ordering(order: currentOrder)
            } else {
                self.errorMessage = "Not enough Sky cash."
            }
            
        } else {
            self.errorMessage = "Order is full."
        }
    }
    
    func addToHire(person:Person) {
        
        guard let currentOrder = currentOrder else {
            errorMessage = "No current order"
            return
        }
        
        // Check Quantity
        if currentOrder.calculateWeight() < GameLogic.earthOrderLimit {
            
            // Check Money
            let subtotal = currentOrder.calculateTotal()
            let total = subtotal + GameLogic.orderPersonPrice
            
            if player.money >= total {
                self.orderCost = total
                self.errorMessage = ""
                currentOrder.addPerson(person: person)
                self.orderQuantity = currentOrder.calculateWeight()
                self.orderStatus = .Ordering(order: currentOrder)
            } else {
                self.errorMessage = "Not enough Sky cash."
            }
            
        } else {
            self.errorMessage = "Order is full."
        }
    }
    
    // Control
    
    // 1. Review
    // 2. Confirm
    
    /// Sets the UI to review mode
    func reviewOrder() {
        guard let currentOrder = currentOrder else {
            errorMessage = "No current order"
            return
        }
        self.orderStatus = .Reviewing(order: currentOrder)
    }
    
    func placeOrder() -> Bool {
        
        guard let currentOrder = currentOrder else {
            errorMessage = "No current order"
            return false
        }
        
        print("Placing Order...")
        
        let totalCost = currentOrder.calculateTotal()
        
        if player.money >= Int(totalCost) {
            
            // Update Data
            player.money -= Int(totalCost)
            currentOrder.delivered = true
            currentOrder.deliveryDate = Date().addingTimeInterval(30) // 30 Seconds
            station.earthOrder = currentOrder
            
            // update UI
            self.money = player.money
            self.orderStatus = .OrderPlaced
            
            // update scene after 1.2 seconds
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.2) {
                SceneDirector.shared.didFinishDeliveryOrder(order: self.station.earthOrder)
            }
            
            // Save Data
            LocalDatabase.shared.saveStation(station: station)
            let result = LocalDatabase.shared.savePlayer(player: player)
            guard result == true else {
                print("ERROR: Player \(player.name) could not be saved.")
                return false
            }
            return true
            
        } else {
            errorMessage = "Cannot afford"
            return false
        }
        
    }
    
    /// Goes back to ordering
    func resumeOrder() {
        
        guard let currentOrder = currentOrder else {
            errorMessage = "No current order"
            return
        }
        
        self.orderCost = currentOrder.calculateTotal()
        self.orderQuantity = currentOrder.calculateWeight()
        
        self.orderStatus = .Ordering(order: currentOrder)
        
    }
    
    /// From the UI, to start over the order
    func clearOrder() {
        self.resetOrder()
    }
    
    /// Resets the order, pass clean = true to clear the order in Station
    private func resetOrder(cleanup:Bool? = false) {
        
        guard let currentOrder = currentOrder else {
            errorMessage = "No current order"
            return
        }
        
        // Reset Order
        currentOrder.resetOrder()
        
        self.orderCost = currentOrder.calculateTotal()
        self.orderQuantity = currentOrder.calculateWeight()
        self.orderStatus = .Ordering(order: currentOrder)
        
        if cleanup == true {
            station.earthOrder = nil
            LocalDatabase.shared.saveStation(station: station)
        }
        
    }
    
    /// When order is complete, this is a chance to order more
//    func orderMore() {
//        self.orderStatus = .Ordering(items: .Ingredients)
//    }
    
    /// Adds the contents of the delivery order to the station and resets all the numbers
    func acceptDelivery() {
        
        guard let currentOrder = currentOrder else {
            errorMessage = "No current order"
            return
        }
        
        for ingredientBox in currentOrder.ingredients {
            // Some Special Ingredients require handling....
            // Batteries
            if ingredientBox.type == .Battery {
                station.truss.batteries.append(Battery(shopped: true))
            } else if ingredientBox.type == .Food {
                // Food
                for _ in 0...ingredientBox.type.boxCapacity() {
                    let dna = PerfectDNAOption.allCases.randomElement()!
                    station.food.append(dna.rawValue)
                }
            } else {
                // Normal Ingredient
                station.truss.extraBoxes.append(ingredientBox)
            }
        }
        
        for tank in currentOrder.tanks {
            station.truss.tanks.append(tank)
        }
        
        for person in currentOrder.people {
            let result = station.addToStaff(person: person)
            if result == false {
                self.errorMessage = "No Room for \(person.name)"
            }
        }
        
        currentOrder.delivered = true
        station.earthOrder = nil
        
        // Save
        LocalDatabase.shared.saveStation(station: station)
        
        // Update UI
        self.resetOrder(cleanup: true)
        
        // Update Scene
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.2) {
            SceneDirector.shared.didFinishDeliveryOrder(order: self.station.earthOrder)
        }
        
        
        
//        self.currentOrder = nil
//        let emptyOrder = PayloadOrder()
//        self.orderCost = emptyOrder.calculateTotal()
//        self.orderStatus = .Ordering(order: emptyOrder)
        
//        for ingredient in selectedIngredients {
//            if ingredient == .Battery {
//                station.truss.batteries.append(Battery(shopped: true))
//            } else if ingredient == .Food {
//                for _ in 0...ingredient.boxCapacity() {
//                    let dna = PerfectDNAOption.allCases.randomElement()!
//                    station.food.append(dna.rawValue)
//                }
//            } else{
//                station.truss.extraBoxes.append(StorageBox(ingType: ingredient, current: ingredient.boxCapacity()))
//            }
//        }
//
//        for tank in selectedTanks {
//            station.truss.tanks.append(Tank(type: tank, full: true))
//        }
//
//        for person in selectedPeople {
//            let result = station.addToStaff(person: person)
//            if result == false {
//                self.errorMessage = "No Room for more people"
//            }else{
//                if let idx = selectedPeople.firstIndex(of: person) {
//                    self.selectedPeople.remove(at: idx)
//                }
//            }
//        }
        
//        station.earthOrder?.delivered = true
        
        
//        station.earthOrder = nil
        
//        // Save
//        LocalDatabase.shared.saveStation(station: station)
        
        // Erase previous
//        self.selectedPeople = []
//        self.selectedTanks = []
//        self.selectedIngredients = []
        
//        self.orderStatus = .OrderPlaced
        
        
    }
    
}


