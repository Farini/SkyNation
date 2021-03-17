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
    
    static let baseAddress = "http://127.0.0.1:8080"
    
    // MARK: - User, Login
    
    /// A function that does `Sign-in`, or `Login` based on what data we have
    static func resolveLogin(completion:((SKNPlayer?, Error?) -> ())?) {
        
        guard let player = LocalDatabase.shared.player else { return }
        
        // Build Request
        let address = "\(baseAddress)/users/login" // shouldSignIn ? "\(baseAddress)/users/login"  // sign-in":"\(baseAddress)/users/login"
        guard let url = URL(string: address) else { return }
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.POST.rawValue // (Post): HTTPMethod.POST.rawValue // (Get): HTTPMethod.GET.rawValue
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(player) {
            print("Adding Data")
            request.httpBody = data
        }
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                if let responseUser = try? decoder.decode(SKNPlayer.self, from: data) {
                    
                    print("Response user: \(responseUser.name)")
                    
                    // Update Player Properties
                    if let pass = responseUser.keyPass {
                        print("Pass: \(pass)")
                        player.keyPass = pass
                    }
                    player.serverID = responseUser.serverID
                    player.playerID = responseUser.playerID
                    print("Player id: \(player.playerID!)")
                    
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
    
    /*
    static func fetchPlayer(id:UUID, completion:((SKNUserPost?, Error?) -> ())?) {
        
        print("Fetching Player")
        
        let url = URL(string: "\(baseAddress)/users")!
        let session = URLSession.shared
        var request = URLRequest(url: url)
        
        request.httpMethod = HTTPMethod.GET.rawValue
        request.setValue(id.uuidString, forHTTPHeaderField: "playerid")
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                print("Got Data")
                if let user = try? decoder.decode([SKNUserPost].self, from: data).first {
                    DispatchQueue.main.async {
                        print("Data returning")
                        completion?(user, nil)
                    }
                } else {
                    print("Data is not a user")
                    
                    do {
                        let string = try decoder.decode([String].self, from: data)
                        print("String: \(string)")
                        completion?(nil, error)
                    } catch {
                        print("Caught error: \(error.localizedDescription)")
                        completion?(nil, error)
                    }
                    //                    if let string = try? decoder.decode(String.self, from: data) {
                    //                        print("Data String: \(string)")
                    //                    }
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
     */
    
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
        
        let url = URL(string: "\(baseAddress)/guilds/load")!
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
    
    // Deprecate (loadGuild resolves it)
    static func guildInfo(user:SKNUserPost, completion:((GuildFullContent?, Error?) -> ())?) {
        
        guard let gid = user.serverID else {
            print("Needs Guild ID to continue")
            completion?(nil, nil)
            return
        }
        
        let url = URL(string: "\(baseAddress)/myguildinfo/\(gid)")!
        
        let session = URLSession.shared
        var request = URLRequest(url: url)
        
        request.httpMethod = HTTPMethod.GET.rawValue // (Post): HTTPMethod.POST.rawValue // (Get): HTTPMethod.GET.rawValue
        
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
    
    // Deprecate
    /*
    static func fetchGuilds(player:SKNUserPost?, completion:(([GuildSummary]?, Error?) -> ())?) {
        
//        let url = URL(string: "\(baseAddress)/fetchguilds")!
        let url = URL(string: "\(baseAddress)/guilds/browse")!
        
        let session = URLSession.shared
        var request = URLRequest(url: url)
        
        request.httpMethod = HTTPMethod.GET.rawValue // (Post): HTTPMethod.POST.rawValue // (Get): HTTPMethod.GET.rawValue
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        // Set the playerID if there is one
        if let player = player {
            request.setValue(player.id.uuidString, forHTTPHeaderField: "playerid")
        }
        
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
 */
    
    
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
    
    static func claimCity(user:SKNUserPost, posdex:Posdex, completion:((CityData?, Error?) -> ())?) {
        print("Claiming City")
        
        let url = URL(string: "\(baseAddress)/guilds/city/claim/\(posdex.rawValue)")!
//        let url = URL(string: "\(baseAddress)/claim_city/\(posdex.rawValue)")!
        
        let session = URLSession.shared
        var request = URLRequest(url: url)
        
        request.httpMethod = HTTPMethod.POST.rawValue // (Post): HTTPMethod.POST.rawValue // (Get): HTTPMethod.GET.rawValue
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
//        request.setValue(localPlayer.id.uuidString, forHTTPHeaderField: "playerid")
//        request.setValue(guildName, forHTTPHeaderField: "guildname")
        
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
    
    // MARK: - Space Vehicle
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
    
    // MARK: - Default
    static func getSimpleData(completion:((Data?, Error?) -> ())?) {
        
        print("Getting Simple Data")
        
        let url = URL(string: "\(baseAddress)/users")!
        let session = URLSession.shared
        var request = URLRequest(url: url)
        
        request.httpMethod = HTTPMethod.POST.rawValue // (Post): HTTPMethod.POST.rawValue // (Get): HTTPMethod.GET.rawValue
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let user = SKNUserPost(name: "Farini")
        
        let encoder = JSONEncoder()
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
