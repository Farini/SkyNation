//
//  ChatBubbleController.swift
//  SkyNation
//
//  Created by Carlos Farini on 10/1/21.
//

import SwiftUI

enum ChatBubbleTab:String, CaseIterable {
    case Achievement
    case Freebie
    
    case Chat
    case Guild
    case Tutorial
    
    case Search
    
    var emoji:String {
        switch self {
            case .Achievement: return "🏆"
            case .Freebie: return "🎁"
            case .Chat: return "💬"
            case .Guild: return "🔰" // ⚙️
            case .Tutorial: return "🎓"
            case .Search: return "🔎" // 🔎❓
        }
    }
}

enum GuildElectionState {
    
    /// No election happening
    case noElection
    
    /// Election hasn't started. Will start on 'until'
    case waiting(until:Date)
    
    /// Election with an Object
    case voting(election:Election)
}


class ChatBubbleController:ObservableObject {
    
    // Tab
    @Published var selectedTab:ChatBubbleTab = .Achievement
    
    // Game Messages
    @Published var gameMessages:[GameMessage] = []
    
    // Player + Freebies
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
    @Published var chatWarnings:[String] = []
    @Published var currentText:String = ""
    
    init(simulating simChat:Bool, simElection:Bool) {
        
        let player = LocalDatabase.shared.player
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
        
        // Server Info
        if GameSettings.onlineStatus == true {
            if simChat == false {
                self.requestChat()
            } else {
                // Simulate Chat
                self.guildChat = []
            }
            if simElection == false {
                self.getGuildInfo()
            } else {
                print("Simulating Election")
            }
        } else {
            self.guildChat = []
        }
    }
    
    // MARK: - Control + Updates
    
    func didSelectTab(tab:ChatBubbleTab) {
        self.selectedTab = tab
    }
    
    private var serverManager = ServerManager.shared
    
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
    
    // MARK: - Achievements
    
    func updateAchievements() {
        // Game Messages (Achievements)
        let gameMessages = LocalDatabase.shared.gameMessages
        self.gameMessages = gameMessages
    }
    
    // MARK: - Chat
    
    /// Posts a message on the Guild Chat
    func postMessage(text:String) {
        let player = LocalDatabase.shared.player
        guard let pid = player.playerID,
              let gid = player.guildID else {
                  print("No Guild = No Chat")
                  return
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
                } else {
                    self.chatWarnings = ["Could not post previous message"]
                }
                self.guildChat = newMessages.sorted(by: { $0.date.compare($1.date) == .orderedAscending })
            }
        }
    }
    
    /// Reads Messages from Guild Chat
    func requestChat() {
        let player = LocalDatabase.shared.player
        guard let pid = player.playerID,
              let gid = player.guildID else {
                  return
              }
        
        self.chatWarnings = ["Updating messages"]
        
        print("Fetching Guild Chat PID:\(pid)")
        
        SKNS.readChat(guildID: gid) { newMessages, error in
            if newMessages.isEmpty {
                print("Empty Messages")
                self.chatWarnings = ["No messages"]
            } else {
                print("Got Messages: \(newMessages.count)")
                self.chatWarnings = []
                
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
    
    // MARK: - Election
    
    func updateElectionData() {
        
        print("Should restart election date")
        
        SKNS.upRestartElection { newElection, error in
            DispatchQueue.main.async {
                if let newElection:GuildElectionData = newElection {
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
    
    func iAmPresident() -> Bool {
        
        if let pid = LocalDatabase.shared.player.playerID,
           let guild = guild {
            return guild.president == pid
        }
        return false
        
    }
    
    // MARK: - Freebies Tab
    
    func seeFreebies() -> [String] {
        
        var freebiesMade = player.wallet.freebiesMade
        if freebiesMade.isEmpty {
            freebiesMade = player.wallet.generateFreebie()
        }
        
        return Array(freebiesMade.keys)
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
        
        let delta = player.wallet.timeToGenerateNextFreebie()
        if delta > 0 {
            self.freebiesAvailable = false
        } else {
            self.freebiesAvailable = true
        }
        
        self.selectedTab = .Achievement
        self.selectedTab = .Freebie
        
    }
    
    @Published var giftedTokenMessage:String = ""
    func searchGiftedToken() {
        if !giftedTokenMessage.isEmpty { return }
        
        SKNS.requestGiftedToken { gameToken, message in
            if let gameToken = gameToken {
                guard self.player.wallet.tokens.contains(where: { $0.id == gameToken.id }) == false else {
                    print("You already have this token")
                    return
                }
                DispatchQueue.main.async {
                    self.player.wallet.tokens.append(gameToken)
                    self.giftedTokenMessage = "Received Token type \(gameToken.origin)"
                    do {
                        try LocalDatabase.shared.savePlayer(self.player)
                    } catch {
                        print("Error saving gifted token on player.")
                        return
                    }
                }
                
            } else {
                DispatchQueue.main.async {
                    self.giftedTokenMessage = message ?? "Could not find any token gifted to you."
                }
            }
        }
    }
    
    // MARK: - Tutorial
    
    /// Current Tutorial Page
    @Published var tutPage:Int = 0
    
    func updateTutorialPage(page:Int) {
        
    }
    
    // MARK: - Search Tab
    
    /// Players Searched
    @Published var searchPlayerResult:[PlayerContent] = []
    @Published var searchText:String = ""
    
    private var lastSearch:Date?
    
    @Published var tokenMessage:String = ""
    
    func searchPlayerByName() {
        SKNS.searchPlayerByName(name: self.searchText) { playerArray, error in
            self.lastSearch = Date()
            self.searchPlayerResult = playerArray
        }
    }
    
    func giftToken(to playerContent:PlayerContent) {
        
        if let entryToken = player.wallet.tokens.filter({ $0.origin == .Entry && $0.usedDate == nil }).first {
            let newToken = GameToken(donator: player.playerID!, receiver: playerContent.id, playerToken: entryToken)
            SKNS.giftToken(to: playerContent, token: newToken) { givenToken, errorMessage in
                DispatchQueue.main.async {
                    if let givenToken = givenToken {
                        self.tokenMessage = "Token successfully given! Receipt:\(givenToken.id)"
                    } else if let errorMessage = errorMessage {
                        self.tokenMessage = "Error. \(errorMessage)"
                    }
                }
            }
        } else {
            self.tokenMessage = "You have no Entry Tokens to give."
        }
    }
    
    func inviteToGuild(playerContent:PlayerContent) {
        self.tokenMessage = ""
        SKNS.inviteToGuild(player: playerContent) { newPlayerContent, error in
            if let pp = newPlayerContent {
                DispatchQueue.main.async {
                    self.tokenMessage = "Guild invite successfully sent to \(pp.name)"
                }
            } else if let error = error {
                self.tokenMessage = "Error. \(error.localizedDescription)"
            }
        }
    }
}
