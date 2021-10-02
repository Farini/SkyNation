//
//  GuildElectionsView.swift
//  SkyNation
//
//  Created by Carlos Farini on 10/1/21.
//

import SwiftUI

struct GuildElectionsView:View {
    
    @ObservedObject var controller:ChatBubbleController
    var playerVotePairs:[PlayerNumKeyPair] = []
    private var castedVotes:Int
    
    init(controller:ChatBubbleController, election:Election) {
        self.controller = controller
        
        var votePairs:[PlayerNumKeyPair] = []
        for(pid, score) in election.voted {
            if let newPair = PlayerNumKeyPair.makeFrom(id: pid, votes: score) {
                votePairs.append(newPair)
            }
        }
        self.playerVotePairs = votePairs.sorted(by: { $0.votes > $1.votes })
        
        let myPid = LocalDatabase.shared.player.playerID ?? UUID()
        let vtCount = election.casted[myPid, default:0]
        self.castedVotes = vtCount
        
        
    }
    
    var body: some View {
        VStack {
            
            let voteLimit:Int = 3
            let remainingVotes = voteLimit - castedVotes
            
            // Votes
            Text("Votes").font(.title3).foregroundColor(.orange)
            ForEach(playerVotePairs, id:\.player.id) { votePair in
                let pCard = votePair.player
                HStack {
                    SmallPlayerCardView(pCard: pCard)
                    Text("\(votePair.votes)")
                        .font(.title2)
                        .padding(4)
                        .background(Color.black.opacity(0.5))
                }
                .onTapGesture {
                    if remainingVotes > 0 {
                        controller.voteForPresident(citizen: votePair.player)
                    } else {
                        
                    }
                }
            }
            
            Divider()
            
            // Candidates
            Text("All Candidates").font(.title3).foregroundColor(.orange)
            ForEach(controller.citizens, id:\.id) { citizen in
                let pCard = PlayerCard(playerContent: citizen)
                SmallPlayerCardView(pCard: pCard)
                    .onTapGesture {
                        if remainingVotes > 0 {
                            controller.voteForPresident(citizen: pCard)
                        } else {
                            
                        }
                    }
            }
            
            Divider()
            
            Text("You've voted \(castedVotes) times. Remaining votes \(remainingVotes)")
            
            // Casts
            // Creation
            // Date Ends (timer)
        }
    }
    
}
