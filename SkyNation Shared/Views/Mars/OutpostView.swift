//
//  OutpostView.swift
//  SkyNation
//
//  Created by Carlos Farini on 3/12/21.
//

import SwiftUI

struct OutpostView: View {
    
    @State var posdex:Posdex
    @State var outpost:DBOutpost
    @State var popTutorial:Bool = false
    
    @ObservedObject var controller = OutpostController()
    
    var body: some View {
        VStack {
            
            HStack {
                Text("Outpost").font(.title)
                Spacer()
                // Tutorial
                Button(action: {
                    popTutorial.toggle()
                }, label: {
                    Image(systemName: "questionmark.circle")
                        .font(.title2)
                })
                .buttonStyle(SmallCircleButtonStyle(backColor: .blue))
                .popover(isPresented: $popTutorial, attachmentAnchor: .point(.bottom),   // here !
                         arrowEdge: .bottom) {
                    TutorialView(tutType:.LabView)
                }
                
                // Close
                Button(action: {
                    print("Close action")
                    NotificationCenter.default.post(name: .closeView, object: self)
                }, label: {
                    Image(systemName: "xmark.circle")
                        .font(.title2)
                })
                .buttonStyle(SmallCircleButtonStyle(backColor: .pink))
                .padding(.trailing, 6)
            }
            .padding(8)
            
            
            Divider()
            
            Group {
                Text("\(posdex.sceneName)").foregroundColor(.orange)
                
                Text("Outpost data").foregroundColor(.blue).padding(.top)
                Text("Level: \(outpost.level)")
                
                Text("Model: \(outpost.model)").foregroundColor(.gray)
                Text("Posdex: \(outpost.posdex)")
                Text("Date: \(GameFormatters.dateFormatter.string(from:outpost.accounting))")
            }
            
            if let cityData = controller.myCity {
                Group {
                    Text("City: \(cityData.id.uuidString)").foregroundColor(.green).font(.title3)
                    ForEach(cityData.boxes, id:\.id) { box in
                        Text("\(box.type.rawValue): \(box.current)/\(box.capacity)")
                    }
                }
            } else {
                Text("No city").foregroundColor(.gray).font(.title3)
            }
            
            Divider()
            
            Text("Outpost Job").foregroundColor(.orange)
            if let nextJob = outpost.getNextJob() {
                VStack {
                    Text("Next Job - Upgrade to \(outpost.level + 1)").font(.title2)
                    Text("Skills: \(nextJob.wantedSkills.count) QTTY: \(nextJob.wantedSkills.compactMap({$0.value}).reduce(0, +))")
                    Text("Ingredients: \(nextJob.wantedIngredients.count) QTTY: \(nextJob.wantedIngredients.compactMap({$0.value}).reduce(0, +))")
                }
                .foregroundColor(.green)
                .padding()
            } else {
                Text("< No upgrades >").foregroundColor(.gray)
            }
            
            Divider()
            
            HStack{
                Button("Close") {
                    NotificationCenter.default.post(name: .closeView, object: nil)
                }
                .buttonStyle(NeumorphicButtonStyle(bgColor: .orange))
                
                Button("Help") {
                    print("Insert help action here")
                }
                .buttonStyle(NeumorphicButtonStyle(bgColor: .orange))
            }
            .padding()
            
            
        }
        
    }
}

struct OutpostView_Previews: PreviewProvider {
    static var previews: some View {
        OutpostView(posdex: .antenna, outpost: DBOutpost.example())
    }
}
