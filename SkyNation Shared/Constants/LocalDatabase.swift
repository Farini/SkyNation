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
    var vehicles:[SpaceVehicle] = []    // Vehicles that are travelling
    var stationBuilder:StationBuilder
    
    
    // MARK: - Game Settings
    static let settingsFile = "GameSettings.json"
    var gameSettings:GameSettings
    static func loadSettings() -> GameSettings {
        // create if doesn't exist
        let finalUrl = LocalDatabase.folder.appendingPathComponent(settingsFile)
        
        if !FileManager.default.fileExists(atPath: finalUrl.path){
            print("File doesn't exist")
            let newSettings = GameSettings.create()
            
            return newSettings
        }
        
        
        if let theData:Data = try? Data(contentsOf: finalUrl),
           let lSettings:GameSettings = try? JSONDecoder().decode(GameSettings.self, from: theData) {
            
            return lSettings
            
        } else {
            // no data found
            return GameSettings.create()
        }
    }
    func saveSettings(newSettings:GameSettings) {
        let fileUrl = LocalDatabase.folder.appendingPathComponent(LocalDatabase.settingsFile)
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        guard let encodedData:Data = try? encoder.encode(newSettings) else { fatalError() }
        
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useKB]
        bcf.countStyle = .file
        
        let dataSize = bcf.string(fromByteCount: Int64(encodedData.count))
        print("Saving Game Size: \(dataSize)")
        
        if !FileManager.default.fileExists(atPath: fileUrl.path) {
            FileManager.default.createFile(atPath: fileUrl.path, contents: encodedData, attributes: nil)
            print("File created")
            return
        }
        
        do{
            try encodedData.write(to: fileUrl, options: .atomic)
            print("Saved Settings locally")
        }catch{
            print("Error writting data to local url: \(error)")
        }
    }
    
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
    var gameMessages:[GameMessage] = []
    static let gameMessagesFile = "GameMessages.json"
    private static func loadMessages() -> [GameMessage] {
        
        print("Loading Messages")
        let finalUrl = LocalDatabase.folder.appendingPathComponent(gameMessagesFile)
        
        if !FileManager.default.fileExists(atPath: finalUrl.path){
            print("File doesn't exist")
            return []
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        
        do{
            let theData = try Data(contentsOf: finalUrl)
            
            do {
                let localData:[GameMessage] = try decoder.decode([GameMessage].self, from: theData)
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
        let encoder = dataEncoder() //JSONEncoder()
//        encoder.dateEncodingStrategy = .secondsSince1970
//        encoder.outputFormatting = .prettyPrinted
        guard let encodedData:Data = try? encoder.encode(gameMessages) else { fatalError() }
        
//        let bcf = ByteCountFormatter()
//        bcf.allowedUnits = [.useKB]
//        bcf.countStyle = .file
//
//        let dataSize = bcf.string(fromByteCount: Int64(encodedData.count))
//        print("Saving Station Builder. Size: \(dataSize)")
        let file = LocalDatabase.gameMessagesFile
        
        reportDataSize(encodedData, file: file)
        
        let fileUrl = LocalDatabase.folder.appendingPathComponent(file)
        
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
        
        self.player = player
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        encoder.outputFormatting = .prettyPrinted
        
        guard let encodedData:Data = try? encoder.encode(player) else { fatalError() }
        print("Saving Player")
        
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useKB]
        bcf.countStyle = .file
        
        let dataSize = bcf.string(fromByteCount: Int64(encodedData.count))
        print("Saving Player Size: \(dataSize)")
        
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
    
    // MARK: - Mars City
    private static let cityFile = "MarsCity.json"
    var city:CityData?
    func saveCity(_ newCity:CityData) throws {
        self.city = newCity
        
        let encoder = dataEncoder()
        
        guard let encodedData:Data = try? encoder.encode(newCity) else { fatalError() }
        print("Saving City")
        
//        let bcf = ByteCountFormatter()
//        bcf.allowedUnits = [.useKB]
//        bcf.countStyle = .file
//
//        let dataSize = bcf.string(fromByteCount: Int64(encodedData.count))
//        print("Saving City Size: \(dataSize)")
        
        reportDataSize(encodedData, file: LocalDatabase.cityFile)
        
        let fileUrl = LocalDatabase.folder.appendingPathComponent(LocalDatabase.cityFile)
        
        if !FileManager.default.fileExists(atPath: fileUrl.path) {
            FileManager.default.createFile(atPath: fileUrl.path, contents: encodedData, attributes: nil)
            print("File created")
            // return true
        } else {
            do {
                try encodedData.write(to: fileUrl, options: .atomic)
                print("Saved City locally")
                // return true
            }catch{
                print("Error writting data to local url: \(error)")
                // return false
                throw error
            }
        }
    }
    func loadCity() -> CityData? {
        
        print("Loading City")
        let finalUrl = LocalDatabase.folder.appendingPathComponent(LocalDatabase.cityFile)
        
        if !FileManager.default.fileExists(atPath: finalUrl.path){
            print("File doesn't exist")
            return nil
        }
        
        do {
            let theData = try Data(contentsOf: finalUrl)
            
            do {
                let marsCity:CityData = try JSONDecoder().decode(CityData.self, from: theData)
                return marsCity
                
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
    
    // ---------------------------
    // MARK: - In Memory (Fetched)
    // ===========================
    
    // Server file
    var serverData:ServerData?
    private static let serverDataFile = "SKNSData.json"
    func saveServerData(skn:ServerData) -> Bool {
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        encoder.outputFormatting = .prettyPrinted
        
        guard let encodedData:Data = try? encoder.encode(skn) else { fatalError() }
        print("Saving Server Data Vehicles")
        
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useKB]
        bcf.countStyle = .file
        
        let dataSize = bcf.string(fromByteCount: Int64(encodedData.count))
        print("Saving Server Data Size: \(dataSize)")
        
        let fileUrl = LocalDatabase.folder.appendingPathComponent(LocalDatabase.serverDataFile)
        
        if !FileManager.default.fileExists(atPath: fileUrl.path) {
            FileManager.default.createFile(atPath: fileUrl.path, contents: encodedData, attributes: nil)
            print("File created")
            return true
        } else {
            do {
                try encodedData.write(to: fileUrl, options: .atomic)
                print("Saved Server Data locally")
                return true
            }catch{
                print("Error writting data to local url: \(error)")
                return false
            }
        }
    }
    func loadServerData() -> ServerData? {
        
        print("Loading Server data")
        let finalUrl = LocalDatabase.folder.appendingPathComponent(LocalDatabase.serverDataFile)
        
        if !FileManager.default.fileExists(atPath: finalUrl.path){
            print("File doesn't exist")
            return nil
        }
        
        do {
            let theData = try Data(contentsOf: finalUrl)
            
            do {
                let localServer:ServerData = try JSONDecoder().decode(ServerData.self, from: theData)
                return localServer
                
            }catch{
                // Decode JSON Error
                print("Error Decoding JSON: \(error)")
                return nil
            }
        }catch{
            // First Do - let data error
            print("Error getting Server Data from URL. \(error)")
            return nil
        }
    }
    
    // Accounting Problems
    var accountingProblems:[String] = []
    
    // MARK: - Data Handling
    
    static var folder:URL {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else{
            fatalError("Default folder for ap not found")
        }
        return url
    }
    
    private init() {
        
        // Player
        if let player = LocalDatabase.loadPlayer() {
            self.player = player
        }
        
        // Space Station
        if let ss = LocalDatabase.loadStation() {
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
        }
        
        // Messages
        self.gameMessages = LocalDatabase.loadMessages()
        
        // Vehicles
        let vehiclesArray = LocalDatabase.loadVehicles()
        self.vehicles = vehiclesArray
        
        // Settings
        print("Loading Settings")
        let settings = LocalDatabase.loadSettings()
        self.gameSettings = settings
        print("Finished Settings")
        
        // Server Database
        if let servData = loadServerData() {
            print("Server data loaded from disk")
            let newData = ServerData(localData: servData)
            self.serverData = newData
        } else {
            if let p1 = player {
                let newData = ServerData(with: p1)
                self.serverData = newData
                if self.saveServerData(skn: newData) == true {
                    print("New server data saved")
                }
            }
            print("Server data not written locally")
        }
    }
}

extension LocalDatabase {
    
    /// Gets the `JsonEncoder` for the game
    private func dataEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        encoder.outputFormatting = .prettyPrinted
        return encoder
    }
    
    /// Gets the `JsonDecoder` for the game
    private func gameDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return decoder
    }
    
    /// Prints the file size
    private func reportDataSize(_ data:Data, file name:String) {
        
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useKB]
        bcf.countStyle = .file
        
        let dataSize = bcf.string(fromByteCount: Int64(data.count))
        // print("💾 \(name) Size: \(dataSize)")
        var dataDesc:String = "💾 \(name), Size: \(dataSize)"
        
        let filePath = LocalDatabase.folder.appendingPathComponent(name)
        if let attributes:[FileAttributeKey:Any] = try? FileManager.default.attributesOfItem(atPath: filePath.path) {
            if let modificationDate = attributes[FileAttributeKey.modificationDate] as? Date {
                let df = DateFormatter()
                df.dateStyle = .short
                df.timeStyle = .short
                dataDesc += ", Mod: \(df.string(from: modificationDate))"
            }
        }
        print(dataDesc)
        
    }
}
