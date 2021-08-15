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

/// The selected tab for MyCityView
enum MarsCityTab {
    case Hab
    case Lab
    case RSS
    case EVs // Electric Vehicles
}

enum CityLabState {
    case NoSelection
    case recipe(name:Recipe)
    case tech(name:CityTech)
    case activity(object:LabActivity)
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
    
    /// Selection item for Lab View
    @Published var labSelection:CityLabState = .NoSelection
    @Published var labActivity:LabActivity?
    
    // Vehicles
    @Published var arrivedVehicles:[SpaceVehicle]
    @Published var travelVehicles:[SpaceVehicle]
    
    init() {
        
        guard let player = LocalDatabase.shared.player else { fatalError() }
        self.player = player
        self.builder = MarsBuilder.shared
        viewState = .loading
        
        if let cd = LocalDatabase.shared.loadCity() {
            self.cityData = cd
            
            if let labActivity = cd.labActivity {
                self.labActivity = labActivity
                self.labSelection = .activity(object: labActivity)
            }
        }
        
        // Vehicles initial state
        let vehicles = LocalDatabase.shared.vehicles
        print("Initting with vehicles.: \(vehicles.count)")
        
        self.travelVehicles = vehicles
        self.arrivedVehicles = LocalDatabase.shared.city?.garage.vehicles ?? []
        
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
                        self.updateVehiclesLists()
                        
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
        LocalDatabase.shared.saveVehicles()
        
        // Save the City with the arrived vehicles
        
        if let city = cityData, !transferring.isEmpty {
            for vehicle in transferring {
                
                // Don't reccord the same vehicle twice
                if city.garage.vehicles.contains(vehicle) {
                    continue
                } else {
                    city.garage.vehicles.append(vehicle)
                    
                    // Achievement
                    GameMessageBoard.shared.newAchievement(type: .vehicleLanding(vehicle: vehicle), message: nil)
                    
                    // FIXME: - Create Notification
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
        for biobox in vehicle.bioBoxes ?? [] {
            city.bioBoxes?.append(biobox)
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
    
    // MARK: - Lab
    
    func labSelect(recipe:Recipe) {
        self.labSelection = .recipe(name: recipe)
    }
    
    func labSelect(tech:CityTech) {
        self.labSelection = .tech(name: tech)
    }
}
