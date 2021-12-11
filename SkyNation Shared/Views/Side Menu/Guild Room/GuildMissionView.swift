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
                
                // Mission Title, and total missions
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
                
                // Mission Status View
                HStack(alignment:.top) {
                    
                    HStack(spacing:12) {
                        Image(systemName:imageNameForMissionStatus())
                            .font(.largeTitle)
                        Divider()
                            .frame(height:30)
                        VStack(alignment:.leading) {
                            
                            let page = mission.pageOf()
                            HStack {
                                Text("Task \(page.page + 1) of \(page.total + 1)").foregroundColor(.orange)
                                Spacer()
                            }
                            
                            switch mission.status {
                                case .notStarted:
                                    Text("not started").foregroundColor(.red)
                                    Text("press start")
                                case .running:
                                    Text("running").foregroundColor(.green)
                                    let dVal:Double = (1 - progress) * 100.0
                                    let dStr:String = String(format: "%.2f", dVal) + "%"
                                    ProgressView("Progress \(dStr)", value: max(0, min(1.0, (dVal / 100.0))))
                                        .frame(width:200)
                                case .finished:
                                    Text("finished").foregroundColor(.orange)
                                    let dVal:Double = (1 - progress) * 100.0
                                    let dStr:String = String(format: "%.2f", dVal) + "%"
                                    ProgressView("Progress \(dStr)", value: max(0, min(1.0, (dVal / 100.0))))
                                        .frame(width:200)
                            }
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
            
            
            // Status
            Text("Status: \(mission.status.displayString)")
                .padding(.top)
            
            // Error
            if let message = controller.missionErrorMessage {
                Text(message).foregroundColor(.red)
            }
            
            // Buttons
            switch mission.status {
                case .notStarted:
                    Button("Start") {
                        print("Start Mission \(mission.mission.missionTitle)")
                        controller.cooperateMission(gMission: mission)
                        print("Going to Autolopp in 2 seconds...")
                        self.progress = 0.0
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            print("Autoloop now")
                            self.autoLoop()
                        }
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
                    .transition(.move(edge: .leading).combined(with: .opacity))
                    
                    if mission.workers.contains(where: { $0 == LocalDatabase.shared.player.playerID ?? UUID() }) {
                        // Already Cooperating. Token Button?
                        Button("Token") {
                            controller.cooperateMission(gMission: mission, token: true)
                            print("Token")
                            print("add token to workers")
                        }
                        .buttonStyle(GameButtonStyle())
                        .transition(.move(edge: .leading).combined(with: .opacity))
                        
                    } else {
                        Button("Cooperate") {
                            controller.cooperateMission(gMission: mission)
                            print("Cooperate")
                            print("Add my ID to workers")
                        }
                        .buttonStyle(GameButtonStyle())
                        .transition(.move(edge: .leading).combined(with: .opacity))
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
    
    func imageNameForMissionStatus() -> String {
        switch mission.status {
            case .notStarted: return "hourglass"
            case .finished: return "clock.arrow.circlepath"
            case .running: return "clock.badge.exclamationmark"
        }
    }
    
    /// Updates the timing of the view
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
