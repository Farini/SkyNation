//
//  GuildElection.swift
//  SkyNation
//
//  Created by Carlos Farini on 12/12/21.
//

import Foundation

/// Object used to elect a president and vote
struct Election:Codable {
    
    var id: UUID?
    
    var guild:[String:UUID?]
    
    // Vote Count
    
    /// Citizen x votes casted
    var casted:[UUID:Int]
    
    /// Citizen x votes received
    var voted:[UUID:Int]
    
    var createdAt:Date?
    
    var start:Date
    
    /// The date election should start
//    func startDate() -> Date {
//        let prestart = self.createdAt ?? Date.distantPast
//        let realStart = prestart.addingTimeInterval(60.0 * 60.0 * 24.0 * 7)
//        return realStart
//    }
    
    func endDate() -> Date {
        return self.start.addingTimeInterval(60.0 * 60.0 * 24.0)
    }
    
    func electionHasEnded() -> Bool {
        let electionStarts = self.start //self.startDate()
        let electionEnds = electionStarts.addingTimeInterval(60.0 * 60.0 * 24.0)
        return Date().compare(electionEnds) != .orderedAscending
    }
    
    /// Election progress comparing start, end and now.
    func progress() -> Double {
        
        let start = start
        let finish = endDate()
        let dateNow = Date()
        
        if dateNow.compare(start) == .orderedAscending {
            return 0
        } else {
            if dateNow.compare(finish) == .orderedAscending {
                let totalInterval = finish.timeIntervalSince(start)
                let partInterval = dateNow.timeIntervalSince(start)
                return partInterval / totalInterval
            } else {
                return 1.0
            }
        }
    }
    
    func getStage() -> GuildEventStage {
        
        let finish = self.endDate()
        let dateNow = Date()
        if dateNow.compare(start) == .orderedAscending {
            return .notStarted
        } else if dateNow.compare(finish) == .orderedAscending {
            return .running
        } else {
            return .finished
        }
    }
    
    
    // Voting Functions
    //    func vote(from:UUID, to:UUID, token:GameToken?) -> Bool {
    //
    //        let dateNow = Date()
    //        if dateNow.compare(startDate()) == .orderedDescending && dateNow.compare(endDate()) == .orderedAscending {
    //
    //            let playerVoteCount = self.casted[from, default:0]
    //
    //            var canVote:Bool = false
    //
    //            if playerVoteCount >= 3 {
    //                if let token = token,
    //                   token.usedDate == nil {
    //                    canVote = true
    //                }
    //            } else {
    //                canVote = true
    //            }
    //
    //            if canVote == true {
    //
    //                // Do the voting
    //                self.casted[from, default:0] += 1
    //                self.voted[to, default:0] += 1
    //            }
    //
    //            return canVote
    //
    //        } else {
    //            // Not a good date
    //            return false
    //        }
    //    }
    
    //    func calculateVictory() -> UUID? {
    //
    //        var winner:UUID?
    //        var maxVotes:Int = 0
    //
    //        for (key, value) in self.voted {
    //            if value > maxVotes {
    //                winner = key
    //            }
    //        }
    //
    //        if let winner = winner,
    //           guild.citizens.contains(winner) {
    //            return winner
    //        } else {
    //            return nil
    //        }
    //    }
    
    
}

/// Any event that has a start, runnins, and finished status. Mostly used by GuildMissions and GuildElections
enum GuildEventStage:String, Codable, CaseIterable {
    
    /// Election hasn't started.
    case notStarted
    
    /// Election is running 'until'
    case running
    
    /// Election Finished. Needs Updating
    case finished
    
    /// A String to be displayed on UI about this status
    var displayString:String {
        switch self {
            case .notStarted: return "not started"
            default: return self.rawValue
        }
    }
    
}

/*
/// Contains president(PlayerContent), `Election` object and `GuildEventStage` of the election.
struct GuildElectionData:Codable {
    
    var president:PlayerContent?
    
    /// ID of the president (now governor)
    var governor:UUID?
    
    var election:Election
    var electionStage:GuildEventStage
    
    /// Election progress comparing start, end and now.
    func progress() -> Double {
        
        let start = election.startDate()
        let finish = election.endDate()
        let dateNow = Date()
        
        if dateNow.compare(start) == .orderedAscending {
            return 0
        } else {
            if dateNow.compare(finish) == .orderedAscending {
                let totalInterval = finish.timeIntervalSince(start)
                let partInterval = dateNow.timeIntervalSince(start)
                return partInterval / totalInterval
            } else {
                return 1.0
            }
        }
    }
}
*/

