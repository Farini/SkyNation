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
//    @Published var guild:GuildFullContent?
    @Published var citizens:[PlayerContent] = []
    @Published var president:PlayerContent?
    
    @Published var guildMap:GuildMap?
    
    // Election
    @Published var electionState:GuildElectionState = .noElection
//    @Published var electionData:GuildElectionData?
    @Published var election:Election?
    
    @Published var electionMessage:String? = nil
    
    @Published var castedVotes:Int = 0
    
    // Guild Chat
    @Published var guildChat:[ChatMessage] = []
    @Published var chatWarnings:[String] = []
    @Published var currentText:String = ""
    
    private var serverManager = ServerManager.shared
    @Published var guildFlags:[ServerManager.GuildFlag] = []
    
    init() {
        
        let player = LocalDatabase.shared.player
        self.player = player
        
        // Server Info
        if GameSettings.onlineStatus == true {
            
            self.guildChat = []
            self.requestChat()
            self.getGuildMap(immediate: false)
            
        } else {
            self.guildChat = []
        }
    }
    
    /*
    /// Retrieves Data about Guild
    ///
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
    */
    
    /// Gets the main `GuildMap` object
    func getGuildMap(immediate:Bool) {
        
        print("Getting GuildMap")
        
        // Make sure player has credentials, etc.
        guard player.guildID != nil && player.playerID != nil && player.marsEntryPass().result == true else {
            self.missionErrorMessage = "Could not get Guild map. Invalid Player."
            return
        }
        
        serverManager.requestGuildMap(force:immediate, maxDelay: 10) { gMap, error in
            
            if let map = gMap {
                
                print("\n\n -- Got Map for Guild \(map.name)")
                DispatchQueue.main.async {
                    
                    // President
                    if let pres = map.president {
                        if let presCitizen = map.citizens.first(where: { $0.id == pres}) {
                            self.president = presCitizen
                            print("President: \(presCitizen.name)")
                        } else {
                            print("Could not find GuildMap's president for Guild (\(map.name))")
                        }
                    } else {
                        // no president
                        print("Map has no president ID")
                    }
                    
                    // Guild Map
                    self.guildMap = map
                    
                    // Citizens
                    self.citizens = map.citizens
                    
                    // Mission
                    if let mapMission = map.mission {
                        self.mission = mapMission
                    } else {
                        self.fetchGuildMission()
                    }
                    
                    // Election
                    if let mapElection = map.election {
                        print("Previous Election. Stage: \(mapElection.getStage().rawValue)")
                        self.election = mapElection
                    } else {
                        print("No Previous Election.")
                        self.updateElectionData()
                    }
                    
                    // Flags
                    let guildFlags:[ServerManager.GuildFlag] = self.serverManager.guildFlags
                    if !guildFlags.isEmpty {
                        print("*** Guild Flags (Changes) = \(guildFlags.description)")
                        self.guildFlags = guildFlags
                    }
                }
                
            } else {
                print("no guild map was found")
                
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                } else {
                    print("no error either")
                }
            }
        }
        
//        SKNS.buildGuildMap { guildMap, error in
//            print("\n\n Guild Map...")
//
//            if let map = guildMap {
//                print("Got Map for Guild: \(map.name)")
//                print(map.president?.uuidString ?? "no president")
//
//                DispatchQueue.main.async {
//
//                    // President
//                    if let pres = map.president {
//                        if let presCitizen = map.citizens.first(where: { $0.id == pres}) {
//                            self.president = presCitizen
//                        }
//                    }
//
//                    self.guildMap = map
//                }
//                self.fetchGuildMission()
//
//            } else {
//                print("no guild map was found")
//
//                if let error = error {
//                    print("Error: \(error.localizedDescription)")
//                } else {
//                    print("no error either")
//                }
//            }
//        }
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
    
    /// When president finishes the MArkdown
    func commitMarkdown(markdown:String) {
        
        // remove quotes
        let unquoted = markdown.replacingOccurrences(of: "\"", with: "'")
        print("Unquoted:::\n\(unquoted)")
        
        guard let guildMap = guildMap else {
            return
        }
        
        guildMap.markdown = markdown
        
        
        SKNS.presyfyGuild(guild: guildMap, clearChat: false, player: LocalDatabase.shared.player) { newMap, error in
            
            if let newMap = newMap {
                DispatchQueue.main.async {
                    self.guildMap = newMap
                }
            } else {
                // TODO: - Deal with error
            }
        }
        
    }
    
    // MARK: - Election
    
    func updateElectionData() {
        
        print("\n\n --- Update Election Data")
        let oldElection = self.election
        
        SKNS.upRestartElection { newElection, error in
            DispatchQueue.main.async {
                if let newElection:Election = newElection {
                    print("Got election. Stage: \(newElection.getStage().rawValue)")
                    // Elections is here
                    self.election = newElection
                    switch newElection.getStage() {
                        case .finished:
                            self.electionState = .noElection
                        case .notStarted:
                            self.electionState = .waiting(until: newElection.start)
                        case .running:
                            self.electionState = .voting(election: newElection)
                    }
                    
                    let vtCount = newElection.casted[self.player.playerID ?? UUID(), default:0]
                    self.castedVotes = vtCount
                    
                    if let oldElection = oldElection, oldElection.getStage() != newElection.getStage() {
                        self.getGuildMap(immediate: true)
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
        
        print("Voting for President -> \(citizen.name)")
        
        // Clear UI from previous errors and messages.
        self.electionMessage = ""
        self.missionErrorMessage = ""
        self.tokenMessage = ""
        
        
        if let election = self.election {
            let pid = player.playerID ?? UUID()
            
            if election.getStage() == .notStarted {
                self.electionMessage = "Election hasn't started. Votes won't count."
                return
            }
            
            let voteCount = election.casted[pid, default: 0]
            if voteCount >= 3 {
                self.electionMessage = "Max 3 votes per Guild citizen"
                return
            }
        }
        
        // Post vote and update UI
        SKNS.voteOnElection(candidate: citizen) { newElection, error in
            if let election = newElection {
                DispatchQueue.main.async {
                    self.election = election
                    self.electionState = .voting(election: election)
                    self.electionMessage = "Voted for \(citizen.name)"
                }
            } else {
                if let error = error {
                    DispatchQueue.main.async {
                        self.electionMessage = error.localizedDescription
                    }
                }
            }
        }
    }
    
    /// Simple check if this player is the president
    func iAmPresident() -> Bool {
        if let pid = LocalDatabase.shared.player.playerID,
           let guildMap = guildMap {
            return guildMap.president == pid
        }
        return false
    }
    
    // MARK: - President Functions
    
    func kickout(kicked:PlayerContent) {
        
        print("Kicking player out \(kicked.name)")
        
        guard let gMap = self.guildMap else {
            print("GuildMap couldn't be found. returning.")
            return
        }
        guard let gcity = gMap.cities.first(where: { $0.owner?.values.first == kicked.id }) else {
            print("There is no city. Needs a city to kick out.")
            return
        }
        
        SKNS.kickPlayer(from: gMap, city: gcity, booted: kicked) { success, error in
            if let success = success {
                if success == true {
                    print("Successfully kicked player out. Update all lists")
                    
                    // Soft Update (instead of re-fetching model)
                    
//                    self.getGuildMap(immmediate: true)
                    self.citizens.removeAll(where: { $0.id == kicked.id })
                }
            }
        }
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
    
    private var hasFetchedWhitelist:Bool = false
    
    /// Fetches the Players that are in `invites` or in `joinlist`
    func fetchGuildWhiteList() {
        
        guard let guildMap = guildMap else {
            return
        }
        let expectPlayerCount:Int = guildMap.joinlist.count + guildMap.invites.count
        guard expectPlayerCount > 0 else {
            print("Guild whitelist is empty. Nothing to fetch.")
            return
        }
        // if expectPlayerCount <= searchPlayerResult.count { return }
        if self.hasFetchedWhitelist == true { return }
        
        let fetchedIDs:[UUID] = searchPlayerResult.compactMap({ $0.id })
        
        SKNS.searchGuildsWhitelist { fetchedPlayers, error in
            
            if !fetchedPlayers.isEmpty {
                
                DispatchQueue.main.async {
                    let filtered:[PlayerContent] = fetchedPlayers.filter({ fetchedIDs.contains($0.id) == false })
                    
                    for fPlayer in fetchedPlayers {
                        if self.searchPlayerResult.contains(fPlayer) {
                            // skip
                        } else {
                            self.searchPlayerResult.append(contentsOf: filtered)
                        }
                    }
                    
                    // Stop whitelist from f=refreshing
                    self.hasFetchedWhitelist = true
                }
            } else {
                print("Returned empty array of players.")
            }
        }
    }
    
    // MARK: - Missions Tab
    
    @Published var mission:GuildMission?
    @Published var missionErrorMessage:String?
    
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
        gMission.makeProgress(pid: coopID)
        
        print("Mission status 2: \(gMission.status.rawValue), \(gMission.currentTask)")
        SKNS.cooperateMission(upMission: gMission) { newMission, error in
            
            if let newMission = newMission {
                
                DispatchQueue.main.async {
                    print("new mission...")
                    
                    // got mission
                    self.mission = newMission
                    self.guildMap?.mission = newMission
                    
                    // Check if need to create dboutpost
                    if let dbo:DBOutpost = self.checkNeedsOutpostCreation() {
                        SKNS.createDBOutpost(entry: dbo) { newOutpost, newError in
                            if let newOutpost = newOutpost {
                                DispatchQueue.main.async {
                                    self.guildMap?.outposts.append(newOutpost)
                                }
                            } else {
                                print("No new outpost - \(error?.localizedDescription ?? "n/a")")
                            }
                        }
                    }
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
    
    func checkNeedsOutpostCreation() -> DBOutpost? {
        
        guard let guildMap = guildMap else {
            return nil
        }
        
        var updatingOutpost:DBOutpost?
        
        let unlockedPosdexes = guildMap.mission?.unlockedPosdexes() ?? []
        for unlocked in unlockedPosdexes {
            if let dbo = guildMap.outposts.first(where: { $0.posdex == unlocked.rawValue }) {
                // already has this outpost
                print("Already has outpost: \(dbo.posdex) \(dbo.type) Lvl \(dbo.level)")
            } else {
                // needs to create
                var opType:OutpostType?
                switch unlocked {
                    case .hq:
                        opType = .HQ
                    case .antenna:
                        opType = .Antenna
                    case .arena:
                        opType = .Arena
                    case .biosphere1, .biosphere2:
                        opType = .Biosphere
                    case .launchPad:
                        opType = .Launchpad
                    case .mining1:
                        opType = .Water
                    case .mining2:
                        opType = .Silica
                    case .mining3:
                        opType = .Titanium
                    case .observatory:
                        opType = .Observatory
                    case .power1, .power2, .power3, .power4:
                        opType = .Energy
                    case .hotel:
                        opType = .HQ
                    default: break
                }
                if let opType = opType {
                    let newOP = DBOutpost(gid: guildMap.id, type: opType, posdex: unlocked)
                    updatingOutpost = newOP
                }
            }
        }
        
        return updatingOutpost
    }
}
