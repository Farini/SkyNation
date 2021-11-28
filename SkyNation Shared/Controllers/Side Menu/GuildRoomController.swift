//
//  GuildRoomController.swift
//  SkyNation
//
//  Created by Carlos Farini on 11/8/21.
//

import Foundation
import SwiftUI

class GuildRoomController:ObservableObject {
    
    @Published var player:SKNPlayer
    
    // The Guild
    @Published var guild:GuildFullContent?
    @Published var citizens:[PlayerContent] = []
    @Published var president:PlayerContent?
    
    @Published var guildMap:GuildMap?
    
    // Election
    @Published var electionState:GuildElectionState = .noElection
    @Published var electionData:GuildElectionData?
    
    @Published var castedVotes:Int = 0
    
    // Guild Chat
    @Published var guildChat:[ChatMessage] = []
    @Published var chatWarnings:[String] = []
    @Published var currentText:String = ""
    
    private var serverManager = ServerManager.shared
    
    init() {
        
        let player = LocalDatabase.shared.player
        self.player = player
        
        // Server Info
        if GameSettings.onlineStatus == true {
            
//            self.requestChat()
            self.getGuildInfo()
            self.getGuildMap()
            
        } else {
            self.guildChat = []
        }
    }
    
    /// Retrieves Data about Guild
    func getGuildInfo() {
        
        self.serverManager.inquireFullGuild(force: false) { fullGuild, error in
            DispatchQueue.main.async {
                
                if let fullGuild = fullGuild {
                    
                    withAnimation() {
                        self.guild = fullGuild
                    }
                    
                    self.citizens = fullGuild.citizens
                    
                    self.updateElectionData()
                    // self.requestChat()
                    
                } else {
                    print("Possible error: \(error?.localizedDescription ?? "n/a")")
                }
            }
        }
    }
    
    // NEW - GuildMap
    func getGuildMap() {
        
        SKNS.buildGuildMap { guildMap, error in
            print("\n\n Guild Map...")
            
            if let map = guildMap {
                print("Got Map for Guild: \(map.name)")
                print(map.president?.uuidString ?? "no president")
                
                DispatchQueue.main.async {
                    
                    // President
                    if let pres = map.president {
                        if let presCitizen = map.citizens.first(where: { $0.id == pres}) {
                            self.president = presCitizen
                        }
                    }
                    
                    self.guildMap = map
                }
                self.fetchGuildMission()
                
            } else {
                print("no guild map was found")
                
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                } else {
                    print("no error either")
                }
            }
        }
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
                self.currentText = ""
                self.requestChat()
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
        
        print("Update Election Data")
        
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
                    
                    let vtCount = newElection.election.casted[self.player.playerID ?? UUID(), default:0]
                    self.castedVotes = vtCount
                    
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
        
        print("Voting for President -> \(citizen.name)")
        
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
    
    // MARK: - Missions Tab
    
    @Published var mission:GuildMission?
    @Published var missionErrorMessage:String?
    
    
    // Actions:
    // Start Mission
    // Cooperate
    // Use Token
    // Finish
    
    // Server Updates
    
    // Fetch Guild Mission
    // Look for Guild Mission. Creates if doesn't exist in server.
    func fetchGuildMission() {
        
        SKNS.fetchMission { gMission, error in
            DispatchQueue.main.async {
                if let gMission = gMission {
                    // got mission
                    print("Fetched mission")
                    self.mission = gMission
                    self.guildMap?.mission = gMission
                    
                } else if let error = error {
                    // deal with error
                    print("Error: \(error.localizedDescription)")
                    self.missionErrorMessage = error.localizedDescription
                }
            }
        }
    }
    
    // Update request (Finish)
    // post request with GuildMission
    // on a request to update, it must be one of these cases:
    // next (task) vs (task + 1),
    // next (missionNumber) vs (missionNumber + 1)
    //
    
    func finishMission(gMission:GuildMission) {
        gMission.workers = []
        
        SKNS.finishMission(upMission: gMission) { newMission, error in
            DispatchQueue.main.async {
                if let newMission = newMission {
                    print("new mission...")
                    // got mission
                    self.mission = newMission
                } else if let error = error {
                    // deal with error
                    self.missionErrorMessage = error.localizedDescription
                }
            }
        }
        
    }
    
    // Cooperate request (Start, Cooperate, or TokenPayment)
    // post request with GuildMission
    // count workers as a Set (eliminate duplicates)
    // (workers.count) must be workers.count + 1
    //
    
    func cooperateMission(gMission:GuildMission, token:Bool = false) {
        
        guard let pid = player.playerID else { return }
        var coopID:UUID = pid
        
        if token == true {
            // charge token first
            if let token = player.requestToken() {
                let result = player.spendToken(token: token, save: true)
                if result == true {
                    coopID = token.id
                }
            } else {
                self.missionErrorMessage = "Not enough tokens"
                return
            }
        } else {
            // make sure player id is not there already. if it is, must charge token
            guard gMission.workers.contains(coopID) == false else {
                self.missionErrorMessage = "Already worked here."
                return
            }
        }
        
        print("Mission status 1: \(gMission.status.rawValue), \(gMission.currentTask)")
        
        gMission.startWorking(pid: coopID)
        print("Mission status 2: \(gMission.status.rawValue), \(gMission.currentTask)")
        
        SKNS.cooperateMission(upMission: gMission) { newMission, error in
            
                if let newMission = newMission {
                    
                    DispatchQueue.main.async {
                        print("new mission...")
                        // got mission
                        self.mission = newMission
                        self.guildMap?.mission = newMission
                    }
                } else if let error = error {
                        DispatchQueue.main.async {
                            // deal with error
                            print("Error: \(error.localizedDescription)")
                            self.missionErrorMessage = error.localizedDescription
                    
                }
            }
        }
    }
}
