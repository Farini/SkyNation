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
    
    @ObservedObject var controller:OutpostController
    @State var popTutorial:Bool = false
    
    // Tabs
    // -------
    // Info
    // Ingredients
    // Tanks
    // BioBoxes
    // Peripherals
    // Skills
    // Contributors
    // Manage
    
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
                    .foregroundColor(controller.isDownloaded ? Color.green:Color.red)
                
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
            .frame(minWidth:500)
            
            // Content
            ScrollView {
                VStack {
                    
                    Group {
                        switch controller.viewTab {
                        case .ingredients:
                            OutpostSectionView(controller:controller, tab:.ingredients, contribRound: $controller.contribRound)
                        case .peopleSkills:
                            OutpostSectionView(controller:controller, tab:.peopleSkills, contribRound: $controller.contribRound)
                        case .tanks:
                            OutpostSectionView(controller:controller, tab:.tanks, contribRound: $controller.contribRound)
                        case .peripherals:
                            OutpostSectionView(controller:controller, tab:.peripherals, contribRound: $controller.contribRound)
                        case .bioboxes:
                            OutpostSectionView(controller:controller, tab:.bioboxes, contribRound: $controller.contribRound)
                        case .info:
                            ScrollView {
                                OutpostInfoView(controller:controller)
                            }
                            
                        case .contributions:
                            ScrollView {
                                VStack {
                                    ContributionRoundView(controller: controller, contribRound: $controller.contribRound)
                                }
                            }
                            .frame(minHeight:300)
                            
                        case .management:
                            OutpostSceneView(dbOutpost: controller.dbOutpost)
                        }
                    }
                    
                }// vstack
            } // scroll
        } // vstack
    }
    
}

// Breaking down the views
/*
 Each supply type (Ingredients, Tanks, Batteries, Skills, Biobox) needs:
 1. Requirements (or none)
 2. Supplied, (and suppliers)
 3. if fully supplied, show a dimmed view
 4. if none required, show an empty view
 5. If needs supply, show CityData's contents
 */

struct OutpostSectionView: View {
    
    var controller:OutpostController
    var tab:OutpostViewTab
    @Binding var contribRound:OutpostSupply // = OutpostSupply()
    
    var body: some View {
        
        VStack {
            
            let comparators:[KeyvalComparator] = getComparators()
            
            // Requirements
            Group {
                HStack {
                    Text("Required \(rssName)")
                        .modifier(GameTypography.init(GameFont.title))
                        .foregroundColor(.gray)
                    Spacer()
                }
                .padding(.horizontal, 6)
                
                Divider()
                
                // Requirements Content
                // end content
                if comparators.isEmpty {
                    Text("< No Requirements >").foregroundColor(.gray).padding()
                } else {
                    switch tab {
                        case .ingredients:
                            LazyVGrid(columns: [GridItem(.fixed(100)), GridItem(.fixed(100)), GridItem(.fixed(100)), GridItem(.fixed(100))], alignment: .center, spacing: 8, pinnedViews: []) {
                                ForEach(comparators) { comparator in
                                    IngredientSmallReqView(ingredient: Ingredient(rawValue:comparator.name)!, required: comparator.needs, available: comparator.supplied)
                                        
                                }
                            }
                        case .tanks:
                            LazyVGrid(columns: [GridItem(.fixed(200)), GridItem(.fixed(200))], alignment: .center, spacing: 8, pinnedViews: []) {
                                ForEach(comparators) { comparator in
                                    VStack {
                                        Text("\(comparator.name)")
                                        Text("\(comparator.needs)")
                                        Text("\(comparator.supplied)")
                                    }
                                }
                            }
                        case .peripherals:
                            LazyVGrid(columns: [GridItem(.fixed(200)), GridItem(.fixed(200))], alignment: .center, spacing: 8, pinnedViews: []) {
                                ForEach(comparators) { comparator in
                                    VStack {
                                        Text("\(comparator.name)")
                                        Text("\(comparator.needs)")
                                        Text("\(comparator.supplied)")
                                    }
                                }
                            }
                        case .bioboxes:
                            LazyVGrid(columns: [GridItem(.fixed(200)), GridItem(.fixed(200))], alignment: .center, spacing: 8, pinnedViews: []) {
                                ForEach(comparators) { comparator in
                                    VStack {
                                        Text("\(comparator.name)")
                                        Text("\(comparator.needs)")
                                        Text("\(comparator.supplied)")
                                    }
                                }
                            }
                            
                        case .peopleSkills:
                            
                            LazyVGrid(columns: [GridItem(.fixed(200)), GridItem(.fixed(200))], alignment: .center, spacing: 8, pinnedViews: []) {
                                ForEach(comparators) { comparator in
                                    VStack {
                                        GameImages.imageForSkill(skill:Skills(rawValue:comparator.name)!)
                                            .resizable()
                                            .frame(width:32, height:32)
                                        Text(comparator.name)
                                        Text("\(comparator.needs)")
                                        Text("\(comparator.supplied)")
                                    }
                                }
                            }
                            
                        default: Text("Invalid")
                    }
                }
                
            }
            
            // My available supplies
            Group {
                HStack {
                    Text("Available \(rssName)")
                        .modifier(GameTypography(.title))
                        .foregroundColor(.gray)
                    Spacer()
                }
                .padding(.horizontal, 6)
                
                Divider()
                
                if comparators.isEmpty {
                    Text("Not Needed").foregroundColor(.gray).padding()
                } else {
                    switch tab {
                        
                        // Available
                        case .ingredients:
                            LazyVGrid(columns: [GridItem(.fixed(150)), GridItem(.fixed(150)), GridItem(.fixed(150))], alignment: .center, spacing: 8, pinnedViews: []) {
                                
                                ForEach(controller.myCity.boxes, id:\.id) { box in
                                    StorageBoxView(box:box, selected:contribRound.ingredients.contains(box))
                                        .frame(height:80)
                                        .onTapGesture {
                                            controller.addToContribRound(object:box)
                                        }
                                }
                            }
                        case .tanks:
                            LazyVGrid(columns: [GridItem(.fixed(200)), GridItem(.fixed(200))], alignment: .center, spacing: 8, pinnedViews: []) {
                                ForEach(controller.myCity.tanks, id:\.id) { tank in
                                    TankViewSmall(tank:tank, selected:contribRound.tanks.contains(tank))
                                        .onTapGesture {
                                            controller.addToContribRound(object:tank)
                                        }
                                }
                            }
                        case .peripherals:
                            LazyVGrid(columns: [GridItem(.fixed(200)), GridItem(.fixed(200))], alignment: .center, spacing: 8, pinnedViews: [], content: {
                                ForEach(controller.myCity.peripherals, id:\.id) { peripheral in
                                    PeripheralSmallSelectView(peripheral:peripheral, selected:contribRound.peripherals.contains(peripheral))
                                        .onTapGesture {
                                            controller.addToContribRound(object:peripheral)
                                        }
                                }
                            })
                        
                        case .peopleSkills:
                            LazyVGrid(columns: [GridItem(.fixed(200)), GridItem(.fixed(200))], alignment: .center, spacing: 8, pinnedViews: [], content: {
                                ForEach(controller.myCity.inhabitants.filter({$0.isBusy() == false}), id:\.id) { person in
                                    PersonSmallView(person:person, selected:contribRound.skills.contains(person))
                                        .onTapGesture {
                                            controller.addToContribRound(object:person)
                                        }
                                }
                            })
                            
                        case .bioboxes:
                            LazyVGrid(columns: [GridItem(.fixed(200)), GridItem(.fixed(200))], alignment: .center, spacing: 8, pinnedViews: [], content: {
                                ForEach(controller.myCity.bioBoxes, id:\.id) { bioBox in
                                    BioBoxSelectView(bioBox:bioBox, selected:contribRound.bioBoxes.contains(bioBox))
                                        .onTapGesture {
                                            controller.addToContribRound(object:bioBox)
                                        }
                                }
                            })
                            
                        default:Text("Invalid")
                    }
                }
                
                // City Data (relevant) Content
                // end content
            }
            
            if !comparators.isEmpty {
                Text("ℹ️ Tap, or click on an item to contribute.")
            }
            
            Spacer()
        }
    }
    
    var rssName:String {
        switch tab {
            case .ingredients: return "Ingredients"
            case .bioboxes: return "Bio boxes"
            case .peopleSkills: return "Skills"
            case .peripherals: return "Peripherals"
            case .tanks: return "Tanks"
            
            default: return "Invalid"
        }
    }
    
    func getComparators() -> [KeyvalComparator] {
        switch tab {
            case .ingredients: return controller.wantsIngredients()
            case .bioboxes: return controller.wantsBio()
            case .peopleSkills: return controller.wantsSkills()
            case .peripherals: return controller.wantsPeripherals()
            case .tanks: return controller.wantsTanks()
                
            default: return []
        }
    }
}

extension KeyvalComparator {
    var color: Color {
        if missing < 1 {
            return Color.green
        } else {
            return Color.orange
        }
    }
}

struct OutpostView_Previews: PreviewProvider {
    
    static let controller = OutpostController(random: true)
    
    static var previews: some View {
        OutpostView(controller: controller)
            .frame(width: 600, height: 500, alignment: .top)
        
        OutpostSectionView(controller: controller, tab:.ingredients, contribRound: .constant(OutpostSupply()))
    }
}


