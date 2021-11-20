//
//  ServerAPI.swift
//  SkyNation
//
//  Created by Carlos Farini on 2/2/21.
//

import Foundation

class SKNS {
    
    enum HTTPMethod:String {
        case POST
        case GET
        case UPDATE
    }
    
    /**
        Routes & Queries - Records
        // Queries should have *route, *date, *objectRetrieved, *errorType
     */
    
    /// Use this to have a reference for the queries we already performed
    enum Routes:String {
        case login
        case guildSummary
        case guildContent
        case cityData
        case vehicleRegistration
    }
    
    /// Keep a record of the queries performed, so we don't keep repeating the same queries.
    var queries:[Routes:Date] = [:] // Queries should have *route, *date, *objectRetrieved, *
    
    static let baseAddress = "https://cfarini.com/SKNS"
//    static let baseAddress = "http://127.0.0.1:8080"
    
    // MARK: - Player, Login
    
    /// Creates a new player is the Server Database.
    static func createNewPlayer(localPlayer:SKNPlayer, completion:((PlayerUpdate?, Error?) -> ())?) {
        
        let pCreate:PlayerCreate = PlayerCreate(player: localPlayer)
        
        // Build Request
        let address = "\(baseAddress)/player/create"
        
        guard let url = URL(string: address) else { return }
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.POST.rawValue
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        encoder.outputFormatting = .prettyPrinted
        
        // Body with `PlayerCreate`
        if let data = try? encoder.encode(pCreate) {
            print("\n\nAdding Data")
            request.httpBody = data
            let dataString = String(data:data, encoding: .utf8) ?? "n/a"
            print("DS: \(dataString)")
        }
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                
                if let responsePlayer:PlayerUpdate = try? decoder.decode(PlayerUpdate.self, from: data) {
                    
                    print("SKNS Created New Player. Name: \(responsePlayer.name), Pass:\(responsePlayer.pass)")
                    
                    DispatchQueue.main.async {
                        completion?(responsePlayer, nil)
                    }
                    return
                }
            }
            DispatchQueue.main.async {
                print("Error: \(error?.localizedDescription ?? "n/a")")
                completion?(nil, error)
            }
        }
        task.resume()
        
    }
    
    /// A Login with Authentication
    static func authorizeLogin(localPlayer:SKNPlayer, pid:UUID, pass:String, completion:((PlayerUpdate?, Error?) -> ())?) {
        
        // Build Request
        let address = "\(baseAddress)/player/credentials/login"
        
        guard let url = URL(string: address) else { return }
        
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.GET.rawValue
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        // Set Credentials for authorization.
        let basicCredential = "\(pid.uuidString):\(pass)".data(using: .utf8)!.base64EncodedString()
        request.setValue("Basic \(basicCredential)", forHTTPHeaderField: "Authorization")
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if let data:Data = data {
                
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                
                if let responsePlayer:PlayerUpdate = try? decoder.decode(PlayerUpdate.self, from: data) {
                    
                    print("Response player: \(responsePlayer.name)")
                    
                    // CHECKPOINTS: Check if player is the same as database
                    var checkPoints:[Bool] = []
                    checkPoints.append(localPlayer.name == responsePlayer.name)
                    checkPoints.append(localPlayer.guildID == responsePlayer.guildID)
                    checkPoints.append(localPlayer.experience == responsePlayer.experience)
                    checkPoints.append(localPlayer.avatar == responsePlayer.avatar)
                    checkPoints.append(localPlayer.money == responsePlayer.money)
                    
                    if checkPoints.contains(false) {
                        print("\n ⚠️ Needs to Update Player (in Server)")
                        SKNS.updatePlayer { newPlayerUpdate, error in
                            DispatchQueue.main.async {
                                if let newPlayerUpdate = newPlayerUpdate {
                                    
                                    // Update Password
                                    localPlayer.keyPass = newPlayerUpdate.pass
                                    
                                    do {
                                        try LocalDatabase.shared.savePlayer(localPlayer)
                                        completion?(newPlayerUpdate, nil)
                                    } catch {
                                        completion?(nil, error)
                                    }
                                    
                                } else {
                                    print("Player not updated. \(error?.localizedDescription ?? "n/a")")
                                    completion?(nil, nil)
                                }
                                return
                            }
                        }
                    } else {
                        // All Checkpoints match. Player hasn't been altered.
                        DispatchQueue.main.async {
                            completion?(responsePlayer, nil)
                        }
                        return
                    }
                    
                } else {
                    
                    // Check if error is that User lost password.
                    if let gameError = try? decoder.decode(GameError.self, from: data) {
                        // game error
                        print("\n\n *** Login Failed. Game Error: \(gameError) ***")
                        
                        if gameError.reason.contains("not authenticated.") {
                            
                            // Request New Password
                            SKNS.requestNewPass { playerNewPass, passError in
                                
                                if let playerNewPass = playerNewPass {
                                    completion?(playerNewPass, nil)
                                    return
                                } else {
                                    // No player returned
                                    // Something went terribly wrong
                                    print("‼️⚠️ Failed attempt to restore password !!!")
                                    completion?(nil, ServerDataError.failedAuthorization)
                                    return
                                }
                            }
                        }
                        
                    } else if let errString:String = String(data: data, encoding: .utf8) {
                        print("\n\n *** Login Failed. String Error: \(errString)")
                    }
                    
                    // Request returned data, but its not a `PlayerUpdate` object.
                    DispatchQueue.main.async {
                        print("Returning error.: \(error?.localizedDescription ?? "n/a")")
                        completion?(nil, error ?? ServerDataError.failedAuthorization)
                    }
                }
                
            } else {
                DispatchQueue.main.async {
                    // Request returned an error
                    print("Authorize Login Error: \(error?.localizedDescription ?? "n/a")")
                    completion?(nil, error)
                }
            }
        }
        task.resume()
    }
    
    static func logoutPlayer() {
        
        let url = URL(string: "\(baseAddress)/player/credentials/logout")!
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.GET.rawValue
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                print("Logout Error: \(error.localizedDescription)")
            } else {
                if let response = response {
                    print("Logout response: \(response)")
                } else if let data = data {
                    let dataString = String(data:data, encoding: .utf8) ?? "Empty"
                    print("Logout response (String):\n \(dataString)")
                }
            }
        }
        task.resume()
        
    }
    
    /// Update Player
    static func updatePlayer(completion:((PlayerUpdate?, Error?) -> ())?) {
        
        let localPlayer = LocalDatabase.shared.player
        var pUpdate:PlayerUpdate?
        
        do {
            pUpdate = try PlayerUpdate.create(player: localPlayer)
        } catch {
            completion?(nil, error)
            return
        }
        
        /// The object being posted
        guard let playerUpdate:PlayerUpdate = pUpdate else {
            fatalError()
        }
        
        // Build Request
        let address = "\(baseAddress)/player/update"
        
        guard let url = URL(string: address) else { return }
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.POST.rawValue
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        encoder.outputFormatting = .prettyPrinted
        
        // Body with `PlayerUpdate`
        if let data = try? encoder.encode(playerUpdate) {
            print("\n\nAdding Data")
            request.httpBody = data
            let dataString = String(data:data, encoding: .utf8) ?? "n/a"
            print("DS: \(dataString)")
        }
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                
                if let responsePlayer:PlayerUpdate = try? decoder.decode(PlayerUpdate.self, from: data) {
                    
                    print("Response user: \(responsePlayer.name)")
                    
                    // Update Player Properties
                    localPlayer.keyPass = responsePlayer.pass
                    
                    // Guild ID
                    if let oldGuild = localPlayer.guildID,
                       oldGuild != responsePlayer.guildID {
                        print("Attention! - Guild ID changing!\n Old Guild:\(oldGuild), New Guild:\(responsePlayer.guildID?.uuidString ?? "none")")
                        localPlayer.guildID = responsePlayer.guildID
                    }
                    
                    // Save
                    do {
                        try LocalDatabase.shared.savePlayer(localPlayer)
                    } catch {
                        print("‼️ Could not save player.: \(error.localizedDescription)")
                    }
                    
                    DispatchQueue.main.async {
                        completion?(responsePlayer, nil)
                    }
                    return
                }
            }
            DispatchQueue.main.async {
                print("Error: \(error?.localizedDescription ?? "n/a")")
                completion?(nil, error)
            }
        }
        task.resume()
        
    }
    
    /// Gets a new passowrd for a Player
    static func requestNewPass(completion:((PlayerUpdate?, Error?) -> ())?) {
        
        let localPlayer = LocalDatabase.shared.player
        var pUpdate:PlayerUpdate?
        
        do {
            pUpdate = try PlayerUpdate.create(player: localPlayer)
        } catch {
            completion?(nil, error)
            return
        }
        
        /// The object being posted
        guard let playerUpdate:PlayerUpdate = pUpdate else {
            fatalError()
        }
       
        // Build Request
        let address = "\(baseAddress)/player/newpass"
        
        guard let url = URL(string: address) else { return }
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.POST.rawValue
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        // Encrypt the LocalID as 64bit
        let lid = (localPlayer.localID.uuidString.data(using: .utf8) ?? Data()).base64EncodedString()
        request.setValue(lid, forHTTPHeaderField: "lid")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        encoder.outputFormatting = .prettyPrinted
        
        print("\n\n*** REQUESTING NEW PASS *** ")
        
        // Body with `PlayerUpdate`
        if let data = try? encoder.encode(playerUpdate) {
            
            request.httpBody = data
            let dataString = String(data:data, encoding: .utf8) ?? "n/a"
            print("Pass Body Data: \n\(dataString)")
            
        } else {
            // print("Awful Errror. Cannot encode data")
            print("‼️ FATAL ERROR ENCODING. Request new pass - Cannot encode data")
            print("The only way to recover from this, is to create a new player in the Database")
            
            completion?(nil, ServerDataError.failedAuthorization)
            return
        }
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if let data = data {
                
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                
                if let responsePlayer:PlayerUpdate = try? decoder.decode(PlayerUpdate.self, from: data) {
                    
                    print("New Pass Response for player: \(responsePlayer.name)")
                    
                    // Update Player Properties
                    localPlayer.keyPass = responsePlayer.pass
                    
                    // Save
                    do {
                        
                        try LocalDatabase.shared.savePlayer(localPlayer)
                        // Success
                        DispatchQueue.main.async {
                            completion?(responsePlayer, nil)
                        }
                        return
                    } catch {
                        
                        // Could not save
                        print("‼️ Could not save player. Reason:\(error.localizedDescription)")
                        DispatchQueue.main.async {
                            completion?(nil, error)
                        }
                        return
                    }
                } else {
                    
                    /// No `PlayerUpdate` object found
                    if let gameError:GameError = try? decoder.decode(GameError.self, from: data) {
                        if gameError.reason.contains("Decoding") {
                            // Server could not decode
                            completion?(nil, ServerDataError.remoteCoding)
                            return
                        } else if gameError.reason.contains("Incorrect") {
                            // localID don't match
                            completion?(nil, ServerDataError.failedAuthorization)
                            return
                        }
                    } else {
                        // failed to return object, and failed to return gameerror
                        print("Failed to return object, and failed to return GameError.")
                        // try to decode string?
                        if let string = String(data: data, encoding: .utf8) {
                            print("Found String:\n\(string)")
                            completion?(nil, ServerDataError.localCoding)
                            return
                        } else {
                            // Nothing was decoded at this point
                            print("‼️ New Pass Response.: Didn't find any data to fix this error.")
                            completion?(nil, error ?? ServerDataError.failedAuthorization)
                            return
                        }
                    }
                }
            } else {
                
                // no data returned
                DispatchQueue.main.async {
                    print("Error: \(error?.localizedDescription ?? "n/a")")
                    completion?(nil, error)
                }
                return
            }
            
        }
        task.resume()
        
    }
    
    /// Tries to Fetch a player
    static func findPlayer(pid:UUID, completion:((PlayerCard?, Error?) -> ())?) {
        
        let url = URL(string: "\(baseAddress)/player/find/\(pid)")!
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.GET.rawValue
        
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if let data = data {
                
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                
                if let fetchedPlayer:PlayerCard = try? decoder.decode(PlayerCard.self, from: data) {
                    
                    print("Fetched Player: \(fetchedPlayer.name)")
                    DispatchQueue.main.async {
                        completion?(fetchedPlayer, nil)
                    }
                    return
                    
                } else {
                    print("Could not decode Fetched Player. Data: \(String(data:data, encoding:.utf8) ?? "n/a")")
                    DispatchQueue.main.async {
                        completion?(nil, error)
                    }
                    return
                }
            } else {
                DispatchQueue.main.async {
                    print("Did not get Data from Find Player Request. Error: \(error?.localizedDescription ?? "n/a")")
                    completion?(nil, error)
                }
            }
        }
        task.resume()
        
    }
    
    /// Fetches a Guild with a PlayerLogin object
    static func requestPlayersGuild(completion:((GuildFullContent?, Error?) -> ())?) {
        
        let localPlayer = LocalDatabase.shared.player
        
        // Build Request
        let address = "\(baseAddress)/guilds/player/find/\(localPlayer.guildID ?? UUID())"
        
        guard let url = URL(string: address) else { return }
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.GET.rawValue
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if let data = data {
                
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                
                if let fetchedGuild:GuildFullContent = try? decoder.decode(GuildFullContent.self, from:data) {
                    print("Fetched Guild: \(fetchedGuild.name)")
                    DispatchQueue.main.async {
                        completion?(fetchedGuild, nil)
                    }
                    return
                } else {
                    print("Could not decode Fetched Guild. Data: \(String(data:data, encoding:.utf8) ?? "n/a")")
                    DispatchQueue.main.async {
                        completion?(nil, error)
                    }
                    return
                }
            } else {
                DispatchQueue.main.async {
                    print("Did not get Data from Find Player Request. Error: \(error?.localizedDescription ?? "n/a")")
                    completion?(nil, error)
                }
            }
        }
        task.resume()
    }
    
    /// Search Player
    static func searchPlayerByName(name:String, completion:(([PlayerContent], Error?) -> ())?) {
        
        let url = URL(string: "\(baseAddress)/player/credentials/search/name/\(name)")!
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.GET.rawValue
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if let data = data {
                
                if let foundPlayers:[PlayerContent] = try? decoder.decode([PlayerContent].self, from: data) {
                    
                    print("Found \(foundPlayers.count) players.")
                    DispatchQueue.main.async {
                        completion?(foundPlayers, nil)
                    }
                    return
                    
                } else {
                    print("Could not decode Fetched Player. Data: \(String(data:data, encoding:.utf8) ?? "n/a")")
                    DispatchQueue.main.async {
                        completion?([], error)
                    }
                    return
                }
            } else {
                DispatchQueue.main.async {
                    print("Did not get Data from Find Player Request. Error: \(error?.localizedDescription ?? "n/a")")
                    completion?([], error)
                }
            }
        }
        task.resume()
        
    }
    
    // MARK: - Tokens + Purchase
    
    // Validate
    static func validateTokenFromTextInput(text:String, completion:((GameToken?, String?) -> ())?) {
        
        guard let validID = UUID(uuidString: text) else {
            completion?(nil, "Invalid Token pass")
            return
        }
        
        let url = URL(string: "\(baseAddress)/token/validate/\(validID.uuidString)")!
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.GET.rawValue
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if let data = data {
                
                    print("Data returning")
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .secondsSince1970
                    
                    do {
                        let token = try decoder.decode(GameToken.self, from: data)
                        completion?(token, nil)
                        return
                    } catch {
                        // Deal with error
                        print("Error getting Token from text input: \(error.localizedDescription)")
                        if let gameError = try? decoder.decode(GameError.self, from: data) {
                            completion?(nil, gameError.reason)
                            return
                        } else {
                            completion?(nil, error.localizedDescription)
                            return
                        }
                    }
                
            } else {
                if let error = error {
                    print("Error returning")
                    DispatchQueue.main.async {
                        completion?(nil, error.localizedDescription)
                        return
                    }
                } else {
                    completion?(nil, "Unknown error occurred")
                    return
                }
            }
        }
        task.resume()
    }
    
    // Register Purchase (post)
    static func registerPurchase(purchase:Purchase, completion:(([GameToken], String?) -> ())?) {
        
        // Build Request
        let address = "\(baseAddress)/token/purchase/register"
        
        guard let url = URL(string: address) else { return }
        let session = URLSession.shared
        var request = URLRequest(url: url)
        
        request.httpMethod = HTTPMethod.POST.rawValue
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("\(purchase.receipt)", forHTTPHeaderField: "receipt")
        request.setValue("\(purchase.date)", forHTTPHeaderField: "dop")
        request.setValue("\(purchase.storeProduct.rawValue)", forHTTPHeaderField: "ptype")
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                
                if let responseTokens:[GameToken] = try? decoder.decode([GameToken].self, from: data) {
                    
                    print("Response Tokens: \(responseTokens.count)")
                    completion?(responseTokens, nil)
                    return
                    
                } else if let gameError = try? decoder.decode(GameError.self, from: data) {
                    print("Response Error.: \(gameError.reason)")
                    completion?([], gameError.reason)
                    return
                }
            } else {
                DispatchQueue.main.async {
                    print("Error: \(error?.localizedDescription ?? "n/a")")
                    completion?([], error?.localizedDescription ?? "Could not register purchase")
                    return
                }
            }
        }
        task.resume()
    }
    
    // Gift Token
    static func giftToken(to player:PlayerContent, token:GameToken, completion:((GameToken?, String?) -> ())?) {
        let address = "\(baseAddress)/token/gifts/give"
        
        guard let url = URL(string: address) else { return }
        let session = URLSession.shared
        var request = URLRequest(url: url)
        
        request.httpMethod = HTTPMethod.POST.rawValue
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        encoder.outputFormatting = .prettyPrinted
        
        if let data:Data = try? encoder.encode(token) {
            request.httpBody = data
        }
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                
                if let responseToken:GameToken = try? decoder.decode(GameToken.self, from: data) {
                    
                    print("Response Token: \(responseToken)")
                    completion?(responseToken, nil)
                    return
                    
                } else if let gameError = try? decoder.decode(GameError.self, from: data) {
                    print("Response Error.: \(gameError.reason)")
                    completion?(nil, gameError.reason)
                    return
                }
            } else {
                DispatchQueue.main.async {
                    print("Error: \(error?.localizedDescription ?? "n/a")")
                    completion?(nil, error?.localizedDescription ?? "Could not register purchase")
                    return
                }
            }
        }
        task.resume()
    }
    
    // Claim Token
    static func requestGiftedToken(completion:((GameToken?, String?) -> ())?) {
        let address = "\(baseAddress)/token/gifts/claim"
        
        guard let url = URL(string: address) else { return }
        let session = URLSession.shared
        var request = URLRequest(url: url)
        
        request.httpMethod = HTTPMethod.GET.rawValue
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                
                if let responseToken:GameToken = try? decoder.decode(GameToken.self, from: data) {
                    
                    print("Response Token: \(responseToken)")
                    completion?(responseToken, nil)
                    return
                    
                } else if let gameError = try? decoder.decode(GameError.self, from: data) {
                    print("Response Error.: \(gameError.reason)")
                    completion?(nil, gameError.reason)
                    return
                }
            } else {
                DispatchQueue.main.async {
                    print("Error: \(error?.localizedDescription ?? "n/a")")
                    completion?(nil, error?.localizedDescription ?? "Could not register purchase")
                    return
                }
            }
        }
        task.resume()
    }
    
    // MARK: - Guild
    
    /// Still Works 8/10/2021
    static func browseGuilds(completion:(([GuildSummary]?, Error?) -> ())?) {
        
        let player = LocalDatabase.shared.player
        
        guard let pid = player.playerID else {
            print("Something Wrong.")
            completion?(nil, nil)
            return
        }
        
        let url = URL(string: "\(baseAddress)/guilds/browse/\(pid)")!
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.GET.rawValue // (Post): HTTPMethod.POST.rawValue // (Get): HTTPMethod.GET.rawValue
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        // Set the playerID if there is one
        request.setValue(pid.uuidString, forHTTPHeaderField: "pid")
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                do {
                    let guilds:[GuildSummary] = try decoder.decode([GuildSummary].self, from: data)
                    DispatchQueue.main.async {
                        print("Data returning")
                        completion?(guilds, nil)
                    }
                } catch {
                    print("Not Guilds Object. Error:\(error.localizedDescription): \(data)")
                    if let string = String(data: data, encoding: .utf8) {
                        print("Not Guilds String: \(string)")
                    }
                }
            } else if let error = error {
                print("Error returning")
                DispatchQueue.main.async {
                    completion?(nil, error)
                }
            }
        }
        task.resume()
    }
    
    static func browseInvitesFromGuilds(completion:(([GuildSummary]?, Error?) -> ())?) {
        
        let player = LocalDatabase.shared.player
        
        guard let _ = player.playerID else {
            print("Something Wrong.")
            completion?(nil, nil)
            return
        }
        
        let url = URL(string: "\(baseAddress)/guilds/player/browse_invites")!
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.GET.rawValue
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                do {
                    let guilds:[GuildSummary] = try decoder.decode([GuildSummary].self, from: data)
                    DispatchQueue.main.async {
                        print("Data returning")
                        completion?(guilds, nil)
                    }
                } catch {
                    print("Not Guilds Object. Error:\(error.localizedDescription): \(data)")
                    if let string = String(data: data, encoding: .utf8) {
                        print("Not Guilds String: \(string)")
                    }
                }
            } else if let error = error {
                print("Error returning")
                DispatchQueue.main.async {
                    completion?(nil, error)
                }
            }
        }
        task.resume()
    }
    
    /// Gets the details (GuildFullContent) about a Guild
    static func fetchGuildDetails(gid:UUID, completion:((GuildFullContent?, Error?) -> ())?) {
        
        let player = LocalDatabase.shared.player
        
        guard let pid = player.playerID else {
            print("Something Wrong.")
            completion?(nil, nil)
            return
        }
        
        let url = URL(string: "\(baseAddress)/guilds/find/\(gid)")!
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.GET.rawValue
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        // Set the playerID if there is one
        request.setValue(pid.uuidString, forHTTPHeaderField: "pid")
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                do {
                    let guild:GuildFullContent = try decoder.decode(GuildFullContent.self, from: data)
                    DispatchQueue.main.async {
                        print("Data returning")
                        completion?(guild, nil)
                    }
                } catch {
                    print("Not Guilds Object. Error:\(error.localizedDescription): \(data)")
                    if let string = String(data: data, encoding: .utf8) {
                        print("Not Guilds String: \(string)")
                    }
                }
            } else if let error = error {
                print("Error returning")
                DispatchQueue.main.async {
                    completion?(nil, error)
                }
            }
        }
        task.resume()
    }
    
    /// Tries to join a Guild
    static func joinGuildPetition(guildID:UUID, completion:((GuildSummary?, Error?) -> ())?) {
        
        let url = URL(string: "\(baseAddress)/guilds/player/join/\(guildID.uuidString)")!
        
        let player = LocalDatabase.shared.player
        
        guard let pid = player.playerID else {
            print("⚠️ Error: Data Missing")
            completion?(nil, nil)
            return
        }
        
        guard let playerPost:PlayerUpdate = try? PlayerUpdate.create(player: player) else {
            print("Player missing basic info")
            completion?(nil, nil)
            return
        }
        
        print("Player ID wants to join a guild: \(pid)")
        
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.POST.rawValue
        
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue(guildID.uuidString, forHTTPHeaderField: "gid")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        
        guard let data = try? encoder.encode(playerPost) else { fatalError() }
        
        request.httpBody = data
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                DispatchQueue.main.async {
                    print("Data returning")
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .secondsSince1970
                    do {
                        let guild = try decoder.decode(GuildSummary.self, from: data)
                        if guild.citizens.contains(pid) {
                            print("PLAYER ADDED TO GUILD. SUCCESS")
                        } else {
                            print("⚠️ Error: could not add player to guild :(")
                        }
                        completion?(guild, nil)
                        return
                    }catch{
                        
                        if let gameError = try? decoder.decode(GameError.self, from: data) {
                            print("Error decoding.: \(gameError.reason)")
                            completion?(nil, error)
                            
                        } else {
                            print("Error - Something else has happened")
                            completion?(nil, error)
                        }
                    }
                }
                
            } else {
                print("Error returning")
                DispatchQueue.main.async {
                    completion?(nil, error)
                }
            }
        }
        task.resume()
    }
    
    /// Builds the Guild Outposts and setup after creating a new Guild
    static func postCreate(newGuildID:UUID, completion:((GuildFullContent?, Error?) -> ())?) {
        
        let address = "\(baseAddress)/guilds/player/postcreate/\(newGuildID)"
        
        guard let url = URL(string: address) else { return }
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.GET.rawValue
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                DispatchQueue.main.async {
                    print("Data returning")
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .secondsSince1970
                    do {
                        let guild = try decoder.decode(GuildFullContent.self, from: data)
                        completion?(guild, nil)
                        return
                    }catch{
                        
                        if let gameError = try? decoder.decode(GameError.self, from: data) {
                            print("Error decoding.: \(gameError.reason)")
                            completion?(nil, error)
                            
                        } else {
                            print("Error - Something else has happened")
                            completion?(nil, error)
                        }
                    }
                }
                
            } else {
                print("Error returning")
                DispatchQueue.main.async {
                    completion?(nil, error)
                }
            }
        }
        task.resume()
    }
    
    /// Creates a new Guild
    static func createGuild(creator:GuildCreate, completion:((GuildSummary?, Error?) -> ())?) {
        // guilds/player/create
        // Build Request
        let address = "\(baseAddress)/guilds/player/create"
        
        guard let url = URL(string: address) else { return }
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.POST.rawValue
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        encoder.outputFormatting = .prettyPrinted
        
        // Body with `PlayerUpdate`
        if let data = try? encoder.encode(creator) {
            print("\n\nAdding Data")
            request.httpBody = data
            let dataString = String(data:data, encoding: .utf8) ?? "n/a"
            print("DS: \(dataString)")
        }
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                DispatchQueue.main.async {
                    print("Data returning")
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .secondsSince1970
                    do {
                        let guild = try decoder.decode(GuildSummary.self, from: data)
                        completion?(guild, nil)
                        return
                    }catch{
                        
                        if let gameError = try? decoder.decode(GameError.self, from: data) {
                            print("Error decoding.: \(gameError.reason)")
                            completion?(nil, error)
                            
                        } else {
                            print("Error - Something else has happened")
                            completion?(nil, error)
                        }
                    }
                }
                
            } else {
                print("Error returning")
                DispatchQueue.main.async {
                    completion?(nil, error)
                }
            }
        }
        task.resume()
    }
    
    static func leaveGuild(completion:((PlayerContent?, Error?) -> ())?) {
        
        let player = LocalDatabase.shared.player
        let cityID:String = player.cityID?.uuidString ?? ""
        guard let guildID = player.guildID else {
            print("No Guild ID to leave")
            completion?(nil, nil)
            return
        }
        
        let url = URL(string: "\(baseAddress)/guilds/player/leave/\(guildID.uuidString)/\(cityID)")!
        
        print("⚠️ Player wants to leave a guild")
        
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.GET.rawValue
        
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        // request.setValue(guildID.uuidString, forHTTPHeaderField: "gid")
    
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                DispatchQueue.main.async {
                    
                    do {
                        let newPlayerContent = try decoder.decode(PlayerContent.self, from: data)
                        let newGuildID = newPlayerContent.guildID
                        print("New Guild ID after left guild: \(String(describing: newGuildID?.debugDescription))")
                        player.guildID = nil
                        completion?(newPlayerContent, nil)
                        
                        return
                    }catch{
                        
                        if let gameError = try? decoder.decode(GameError.self, from: data) {
                            print("Error decoding.: \(gameError.reason)")
                            completion?(nil, error)
                            
                        } else {
                            print("Error - Something else has happened")
                            completion?(nil, error)
                        }
                    }
                } // End Dispatch
                
            } else {
                print("Error returning")
                DispatchQueue.main.async {
                    completion?(nil, error)
                }
            }
        }
        task.resume()
    }
    
    static func inviteToGuild(player:PlayerContent, completion:((PlayerContent?, Error?) -> ())?) {
        let player = LocalDatabase.shared.player
        
        guard let _ = player.playerID else {
            print("Something Wrong.")
            completion?(nil, nil)
            return
        }
        
        let url = URL(string: "\(baseAddress)/guilds/player/invite")!
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.GET.rawValue
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        // Set the playerID if there is one
        //        request.setValue(pid.uuidString, forHTTPHeaderField: "pid")
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                do {
                    let playerContent:PlayerContent = try decoder.decode(PlayerContent.self, from: data)
                    DispatchQueue.main.async {
                        print("Data returning")
                        completion?(playerContent, nil)
                    }
                } catch {
                    print("⚠️ Invite unsuccessful. Error:\(error.localizedDescription): \(data)")
                    if let string = String(data: data, encoding: .utf8) {
                        print("Not Guilds String: \(string)")
                    }
                }
            } else if let error = error {
                print("⚠️ Error returning")
                DispatchQueue.main.async {
                    completion?(nil, error)
                }
            }
        }
        task.resume()
    }
    
    // Chat
    
    static func readChat(guildID:UUID, completion:(([ChatMessage], Error?) -> ())?) {
        
        let url = URL(string: "\(baseAddress)/guilds/chat/read/\(guildID.uuidString)")!
        
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.GET.rawValue
        
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                DispatchQueue.main.async {
                    print("Data returning")
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .secondsSince1970
                    do {
                        let messages = try decoder.decode([ChatMessage].self, from: data)
                        completion?(messages, nil)
                        return
                    }catch{
                        
                        if let gameError = try? decoder.decode(GameError.self, from: data) {
                            print("Error decoding.: \(gameError.reason)")
                            completion?([], error)
                            
                        } else {
                            print("Error - Something else has happened")
                            completion?([], error)
                        }
                    }
                }
            } else {
                print("Error returning")
                DispatchQueue.main.async {
                    completion?([], error)
                }
            }
        }
        task.resume()
        
    }
    
    static func postChat(message:ChatPost, completion:(([ChatMessage], Error?) -> ())?) {
        
        let url = URL(string: "\(baseAddress)/guilds/chat/write/\(message.guildID)")!
        
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.POST.rawValue
        
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        
        guard let bodyData = try? encoder.encode(message) else { fatalError() }
        
        request.httpBody = bodyData
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if let data = data {
                DispatchQueue.main.async {
                    print("Data returning")
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .secondsSince1970
                    do {
                        let messages = try decoder.decode([ChatMessage].self, from: data)
                        completion?(messages, nil)
                        return
                    }catch{
                        
                        if let gameError = try? decoder.decode(GameError.self, from: data) {
                            print("Error decoding.: \(gameError.reason)")
                            completion?([], error)
                            
                        } else {
                            print("Error - Something else has happened")
                            completion?([], error)
                        }
                    }
                }
            } else {
                print("Error returning")
                DispatchQueue.main.async {
                    completion?([], error)
                }
            }
        }
        task.resume()
        
    }
    
    // Election
    
    // update(restart)
    static func upRestartElection(completion:((GuildElectionData?, Error?) -> ())?) {
        
        let url = URL(string: "\(baseAddress)/guilds/election/update")!
        
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.GET.rawValue
        
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        //        request.setValue(guildID.uuidString, forHTTPHeaderField: "gid")
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                DispatchQueue.main.async {
                    print("Data returning")
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .secondsSince1970
                    do {
                        let election = try decoder.decode(GuildElectionData.self, from: data)
                        completion?(election, nil)
                        return
                    }catch{
                        
                        if let string = String(data: data, encoding: .utf8) {
                            print("\n UpRestartElection return String:")
                            print(string)
                            print("--- eof")
                        }
                        if let gameError = try? decoder.decode(GameError.self, from: data) {
                            print("Error decoding.: \(gameError.reason)")
                            if gameError.reason == "Election not started" {
                                print("Its okay. Election not started")
                                completion?(nil, nil)
                                return
                            }
                            completion?(nil, error)
                            return
                        } else {
                            print("Error - Something else has happened")
                            completion?(nil, error)
                            return
                        }
                    }
                }
            } else {
                print("Error returning")
                DispatchQueue.main.async {
                    completion?(nil, error)
                }
            }
        }
        task.resume()
        
    }
    
    // vote
    static func voteOnElection(candidate:PlayerCard, completion:((Election?, Error?) -> ())?) {
        
        let url = URL(string: "\(baseAddress)/guilds/election/vote/\(candidate.id)")!
        
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.GET.rawValue
        
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                DispatchQueue.main.async {
                    print("Data returning")
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .secondsSince1970
                    do {
                        let election = try decoder.decode(Election.self, from: data)
                        completion?(election, nil)
                        return
                    }catch{
                        
                        if let gameError = try? decoder.decode(GameError.self, from: data) {
                            print("Error decoding.: \(gameError.reason)")
                            completion?(nil, error)
                            return
                        } else {
                            print("Error - Something else has happened")
                            completion?(nil, error)
                            return
                        }
                    }
                }
            } else {
                print("Error returning")
                DispatchQueue.main.async {
                    completion?(nil, error)
                }
            }
        }
        task.resume()
    }
    
    // President
    
    // 1. kickout
    static func kickPlayer(from guild:GuildFullContent, city:DBCity, booted:PlayerContent, completion:((Bool?, Error?) -> ())?) {
        
        let url = URL(string: "\(baseAddress)/guilds/kickout/\(guild.id)/\(city.id)")!
        
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.GET.rawValue
        
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                DispatchQueue.main.async {
                    print("Data returning")
                    do {
                        let message = try JSONDecoder().decode(String.self, from: data)
                        if message.contains("ok") || message.contains("OK") {
                            completion?(true, error)
                            return
                        }
                        completion?(nil, error)
                        return
                    }catch{
                        
                        if let gameError = try? JSONDecoder().decode(GameError.self, from: data) {
                            print("Error decoding.: \(gameError.reason)")
                            completion?(false, error)
                            
                        } else {
                            print("Error - Something else has happened")
                            completion?(false, error)
                        }
                    }
                }
            } else {
                if let response = response {
                    if response.debugDescription.contains("ok") || response.debugDescription.contains("OK") {
                        completion?(true, error)
                        return
                    }
                }
                print("Error returning")
                DispatchQueue.main.async {
                    completion?(false, error)
                }
            }
        }
        task.resume()
        
    }
    // 2. Modify
    static func modifyGuild(guild:GuildFullContent, player:SKNPlayer, completion:((GuildFullContent?, Error?) -> ())?) {
        
        let url = URL(string: "\(baseAddress)/guilds/player/modify/\(player.keyPass ?? "")")!
        
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.POST.rawValue
        
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        //        request.setValue(guildID.uuidString, forHTTPHeaderField: "gid")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        
        guard let data = try? encoder.encode(guild) else { fatalError() }
        
        request.httpBody = data
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                DispatchQueue.main.async {
                    print("Data returning")
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .secondsSince1970
                    do {
                        let upGuild = try decoder.decode(GuildFullContent.self, from: data)
                        completion?(upGuild, nil)
                        return
                    }catch{
                        
                        if let gameError = try? decoder.decode(GameError.self, from: data) {
                            print("Error decoding.: \(gameError.reason)")
                            completion?(nil, error)
                            
                        } else {
                            print("Error - Something else has happened")
                            completion?(nil, error)
                        }
                    }
                }
            } else {
                print("Error returning")
                DispatchQueue.main.async {
                    completion?(nil, error)
                }
            }
        }
        task.resume()
    }
    // 3. invite
    static func addToInvite(player:PlayerContent, completion:((Bool?, Error?) -> ())?) {
        
        let url = URL(string: "\(baseAddress)/guilds/player/invite/\(player.id)")!
        
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.GET.rawValue
        
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        //        request.setValue(guildID.uuidString, forHTTPHeaderField: "gid")
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                DispatchQueue.main.async {
                    print("Data returning")
                    do {
                        let message = try JSONDecoder().decode(String.self, from: data)
                        if message.contains("ok") || message.contains("OK") {
                            completion?(true, error)
                            return
                        }
                        completion?(nil, error)
                        return
                    }catch{
                        
                        if let gameError = try? JSONDecoder().decode(GameError.self, from: data) {
                            print("Error decoding.: \(gameError.reason)")
                            completion?(false, error)
                            
                        } else {
                            print("Error - Something else has happened")
                            completion?(false, error)
                        }
                    }
                }
            } else {
                if let response = response {
                    if response.debugDescription.contains("ok") || response.debugDescription.contains("OK") {
                        completion?(true, error)
                        return
                    }
                }
                print("Error returning")
                DispatchQueue.main.async {
                    completion?(false, error)
                }
            }
        }
        task.resume()
        
    }
    
    // MARK: - City
    
    static func claimCity(posdex:Posdex, completion:((DBCity?, Error?) -> ())?) {
        
        print("Claiming City")
        
        let url = URL(string: "\(baseAddress)/guilds/city/claim/\(posdex.rawValue)")!
        
        let player = LocalDatabase.shared.player
        
        
        let session = URLSession.shared
        var request = URLRequest(url: url)
        
        request.httpMethod = HTTPMethod.POST.rawValue
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        
        let playerUpdate:PlayerUpdate = try! PlayerUpdate.create(player: player)
        if let data = try? encoder.encode(playerUpdate) {
            print("Adding Data")
            request.httpBody = data
            let dataString = String(data:data, encoding: .utf8) ?? "n/a"
            print("DS: \(dataString)")
        }
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                DispatchQueue.main.async {
                    print("Data returning")
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .secondsSince1970
                    if let decodedCity = try? decoder.decode(DBCity.self, from: data) {
                        print("Decoded City. Save new CID for Player and User !!!")
                        completion?(decodedCity, nil)
                    } else {
                        print("*-*-*- Could not decode -*-*-*")
                        completion?(nil, error)
                    }
                }
                
            } else if let error = error {
                print("Error returning")
                DispatchQueue.main.async {
                    completion?(nil, error)
                }
            }
        }
        task.resume()
    }
    
    // MARK: - Outpost
    
    // request OutpostData
    static func requestOutpostData(dbOutpost:DBOutpost, completion:((Outpost?, Error?) -> ())?) {
        
        let url = URL(string: "\(baseAddress)/outposts/data/\(dbOutpost.id)")!

        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.GET.rawValue

        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if let data = data {
                DispatchQueue.main.async {
                    print("Data returning")
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .secondsSince1970
                    do {
                        let outpost = try decoder.decode(Outpost.self, from: data)
                        completion?(outpost, nil)
                        return
                    }catch{

                        if let gameError = try? decoder.decode(GameError.self, from: data) {
                            
                            print("Error decoding.: \(gameError.reason)")
                            
                            // Check if file doesn't exist
                            if gameError.reason.contains("noContent") {
                                completion?(nil, ServerDataError.noOutpostFile)
                                return
                            }
                            
                            completion?(nil, error)
                            return

                        } else {
                            print("\n Outpost Data")
                            print("Error - Something else has happened")
                            print(error.localizedDescription)
                            if let string = try? decoder.decode(String.self, from: data) {
                                print("Error String \n \(string)")
                            } else {
                                print("No error string")
                            }
                            
                            completion?(nil, error)
                        }
                    }
                }
            } else {
                print("Error returning")
                DispatchQueue.main.async {
                    completion?(nil, error)
                }
            }
        }
        task.resume()
        
    }
    
    // create outpost data (1st time)
    static func createOutpostData(dbOutpost:DBOutpost, completion:((Outpost?, Error?) -> ())?) {
        
        let url = URL(string: "\(baseAddress)/outposts/data")!
        
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.POST.rawValue
        
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        // Prepare upload data
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        let outpost = Outpost(dbOutpost: dbOutpost)
        guard let data = try? encoder.encode(outpost) else { fatalError() }
        request.httpBody = data
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                DispatchQueue.main.async {
                    print("Data returning")
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .secondsSince1970
                    do {
                        let outpost = try decoder.decode(Outpost.self, from: data)
                        completion?(outpost, nil)
                        return
                    }catch{
                        
                        if let gameError = try? decoder.decode(GameError.self, from: data) {
                            print("Error decoding.: \(gameError.reason)")
                            completion?(nil, error)
                            
                        } else {
                            print("Error - Something else has happened")
                            completion?(nil, error)
                        }
                    }
                }
            } else {
                print("Error returning")
                DispatchQueue.main.async {
                    completion?(nil, error)
                }
            }
        }
        task.resume()
        
    }
    
    // update (upload) outpost data
    
    // contribute to outpost
    static func outpostContribution(outpost:Outpost, newSupply:OutpostSupply, completion:((Outpost?, Error?) -> ())?) {
        
        let url = URL(string: "\(baseAddress)/outposts/data/contribute/\(outpost.id)")!
        
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.POST.rawValue
        
        // Headers
        let dateUpdate = outpost.collected ?? Date()
        let dateUpTime:Double = dateUpdate.timeIntervalSince1970
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        // Date in Header
        request.setValue("\(dateUpTime)", forHTTPHeaderField: "date")
        
        // Body
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        encoder.outputFormatting = .prettyPrinted
        
        guard let bodyData:Data = try? encoder.encode(newSupply) else {
            print("Could not encode body data")
            return
        }
        request.httpBody = bodyData
        
        // Execution
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if let data = data {
                DispatchQueue.main.async {
//                    print("Data returning")
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .secondsSince1970
                    do {
                        let outpost = try decoder.decode(Outpost.self, from: data)
                        completion?(outpost, nil)
                        return
                    } catch {
                        
                        // No OutpostData
                        if let gameError = try? decoder.decode(GameError.self, from: data) {
                            // print("Error decoding.: \(gameError.reason)")
                            if gameError.reason == "Missing Outpost ID" {
                                completion?(nil, OPContribError.missingOutpostID)
                            } else if gameError.reason == "Bad Supply Data" {
                                completion?(nil, OPContribError.badSupplyData)
                            } else if gameError.reason == "OUTDATED" {
                                completion?(nil, OPContribError.outdated)
                            } else if gameError.reason == "Decoding Outpost Data" {
                                completion?(nil, OPContribError.serverDecodingData)
                            } else if gameError.reason == "Could not write new data" {
                                completion?(nil, OPContribError.serverWritingData)
                            } else {
                                completion?(nil, error)
                            }
                            return
                            
                        } else {
                            print("Error - An error not supported by GameError happened: \(error.localizedDescription)")
                            completion?(nil, error)
                            return
                        }
                    }
                }
            } else {
                print("Error returning")
                DispatchQueue.main.async {
                    completion?(nil, error)
                }
            }
        }
        task.resume()
        
    }
    
    static func applyForOutpostUpgrades(outpost:Outpost, upgrade:OutpostUpgradeResult, completion:((Outpost?, Error?) -> ())?) {
        // updates
        let url = URL(string: "\(baseAddress)/outposts/data/upgrade")!
        
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.POST.rawValue
        
        // Headers
        let dateUpdate = outpost.collected ?? Date()
        let dateUpTime:Double = dateUpdate.timeIntervalSince1970
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        // Date in Header
        request.setValue("\(dateUpTime)", forHTTPHeaderField: "date")
        
        // type in Header
        switch upgrade {
            case .needsDateUpgrade, .dateUpgradeShouldBeNil, .noChanges:
                print("Cannot upgrade an outpost at this state.")
                return
            case .nextState(let next):
                // if you pass "finished", it is the same as ".applyForLevelUp"
                request.setValue(next.rawValue, forHTTPHeaderField: "type")
            case .applyForLevelUp(let currentLevel):
                print("Trying to update from level: \(currentLevel)")
                request.setValue(OutpostState.finished.rawValue, forHTTPHeaderField: "type")
        }
        
        // Body
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        encoder.outputFormatting = .prettyPrinted
        
        guard let bodyData:Data = try? encoder.encode(outpost) else {
            print("Could not encode Outpost body data")
            return
        }
        request.httpBody = bodyData
        
        // Execution
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if let data = data {
                DispatchQueue.main.async {
                    //                    print("Data returning")
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .secondsSince1970
                    do {
                        let outpost = try decoder.decode(Outpost.self, from: data)
                        completion?(outpost, nil)
                        return
                    } catch {
                        
                        // No OutpostData
                        if let gameError = try? decoder.decode(GameError.self, from: data) {
                            // print("Error decoding.: \(gameError.reason)")
                            if gameError.reason == "Missing Outpost ID" {
                                completion?(nil, OPContribError.missingOutpostID)
                            } else if gameError.reason == "Bad Supply Data" {
                                completion?(nil, OPContribError.badSupplyData)
                            } else if gameError.reason == "OUTDATED" {
                                completion?(nil, OPContribError.outdated)
                            } else if gameError.reason == "Decoding Outpost Data" {
                                completion?(nil, OPContribError.serverDecodingData)
                            } else if gameError.reason == "Could not write new data" {
                                completion?(nil, OPContribError.serverWritingData)
                            } else {
                                completion?(nil, error)
                            }
                            return
                            
                        } else {
                            print("Error - An error not supported by GameError happened: \(error.localizedDescription)")
                            completion?(nil, error)
                            return
                        }
                    }
                }
            } else {
                print("Error returning")
                DispatchQueue.main.async {
                    completion?(nil, error)
                }
            }
        }
        task.resume()
        
    }
    
    
    // MARK: - Space Vehicle
    
    /// Register Vehicle in Server
    static func registerSpace(vehicle:SpaceVehicle, completion:((SpaceVehicleTicket?, Error?) -> ())?) {
        
        let player = LocalDatabase.shared.player
        
        guard let playerID = player.playerID else {
            print("ERROR: No Player ID to register vehicle.")
            return
        }
        
        let url = URL(string: "\(baseAddress)/guilds/travelling/register")!
        let session = URLSession.shared
        var request = URLRequest(url: url)
        
        request.httpMethod = HTTPMethod.POST.rawValue // (Post): HTTPMethod.POST.rawValue // (Get): HTTPMethod.GET.rawValue
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue(playerID.uuidString, forHTTPHeaderField: "playerid")
        // request.setValue(guildName, forHTTPHeaderField: "guildname")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        encoder.outputFormatting = .prettyPrinted
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        
        // Data
        let postObject:SpaceVehiclePost = SpaceVehiclePost(spaceVehicle: vehicle, playerID: playerID)
        if let data = try? encoder.encode(postObject) {
            print("Adding Data - Space Vehicle Post")
            request.httpBody = data
            let dataString = String(data:data, encoding: .utf8) ?? "n/a"
            print("DS: \(dataString)")
        }
        
//        let vehicleModel:SpaceVehicleModel = SpaceVehicleModel(spaceVehicle: vehicle, player: player)
//        if let data = try? encoder.encode(vehicleModel) {
//            print("Adding Data")
//            request.httpBody = data
//            let dataString = String(data:data, encoding: .utf8) ?? "n/a"
//            print("DS: \(dataString)")
//        }
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let data = data,
               let ticket:SpaceVehicleTicket = try? decoder.decode(SpaceVehicleTicket.self, from: data) {
                DispatchQueue.main.async {
                    print("Data returning")
                    completion?(ticket, nil)
                }
                
            } else if let error = error {
                print("Error returning")
                DispatchQueue.main.async {
                    completion?(nil, error)
                }
            }
        }
        task.resume()
    }
    
    /// Search vehicles in Guild (arrived)
    static func arrivedVehiclesInGuildMap(completion:(([SpaceVehicleTicket]?, Error?) -> ())?) {
        // URL: /guilds/space_vehicles/arrived/:gid
        // Expects: :gid GuildID
        // Returns: Array of vehicles in Guild file (arrived)
        
        let player = LocalDatabase.shared.player
        
        guard let gid = player.guildID else {
            print("Needs playerID")
            return
        }
        
        // Takes GID as parameter
        // Takes SpaceVehicleContent in body
        
        let url = URL(string: "\(baseAddress)/guilds/space_vehicles/arrived/\(gid)")!
        let session = URLSession.shared
        var request = URLRequest(url: url)
        
        request.httpMethod = HTTPMethod.GET.rawValue
//        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
//        request.setValue(player.id.uuidString, forHTTPHeaderField: "playerid")
        // request.setValue(guildName, forHTTPHeaderField: "guildname")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        encoder.outputFormatting = .prettyPrinted
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                
                print("arrived data in")
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                
                if let vResponse = try? decoder.decode([SpaceVehicleTicket].self, from: data) {
                    DispatchQueue.main.async {
                        print("Data returning")
                        completion?(vResponse, nil)
                    }
                } else if let rString = String(data:data, encoding: .utf8) {
                    print("Decoded String: \(rString)")
                }
                
                
            } else if let error = error {
                print("Error returning")
                DispatchQueue.main.async {
                    completion?(nil, error)
                }
            }
        }
        task.resume()
        
    }
    
    
}

// Cookies
//            if let a = HTTPCookieStorage.shared.cookies?.first(where: { $0.name.contains("vapor")}) {
//
//            }
//            if let prevCookies = HTTPCookieStorage.shared.cookies {
//                print("Previous Cookies: \(prevCookies.description)")
//            }
//
//            if let a = response as? HTTPURLResponse,
//               let b = a.allHeaderFields as? [String:String],
//               let rurl = response?.url {
//               let cookies = HTTPCookie.cookies(withResponseHeaderFields: b, for: rurl)
//                print("Incoming Cookies...")
//                for cookie in cookies {
//                    var cookieProperties = [HTTPCookiePropertyKey: Any]()
//                    cookieProperties[.name] = cookie.name
//                    cookieProperties[.value] = cookie.value
//                    cookieProperties[.domain] = cookie.domain
//                    cookieProperties[.path] = cookie.path
//                    cookieProperties[.version] = cookie.version
//                    cookieProperties[.expires] = Date().addingTimeInterval(31536000)
//                    print("Cookie name: \(cookie.name) value: \(cookie.value)")
////                    let newCookie = HTTPCookie(properties: cookieProperties)
////                    HTTPCookieStorage.shared.setCookie(newCookie!)
//                }
//            }
