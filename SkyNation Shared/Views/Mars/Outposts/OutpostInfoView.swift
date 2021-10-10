//
//  OutpostInfoView.swift
//  SkyNation
//
//  Created by Carlos Farini on 9/5/21.
//

import SwiftUI

struct OutpostInfoView: View {
    
    @ObservedObject var controller:OutpostController
    
    let levelShape = RoundedRectangle(cornerRadius: 4, style: .continuous)
    
    var body: some View {
        
        VStack {
            
            // Info Group
            Group {
                HStack {
                    Text("Info")
                        .font(.title2)
                        .foregroundColor(.orange)
                        .padding(.vertical, 6)
                    Spacer()
                }
                
                HStack {
                    // Outpost Type
                    VStack(alignment:.leading) {
                        Text("\(controller.dbOutpost.type.rawValue)").font(.title3)
                        Text("\(controller.dbOutpost.type.explanation)").foregroundColor(.gray)
                    }
                    
                    Spacer()
                    VStack {
                        Text("📍\(controller.dbOutpost.posdex)").foregroundColor(.gray)
                        if let date = controller.outpostData.dateUpgrade {
                            Text(GameFormatters.fullDateFormatter.string(from: date))
                        } else {
                            Text("---").foregroundColor(.gray)
                        }
                    }
                }
                
                Divider()
            }
            .padding(.horizontal)
            
            switch controller.dbOutpost.state {
                case .collecting:
                    HStack(spacing:12) {
                        
                        levelView
                        Divider().frame(height:12)
                        
                        Spacer()
                        productionView
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    
                    // Contributions
                    Group {
                        
                        HStack {
                            Text("Contributions")
                                .font(.title2)
                                .foregroundColor(.orange)
                                .padding(.vertical, 6)
                            Spacer()
                        }
                        
                        HStack(spacing:12) {
                            
                            VStack {
                                Text("PROGRESS").foregroundColor(.gray)
                                
                                let totalSup = controller.outpostData.getNextJob()?.maxScore() ?? 0
                                let supplied = max(controller.contribList.compactMap({ $0.score }).reduce(0, +), totalSup)
                                
                                ContributionProgressBar(value: supplied, total: totalSup)
                                    .padding(.bottom, 12)
                                    .padding()
                            }
                            
                            Divider().frame(height:40)
                            
                            VStack {
                                Text("Contributors")
                                ForEach(controller.contribList) { contribution in
                                    PlayerScorePairView(playerPair: PlayerNumKeyPair(contribution.citizen, votes: contribution.score))
                                }
                                if controller.contribList.isEmpty {
                                    Text("< No Contributions >").foregroundColor(.gray)
                                        .padding(.vertical)
                                }
                            }
                            
                            Spacer()
                        }
                        
                        Divider()
                    }
                    .padding(.horizontal)
                    
                    
                case .cooldown:
                    
                    HStack(spacing:12) {
                        
                        levelView
                        Divider().frame(height:12)
                        
                        VStack {
                            Text("Cooldown").font(.title3).foregroundColor(.red)
                                .padding(6)
                                .background(Color.black.opacity(0.5))
                                .cornerRadius(4)
                                .overlay(
                                    levelShape
                                        .inset(by: 1.5)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 2)
                                )
                            Text("Upgrading to \(controller.dbOutpost.level + 1)")
                        }
                        
                        VStack {
                            let deadline = controller.outpostData.dateUpgrade ?? Date.distantFuture
                            Text("Date: \(GameFormatters.dateFormatter.string(from: deadline))")
                            if Date().compare(deadline) == .orderedDescending {
                                Button("⇧ Update") {
                                    controller.upgradeButtonTapped()
                                }
                                .buttonStyle(GameButtonStyle())
                                .disabled(!controller.outpostUpgradeMessage.isEmpty)
                            }
                        }
                        
                        Spacer()
                        productionView
                    }
                    
                case .finished:
                    
                    VStack {
                        
                        levelView
                        Divider().frame(width:12)
                        
                        Text("Outpost Needs update.")
                            .padding()
                        
                        Button("⇧ Update") {
                            controller.upgradeButtonTapped()
                        }
                        .buttonStyle(GameButtonStyle())
                        .disabled(!controller.outpostUpgradeMessage.isEmpty)
                    }
                    
                case .maxed:
                    
                    HStack(spacing:12) {
                        
                        levelView
                        Divider().frame(height:12)
                        
                        VStack {
                            Text("Maxed").font(.title3).foregroundColor(.red)
                                .padding(6)
                                .background(Color.black.opacity(0.5))
                                .cornerRadius(4)
                                .overlay(
                                    levelShape
                                        .inset(by: 1.5)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 2)
                                )
                            Text("No more upgrades for this outpost")
                        }
                        
                        Spacer()
                        productionView
                    }
            }
        
            Group {
                Text(controller.serverError).foregroundColor(.red)
                
                Text("ℹ️ Outposts are great for producing things you may need for the Guild. Updating them is a great idea, and you should definitely do it!")
                    .foregroundColor(.gray)
                    .font(.footnote)
                    .padding(.vertical, 6)
            }
            .padding(.horizontal)
            
        }
    }
    
    var levelView: some View {
        // Level number
        VStack {
            
            Text("Level")
                .font(.title2)
                .foregroundColor(.orange)
                .padding(.vertical, 6)
            
            Text(" \(controller.dbOutpost.level) ").font(.title)
                .padding(6)
                .background(Color.black.opacity(0.5))
                .cornerRadius(4)
                .overlay(
                    levelShape
                        .inset(by: 1.5)
                        .stroke(Color.white.opacity(0.2), lineWidth: 2)
                )
            
            Text(controller.dbOutpost.state.rawValue)
                .foregroundColor(controller.dbOutpost.state == .cooldown ? Color.red:(controller.dbOutpost.state == .maxed ? Color.gray:Color.orange))
        }
    }
    
    var productionView: some View {
        // Production
        VStack(alignment:.trailing) {
            Text("Production").font(.title3) // .foregroundColor(.green)
            Text(productionDisplay()).font(.title3).foregroundColor(.green)
            
            // Upgradable?
            if let _ = controller.outpostData.getNextJob() {
                Text("Upgradable to \(controller.dbOutpost.level + 1)")
                
            }
        }
    }
    
    func productionDisplay() -> String {
        
        let prod = controller.dbOutpost.type.baseProduce()
        if let produce = prod {
            return "\(produce.name) x \(produce.quantity)"
        } else {
            return "< No production >"
        }
    }
    
}

struct OutpostInfoView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            OutpostInfoView(controller: OutpostController(random: true))
                .frame(height:450)
        }
        
    }
}
