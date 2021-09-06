//
//  OutpostInfoView.swift
//  SkyNation
//
//  Created by Carlos Farini on 9/5/21.
//

import SwiftUI

struct OutpostInfoView: View {
    
    var dbOutpost:DBOutpost
    var outpostData:Outpost
    
    @State var progress = 0.5
    
    // Supply
    @State var supplied:Int = 19
    @State var totalSupply:Int = 48
    
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
                        Text("\(dbOutpost.type.rawValue)").font(.title3)
                        Text("\(dbOutpost.type.explanation)").foregroundColor(.gray)
                        
                        Text("State: \(dbOutpost.state.rawValue)")
                            .padding(.top, 6)
                    }
                    Spacer()
                    VStack {
                        Text("📍\(dbOutpost.posdex)").foregroundColor(.gray)
                        if let date = outpostData.dateUpgrade {
                            Text(GameFormatters.fullDateFormatter.string(from: date))
                        } else {
                            Text("---").foregroundColor(.gray)
                        }
                    }
                }
                
                Divider()
            }
            .padding(.horizontal)
            
            // Level Group
            Group {
                HStack {
                    Text("Level")
                        .font(.title2)
                        .foregroundColor(.orange)
                        .padding(.vertical, 6)
                    Spacer()
                }
                
                // Level
                HStack(spacing:12) {
                    
                    // Level number
                    VStack {
                        Text(" \(dbOutpost.level) ").font(.title)
                            .padding(6)
                            .background(Color.black.opacity(0.5))
                            .cornerRadius(4)
                            .overlay(
                                levelShape
                                    .inset(by: 1.5)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 2)
                            )
                        
                    }
                    
                    Divider().frame(height:12)
                    
                    // Production
                    VStack {
                        Text("Production").font(.title3).foregroundColor(.green)
                        Text(productionDisplay()).font(.title3).foregroundColor(.green)
                        
                        // Upgradable?
                        if let _ = outpostData.getNextJob() {
                            Text("Upgradable to \(dbOutpost.level + 1)")
                            
                        } else {
                            Text("No upgrades").foregroundColor(.gray)
                        }
                    }
                    
                    Divider().frame(height:12)
                    
                    // Collect Button
                    VStack {
                        
                        Button("Collect") {
                            print("Collect")
                        }
                        .buttonStyle(GameButtonStyle())
                    }
                    
                    Spacer()
                    
                }
                
                Divider()
            }
            .padding(.horizontal)
            
            
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
                        ContributionProgressBar(value: supplied, total: totalSupply)
                    }
                    
                    Divider().frame(height:12)
                    
                    VStack {
                        Text("Contributors")
                        Text("Person 1")
                        Text("Person 2")
                        Text("Person 3")
                    }
                    
                    Spacer()
                }
                
                Divider()
            }
            .padding(.horizontal)
            
            Group {
                Text("ℹ️ Outposts are great for producing things you may need for the Guild. Updating them is a great idea, and you should definitely do it!")
                    .foregroundColor(.gray)
                    .font(.footnote)
                    .padding(.vertical, 6)
            }
            .padding(.horizontal)
            
        }
    }
    
    func productionDisplay() -> String {
        
        let prod = dbOutpost.type.baseProduce()
        if let produce = prod {
            return "\(produce.name) x \(produce.quantity)"
        } else {
            return "< No production >"
        }
    }
    
//    func getProgress() -> Double {
//        if supplied > 0 {
//            return Double(supplied) / Double(totalSupply)
//        } else {
//            return 0.0
//        }
//    }
    
}

struct OutpostInfoView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            let op = DBOutpost.example()
            let opData = Outpost.exampleFromDatabase(dbData:op)
            OutpostInfoView(dbOutpost: DBOutpost.example(), outpostData: opData)
                .frame(minHeight:450, maxHeight:.infinity)
        }
        
    }
}
