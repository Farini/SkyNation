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
    case foreign                     // Belongs to someone else
    case mine(cityData:CityData)    // Belongs to Player
}

class CityController:ObservableObject {
    
    var builder:MarsBuilder
    @Published var player:SKNPlayer
    
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
        
        if let theCity = builder.cities.filter({ $0.posdex == posdex.rawValue }).first {
            print("The City: \(theCity.name)")
            self.city = theCity
            let cityOwner = theCity.owner ?? [:]
            
            
            if let ownerID = cityOwner["id"] as? UUID {
                print("Owner ID: \(ownerID)")
                if player.playerID == ownerID {
                    print("PLAYR OWNS IT !!!!")
                    isMyCity = true
                    
                    SKNS.loadCity(posdex: Posdex(rawValue: theCity.posdex)!) { (cityData, error) in
                        if let cData = cityData {
                            print("Loaded City Data. Ready.")
                            self.cityData = cData
                            self.viewState = .mine(cityData: cData)
                            self.getArrivedVehicles()
                        } else {
                            print("⚠️ Error: \(error?.localizedDescription ?? "n/a")")
                        }
                    }
                    
                } else {
                    // Also get city data from server (not editable)
                    isMyCity = false
                    self.viewState = .foreign
                }
            }
        } else {
            print("This is an unclaimed city")
            isMyCity = false
            isClaimedCity = false
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
        
        var cCopy = cityData!
        
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
}
