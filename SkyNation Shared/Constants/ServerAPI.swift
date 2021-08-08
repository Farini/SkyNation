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
        // Queries should have *route, *date, *objectRetrieved, *
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
    
//    var encoder:JSONEncoder {
//        get {
//            let encoder = JSONEncoder()
//            encoder.dateEncodingStrategy = .secondsSince1970
//            return encoder
//        }
//    }
//
//    var decoder:JSONDecoder {
//        get {
//            let decoder = JSONDecoder()
//            decoder.dateDecodingStrategy = .secondsSince1970
//            return decoder
//        }
//    }
    
    
    
    static let baseAddress = "http://127.0.0.1:8080"
    
    // MARK: - User, Login
    
    /// A function that does `Sign-in`, or `Login` based on what data we have
    static func resolveLogin(completion:((PlayerPost?, Error?) -> ())?) {
        
        guard let player = LocalDatabase.shared.player else { return }
        let playerPost = PlayerPost(player: player)
        
        // Build Request
        let address = "\(baseAddress)/users/login" // shouldSignIn ? "\(baseAddress)/users/login"  // sign-in":"\(baseAddress)/users/login"
        guard let url = URL(string: address) else { return }
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.POST.rawValue // (Post): HTTPMethod.POST.rawValue // (Get): HTTPMethod.GET.rawValue
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        
        if let data = try? encoder.encode(playerPost) {
            print("\n\nAdding Data")
            request.httpBody = data
            let dataString = String(data:data, encoding: .utf8) ?? "n/a"
            print("DS: \(dataString)")
        }
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                if let responseUser = try? decoder.decode(PlayerPost.self, from: data) {
                    
                    print("Response user: \(responseUser.name)")
                    
                    // Update Player Properties
                    if let pass = responseUser.keyPass {
                        print("Pass: \(pass)")
                        player.keyPass = pass
                    }
                    player.serverID = responseUser.serverID
                    player.playerID = responseUser.playerID
                    print("Player id: \(player.playerID!)")
                    if let gid = player.guildID {
                        print("Guild id: \(gid)")
                    } else {
                        print("⚠️ Player doesn't have a Guild")
                    }
                    
                    // Save
                    let res = LocalDatabase.shared.savePlayer(player: player)
                    if !res { print("Error: Could not save player") }
                    
                    DispatchQueue.main.async {
                        completion?(responseUser, nil)
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
    
    // Deprecate (resolveLogin solves it)
    static func newLogin(user:SKNUserPost, completion:((SKNUserPost?, Error?) -> ())?) {
        
        print("New Login")
        
//        if let guild = user.guildID {
//            // user already has guild
//            print("* Guild \(guild)")
//        } else {
//            // user doesn't have a guild
//            print("no guild")
//        }
        
        let url = URL(string: "\(baseAddress)/login")!
        let session = URLSession.shared
        var request = URLRequest(url: url)
        
        request.httpMethod = HTTPMethod.POST.rawValue // (Post): HTTPMethod.POST.rawValue // (Get): HTTPMethod.GET.rawValue
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(user) {
            print("Adding Data")
            request.httpBody = data
//            let dataString = String(data:data, encoding: .utf8) ?? "n/a"
//            print("DS: \(dataString)")
        }
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                if let responseUser = try? decoder.decode(SKNUserPost.self, from: data) {
                    DispatchQueue.main.async {
//                        print("Data returning")
                        completion?(responseUser, nil)
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
    
    // Deprecate (resolveLogin solves it)
    static func createPlayer(localPlayer:SKNUserPost, completion:((Data?, Error?) -> ())?) {
        
        print("Creating Player")
        
        let url = URL(string: "\(baseAddress)/users")!
        let session = URLSession.shared
        var request = URLRequest(url: url)
        
        request.httpMethod = HTTPMethod.POST.rawValue // (Post): HTTPMethod.POST.rawValue // (Get): HTTPMethod.GET.rawValue
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(localPlayer) {
            print("Adding Data")
            request.httpBody = data
            let dataString = String(data:data, encoding: .utf8) ?? "n/a"
            print("DS: \(dataString)")
        }
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                DispatchQueue.main.async {
                    print("Data returning")
                    completion?(data, nil)
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
    
    static func updatePlayer(object:PlayerContent, completion:((PlayerContent?, Error?) -> ())?) {
        
        print("Creating Player")
        
        let url = URL(string: "\(baseAddress)/update_player")!
        let session = URLSession.shared
        var request = URLRequest(url: url)
        
        request.httpMethod = HTTPMethod.POST.rawValue // (Post): HTTPMethod.POST.rawValue // (Get): HTTPMethod.GET.rawValue
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(object) {
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
                    if let playerBack = try? decoder.decode(PlayerContent.self, from: data) {
                        completion?(playerBack, nil)
                    }else {
                        print("Data is not formattted to 'PlayerContent' ")
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
    
    // MARK: - Tokens
    
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
                DispatchQueue.main.async {
                    print("Data returning")
                    
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .secondsSince1970
                    let string = String(data:data, encoding:.utf8)
                    
                    do {
                        let token = try decoder.decode(GameToken.self, from: data)
                        completion?(token, nil)
                        return
                    }catch{
                        print("Error decoding: \(error.localizedDescription)")
                        print("\n\nString:")
                        print(string ?? "n/a")
                        
                        completion?(nil, error.localizedDescription)
                    }
                }
                
            } else {
                print("Error returning")
                DispatchQueue.main.async {
                    completion?(nil, error?.localizedDescription)
                }
            }
        }
        task.resume()
        
    }
    
    // Make Purchase (push)
    
    
    // MARK: - Guild
    
    static func joinGuildPetition(guildID:UUID, completion:((GuildSummary?, Error?) -> ())?) {
        
        let url = URL(string: "\(baseAddress)/guilds/join/\(guildID.uuidString)")!
        guard let player = LocalDatabase.shared.player,
              let pid = player.playerID else {
            print("⚠️ Error: Data Missing")
            completion?(nil, nil)
            return
        }
        
        print("Player ID wants to join a guild: \(pid)")
        
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.POST.rawValue
        
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue(guildID.uuidString, forHTTPHeaderField: "gid")
//        request.setValue(pid.uuidString, forHTTPHeaderField: "pid")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        
        guard let data = try? encoder.encode(player) else { fatalError() }
        
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
                        print("Error decoding")
                        completion?(nil, error)
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
    
    static func requestJoinGuild(playerID:UUID, guildID:UUID, completion:((Guild?, Error?) -> ())?) {
        
        let url = URL(string: "\(baseAddress)/guildjoin/\(playerID.uuidString)/\(guildID.uuidString)")!
        
        
        let session = URLSession.shared
        var request = URLRequest(url: url)
        
        request.httpMethod = HTTPMethod.GET.rawValue // (Post): HTTPMethod.POST.rawValue // (Get): HTTPMethod.GET.rawValue
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                DispatchQueue.main.async {
                    print("Data returning")
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .secondsSince1970
                    do {
                        let guild = try decoder.decode(Guild.self, from: data)
                        completion?(guild, nil)
                        return
                    }catch{
                        print("Error decoding")
                        completion?(nil, error)
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
    
    static func findMyGuild(user:SKNUserPost, completion:((Guild?, Error?) -> ())?) {
        
        let url = URL(string: "\(baseAddress)/eagerguild/\(user.id.uuidString)")!
        
        let session = URLSession.shared
        var request = URLRequest(url: url)
        
        request.httpMethod = HTTPMethod.GET.rawValue // (Post): HTTPMethod.POST.rawValue // (Get): HTTPMethod.GET.rawValue
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                DispatchQueue.main.async {
                    print("Data returning")
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .secondsSince1970
                    let string = String(data:data, encoding:.utf8)
                    
                    do {
                        let guilds = try decoder.decode([Guild].self, from: data)
                        completion?(guilds.first, nil)
                        return
                    }catch{
                        print("Error decoding: \(error.localizedDescription)")
//                        if let string = try? String(data:data, encoding:.utf8) {
                            print("\n\nString:")
                            print(string ?? "n/a")
//                        }
                        completion?(nil, error)
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
    
    // Load Guild (Using the Guild Router)
    static func loadGuild(completion:((GuildFullContent?, Error?) -> ())?) {
        
        guard let player = LocalDatabase.shared.player,
              let pid = player.serverID,
              let gid = player.guildID else {
            completion?(nil, nil)
            return
        }
        
        let url = URL(string: "\(baseAddress)/guilds/load/\(gid)")!
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.GET.rawValue // (Post): HTTPMethod.POST.rawValue // (Get): HTTPMethod.GET.rawValue
        
        request.setValue(gid.uuidString, forHTTPHeaderField: "gid")
        request.setValue(pid.uuidString, forHTTPHeaderField: "pid")
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                DispatchQueue.main.async {
                    //                    print("Data returning")
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .secondsSince1970
                    let string = String(data:data, encoding:.utf8)
                    
                    do {
                        let guild = try decoder.decode(GuildFullContent.self, from: data)
                        completion?(guild, nil)
                        return
                    }catch{
                        print("Error decoding: \(error.localizedDescription)")
                        print("\n\nString:")
                        print(string ?? "n/a")
                        completion?(nil, error)
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
    
    static func browseGuilds(completion:(([GuildSummary]?, Error?) -> ())?) {
        
        guard let player = LocalDatabase.shared.player,
              let pid = player.playerID else {
            print("Something Wrong.")
            completion?(nil, nil)
            return
        }
        
        let url = URL(string: "\(baseAddress)/guilds/browse")!
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
    
    static func createGuild(localPlayer:SKNUserPost, guildName:String, completion:((Data?, Error?) -> ())?) {
        
        print("Creating Guild")
        
        let url = URL(string: "\(baseAddress)/guilds")!
        let session = URLSession.shared
        var request = URLRequest(url: url)
        
        request.httpMethod = HTTPMethod.POST.rawValue // (Post): HTTPMethod.POST.rawValue // (Get): HTTPMethod.GET.rawValue
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue(localPlayer.id.uuidString, forHTTPHeaderField: "playerid")
        request.setValue(guildName, forHTTPHeaderField: "guildname")
        
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(localPlayer) {
            print("Adding Data")
            request.httpBody = data
            let dataString = String(data:data, encoding: .utf8) ?? "n/a"
            print("DS: \(dataString)")
        }
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                DispatchQueue.main.async {
                    print("Data returning")
                    completion?(data, nil)
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
    
    // MARK: - City
    
    static func claimCity(user:SKNUserPost, posdex:Posdex, completion:((CityData?, Error?) -> ())?) {
        print("Claiming City")
        
        let url = URL(string: "\(baseAddress)/guilds/city/claim/\(posdex.rawValue)")!
//        let url = URL(string: "\(baseAddress)/claim_city/\(posdex.rawValue)")!
        
        
        guard let player = LocalDatabase.shared.player else { fatalError() }
        
        
        let session = URLSession.shared
        var request = URLRequest(url: url)
        
        request.httpMethod = HTTPMethod.POST.rawValue // (Post): HTTPMethod.POST.rawValue // (Get): HTTPMethod.GET.rawValue
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
//        request.setValue(localPlayer.id.uuidString, forHTTPHeaderField: "playerid")
//        request.setValue(guildName, forHTTPHeaderField: "guildname")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        
        if let data = try? encoder.encode(player) {
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
                    if let decodedCity = try? decoder.decode(CityData.self, from: data) {
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
    
    static func loadCity(posdex:Posdex, completion:((CityData?, Error?) -> ())?) {
        
        print("Loading City")
        
        let url = URL(string: "\(baseAddress)/guilds/city/load/\(posdex.rawValue)")!
        
        guard let player = LocalDatabase.shared.player,
              let pid = player.playerID
              // let cid = player.cityID
        else { fatalError() }
        
        print("Player ID: \(pid)")
//        print("City ID: \(cid)")
        
        let session = URLSession.shared
        var request = URLRequest(url: url)
        
        request.httpMethod = HTTPMethod.POST.rawValue
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        
        if let data = try? encoder.encode(player) {
            print("Adding Data")
            request.httpBody = data
            let dataString = String(data:data, encoding: .utf8) ?? "n/a"
            print("DS: \(dataString)")
        }
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            
            if let data = data {
                print("Cityload let data -> ok")
                do {
                    let city = try decoder.decode(CityData.self, from: data)
                    DispatchQueue.main.async {
                        print("My City Returning: \(city.id)")
                        completion?(city, nil)
                        return
                    }
                } catch {
                    print("Could not decode. Reason? \(error.localizedDescription)")
                    completion?(nil, error)
                    return
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
    
    static func saveCity(city:CityData, completion:((CityData?, Error?) -> ())?) {
        
//        let url = URL(string: "\(baseAddress)/guild/city/update")!
        guard
              let player = LocalDatabase.shared.player,
              let pid = player.playerID,
              let gid = player.guildID,
            
            let url = URL(string: "\(baseAddress)/guilds/city/update/\(pid.uuidString)/\(gid.uuidString)/\(city.id.uuidString)")
        else {
            fatalError()
        }
        
        
        let session = URLSession.shared
        var request = URLRequest(url: url)
        
        request.httpMethod = HTTPMethod.POST.rawValue
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue(pid.uuidString, forHTTPHeaderField: "pid")
        request.setValue(gid.uuidString, forHTTPHeaderField: "gid")
        
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        encoder.outputFormatting = .prettyPrinted
        
        // Data
//        let vehicleModel:SpaceVehicleModel = SpaceVehicleModel(spaceVehicle: vehicle, player: player)
        if let data = try? encoder.encode(city) {
            print("Adding Data")
            request.httpBody = data
            let dataString = String(data:data, encoding: .utf8) ?? "n/a"
            print("DS: \(dataString)")
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        
        print("Updating City")
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                DispatchQueue.main.async {
                    print("Data returning")
                    if let dCity = try? decoder.decode(CityData.self, from: data) {
                        completion?(dCity, nil)
                        return
                    } else {
                        if let string = String(data:data, encoding: .utf8) {
                            print("SR: \(string)")
                        }
                        
                        print("No data")
                        completion?(nil, nil)
                        return
                    }
                }
                
            } else if let error = error {
                print("Error returning")
                DispatchQueue.main.async {
                    completion?(nil, error)
                    return
                }
            }
        }
        task.resume()
    }
    
    // MARK: - Outpost
    
    static func contributionRequest(object:Codable, type:ContributionType, outpost:Outpost) {
        
        let url = URL(string: "\(baseAddress)/guilds/outpost/contribute/\(outpost.id.uuidString)")!
        print("Needs to continue code. Create URL request: \(url)")
        
        // FIXME: - Contribution Request
        
        // Request will need:
        // 1. SKNUserPost (user + pass)
        // 2. Outpost ID
        // 3. Object Type (type here)
        // 4. Object being contributed Optional (key, val)
        
        // Response:
        // 0. In Server, fetch outpostID.json, then add contribution by (key, val)
        // 1. Yes, or No (Contribution Successful)
        
        // After response:
        // 1. Update Server to let it know if Outpost State is UPGRADING
    }
    
    // MARK: - Space Vehicle
    
    /// Register Vehicle in Server
    static func registerSpace(vehicle:SpaceVehicle, player:SKNUserPost, completion:((Data?, Error?) -> ())?) {
        
        let url = URL(string: "\(baseAddress)/register_vehicle")!
        let session = URLSession.shared
        var request = URLRequest(url: url)
        
        request.httpMethod = HTTPMethod.POST.rawValue // (Post): HTTPMethod.POST.rawValue // (Get): HTTPMethod.GET.rawValue
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue(player.id.uuidString, forHTTPHeaderField: "playerid")
        // request.setValue(guildName, forHTTPHeaderField: "guildname")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        encoder.outputFormatting = .prettyPrinted
        
        // Data
        let vehicleModel:SpaceVehicleModel = SpaceVehicleModel(spaceVehicle: vehicle, player: player)
        if let data = try? encoder.encode(vehicleModel) {
            print("Adding Data")
            request.httpBody = data
            let dataString = String(data:data, encoding: .utf8) ?? "n/a"
            print("DS: \(dataString)")
        }
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                DispatchQueue.main.async {
                    print("Data returning")
                    completion?(data, nil)
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
    
    /// Transfer items from arriving vehicles
    static func orbitMarsWith(vehicle:SpaceVehicle, completion:((SpaceVehicleContent?, Error?) -> ())?) {
        
        guard let player = LocalDatabase.shared.player,
              let gid = player.guildID else {
            return
        }
        
        // Takes GID as parameter
        // Takes SpaceVehicleContent in body
        
        let url = URL(string: "\(baseAddress)/guilds/space_vehicles/edl/\(gid)")!
        let session = URLSession.shared
        var request = URLRequest(url: url)
        
        request.httpMethod = HTTPMethod.POST.rawValue
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue(player.id.uuidString, forHTTPHeaderField: "playerid")
        // request.setValue(guildName, forHTTPHeaderField: "guildname")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        encoder.outputFormatting = .prettyPrinted
        
        // Data
//        let vehicleModel:SpaceVehicleModel = SpaceVehicleModel(spaceVehicle: vehicle, player: player)
        let vehicleContent = SpaceVehicleContent(with: vehicle)
        if let data = try? encoder.encode(vehicleContent) {
            print("Adding Data")
            request.httpBody = data
            let dataString = String(data:data, encoding: .utf8) ?? "n/a"
            print("DS: \(dataString)")
        }
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                if let vResponse = try? decoder.decode(SpaceVehicleContent.self, from: data) {
                    DispatchQueue.main.async {
                        print("Data returning")
                        completion?(vResponse, nil)
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
    
    /// Search vehicles in Guilds File (arrived)
    static func arrivedVehiclesInGuildFile(completion:(([SpaceVehicleContent]?, Error?) -> ())?) {
        // URL: /guilds/space_vehicles/arrived/:gid
        // Expects: :gid GuildID
        // Returns: Array of vehicles in Guild file (arrived)
        
        guard let player = LocalDatabase.shared.player,
              let gid = player.guildID else {
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
                
                if let vResponse = try? decoder.decode([SpaceVehicleContent].self, from: data) {
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
    
    // MARK: - Default
    static func getSimpleData(completion:((Data?, Error?) -> ())?) {
        
        print("Getting Simple Data")
        
        let url = URL(string: "\(baseAddress)/users")!
        let session = URLSession.shared
        var request = URLRequest(url: url)
        
        request.httpMethod = HTTPMethod.POST.rawValue
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let user = SKNUserPost(name: "Farini")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        if let data = try? encoder.encode(user) {
            print("Adding Data")
            request.httpBody = data
            let dataString = String(data:data, encoding: .utf8) ?? "n/a"
            print("DS: \(dataString)")
        }
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                DispatchQueue.main.async {
                    print("Data returning")
                    completion?(data, nil)
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
