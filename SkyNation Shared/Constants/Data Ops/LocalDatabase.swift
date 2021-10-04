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

enum LocalDatabaseError:Error {
    
    /// File Doesn't exist
    case noFile
    
    /// Error Encoding/Decoding
    case coding(type: Codable.Type, reason:String)
    
    /// A `String` to display to the user.
    var message:String {
        switch self {
            case .noFile: return "💾 File doesn't exist in LocalDatabase."
            case .coding(let type, let string): return "Could not encode/decode file type \(type). Reason: \(string)"
        }
    }
}

class LocalDatabase {
    
    static let shared = LocalDatabase()
    
    // MARK: - Game Settings
    
    var gameSettings:GameSettings
    func saveSettings(settings:GameSettings) throws {
        do {
            let data = try LocalDatabase.encodeData(object: settings)
            do {
                try data.write(to: LocalDatabase.folder.appendingPathComponent(GameFile.settings.fileName), options: .atomic)
                self.gameSettings = settings
            } catch {
                throw error
            }
        } catch {
            throw error
        }
    }
    private static func loadSettings() throws -> GameSettings {
        print("Loading Settings")
        do {
            let data:Data = try LocalDatabase.loadData(file: .settings)
            LocalDatabase.reportDataSize(data, file: GameFile.settings.fileName)
            do {
                let settings = try LocalDatabase.decodeData(GameSettings.self, from: data)
                return settings
            } catch {
                print("Error decoding Settings. \(error.localizedDescription)")
                throw error
            }
        } catch {
            print("Error loading data for Game Settings. \(error.localizedDescription)")
            // probably was empty
            return GameSettings.create()
        }
    }
    
    // MARK: - Player
    var player:SKNPlayer
    func savePlayer(_ player:SKNPlayer) throws {
        do {
            let data = try LocalDatabase.encodeData(object: player)
            do {
                try data.write(to: LocalDatabase.folder.appendingPathComponent(GameFile.player.fileName), options: .atomic)
                self.player = player
            } catch {
                if let error = error as? EncodingError {
                    print("Encoding Default error.: \(error.localizedDescription)")
                    throw LocalDatabaseError.coding(type: SKNPlayer.self, reason: error.localizedDescription)
                } else {
                    print("Unrecognizable error during encoding serverData. Reason.: \(error.localizedDescription)")
                    throw error
                }
            }
        } catch {
            if let error = error as? EncodingError {
                print("Encoding Default error.: \(error.localizedDescription)")
                throw LocalDatabaseError.coding(type: SKNPlayer.self, reason: error.localizedDescription)
            } else {
                print("Unrecognizable error during encoding serverData. Reason.: \(error.localizedDescription)")
                throw error
            }
        }
    }
    static func loadPlayer() throws -> SKNPlayer {
        
        print("Loading Player")
        do {
            let data:Data = try LocalDatabase.loadData(file: .player)
            reportDataSize(data, file: GameFile.player.fileName)
            do {
                let player = try LocalDatabase.decodeData(SKNPlayer.self, from: data)
                return player
            } catch {
                throw error
            }
        } catch {
            print("Error loading Player. \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Builder
    var stationBuilder:StationBuilder
    
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
    
    // MARK: - Station
    var station:Station
    func saveStation(_ station:Station) throws {
        do {
            let data = try LocalDatabase.encodeData(object: station)
            do {
                try data.write(to: LocalDatabase.folder.appendingPathComponent(GameFile.station.fileName), options: .atomic)
                self.station = station
            } catch {
                if let error = error as? EncodingError {
                    print("Encoding Default error.: \(error.localizedDescription)")
                    throw LocalDatabaseError.coding(type: Station.self, reason: error.localizedDescription)
                } else {
                    print("Unrecognizable error during encoding Space Station. Reason.: \(error.localizedDescription)")
                    throw error
                }
            }
        } catch {
            if let error = error as? EncodingError {
                print("Encoding Default error.: \(error.localizedDescription)")
                throw LocalDatabaseError.coding(type: Station.self, reason: error.localizedDescription)
            } else {
                print("Unrecognizable error during encoding Space Station. Reason.: \(error.localizedDescription)")
                throw error
            }
        }
    }
    private static func loadStation() throws -> Station {
        print("Loading Station")
        do {
            let data:Data = try LocalDatabase.loadData(file: .station)
            LocalDatabase.reportDataSize(data, file: GameFile.station.fileName)
            do {
                let station = try LocalDatabase.decodeData(Station.self, from: data)
                return station
            } catch {
                print("Error decoding Station. \(error.localizedDescription)")
                throw error
            }
        } catch {
            print("Error loading data for Space Station. \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Game Messages
    var gameMessages:[GameMessage] // = []
    func saveMessages(messages:[GameMessage]) throws {
        do {
            let data = try LocalDatabase.encodeData(object: messages)
            do {
                try data.write(to: LocalDatabase.folder.appendingPathComponent(GameFile.messages.fileName), options: .atomic)
                self.gameMessages = messages
            } catch {
                throw error
            }
        } catch {
            throw error
        }
    }
    private static func loadGameMessages() -> [GameMessage] {
        do {
            let data:Data = try LocalDatabase.loadData(file: .messages)
            LocalDatabase.reportDataSize(data, file: GameFile.messages.fileName)
            do {
                let messages = try LocalDatabase.decodeData([GameMessage].self, from: data)
                return messages
            } catch {
                return []
            }
        } catch {
            print("Error loading data for Game Messages. \(error.localizedDescription)")
            return []
        }
    }
    
    // MARK: - Space Vehicles - Travelling
    var vehicles:[SpaceVehicle]
    func saveVehicles(_ array:[SpaceVehicle]) throws {
        
        do {
            let data = try LocalDatabase.encodeData(object: array)
            do {
                try data.write(to: LocalDatabase.folder.appendingPathComponent(GameFile.travels.fileName), options: .atomic)
                self.vehicles = array
            } catch {
                if let error = error as? EncodingError {
                    print("Encoding Default error.: \(error.localizedDescription)")
                    throw LocalDatabaseError.coding(type: CityData.self, reason: error.localizedDescription)
                } else {
                    print("Unrecognizable error during encoding serverData. Reason.: \(error.localizedDescription)")
                    throw error
                }
            }
        } catch {
            if let error = error as? EncodingError {
                print("Encoding Default error.: \(error.localizedDescription)")
                throw LocalDatabaseError.coding(type: SpaceVehicle.self, reason: error.localizedDescription)
            } else {
                print("Unrecognizable error during encoding serverData. Reason.: \(error.localizedDescription)")
                throw error
            }
        }
    }
    private static func loadVehicles() -> [SpaceVehicle] {
        
        print("Loading Vehicles")
        do {
            let data:Data = try LocalDatabase.loadData(file: .travels)
            reportDataSize(data, file: GameFile.travels.fileName)
            do {
                let vehicles = try LocalDatabase.decodeData([SpaceVehicle].self, from: data)
                return vehicles
            } catch {
                print("Error decoding Travelling Vehicles. \(error.localizedDescription)")
                return []
            }
        } catch {
            print("Error loading Travelling Vehicles. \(error.localizedDescription)")
            return []
        }
    }
    
    // MARK: - Mars City
    var cityData:CityData?
    func saveCity(_ city:CityData) throws {
        do {
            let data = try LocalDatabase.encodeData(object: city)
            do {
                try data.write(to: LocalDatabase.folder.appendingPathComponent(GameFile.cityData.fileName), options: .atomic)
                self.cityData = city
            } catch {
                print("Error writing data from 'CityData'")
                throw error
            }
        } catch {
            if let error = error as? EncodingError {
                print("Encoding Default error.: \(error.localizedDescription)")
                throw LocalDatabaseError.coding(type: CityData.self, reason: error.localizedDescription)
            } else {
                print("Unrecognizable error during encoding serverData. Reason.: \(error.localizedDescription)")
                throw error
            }
        }
    }
    static func loadCity() throws -> CityData {
        
        print("Loading City")
        do {
            let data:Data = try LocalDatabase.loadData(file: .cityData)
            reportDataSize(data, file: GameFile.cityData.fileName)
            do {
                let city = try LocalDatabase.decodeData(CityData.self, from: data)
                return city
            } catch {
                throw error
            }
        } catch {
            print("Error loading CityData. \(error.localizedDescription)")
            throw error
        }
    }
    
    // ---------------------------
    // MARK: - In Memory ServerData
    var serverData:ServerData?
    func saveServerData(_ serverData:ServerData) throws {
        do {
            let data = try LocalDatabase.encodeData(object: serverData)
            do {
                try data.write(to: LocalDatabase.folder.appendingPathComponent(GameFile.server.fileName), options: .atomic)
                self.serverData = serverData
            } catch {
                print("Error writing data from 'ServerData'")
                throw error
            }
        } catch {
            if let error = error as? EncodingError {
                print("Encoding Default error.: \(error.localizedDescription)")
                throw LocalDatabaseError.coding(type: ServerData.self, reason: error.localizedDescription)
            } else {
                print("Unrecognizable error during encoding serverData. Reason.: \(error.localizedDescription)")
                throw error
            }
        }
    }
    static func loadServerData() throws -> ServerData {
        do {
            let data:Data = try LocalDatabase.loadData(file: .server)
            do {
                let serverData = try LocalDatabase.decodeData(ServerData.self, from: data) //decodeData(object: gameFile.fileType, data: data)
                return serverData
            } catch {
                if let error = error as? LocalDatabaseError {
                    print("Error decoding Server Data. \(error.localizedDescription)")
                    throw error
                } else {
                    print("Another error with Server Data. \(error.localizedDescription)")
                    throw error
                }
            }
        } catch {
            print("Error loading Server Data. \(error.localizedDescription)")
            throw error
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
        
        /*
         When loading an object, check the 'throws'
         if the throw is LocalDatabaseError.noFile,
         
         [ recover ] - Simply Check if we can create the file
         */
        
        // Player
        do {
            let player = try LocalDatabase.loadPlayer()
            self.player = player
        } catch {
            if let error = error as? LocalDatabaseError {
                switch error {
                    case .noFile:
                        print("Creating new player !!")
                        let newPlayer = SKNPlayer()
                        self.player = newPlayer
                    case .coding(let type, let reason):
                        fatalError("Coding Error loading Player.: \(type), reason:\(reason)")
                }
            } else {
                fatalError("Error Loading Player.: \(error.localizedDescription)")
            }
        }
        
        // Space Station + Builder
        do {
            let spaceStation = try LocalDatabase.loadStation()
            self.station = spaceStation
            let builder = StationBuilder(station: spaceStation)
            self.stationBuilder = builder
            
        } catch {
            if let error = error as? LocalDatabaseError {
                switch error {
                    case .noFile:
                        print("Creating new station !!")
                        let builder = StationBuilder()
                        self.stationBuilder = builder
                        let spaceStation = Station(stationBuilder: builder)
                        self.station = spaceStation
                    case .coding(let type, let reason):
                        fatalError("Coding Error loading SpaceStation.: \(type), reason:\(reason)")
                }
            } else {
                fatalError("Error Loading Station.: \(error.localizedDescription)")
            }
        }
        
        // Messages
        let gMessages = LocalDatabase.loadGameMessages()
        self.gameMessages = gMessages
        
        // Vehicles
        let vehiclesArray = LocalDatabase.loadVehicles()
        self.vehicles = vehiclesArray
        
        // Settings
        print("Loading Settings")
        do {
            let gSettings = try LocalDatabase.loadSettings()
            self.gameSettings = gSettings
        } catch {
            print("Loading Settings for the first time")
            let newGameSettings = GameSettings.create()
            self.gameSettings = newGameSettings
        }
        
        // City Data
        do {
            let cityData = try LocalDatabase.loadCity()
            self.cityData = cityData
        } catch {
            print("Could not load CityData")
        }
        
        // Server Database
        do {
            let server = try LocalDatabase.loadServerData()
            self.serverData = server
        } catch {
            // Serverdata doesn't need to be loaded.
            if let error = error as? LocalDatabaseError {
                switch error {
                    case .noFile:
                        print("ServerData - No File. Doesn't need to be set")
                    case .coding(let type, let reason):
                        print("Error coding server data. \(type). reason:\(reason)")
                }
            }
        }
        
        print("LocalDatabase Finished Loading \n\n")
    }
}

extension LocalDatabase {
    
    /// Returns Data encoded from the object passed.
    private class func encodeData<T:Codable>(object:T) throws -> Data {
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let data = try encoder.encode(object)
            return data
        } catch {
            if let error = error as? EncodingError {
                print("Encoding Default error.: \(error.localizedDescription)")
                throw error
            } else {
                print("Unrecognizable error during encoding: \(object).: Reason.: \(error.localizedDescription)")
                throw error
            }
        }
    }
    
    /// Returns the `Data` from file
    private static func loadData(file:GameFile) throws -> Data {
        
        let url = folder.appendingPathComponent(file.fileName)
        
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useKB]
        bcf.countStyle = .file
        
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw LocalDatabaseError.noFile
        }
        
        do {
            let data = try Data(contentsOf: url)
            
            return data
        } catch {
            if let decodingError = error as? DecodingError {
                print("‼️ Error Decoding file of type.: \(file.fileType)")
                throw LocalDatabaseError.coding(type: file.fileType, reason: "\(decodingError.localizedDescription)")
            }
            throw error
        }
    }
    
    /// Returns a Decoded Object
    private class func decodeData<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        
        do {
            let decoded = try decoder.decode(T.self, from: data)
            return decoded
        } catch {
            if let error = error as? DecodingError {
                print("‼️ Decoding (DecodingError) error.: \(error.localizedDescription)")
                throw error
            } else {
                print("‼️ Unrecognizable error during decoding: \(type.self).: Reason.: \(error.localizedDescription)")
                throw error
            }
        }
    }
    
    /// Prints the file size
    private static func reportDataSize(_ data:Data, file name:String) {
        
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
                dataDesc += ", Modified: \(df.string(from: modificationDate))"
            }
        }
        print(dataDesc)
        
    }
}
