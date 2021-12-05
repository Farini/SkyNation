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
            
            VStack(alignment:.leading) {
                
                // Mission Title
                HStack {
                    Text(mission.mission.missionTitle)
                        .font(GameFont.section.makeFont())
                        .foregroundColor(.blue)
                    
                    Spacer()
                    Text("\(MissionNumber.allCases.count) total missions")
                        .font(GameFont.section.makeFont())
                        .foregroundColor(.gray)
                }
                .padding(.bottom, 6)
                
                
                // Images:
                // deskclock
                // stopwatch
                // clock.badge.exclamationmark (v3.0)
                // clock.arrow.circlepath (v2.0)
                // hourglass
                HStack(alignment:.top) {
                    HStack(spacing:12) {
                        Image(systemName:"clock.badge.exclamationmark")
                            .font(.largeTitle)
                        Divider()
                            .frame(height:30)
                        VStack(alignment:.leading) {
                            Text("Timing: \(Double(mission.mission.timing).stringFromTimeInterval())")
                            
                            let dVal:Double = (1 - progress) * 100.0
                            let dStr:String = String(format: "%.2f", dVal) + "%"
                            //                        Text(dStr)
                            ProgressView("Progress \(dStr)", value: max(0, min(1.0, (dVal / 100.0))))
                                .frame(width:200)
                            // Text(Double(1.0 - progress), format: "%.2d") //Text("Progress: \(progress)")
                        }
                    }
                    .padding(8)
                    .background(Color.black)
                    .cornerRadius(8)
                    
                    VStack(alignment:.leading) {
                        Text("Info").foregroundColor(.orange)
                        Text(mission.mission.missionStatement).foregroundColor(.gray)
                    }
                    
                    
                }
                
                
                let page = mission.pageOf()
                Text("Task \(page.page + 1) of \(page.total + 1)").foregroundColor(.orange)
                
                HStack {
                    // Citizens (colored by participation)
                    ForEach(controller.citizens) { citizen in
                        if mission.workers.contains(citizen.id) {
                            Text(citizen.name).foregroundColor(.blue)
                        } else {
                            Text(citizen.name).foregroundColor(.gray)
                        }
                    }
                    // Extra Tokens Spent?
                    let citizensIDs:[UUID] = controller.citizens.compactMap({ $0.id })
                    // The tokens (not citizens)
                    let pTokens:[UUID] = mission.workers.filter({ citizensIDs.contains($0) == false })
                    ForEach(pTokens, id:\.self) { _ in
                        Text("🪙")
                    }
                        
                }
                
                
                Divider()
                
                
                
            }
            .padding([.top, .horizontal])
            
            
            
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
                    .buttonStyle(GameButtonStyle())
                case .running:
                    
                    VStack {
                        // Text("Dates")
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
                    
                    if mission.workers.contains(where: { $0 == LocalDatabase.shared.player.playerID ?? UUID() }) {
                        // Already Cooperating. Token Button?
                        Button("Token") {
                            controller.cooperateMission(gMission: mission, token: true)
                            print("Token")
                            print("add token to workers")
                        }
                        .buttonStyle(GameButtonStyle())
                    } else {
                        Button("Cooperate") {
                            controller.cooperateMission(gMission: mission)
                            print("Cooperate")
                            print("Add my ID to workers")
                        }
                        .buttonStyle(GameButtonStyle())
                    }
                    
                case .finished:
                    
                    VStack {
                        // Text("Dates")
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
                    
                    Button("Finish") {
                        print("Register end of work - End mission, get next mission = '.notStarted'")
                        controller.finishMission(gMission: mission)
                        
                    }
                    .buttonStyle(GameButtonStyle())
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
