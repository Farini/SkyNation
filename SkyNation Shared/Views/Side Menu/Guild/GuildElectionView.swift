//
//  GuildElectionView.swift
//  SkyNation
//
//  Created by Carlos Farini on 11/9/21.
//

import SwiftUI

struct GuildElectionView: View {
    
    @ObservedObject var controller:GuildRoomController
    let voteLimit:Int = 3
    
    var body: some View {
        
        ScrollView {
            VStack {
                
                Text("Guild Election")
                    .font(GameFont.section.makeFont())
                    .padding(.top, 8)
                
                Divider()
                
                if let guild = controller.guild {
                    
                    Text("My Guild: \(guild.name)")
                    Text("Election: \(GameFormatters.fullDateFormatter.string(from: guild.election))")
                    Text("Election State: \(controller.electionState.displayString)")
                    
                    if let eData = controller.electionData {
                        Text("Election Data: \(eData.electionStage.rawValue)")
                    } else {
                        Text("Election Data: none")
                    }
                    
                    if let presidentID = guild.president {
                        Text("President: \(presidentID.uuidString)")
                    } else {
                        
                        // No President
                        Text("No President")
                            .foregroundColor(.red)
                            .padding(4)
                            .background(Color.black.opacity(0.5))
                            .cornerRadius(4)
                    }
                    
                    Group {
                        // Candidates
                        Text("All Candidates").font(.title3).foregroundColor(.orange)
                        Divider()
                        ForEach(controller.citizens, id:\.id) { citizen in
                            HStack {
                                
                                let pCard = PlayerCard(playerContent: citizen)
                                SmallPlayerCardView(pCard: pCard)
                                
                                // Count Votes
                                let voteCount:Int = controller.electionData?.election.voted[citizen.id] ?? 0
                                
                                Text("\(voteCount)")
                                    .font(GameFont.section.makeFont())
                                    .padding(6)
                                    .background(Color.black.opacity(0.5))
                                    .cornerRadius(6)
                                
                                // Vote
                                Button("Vote") {
                                    // Count Remaining Votes
                                    let remainingVotes:Int = voteLimit - controller.castedVotes
                                    print("Remaining Votes: \(remainingVotes)")
                                    
                                    controller.castedVotes += 1
                                    
                                    controller.voteForPresident(citizen: pCard)
                                }
                                .buttonStyle(GameButtonStyle())
                            }
                            
                        }
                    }
                    
                    let remainingVotes:Int = voteLimit - controller.castedVotes
                    Text("Remaining Votes x \(remainingVotes)")
                        .font(GameFont.section.makeFont())
                        .foregroundColor(remainingVotes < 1 ? .red:.orange)
                    
                    Spacer()
                    
                    
                } else {
                    Text("No Guild")
                        .font(.title2)
                        .foregroundColor(.red)
                        .padding(6)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(6)
                }
                
                Spacer()
            }
        }
        
    }
}

struct GuildElectionView_Previews: PreviewProvider {
    static var previews: some View {
        GuildElectionView(controller:GuildRoomController())
    }
}
