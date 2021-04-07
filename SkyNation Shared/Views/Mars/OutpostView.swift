//  OutpostView.swift
//  SkyNation
//  Created by Carlos Farini on 3/12/21.

import SwiftUI

/**
 Guide
 Create raw data for Outpost, DBOutpost, DBCity, CityData, Guild
 Try an interface where we can take things from citydata and transfer to outpost
 Write to Outpost keeping in mid there will be multiple people doing it at the same time.
 When fulfilled, the Outpost should go on locked mode, until the time of building expires, or enough tokens are spent.
 */
struct OutpostView: View {
    
    @State var posdex:Posdex
    @State var outpost:DBOutpost
    @State var popTutorial:Bool = false
    
    @ObservedObject var controller = OutpostController()
    
    // Tabs
    // 1 - Ingredient Picker
    // 2 - People Picker
    // 3 - Other resources picker
    // 4 - Current Contributions
    // 5 - Management
    
    var body: some View {
        VStack {
            
            // Header
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
            
            // City
            Group {
                
                let vstate = controller.viewTab
                let myGradient = Gradient(colors: [Color.red.opacity(0.6), Color.blue.opacity(0.7)])
                let unseGradient = Gradient(colors: [Color.red.opacity(0.3), Color.blue.opacity(0.3)])
                let selLinear = LinearGradient(gradient: myGradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                let unselinear = LinearGradient(gradient: myGradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                
                HStack {
                    ForEach(OutpostViewTab.allCases, id:\.self) { aTab in
                        Image(systemName: aTab.imageName()).padding(6).frame(height: 32, alignment: .center)
                            .background(controller.viewTab == aTab ? selLinear:unselinear)
                            .onTapGesture {
                                controller.selected(tab: aTab)
                            }
                            .cornerRadius(4)
                            .clipped()
                            .border(controller.viewTab == aTab ? Color.blue:Color.clear, width: 1)
                            .cornerRadius(6)
                            .help(aTab.tabName())
                    }
                    
                    Spacer()
                    Text("\(vstate.tabName())")
                }
                .padding(.horizontal, 6)
                .font(.title3)
                
                Divider()
                
                ScrollView {
                    switch controller.viewTab {
                        case .ingredients:
                            Group {
                                // Required
                                let kkeys = (controller.opData.remaining() ?? [:]).map{$0.key}
                                let kvals = (controller.opData.remaining() ?? [:]).map{$0.value}
                                HStack {
                                    ForEach(kkeys.indices) { index in
                                        IngredientSmallReqView(ingredient: kkeys[index], required: kvals[index], available: controller.opData.materials[kkeys[index]] ?? 0)
                                        Divider()
                                    }
                                }
                                // Available
                                LazyVGrid(columns: [GridItem(.fixed(100)), GridItem(.fixed(100)), GridItem(.fixed(100)), GridItem(.fixed(100))], alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 8, pinnedViews: /*@START_MENU_TOKEN@*/[]/*@END_MENU_TOKEN@*/, content: {
                                    ForEach(controller.myCity.boxes, id:\.id) { box in
                                        IngredientView(ingredient: box.type, hasIngredient: true, quantity: box.current)
                                    }
                                })
                            }
                        case .people:
                            LazyVGrid(columns: [GridItem(.fixed(200)), GridItem(.fixed(200))], alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 8, pinnedViews: /*@START_MENU_TOKEN@*/[]/*@END_MENU_TOKEN@*/, content: {
                                ForEach(controller.myCity.inhabitants, id:\.id) { person in
                                    PersonSmallView(person:person)
                                }
                            })
                            
                        case .tanks:
                            LazyVGrid(columns: [GridItem(.fixed(200)), GridItem(.fixed(200))], alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 8, pinnedViews: /*@START_MENU_TOKEN@*/[]/*@END_MENU_TOKEN@*/, content: {
                                ForEach(controller.myCity.tanks, id:\.id) { tank in
                                    TankViewSmall(tank:tank)
                                }
                            })
                        case .peripherals:
                            LazyVGrid(columns: [GridItem(.fixed(200)), GridItem(.fixed(200))], alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 8, pinnedViews: /*@START_MENU_TOKEN@*/[]/*@END_MENU_TOKEN@*/, content: {
                                ForEach(controller.myCity.peripherals, id:\.id) { peripheral in
                                    peripheral.getImage()
                                }
                            })
                        case .bioboxes:
                            LazyVGrid(columns: [GridItem(.fixed(200)), GridItem(.fixed(200))], alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 8, pinnedViews: /*@START_MENU_TOKEN@*/[]/*@END_MENU_TOKEN@*/, content: {
                                ForEach(controller.myCity.peripherals, id:\.id) { peripheral in
                                    peripheral.getImage()
                                }
                            })
                            
                        case .info:
                            // Antenna and job
                            HStack {
                                VStack(alignment:.leading) {
                                    Text("\(posdex.sceneName)").foregroundColor(.orange)
                                    
                                    Text("DBOutpost P.: \(outpost.posdex)").foregroundColor(.blue).padding(.top, 6)
                                    Text("Level: \(outpost.level)")
                                    //                    Text("Model: \(outpost.model)").foregroundColor(.gray)
                                    Text("Date: \(GameFormatters.dateFormatter.string(from:outpost.accounting))")
                                }
                                
                                Spacer()
                                
                                if let nextJob = outpost.getNextJob() {
                                    VStack(alignment:.leading) {
                                        Text("Outpost Job").foregroundColor(.orange)
                                            .padding(.bottom, 6)
                                        
                                        Text("🔄 Upgrade to \(outpost.level + 1)").font(.title2)
                                        let kkeys = nextJob.wantedSkills.map{$0.key}
                                        let kvals = nextJob.wantedSkills.map{$0.value}
                                        HStack {
                                            ForEach(kkeys.indices) { index in
                                                Text("\(kkeys[index].rawValue) | \(kvals[index])")
                                            }
                                        }
                                        Text("Ingredients: \(nextJob.wantedIngredients.count) QTTY: \(nextJob.wantedIngredients.compactMap({$0.value}).reduce(0, +))")
                                    }
                                    .foregroundColor(.green)
                                    .padding(.trailing, 8)
                                } else {
                                    Text("< No upgrades >").foregroundColor(.gray)
                                }
                            }
                            .padding(.horizontal, 8)
                            
                        case .contributions:
                            Group {
                                Text("Ingredients Contributions").font(.title3).foregroundColor(.orange)
                                let kkeys = controller.opData.materials.map{$0.key}
                                let kvals = controller.opData.materials.map{$0.value}
                                ForEach(kkeys.indices) { index in
                                    Text("Ingredient \(kkeys[index].rawValue) | \(kvals[index])")
                                }
                            }
                            
                        case .management:
                            Text("Manage")
                            
                    }
                    
                    if !controller.myCity.boxes.isEmpty {
                        
                        Text("City: \(controller.myCity.id.uuidString)").foregroundColor(.green).font(.title3)
                            .padding(.top, 6)
                        
                    } else {
                        Spacer()
                        Text("Contributions...").foregroundColor(.gray).font(.title3)
                        // A chart showing the contributors
                        Spacer()
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
    }
}

struct OutpostView_Previews: PreviewProvider {
    static var previews: some View {
        OutpostView(posdex: .antenna, outpost: DBOutpost.example())
            .frame(width: 600, height: 500, alignment: .top)
    }
}
