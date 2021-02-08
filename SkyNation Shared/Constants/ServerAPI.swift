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
    
    static func login(completion:((Data?, Error?) -> ())?) {
        
        let url = URL(string: baseAddress)!
        let session = URLSession.shared
        var request = URLRequest(url: url)
        
        // Post
        request.httpMethod = HTTPMethod.GET.rawValue
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                DispatchQueue.main.async {
                    completion?(data, nil)
                }
                
            } else if let error = error {
                DispatchQueue.main.async {
                    completion?(nil, error)
                }
            }
        }
        task.resume()
        
    }
    
    static func newLogin(user:SKNUser, completion:((SKNUser?, Error?) -> ())?) {
        
        print("New Login")
        
        if let guild = user.guildID {
            // user already has guild
            print("* Guild \(guild)")
        } else {
            // user doesn't have a guild
            print("no guild")
        }
        
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
                if let responseUser = try? decoder.decode(SKNUser.self, from: data) {
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
    
    static func findMyGuild(user:SKNUser, completion:((Guild?, Error?) -> ())?) {
        
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
    
    static func getSimpleData(completion:((Data?, Error?) -> ())?) {
        
        print("Getting Simple Data")
        
        let url = URL(string: "\(baseAddress)/users")!
        let session = URLSession.shared
        var request = URLRequest(url: url)
        
        request.httpMethod = HTTPMethod.POST.rawValue // (Post): HTTPMethod.POST.rawValue // (Get): HTTPMethod.GET.rawValue
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let user = SKNUser(name: "Farini")
        
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
    
    static func fetchGuilds(player:SKNUser?, completion:(([Guild]?, Error?) -> ())?) {
        
        let url = URL(string: "\(baseAddress)/fetchguilds")! // "\(baseAddress)/fetchguilds" // "\(baseAddress)/create/guild/test"
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
                    let guilds:[Guild] = try decoder.decode([Guild].self, from: data)
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
//                if let guilds:[Guild] = try? decoder.decode([Guild].self, from: data) {
//
//                } else {
//
//                }
                
                
            } else if let error = error {
                print("Error returning")
                DispatchQueue.main.async {
                    completion?(nil, error)
                }
            }
        }
        task.resume()
    }
    
    static func createGuild(localPlayer:SKNUser, guildName:String, completion:((Data?, Error?) -> ())?) {
        
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
    
    static func createPlayer(localPlayer:SKNUser, completion:((Data?, Error?) -> ())?) {
        
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
    
    static func fetchPlayer(id:UUID, completion:((SKNUser?, Error?) -> ())?) {
        
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
                if let user = try? decoder.decode([SKNUser].self, from: data).first {
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
    
    // Example Pulled from TradeTycoon
//    static func getData(address:String, data:Data? = nil, completion: ((Error?, Data?) -> ())?) {
//
//        let config = URLSessionConfiguration.default
//        config.requestCachePolicy = .reloadIgnoringLocalCacheData
//        let session = URLSession(configuration: config)
//
//        let urlString = address
//
//        guard let url = URL(string: urlString) else {
//            NSLog("INVALID URL: \(urlString)")
//            completion?(NSError(domain: "local", code: 500, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]), nil)
//            return
//        }
//
//        let request = NSMutableURLRequest(url: url)
//        request.httpMethod = data != nil ? "POST":"GET"
//
//        print("Method \(request.httpMethod)")
//
//        if let data = data {
//            request.httpBody = data
//        }
//
//        let task = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
//
//            if let data = data {
//                DispatchQueue.main.async(execute: {
//                    completion?(error, data)
//                })
//            }else{
//                DispatchQueue.main.async(execute: {
//                    completion?(error, nil)
//                })
//            }
//
//        })
//        task.resume()
//
//    }
}
