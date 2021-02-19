//  LocalDatabase.swift
//  SkyNation
//  Created by Farini on 9/10/20.
//  Copyright © 2020 Farini. All rights reserved.

// MAP OF ISS
// --------------------
//        *
//   /|   |/
// -*-*-*-*-<
// /|    /
//  *
//
// ====================

import Foundation

class LocalDatabase {
    
    static let shared = LocalDatabase()
    
    var player:SKNPlayer?
    var station:Station?
    var vehicles:[SpaceVehicle] = [] // Vehicles that are travelling
    var stationBuilder:StationBuilder
    
    // MARK: - Game Generators
    static let generatorsFile = "Gamegen.txt"
    private static func loadGameGenerators() -> GameGenerators? {
        let finalUrl = LocalDatabase.folder.appendingPathComponent(generatorsFile)
        if !FileManager.default.fileExists(atPath: finalUrl.path){
            print("File doesn't exist")
            // return nil
            let new = GameGenerators()
            LocalDatabase.saveGenerators(gameGen: new)
            return new
        } else {
            do {
                let d1 = try Data(contentsOf: finalUrl)
                let d2 = Data(base64Encoded: d1)!
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                if let generators = try? decoder.decode(GameGenerators.self, from: d2) {
                    return generators
                }
            }catch{
                print("Error - Cant handle data")
            }
        }
        return nil
    }
    private static func saveGenerators(gameGen:GameGenerators) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        encoder.outputFormatting = .prettyPrinted
        
        guard let encodedData:Data = try? encoder.encode(gameGen).base64EncodedData() else { fatalError() }
        
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useKB]
        bcf.countStyle = .file
        
        let dataSize = bcf.string(fromByteCount: Int64(encodedData.count))
        print("Saving Game Size: \(dataSize)")
        
        let fileUrl = LocalDatabase.folder.appendingPathComponent(LocalDatabase.generatorsFile)
        
        if !FileManager.default.fileExists(atPath: fileUrl.path) {
            FileManager.default.createFile(atPath: fileUrl.path, contents: encodedData, attributes: nil)
            print("File created")
            return
        }
        
        do{
            try encodedData.write(to: fileUrl, options: .atomic)
            print("Saved locally")
        }catch{
            print("Error writting data to local url: \(error)")
        }
        
    }
    var gameGenerators:GameGenerators?
    
    // MARK: - Builder
    static let stationBuilderFile = "StationBuilder.json"
    /// Initializes `StationBuilder` with the `Station` object, or none if this is a new game.
    private static func initializeStationBuilder() -> StationBuilder {
        if let station = LocalDatabase.loadStation() {
            let builder = StationBuilder(station: station)
            return builder
        } else {
            let builder = StationBuilder()
            return builder
        }
    }
    /// Public function to reload the Builder. Pass a Station, or reload from start. Useful to reload scene
    func reloadBuilder(newStation:Station?) -> StationBuilder {
        if let new = newStation {
            let builder = StationBuilder(station: new)
            return builder
        } else {
            let starter = StationBuilder()
            return starter
        }
    }
    func saveStationBuilder(builder:StationBuilder) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        encoder.outputFormatting = .prettyPrinted
        guard let encodedData:Data = try? encoder.encode(builder) else { fatalError() }
        
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useKB]
        bcf.countStyle = .file
        
        let dataSize = bcf.string(fromByteCount: Int64(encodedData.count))
        print("Saving Station Builder. Size: \(dataSize)")
        
        let fileUrl = LocalDatabase.folder.appendingPathComponent(LocalDatabase.stationBuilderFile)
        
        if !FileManager.default.fileExists(atPath: fileUrl.path) {
            FileManager.default.createFile(atPath: fileUrl.path, contents: encodedData, attributes: nil)
            print("File created")
            return
        }
        
        do{
            try encodedData.write(to: fileUrl, options: .atomic)
            print("Saved locally")
        }catch{
            print("Error writting data to local url: \(error)")
        }
        
    }
    
    // MARK: - Game Messages
    static let gameMessagesFile = "GameMessages.json"
    var gameMessages:[GameMessage] = []
    private static func loadMessages() -> [GameMessage] {
        
        print("Loading Messages")
        let finalUrl = LocalDatabase.folder.appendingPathComponent(gameMessagesFile)
        
        if !FileManager.default.fileExists(atPath: finalUrl.path){
            print("File doesn't exist")
//            return nil
            return []
        }
        
        do{
            let theData = try Data(contentsOf: finalUrl)
            
            do{
                let localData:[GameMessage] = try JSONDecoder().decode([GameMessage].self, from: theData)
                return localData
                
            }catch{
                // Decode JSON Error
                print("Error Decoding JSON: \(error)")
                return []
            }
        }catch{
            // First Do - let data error
            print("Error getting Data from URL: \(error)")
            return []
        }
    }
    func saveMessages() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        encoder.outputFormatting = .prettyPrinted
        guard let encodedData:Data = try? encoder.encode(gameMessages) else { fatalError() }
        
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useKB]
        bcf.countStyle = .file
        
        let dataSize = bcf.string(fromByteCount: Int64(encodedData.count))
        print("Saving Station Builder. Size: \(dataSize)")
        
        let fileUrl = LocalDatabase.folder.appendingPathComponent(LocalDatabase.gameMessagesFile)
        
        if !FileManager.default.fileExists(atPath: fileUrl.path) {
            FileManager.default.createFile(atPath: fileUrl.path, contents: encodedData, attributes: nil)
            print("File created")
            return
        }
        
        do{
            try encodedData.write(to: fileUrl, options: .atomic)
            print("Saved locally")
        }catch{
            print("Error writting data to local url: \(error)")
        }
    }
    
    // MARK: - Station
    static let stationFile = "Station.json"
    func saveStation(station:Station) {
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        guard let encodedData:Data = try? encoder.encode(station) else { fatalError() }
        
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useKB]
        bcf.countStyle = .file
        
        let dataSize = bcf.string(fromByteCount: Int64(encodedData.count))
        print("Saving Game Size: \(dataSize)")
        
        let fileUrl = LocalDatabase.folder.appendingPathComponent(LocalDatabase.stationFile)
        
        if !FileManager.default.fileExists(atPath: fileUrl.path) {
            FileManager.default.createFile(atPath: fileUrl.path, contents: encodedData, attributes: nil)
            print("File created")
            return
        }
        
        do{
            try encodedData.write(to: fileUrl, options: .atomic)
            print("Saved locally")
        }catch{
            print("Error writting data to local url: \(error)")
        }
    }
    private static func loadStation() -> Station? {
//        print("Loading Station")
        let finalUrl = LocalDatabase.folder.appendingPathComponent(stationFile)
        
        if !FileManager.default.fileExists(atPath: finalUrl.path){
            print("File doesn't exist")
            return nil
        }
        
        do{
            let theData = try Data(contentsOf: finalUrl)
            
            do{
                let localData:Station = try JSONDecoder().decode(Station.self, from: theData)
                return localData
                
            }catch{
                // Decode JSON Error
                print("Error Decoding JSON: \(error)")
                return nil
            }
        }catch{
            // First Do - let data error
            print("Error getting Data from URL: \(error)")
            return nil
        }
    }
    
    // MARK: - Space Vehicles - Travelling
    static let vehiclesFile = "Travelling.json"
    func saveVehicles() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        guard let encodedData:Data = try? encoder.encode(vehicles) else { fatalError() }
        print("Saving Travelling Vehicles")
        
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useKB]
        bcf.countStyle = .file
        
        let dataSize = bcf.string(fromByteCount: Int64(encodedData.count))
        print("Saving Vehicles Size: \(dataSize)")
        
        let fileUrl = LocalDatabase.folder.appendingPathComponent(LocalDatabase.vehiclesFile)
        
        if !FileManager.default.fileExists(atPath: fileUrl.path) {
            FileManager.default.createFile(atPath: fileUrl.path, contents: encodedData, attributes: nil)
            print("File created")
            return
        }
        
        do{
            try encodedData.write(to: fileUrl, options: .atomic)
            print("Saved locally")
        }catch{
            print("Error writting data to local url: \(error)")
        }
    }
    private static func loadVehicles() -> [SpaceVehicle] {
        
        print("Loading Travelling Vehicles")
        let finalUrl = LocalDatabase.folder.appendingPathComponent(vehiclesFile)
        
        if !FileManager.default.fileExists(atPath: finalUrl.path){
            print("File doesn't exist")
            return []
        }
        
        do{
            let theData = try Data(contentsOf: finalUrl)
            
            do{
                let localData:[SpaceVehicle] = try JSONDecoder().decode([SpaceVehicle].self, from: theData)
                return localData
                
            }catch{
                // Decode JSON Error
                print("Error Decoding JSON: \(error)")
                return []
            }
        }catch{
            // First Do - let data error
            print("Error getting Data from URL: \(error)")
            return []
        }
        
//        return []
    }
    
    // MARK: - Player
    private static let playerFile = "Player.json"
    func savePlayer(player:SKNPlayer) -> Bool {
        print("Save player not yet implemented")
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        guard let encodedData:Data = try? encoder.encode(player) else { fatalError() }
        print("Saving Travelling Vehicles")
        
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useKB]
        bcf.countStyle = .file
        
        let dataSize = bcf.string(fromByteCount: Int64(encodedData.count))
        print("Saving Vehicles Size: \(dataSize)")
        
        let fileUrl = LocalDatabase.folder.appendingPathComponent(LocalDatabase.playerFile)
        
        if !FileManager.default.fileExists(atPath: fileUrl.path) {
            FileManager.default.createFile(atPath: fileUrl.path, contents: encodedData, attributes: nil)
            print("File created")
            return true
        } else {
            do {
                try encodedData.write(to: fileUrl, options: .atomic)
                print("Saved Player locally")
                return true
            }catch{
                print("Error writting data to local url: \(error)")
                return false
            }
        }
    }
    private static func loadPlayer() -> SKNPlayer? {
        
        print("Loading Player")
        let finalUrl = LocalDatabase.folder.appendingPathComponent(playerFile)
        
        if !FileManager.default.fileExists(atPath: finalUrl.path){
            print("File doesn't exist")
            return nil
        }
        
        do {
            let theData = try Data(contentsOf: finalUrl)
            
            do {
                let localPlayer:SKNPlayer = try JSONDecoder().decode(SKNPlayer.self, from: theData)
                return localPlayer
                
            }catch{
                // Decode JSON Error
                print("Error Decoding JSON: \(error)")
                return nil
            }
        }catch{
            // First Do - let data error
            print("Error getting Data from URL: \(error)")
            return nil
        }
    }
    
    // Accounting Problems
    var accountingProblems:[String] = []    // Set by Station.runAccounting
    
    // MARK: - Data Handling
    
    static var folder:URL {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else{
            fatalError("Default folder for ap not found")
        }
        return url
    }
    
    init() {
        
        // Player
        if let player = LocalDatabase.loadPlayer() {
            self.player = player
        }
        
        // Space Station
        if let ss = LocalDatabase.loadStation() {
//            print("Loading Station")
            // Set the Station
            self.station = ss
            // Load builder for station
            let sBuilder = LocalDatabase.initializeStationBuilder()
            self.stationBuilder = sBuilder
        }else{
            print("=== Starting New Game ===")
            let sBuilder = LocalDatabase.initializeStationBuilder()
            self.stationBuilder = sBuilder
            self.station = Station(stationBuilder: sBuilder)
//            self.station = Station(builder: builder)
        }
        
        self.gameMessages = LocalDatabase.loadMessages()
        
        // Vehicles
        let vehiclesArray = LocalDatabase.loadVehicles()
        self.vehicles = vehiclesArray
        
        // Generators
        if let gg:GameGenerators = LocalDatabase.loadGameGenerators() {
            self.gameGenerators = gg
        }
        
    }
    
}

/// To load automatically the People offered and more Freebies - Well Encoded
class GameGenerators:Codable {
    
    // People
    var datePeople:Date
    var people:[Person]
    var spentOnPeople:Int = 0 // Spent tokens on people (how many)
    
    // Freebies
    var dateFreebies:Date
    var boxes:[StorageBox]
    var tokens:[UUID]
    var tanks:[Tank]
    var money:Int
    var spentOnFreebies:Int = 0 // Spent tokens on people (how many)
    
    init() {
        // Generate
        
        // People
        var ppl:[Person] = []
        for _ in 0...15 {
            let newPerson = Person(random: true)
            ppl.append(newPerson)
        }
        self.people = ppl
        self.datePeople = Date()
        
        // Freebies
        dateFreebies = Date()
        var ingredients:[StorageBox] = []
        var newTokens:[UUID] = []
        var newTanks:[Tank] = []
        var newMoney:Int = 0
        
        if Bool.random() { newMoney += 100 }
        
        if Bool.random() {
            // 50 %
            if Bool.random() && Bool.random() {
                // 12 %
                if Bool.random() { newMoney += 500 }
                if Bool.random() && Bool.random() {
                    // 3 % TOKENS
                    let newToken = UUID()
                    newTokens.append(newToken)
                    if Bool.random() { newTokens.append(UUID()) }
                } else {
                    let newIngredient = Ingredient.allCases.randomElement()!
                    var shouldBeEmpty:Bool = false
                    if newIngredient == .wasteLiquid || newIngredient == .wasteSolid {
                        shouldBeEmpty = true
                    }
                    let newBox = StorageBox(ingType: newIngredient, current: shouldBeEmpty ? 0:newIngredient.boxCapacity())
                    ingredients.append(newBox)
                    if Bool.random() {
                        let otherBox = StorageBox(ingType: newIngredient, current: shouldBeEmpty ? 0:newIngredient.boxCapacity())
                        ingredients.append(otherBox)
                    }
                }
                
            } else {
                // Tanks
                let ttype = TankType.allCases.randomElement()!
                let tankEmpty:Bool = [TankType.co2].contains(ttype)
                let newTank = Tank(type: ttype, full: !tankEmpty)
                newTanks.append(newTank)
                
                if Bool.random() {
                    let t2 = Tank(type: ttype, full: !tankEmpty)
                    newTanks.append(t2)
                } else {
                    if Bool.random() { newMoney += 100 }
                }
            }
        } else {
            // 50 %
            newMoney += 1000
        }
        
        self.money = newMoney
        self.boxes = ingredients
        self.tokens = newTokens
        self.tanks = newTanks
        
    }
    
    /// Updates to generate data
    func update() {
        if canGenerateFreebies() {
            // Generate Freebies
            generateFreebies()
        }
        if canGenerateNewPeople() {
            // Generate PPL
            generatePeople()
        }
    }
    
    /// Force updates with Tokens
    func spentTokenToUpdate(amt:Int) {
        generatePeople()
        generateFreebies()
        
        spentOnPeople += amt
        spentOnFreebies += amt
    }
    
    func canGenerateNewPeople() -> Bool {
        return datePeople.addingTimeInterval(60 * 60 * 1).compare(Date()) == .orderedDescending // 1hr
    }
    
    func canGenerateFreebies() -> Bool {
        return dateFreebies.addingTimeInterval(60 * 60 * 24).compare(Date()) == .orderedDescending // 24hr
    }
    
    private func generatePeople() {
        
        // People
        var ppl:[Person] = []
        for _ in 0...15 {
            let newPerson = Person(random: true)
            ppl.append(newPerson)
        }
        self.people = ppl
        self.datePeople = Date()
    }
    
    private func generateFreebies() {
        // Freebies
        dateFreebies = Date()
        var ingredients:[StorageBox] = []
        var newTokens:[UUID] = []
        var newTanks:[Tank] = []
        var newMoney:Int = 0
        
        if Bool.random() { newMoney += 100 }
        
        if Bool.random() {
            // 50 %
            if Bool.random() && Bool.random() {
                // 12 %
                if Bool.random() { newMoney += 500 }
                if Bool.random() && Bool.random() {
                    // 3 % TOKENS
                    let newToken = UUID()
                    newTokens.append(newToken)
                    if Bool.random() { newTokens.append(UUID()) }
                } else {
                    let newIngredient = Ingredient.allCases.randomElement()!
                    var shouldBeEmpty:Bool = false
                    if newIngredient == .wasteLiquid || newIngredient == .wasteSolid {
                        shouldBeEmpty = true
                    }
                    let newBox = StorageBox(ingType: newIngredient, current: shouldBeEmpty ? 0:newIngredient.boxCapacity())
                    ingredients.append(newBox)
                    if Bool.random() {
                        let otherBox = StorageBox(ingType: newIngredient, current: shouldBeEmpty ? 0:newIngredient.boxCapacity())
                        ingredients.append(otherBox)
                    }
                }
                
            } else {
                // Tanks
                let ttype = TankType.allCases.randomElement()!
                let tankEmpty:Bool = [TankType.co2].contains(ttype)
                let newTank = Tank(type: ttype, full: !tankEmpty)
                newTanks.append(newTank)
                
                if Bool.random() {
                    let t2 = Tank(type: ttype, full: !tankEmpty)
                    newTanks.append(t2)
                } else {
                    if Bool.random() { newMoney += 100 }
                }
            }
        } else {
            // 50 %
            newMoney += 1000
        }
        
        self.money = newMoney
        self.boxes = ingredients
        self.tokens = newTokens
        self.tanks = newTanks
    }
    
}
