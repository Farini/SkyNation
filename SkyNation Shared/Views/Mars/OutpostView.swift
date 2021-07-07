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
    
    var header: some View {
        Group {
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
        }
    }
    
    var tabber: some View {
        // Tabs
        Group {
            
            let vstate = controller.viewTab
            let myGradient = Gradient(colors: [Color.red.opacity(0.6), Color.blue.opacity(0.7)])
            let unseGradient = Gradient(colors: [Color.red.opacity(0.3), Color.blue.opacity(0.3)])
            let selLinear = LinearGradient(gradient: myGradient, startPoint: .topLeading, endPoint: .bottomTrailing)
            let unselinear = LinearGradient(gradient: unseGradient, startPoint: .topLeading, endPoint: .bottomTrailing)
            
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
        }
    }
    
    var body: some View {
        VStack {
            
            // Top
            Group {
                // Header
                header
                // Tabs
                tabber
            }
            
            // Content
            ScrollView {
                VStack {
                    
                    Group {
                        switch controller.viewTab {
                        case .ingredients:
                            Group {
                                let array = controller.wantsIngredients()
                                HStack {
                                    if array.isEmpty {
                                        Text("No Requirements").foregroundColor(.gray)
                                    }
                                    ForEach(array) { kevii in
                                        IngredientSmallReqView(ingredient: Ingredient(rawValue:kevii.name)!, required: kevii.iNeed, available: kevii.iHave)
                                        Divider()
                                    }
                                }
                                // Available
                                LazyVGrid(columns: [GridItem(.fixed(100)), GridItem(.fixed(100)), GridItem(.fixed(100)), GridItem(.fixed(100))], alignment: .center, spacing: 8, pinnedViews: [], content: {
                                    ForEach(controller.myCity.boxes, id:\.id) { box in
                                        IngredientView(ingredient: box.type, hasIngredient: true, quantity: box.current)
                                            .onTapGesture {
                                                controller.makeContribution(object: box)
                                            }
                                    }
                                })
                            }
                        case .people:
                            Group {
                                let array = controller.wantsSkills()
                                HStack {
                                    if array.isEmpty {
                                        Text("No Requirements").foregroundColor(.gray)
                                    }
                                    ForEach(array) { kevii in
                                        VStack {
                                            GameImages.imageForSkill(skill:Skills(rawValue:kevii.name)!)
                                                .resizable()
                                                .frame(width:32, height:32)
                                            Text("\(kevii.iNeed)")
                                            Text("\(kevii.iHave)")
                                        }
                                        Divider()
                                    }
                                }
                                
                                LazyVGrid(columns: [GridItem(.fixed(200)), GridItem(.fixed(200))], alignment: .center, spacing: 8, pinnedViews: [], content: {
                                    ForEach(controller.myCity.inhabitants, id:\.id) { person in
                                        PersonSmallView(person:person)
                                            .onTapGesture {
                                                controller.makeContribution(object: person)
                                            }
                                    }
                                })
                            }
                        case .tanks:
                            Group {
                                let array = controller.wantsTanks()
                                HStack {
                                    if array.isEmpty {
                                        Text("No Requirements").foregroundColor(.gray)
                                    }
                                    ForEach(array) { kevii in
                                        VStack {
                                            Text("\(kevii.name)")
                                            Text("\(kevii.iNeed)")
                                            Text("\(kevii.iHave)")
                                        }

                                        Divider()
                                    }
                                }
                                
                                LazyVGrid(columns: [GridItem(.fixed(200)), GridItem(.fixed(200))], alignment: .center, spacing: 8, pinnedViews: [], content: {
                                    ForEach(controller.myCity.tanks, id:\.id) { tank in
                                        TankViewSmall(tank:tank)
                                            .onTapGesture {
                                                controller.makeContribution(object: tank)
                                            }
                                    }
                                })
                            }
                        case .peripherals:
                            Group {
                                
                                let array = controller.wantsPeripherals()
                                HStack {
                                    ForEach(array) { kevii in
                                        VStack {
                                            Text("\(kevii.name)")
                                            Text("\(kevii.iNeed)")
                                            Text("\(kevii.iHave)")
                                        }

                                        Divider()
                                    }
                                }
                                
                                LazyVGrid(columns: [GridItem(.fixed(200)), GridItem(.fixed(200))], alignment: .center, spacing: 8, pinnedViews: [], content: {
                                    ForEach(controller.myCity.peripherals, id:\.id) { peripheral in
                                        peripheral.getImage()!
                                            .resizable()
                                            .frame(width:32, height:32)
                                            .onTapGesture {
                                                controller.makeContribution(object: peripheral)
                                            }
                                    }
                                })
                            }
                        case .bioboxes:
                            Group {
                                let bbxes = controller.wantsBio()
                                HStack {
                                    if bbxes.isEmpty {
                                        Text("No Requirements").foregroundColor(.gray)
                                    } else {
                                        ForEach(bbxes) { kevii in
                                            VStack {
                                                Text("\(kevii.name)")
                                                Text("\(kevii.iNeed)")
                                                Text("\(kevii.iHave)")
                                            }
                                        }
                                    }
                                }
                                
                                LazyVGrid(columns: [GridItem(.fixed(200)), GridItem(.fixed(200))], alignment: .center, spacing: 8, pinnedViews: [], content: {
                                    ForEach(controller.myCity.bioBoxes ?? [], id:\.id) { bioBox in
                                        Text("\(DNAOption(rawValue:bioBox.perfectDNA)!.emoji) x \(bioBox.population.count)").font(.title)
                                            .onTapGesture {
                                                controller.makeContribution(object: bioBox)
                                            }
                                    }
                                })
                            }
                        case .info:
                            // Antenna and job
                            Group {
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
                                
                                Text("Remains").font(.title3).foregroundColor(.orange)
                                    .padding(.top, 6)
                                
                                Text(controller.remains.description)
                            }
                        case .contributions:
                            Group {
                                Text(" Contributions").font(.title3).foregroundColor(.orange)
                                let kkeys = controller.remains.map{$0.key}
                                let kvals = controller.remains.map{$0.value}
                                ForEach(kkeys.indices) { index in
                                    Text("Missing \(kkeys[index]) | \(kvals[index])")
                                }
                            }
                            
                        case .management:
                            Group {
                                Text("Manage")
                            }
                        }
                    }
                    
                    Group {
                        
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
                }// vstack
            } // scroll
        } // vstack
    }
}

struct OutpostView_Previews: PreviewProvider {
    static var previews: some View {
        OutpostView(posdex: .antenna, outpost: DBOutpost.example())
            .frame(width: 600, height: 500, alignment: .top)
    }
}
