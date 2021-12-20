//
//  ChatBubbleGuildTab.swift
//  SkyNation
//
//  Created by Carlos Farini on 10/1/21.
//

import SwiftUI

/*
struct ChatBubbleGuildTab: View {
    
    @ObservedObject var controller:ChatBubbleController
    @State var guild:GuildFullContent
    
    var body: some View {
        VStack {
            
            Group {
                HStack {
                    Image(systemName: guild.icon)
                    Text("\(guild.name)").foregroundColor(.orange)
                }
                .font(.title3)
                Divider()
            }
            
            
            // President
            Text("President")
                .font(.title3)
                .foregroundColor(.orange)
            
            if let presid = guild.president,
               let person = guild.citizens.filter({ $0.id == presid }).first {
                
                SmallPlayerCardView(pCard: person.makePlayerCard())
                
                if controller.iAmPresident() == true {
                    Text("I am president")
                    
                    // Add President Actions here
                    // Guild Modify
                    // Kickout
                }
                
            } else {
                Text("No President").foregroundColor(.gray)
            }
            
            Divider()
                .padding(.horizontal)
            
            // Election
            Text("Election")
                .font(.title3)
                .foregroundColor(.orange)
            
            let electing = guild.election
            Text(GameFormatters.dateFormatter.string(from: electing))
            
            switch controller.electionState {
                case .noElection:
                    Text("It is not time for election.").foregroundColor(.gray)
                case .waiting(let date):
                    Text("Waiting for election")
                    Text("Next Election: \(GameFormatters.fullDateFormatter.string(from: date))")
                    let delta:TimeInterval = date.timeIntervalSince(Date())
                    Text("in \(delta.stringFromTimeInterval())")
                    
                case .voting(let election):
                    GuildElectionsView(controller: controller, election: election)
            }
            
        }
    }
}
*/

/*
struct ChatBubbleGuildTab_Previews: PreviewProvider {
    static var previews: some View {
        ChatBubbleGuildTab(controller: ChatBubbleController(simulating: true, simElection: true), guild: <#GuildFullContent#>)
    }
}
*/

