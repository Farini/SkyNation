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
    CityController vs. LocalCityController
        
        City Controller: Controls any city, and whether is claimable
        LocalCity - Controls the City of the Local Player
*/
class CityController:ObservableObject {
    
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
//                    self.updateVehiclesLists()
                    
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
        
        self.warnings = []
        
        // FIXME: - Develop this
        // Save CityData?
        // the self.loadAt might need updates
        
        SKNS.claimCity(posdex: posdex) { (city, error) in
            
            // This request should return a DBCity instead
            if let dbCity = city {
                
                print("We have a new city !!!! \t \(dbCity.id)")
                
                var localCity:CityData?
                
                // First, check if player alread has a city in LocalDatabase
                if let savedCity:CityData = LocalDatabase.shared.cityData {
                    
                    // We have a local city saved. Update ID
                    savedCity.id = dbCity.id
                    localCity = savedCity
                    
                } else {
                    localCity = CityData(dbCity: dbCity)
                }
                
                guard let localCity = localCity else {
                    return
                }

                try? LocalDatabase.shared.saveCity(localCity)
                
                let player = self.player
                player.cityID = dbCity.id
                
                DispatchQueue.main.async {
                    do {
                        try LocalDatabase.shared.savePlayer(player)
                        self.isMyCity = true
                        self.isClaimedCity = true
                        self.warnings = ["City Claimed by \(player.name)"]
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            self.viewState = .mine(cityData: localCity)
                        }
                    } catch {
                        print("Could not save Player. Error.: \(error.localizedDescription)")
                        self.warnings = ["Could not save Player. Error.: \(error.localizedDescription)"]
                    }
                }
                
            } else {
//                print("No City. Error: \(error?.localizedDescription ?? "n/a")")
                self.warnings = ["Error claiming city: \(error?.localizedDescription ?? "n/a")"]
            }
        }
    }
    
    // MARK: - Vehicles
    
    /*
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
                    // GameMessageBoard.shared.newAchievement(type: .vehicleLanding(vehicle: vehicle), money: 100, message: nil)
                    
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
     */
}


