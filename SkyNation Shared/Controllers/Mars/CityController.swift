//
//  CityController.swift
//  SkyNation
//
//  Created by Carlos Farini on 3/20/21.
//

import Foundation

enum MarsCityStatus {
    case loading                    // Data not loaded yet
    case unclaimed                  // City has no owner
    case foreign(pid:UUID)          // Belongs to someone else
    case mine(cityData:CityData)    // Belongs to Player
}

class CityController:ObservableObject {
    
    var builder:MarsBuilder
    @Published var player:SKNPlayer
    
    @Published var cityTitle:String = "Unclaimed City"
    
    @Published var city:DBCity?
    @Published var cityData:CityData?
    @Published var ownerID:UUID?
    
    @Published var isMyCity:Bool = false
    @Published var isClaimedCity:Bool = true
    
    @Published var viewState:MarsCityStatus
    
    init() {
        guard let player = LocalDatabase.shared.player else { fatalError() }
        self.player = player
        self.builder = MarsBuilder.shared
        viewState = .loading
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
                if player.playerID == ownerID {
                    print("PLAYER OWNS IT !!!!")
                    isMyCity = true
                    
                    // Load City (New Method)
                    if let cityData:CityData = MarsBuilder.shared.myCityData {
                        if let localCity:CityData = LocalDatabase.shared.city {
                            self.cityData = localCity
                        } else {
                            
                            print("Try to save city")
//                            do {
//                                try LocalDatabase.shared.saveCity(cityData)
//                            } catch {
//                                print("⚠️ ERROR loading city data")
//                            }
                        }
                        
                        self.cityData = cityData
                        self.viewState = .mine(cityData: cityData)
                        // self.getArrivedVehicles()
                        
                    }
                    
                    
                    // Load city from Server
                    /*
                    SKNS.loadCity(posdex: Posdex(rawValue: theCity.posdex)!) { (cityData, error) in
                        if let cData = cityData {
                            print("Loaded City Data. Ready.")
                            self.cityData = cData
                            self.viewState = .mine(cityData: cData)
                            self.getArrivedVehicles()
                            MarsBuilder.shared.myCityData = cData
                        } else {
                            print("⚠️ CityData: \(error?.localizedDescription ?? "n/a")")
                        }
                    }
                     */
                    
                } else {
                    
                    // City Belongs to someone else
                    isMyCity = false
                    
                    
                    self.viewState = .foreign(pid:ownerID)
                    // let citizen = MarsBuilder.shared.players.filter({ $0.id == ownerID })
                    
                }
            }
        } else {
            print("This is an unclaimed city")
            isMyCity = false
            isClaimedCity = false
            viewState = .unclaimed
        }
        
    }
    
    @Published var allVehicles:[SpaceVehicleContent] = []
    @Published var cityVehicles:[SpaceVehicleContent] = []
    
    /// Gets all vehicles that arrived
    func getArrivedVehicles() {
        
        switch viewState {
            case .loading:
                print("Still loading")
                return
            case .unclaimed:
                print("Unclaimed cities don't need vehicles")
                return
            default:break
        }
        
        
        allVehicles = []
        cityVehicles = []
        
        print("Getting Arrived Vehicles")
        SKNS.arrivedVehiclesInGuildFile { gVehicles, error in
            if let gVehicles:[SpaceVehicleContent] = gVehicles {
                self.allVehicles = gVehicles
                print("Guild garage vehicles: \(gVehicles.count)")
                let cityOwner = self.city?.owner ?? [:]
                let ownerID = cityOwner["id"] as? UUID ?? UUID()
                
                for vehicle in gVehicles {
                    
                    if vehicle.owner == ownerID {
                        self.cityVehicles.append(vehicle)
                    }
                    
                    if vehicle.owner == self.player.id {
                        print("Vehicle is mine: \(vehicle.engine)")
                        print("Contents (count): \(vehicle.boxes.count + vehicle.tanks.count + vehicle.batteries.count + vehicle.passengers.count + vehicle.peripherals.count)")
                        
                        // Bring contents to city
                        // Update City
                        // Post city update
                    }
                }
            } else {
                print("⚠️ Error: Could not get arrived vehicles. error -> \(error?.localizedDescription ?? "n/a")")
            }
        }
    }
    
    func unpackVehicle(vehicle:SpaceVehicleContent) {
        
        // Testing time
        
        
//        guard let vid = vehicle.id,
//              self.cityData != nil else {
//            print("No vehicle ID !!!")
//            return
//        }
        
        let cCopy = cityData!
        
//        print("Unpacking vehicle. id: \(vid)")
        cCopy.boxes.append(contentsOf: vehicle.boxes)
        cCopy.tanks.append(contentsOf: vehicle.tanks)
        cCopy.batteries.append(contentsOf: vehicle.batteries)
        cCopy.peripherals.append(contentsOf: vehicle.peripherals)
        cCopy.inhabitants.append(contentsOf: vehicle.passengers)
        
        self.cityData = cCopy
        
        // Update city to server
        SKNS.saveCity(city: cCopy) { (cData, error) in
            if let cData:CityData = cData {
                print("Got cData! Updated.")
                self.cityData = cData
            } else {
                print("Error: \(error?.localizedDescription ?? "n/a")")
            }
        }
        
        
        switch self.viewState {
            case .mine(let city):
                self.allVehicles.removeAll(where: { $0.id == vehicle.id })
                self.viewState = .mine(cityData: city)
            default:
                print("not my city")
                
        }
        
        // Updated city. Now needs to update server
        // Updated server. Delete Vehicle
        //
    }
    
    
    // Development Helper
    func addSomethingToCity() {
        
        if cityData == nil {
            print("!! City data is nil !!!")
        }
        
        var willAddBatteries:Bool = Bool.random()
        var willAddTanks:Bool = Bool.random()
        var willAddBoxes:Bool = Bool.random()
        
        if cityData?.batteries.isEmpty == false {
            willAddBatteries = false
        }
        if cityData?.tanks.isEmpty == false {
            willAddTanks = false
        }
        if cityData?.boxes.isEmpty == false {
            willAddBoxes = false
        }
        
        if willAddBatteries {
            for _ in 0..<5 {
                let newBattery = Battery(shopped: true)
                cityData?.batteries.append(newBattery)
            }
            print("Added 5 batteries")
            
        }
        
        if willAddBoxes {
            for _ in 0..<10 {
                let newBoxType = Ingredient.allCases.randomElement()!
                let nb = StorageBox(ingType: newBoxType, current: newBoxType.boxCapacity())
                cityData?.boxes.append(nb)
            }
            print("Added 10 ingredients")
        }
        
        if willAddTanks {
            for _ in 0..<10 {
            
                let ttype = TankType.allCases.randomElement()!
                let tank = Tank(type: ttype, full: true)
                cityData?.tanks.append(tank)
            }
            print("Added 10 tanks")
        }
    }
}
