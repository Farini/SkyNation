//
//  SideChatController.swift
//  SkyNation
//
//  Created by Carlos Farini on 9/17/21.
//

import SwiftUI

enum GuildElectionState {
    
    /// No election happening
    case noElection
    
    /// Election hasn't started. Will start on 'until'
    case waiting(until:Date)
    
    /// Election is running 'until'
//    case running(until:Date)
    
    /// Election with an Object
    case voting(election:Election)
    
    /// Election Finished. Needs Updating
//    case finished
}

class SideChatController:ObservableObject {
    
    // Tab
    @Published var selectedTab:GameMessageType = GameMessageType.Achievement
    
    // Game Messages
    @Published var gameMessages:[GameMessage] = []
    
    // Player
    @Published var player:SKNPlayer
    @Published var freebiesAvailable:Bool = false
    
    // The Guild
    @Published var guild:GuildFullContent?
    @Published var citizens:[PlayerContent] = []
    
    // Election
    @Published var electionState:GuildElectionState = .noElection
    @Published var electionData:GuildElectionData?
    
    // Guild Chat
    @Published var guildChat:[ChatMessage] = []
    @Published var currentText:String = ""
    
    private var serverManager = ServerManager.shared
    
    init() {
        
        /*
        #if DEBUG
        self.guildChat = GuildChatView_Previews.exampleMessages()
        #else
        if GameSettings.onlineStatus == true {
            self.updateMessages()
        } else {
            self.messages = GuildChatView_Previews.exampleMessages()
        }
        #endif
        */
        
        guard let player = LocalDatabase.shared.player else {
            fatalError("No Player")
        }
        self.player = player
        
        // Game Messages (Achievements)
        let gameMessages = LocalDatabase.shared.gameMessages
        self.gameMessages = gameMessages
        
        // Freebies
        let delta = player.wallet.timeToGenerateNextFreebie()
        if delta > 0 {
            self.freebiesAvailable = false
        } else {
            self.freebiesAvailable = true
        }
        
        if GameSettings.onlineStatus == true {
            
            self.getGuildInfo()
            self.requestChat()
            
        } else {
            self.guildChat = GuildChatView_Previews.exampleMessages()
        }
    }
    
    // MARK: - Control + Updates
    
    func didSelectTab(tab:GameMessageType) {
        self.selectedTab = tab
    }
    
    func getGuildInfo() {
        
        self.serverManager.inquireFullGuild(force: false) { fullGuild, error in
            DispatchQueue.main.async {
                if let fullGuild = fullGuild {
                    self.guild = fullGuild
                    self.citizens = fullGuild.citizens
                    self.updateElectionData()
                    self.requestChat()
                } else {
                    print("Possible error: \(error?.localizedDescription ?? "n/a")")
                }
            }
        }
    }
    
    // MARK: - Chat
    
    /// Posts a message on the Guild Chat
    func postMessage(text:String) {
        
        guard let player = LocalDatabase.shared.player,
              let pid = player.playerID,
              let gid = player.guildID else {
            fatalError()
        }
        
        guard text.count < 150 else {
            print("Text is too large !!!")
            return
        }
        
        let post = ChatPost(guildID: gid, playerID: pid, name: player.name, date: Date(), message: text)
        
        SKNS.postChat(message: post) { newMessages, error in
            
            DispatchQueue.main.async {
                if !newMessages.isEmpty {
                    self.currentText = ""
                }
                self.guildChat = newMessages.sorted(by: { $0.date.compare($1.date) == .orderedAscending })
            }
        }
    }
    
    /// Reads Messages from Guild Chat
    func requestChat() {
        
        guard let player = LocalDatabase.shared.player,
              let pid = player.playerID,
              let gid = player.guildID else {
            return
        }
        
        print("Fetching Guild Chat PID:\(pid)")
        
        SKNS.readChat(guildID: gid) { newMessages, error in
            if newMessages.isEmpty {
                print("Empty Messages")
            } else {
                print("Got Messages: \(newMessages.count)")
                DispatchQueue.main.async {
                    print("Updating \(newMessages.count) messages on screen")
                    self.guildChat = newMessages.sorted(by: { $0.date.compare($1.date) == .orderedAscending }).suffix(20)
                }
            }
        }
    }
    
    /// Keeps track of how many characters user wrote
    func textCount() -> Int {
        return currentText.count
    }
    
    // Others
    
    func iAmPresident() -> Bool {
        
        if let pid = LocalDatabase.shared.player?.playerID,
           let guild = guild {
           return guild.president == pid
        }
        return false
    
    }
    
    func seeFreebies() -> [String] {
        
        
        
        var freebiesMade = player.wallet.freebiesMade
        if freebiesMade.isEmpty {
            freebiesMade = player.wallet.generateFreebie()
        }
        return Array(freebiesMade.keys)
        
    }
    
    func retrieveFreebies() {
        
        var freebiesMade = player.wallet.freebiesMade
        if freebiesMade.isEmpty {
            freebiesMade = player.wallet.generateFreebie()
        }
        
        player.wallet.freebiesLast = Date()
        
        for (key, _) in freebiesMade {
            if key == "token" {
                player.wallet.tokens.append(GameToken(beginner: player.playerID ?? player.localID))
                print("Token added.")
            } else if key == "money" {
                player.money += 1000
                print("Money added")
                
            } else if let tank = TankType(rawValue: key) {
                let station = LocalDatabase.shared.station
                station?.truss.tanks.append(Tank(type: tank, full: true))
                LocalDatabase.shared.saveStation(station: station!)
                print("Tank type \(tank.rawValue) added.")
            }
        }
        
        let r = LocalDatabase.shared.savePlayer(player: player)
        print("Prize added. Save \(r)")
        
        let delta = player.wallet.timeToGenerateNextFreebie()
        if delta > 0 {
            self.freebiesAvailable = false
        } else {
            self.freebiesAvailable = true
        }
        
        self.selectedTab = .Achievement
        self.selectedTab = .Freebie
        
    }
    
    // MARK: - Election
    
//    func updateElectionState() {
//
//        guard let guild = guild else {
//            self.electionState = .noElection
//            return
//        }
//
//        let election:Date = guild.election
//        let electStart = election.addingTimeInterval(60.0 * 60.0 * 24.0 * 7.0)
//        let electEnd = electStart.addingTimeInterval(60.0 * 60.0 * 24.0)
//        let dateNow = Date()
//
//        if dateNow.compare(electStart) == .orderedDescending {
//            // Past election start
//            if dateNow.compare(electEnd) == .orderedDescending {
//                // Past election end
//                self.electionState = .finished
//            } else {
//                // Before Election end
//                self.electionState = .running(until: electEnd)
//            }
//        } else {
//            // Before Election Start
//            self.electionState = .waiting(until: electStart)
//        }
//    }
    
    func updateElectionData() {
        
        print("Should restart election date")
        
        SKNS.upRestartElection { newElection, error in
            DispatchQueue.main.async {
                if let newElection = newElection {
                    print("Got election")
                    // Elections is here
                    self.electionData = newElection
                    switch newElection.electionStage {
                        case .finished:
                            self.electionState = .noElection
                        case .notStarted:
                            self.electionState = .waiting(until: newElection.election.startDate())
                        case .running:
                            self.electionState = .voting(election: newElection.election)
                    }
                    
                } else if let error = error {
                    // Error
                    print("Got error: \(error.localizedDescription)")
                } else {
                    // no error (may be caused because election haven't started
                    print("No election, and no error")
                }
            }
        }
    }
    
    func voteForPresident(citizen:PlayerCard) {
        
        switch self.electionState {
            case .voting(let election):
                guard election.electionHasEnded() == false else {
                    print("Election has ended")
                    return
                }
                print("Voting for \(citizen.name)")
            default:
                print("Can only vote when election is running.")
                return
        }
        
        SKNS.voteOnElection(candidate: citizen) { newElection, error in
            if let election = newElection {
                DispatchQueue.main.async {
                    self.electionState = .voting(election: election)
                }
            }
        }
        
        //updateElectionData()
    }
}
