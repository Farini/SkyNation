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

enum MarsCityTab {
    case Hab
    case Lab
    case RSS
    case EVs // Electric Vehicles
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
    @Published var cityTab:MarsCityTab = .Hab
    
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
                
                // My City
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
                        self.getArrivedVehicles()
                        
                    }
                } else {
                    
                    // Other City - Belongs to someone else
                    isMyCity = false
                    self.viewState = .foreign(pid:ownerID)
                    // Get Player card from GuildFullContent, in 
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
    
    @Published var arrivedVehicles:[SpaceVehicle] = []
    
    /// Gets all vehicles that arrived
    func getArrivedVehicles() {
        
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
        
        var travellingVehicles = LocalDatabase.shared.vehicles
        
        // Loop through Vehicles to see if any one arrived
        var transferringVehicles:[SpaceVehicle] = []
        for vehicle in travellingVehicles {
            if let arrivalDate = vehicle.dateTravelStarts?.addingTimeInterval(GameLogic.vehicleTravelTime) {
                if Date().compare(arrivalDate) == .orderedDescending {
                    // Arrived
                    // Change vehicle destination to either [MarsOrbit, or Exploring, or Settled]
                    transferringVehicles.append(vehicle)
                }
            }
        }
        
        
        self.arrivedVehicles = transferringVehicles
        
        if let city = cityData {
            for vehicle in transferringVehicles {
            
                travellingVehicles.removeAll(where: { $0.id == vehicle.id })
                city.garage.vehicles.append(vehicle)
                
                // Achievement
                GameMessageBoard.shared.newAchievement(type: .vehicleLanding(vehicle: vehicle), message: nil)
            }
            
            do {
                try LocalDatabase.shared.saveCity(city)
            } catch {
                print("⚠️ Could not save city in LocalDatabase after getting arrived vehicles")
            }
        }
        
        LocalDatabase.shared.vehicles = travellingVehicles
        self.arrivedVehicles = cityData?.garage.vehicles ?? []
        
        /*
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
        */
        
    }
    
    /*
    func unpackVehicle(vehicle:SpaceVehicleContent) {
        
        // Testing time
        
        
//        guard let vid = vehicle.id,
//              self.cityData != nil else {
//            print("No vehicle ID !!!")
//            return
//        }
        
//        let cCopy = cityData!
//
////        print("Unpacking vehicle. id: \(vid)")
//        cCopy.boxes.append(contentsOf: vehicle.boxes)
//        cCopy.tanks.append(contentsOf: vehicle.tanks)
//        cCopy.batteries.append(contentsOf: vehicle.batteries)
//        cCopy.peripherals.append(contentsOf: vehicle.peripherals)
//        cCopy.inhabitants.append(contentsOf: vehicle.passengers)
        
//        self.cityData = cCopy
//
//        // Update city to server
//        SKNS.saveCity(city: cCopy) { (cData, error) in
//            if let cData:CityData = cData {
//                print("Got cData! Updated.")
//                self.cityData = cData
//            } else {
//                print("Error: \(error?.localizedDescription ?? "n/a")")
//            }
//        }
//
//
//        switch self.viewState {
//            case .mine(let city):
////                self.allVehicles.removeAll(where: { $0.id == vehicle.id })
//                self.viewState = .mine(cityData: city)
//            default:
//                print("not my city")
//
//        }
        
        // Updated city. Now needs to update server
        // Updated server. Delete Vehicle
        //
    }
    */
    
    /// Claims the city for the Player
    func claimCity(posdex:Posdex) {
        
        // FIXME: - Develop this
        // Save CityData?
        // the self.loadAt might need updates
        
        SKNS.claimCity(user: SKNUserPost(player: LocalDatabase.shared.player!), posdex: posdex) { (city, error) in
            
            // This request should return a DBCity instead
            if let dbCity = city {
                
                print("We have a new city !!!! \t \(dbCity.id)")
                
                var localCity:CityData!
                
                // First, check if player alread has a city in LocalDatabase
                if let savedCity:CityData = LocalDatabase.shared.loadCity() {
                    
                    // We have a local city saved. Update ID
                    savedCity.id = dbCity.id
                    localCity = savedCity
                    
                } else {
                    localCity = CityData(dbCity: dbCity)
                }
                
                try? LocalDatabase.shared.saveCity(localCity)
                
                let player = self.player
                player.cityID = dbCity.id
                
                let res = LocalDatabase.shared.savePlayer(player: player)
                
                print("Claim city results Saved. Player:\(res)")
                
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
