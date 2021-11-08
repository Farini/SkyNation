//
//  GameRoomController.swift
//  SkyNation
//
//  Created by Carlos Farini on 11/7/21.
//

import Foundation
import SwiftUI

class GameRoomController:ObservableObject {
    
    @Published var player:SKNPlayer
    
    /// Achievements the player has made
    @Published var achievements:[GameMessage]
    
    /// Whether freebies are available
    @Published var freebiesAvailable:Bool
    @Published var freebiesArray:[String] = []
    
    init() {
        self.player = LocalDatabase.shared.player
        self.achievements = []
        
        self.freebiesAvailable = false
        
        self.updateMessages()
        self.updateFreebiesInfo()
    }
    
    // MARK: - Messages & Achievements
    
    func updateMessages() {
        let allGameMessages:[GameMessage] = LocalDatabase.shared.gameMessages
        let achievementMessages = allGameMessages.filter({$0.type == .Achievement })
        self.achievements = Array(achievementMessages.sorted(by: { $0.date.compare($1.date) == .orderedDescending}).prefix(100))
    }
    
    func collectRewardFrom(message:GameMessage) {
        
        var allGameMessages = LocalDatabase.shared.gameMessages
        guard let messageIndex = allGameMessages.firstIndex(where: { $0.id == message.id }) else {
            fatalError("invalid id")
        }
        
        var newMessage = message
        newMessage.collectReward()
        allGameMessages[messageIndex] = newMessage
        
        do {
            try LocalDatabase.shared.saveMessages(messages: allGameMessages)
            print("Success")
            self.updateMessages()
            
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Freebies
    
    func updateFreebiesInfo() {
        var freebiesMade = player.wallet.freebiesMade
        if freebiesMade.isEmpty {
            freebiesMade = player.wallet.generateFreebie()
        }
        
        let fArray = Array(freebiesMade.keys)
        self.freebiesArray = fArray
        
        // Freebies
        let delta = player.wallet.timeToGenerateNextFreebie()
        if delta > 0 {
            self.freebiesAvailable = false
        } else {
            self.freebiesAvailable = true
        }
    }
    
    func retrieveFreebies(using tokens:Bool? = false) {
        
        if tokens == true {
            if let token = player.requestToken() {
                print("Using token: \(token.id)")
                let res = player.spendToken(token: token, save: false)
                if res == false { return }
            } else {
                print("Not enough tokens")
                return
            }
        }
        
        var freebiesMade = player.wallet.freebiesMade
        if freebiesMade.isEmpty {
            freebiesMade = player.wallet.generateFreebie()
        }
        
        player.wallet.freebiesLast = Date()
        let next = player.wallet.generateFreebie() // sets the new freebies made
        print("Next freebie: \(next)")
        
        
        for (key, _) in freebiesMade {
            if key == "token" {
                player.wallet.tokens.append(GameToken(beginner: player.playerID ?? player.localID))
                print("Token added.")
            } else if key == "money" {
                player.money += 1000
                print("Money added")
                
            } else if let tank = TankType(rawValue: key) {
                let station = LocalDatabase.shared.station
                station.truss.tanks.append(Tank(type: tank, full: true))
                // Save
                do {
                    try LocalDatabase.shared.saveStation(station)
                } catch {
                    print("‼️ Could not save station.: \(error.localizedDescription)")
                }
            }
        }
        
        // Save
        do {
            try LocalDatabase.shared.savePlayer(player)
        } catch {
            print("‼️ Could not save station.: \(error.localizedDescription)")
        }
        
        self.updateFreebiesInfo()
        
//        let delta = player.wallet.timeToGenerateNextFreebie()
//        if delta > 0 {
//            self.freebiesAvailable = false
//        } else {
//            self.freebiesAvailable = true
//        }
        
        
    }
    
    
}
