//
//  GuildMissionView.swift
//  SkyNation
//
//  Created by Carlos Farini on 11/26/21.
//

import SwiftUI

struct GuildMissionView: View {
    
    @State var mission:GuildMission = GuildMission()
    @State var progress:Double = 0
    
    var body: some View {
        VStack {
            
            Text("Guild Mission").font(GameFont.section.makeFont())
                .padding(.top)
            
            Divider()
            
            VStack {
                Text("Title")
                Text(mission.mission.missionTitle)
                Text("Statement")
                Text(mission.mission.missionStatement)
                
                Text("Timing: \(mission.mission.timing)")
                Text("Progress: \(progress)")
            }
            .padding(.top)
            
            VStack {
                Text("Dates")
                HStack(spacing:8) {
                    Text("Start")
                    Text(GameFormatters.dateFormatter.string(from: mission.start))
                }
                HStack(spacing:8) {
                    Text("Finish")
                    Text(GameFormatters.dateFormatter.string(from: mission.calculatedEnding()))
                }
            }
            .padding(.top)
            
            Text("Status: \(mission.status.rawValue)")
                .padding(.top)
            
            Spacer()
        }
        .onAppear(perform: autoLoop)
    }
    
    func autoLoop() {
        
        let start = mission.start
        let ends = mission.calculatedEnding()
        
        let totalDelta = ends.timeIntervalSince(start)
        let nowDelta = ends.timeIntervalSinceNow
        
        self.progress = nowDelta / totalDelta
        if self.progress > 0 && self.progress < 1 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                autoLoop()
            }
        }
    }
    
    
}

struct GuildMissionView_Previews: PreviewProvider {
    static var previews: some View {
        GuildMissionView()
    }
}
