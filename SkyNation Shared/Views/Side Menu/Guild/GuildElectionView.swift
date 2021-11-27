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
                
                if let guild:GuildFullContent = controller.guild {
                    
                    // 2 Columns: Election Info vs Candidates
                    HStack(alignment:.top) {
                        // Election Info
                        VStack(alignment:.leading) {
                            Text("Election").font(GameFont.section.makeFont()).foregroundColor(.orange)
                            Divider()
                            
                            // Text("My Guild: \(guild.name)")
                            // Text("Election: \(GameFormatters.fullDateFormatter.string(from: guild.election))")
                            // Text("Election State: \(controller.electionState.displayString)")
                            
                            if let eData:GuildElectionData = controller.electionData {
                                
                                Text("Election: \(eData.electionStage.rawValue)")
                                
                                Text("Start: \(GameFormatters.dateFormatter.string(from:eData.election.startDate()))")
                                Text("Ending: \(GameFormatters.dateFormatter.string(from:eData.election.endDate()))")
                                
                                let elProg:Double = eData.progress()
                                let stProg:String = "\(GameFormatters.numberFormatter.string(from: NSNumber(value: eData.progress() * 100.0)) ?? "") %"
                                
                                ProgressView(stProg, value:elProg)
                                    .frame(width:200)
                                
                            } else {
                                Text("Election Data: none")
                            }
                            
                            
                            // President
//                            if let presidentID = controller.president {
                                // Crown and Name
                                if let presidentContent = controller.president {
                                    Label(presidentContent.name, systemImage:"crown.fill")
                                        .foregroundColor(.red)
                                        .padding(4)
                                        .background(Color.black.opacity(0.5))
                                        .cornerRadius(4)
                                    
                                } else {
                                    // Unknown President
//                                    Text("President: \(presidentID.uuidString)")
//                                        .foregroundColor(.red)
//                                        .padding(4)
//                                        .background(Color.black.opacity(0.5))
//                                        .cornerRadius(4)
                                    
                                    // No President
                                    Text("No President")
                                        .foregroundColor(.red)
                                        .padding(4)
                                        .background(Color.black.opacity(0.5))
                                        .cornerRadius(4)
                                }
                                
                                
//                            } else {
//
//
//                            }
                        }
                        .padding(.horizontal, 8)
                        .frame(minWidth:220)
                        
                        Divider()
                        
                        // Candidates
                        VStack(alignment:.leading) {
                            Group {
                                // Candidates
                                Text("Candidates").font(GameFont.section.makeFont()).foregroundColor(.orange)
                                Divider()
                                ForEach(controller.citizens, id:\.id) { citizen in
                                    HStack {
                                        
                                        let pCard = PlayerCard(playerContent: citizen)
                                        if citizen == controller.president {
                                            
                                            // President gets a crown on top
                                            ZStack(alignment:.topLeading) {
                                                SmallPlayerCardView(pCard: pCard)
                                                Image(systemName:"crown.fill").font(.title).foregroundColor(.orange)
                                            }
                                            
                                        } else {
                                            
                                            // Ordinary Citizen
                                            SmallPlayerCardView(pCard: pCard)
                                        }
                                        
                                        
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
                        }
                    }
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
