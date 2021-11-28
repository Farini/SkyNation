//
//  GuildMissionView.swift
//  SkyNation
//
//  Created by Carlos Farini on 11/26/21.
//

import SwiftUI

struct GuildMissionView: View {
    
    @ObservedObject var controller:GuildRoomController
    @State var mission:GuildMission
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
                    Text(GameFormatters.dateFormatter.string(from: mission.calculatedEnding() ?? Date.distantFuture))
                }
            }
            .padding(.top)
            
            Text("Status: \(mission.status.rawValue)")
                .padding(.top)
            
            if let message = controller.missionErrorMessage {
                Text(message).foregroundColor(.red)
            }
            
            switch mission.status {
                case .notStarted:
                    Button("Start") {
                        print("Start")
                        print("Register start of task")
                        print("add token to workers")
                        controller.cooperateMission(gMission: mission)
                    }
                case .running:
                    
                    if mission.workers.contains(where: { $0 == LocalDatabase.shared.player.playerID ?? UUID() }) {
                        // Already Cooperating. Token Button?
                        Button("Token") {
                            controller.cooperateMission(gMission: mission, token: true)
                            print("Token")
                            print("add token to workers")
                        }
                    } else {
                        Button("Cooperate") {
                            controller.cooperateMission(gMission: mission)
                            print("Cooperate")
                            print("Add my ID to workers")
                        }
                    }
                    
                case .finished:
                    Button("Finish") {
                        print("Register end of work - End mission, get next mission = '.notStarted'")
                        controller.finishMission(gMission: mission)
                        
                    }
            }
            
            Spacer()
        }
        .onAppear(perform: autoLoop)
    }
    
    func autoLoop() {
        
        let start = mission.start
        if let ends = mission.calculatedEnding() {
            let totalDelta = ends.timeIntervalSince(start)
            let nowDelta = ends.timeIntervalSinceNow
            
            self.progress = nowDelta / totalDelta
            if self.progress > 0 && self.progress < 1 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    autoLoop()
                }
            } else if self.progress < 0 {
                mission.renew()
            }
        } else {
            // no ending in sight (.notStarted)
            print("Stopping autoloop, because task was not started.")
            return
        }
    }
    
    
}

struct GuildMissionView_Previews: PreviewProvider {
    static var previews: some View {
        GuildMissionView(controller: GuildRoomController(), mission: GuildMission())
    }
}
