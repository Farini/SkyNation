//
//  HabModuleView.swift
//  SkyTestSceneKit
//
//  Created by Farini on 9/14/20.
//  Copyright © 2020 Farini. All rights reserved.
//

import SwiftUI

struct HabModuleView: View {
    
    @State var habPopoverOn:Bool = false
    @State var popTutorial:Bool = false
    
    @ObservedObject var controller:HabModuleController
    
    init(module:HabModule) {
        let controller = HabModuleController(hab: module)
        self.controller = controller
    }
    
    var body: some View {
        
        VStack(alignment:.leading) {
            
            // Header
            HStack (alignment: .center, spacing: nil) {
                
                HabModuleHeaderView(module: controller.habModule)
                
                Spacer()
                
                // Tutorial
                Button(action: {
                    popTutorial.toggle()
                }, label: {
                    Image(systemName: "questionmark.circle")
                        .font(.title2)
                })
                .buttonStyle(SmallCircleButtonStyle(backColor: .orange))
                .popover(isPresented: $popTutorial, attachmentAnchor: .point(.bottom), arrowEdge: .bottom) {
                    TutorialView(tutType:.HabView)
                }
                
                // Settings
                Button(action: {
                    print("Gear action")
                    habPopoverOn.toggle()
                }, label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.title2)
                })
                .buttonStyle(SmallCircleButtonStyle(backColor: .blue))
                .popover(isPresented: $habPopoverOn, attachmentAnchor: .point(.bottom), arrowEdge: .bottom) {
                    ModulePopView(name: controller.habModule.name, module:controller.station.modules.filter({ $0.id == controller.habModule.id }).first!)
                }
                
                // Close
                Button(action: {
                    NotificationCenter.default.post(name: .closeView, object: self)
                }, label: {
                    Image(systemName: "xmark.circle")
                        .font(.title2)
                })
                .buttonStyle(SmallCircleButtonStyle(backColor: .red))
                .padding(.trailing, 6)
            }
            .padding([.horizontal, .top], 6)
            
            Divider().offset(x: 0, y: -5)
            
            switch controller.viewState {
                case .noSelection:
                    if controller.inhabitants.isEmpty {
                        // Empty Module
                        HStack {
                            Spacer()
                            Image(systemName: "camera.metering.none")
                                .foregroundColor(.gray)
                                .font(.largeTitle)
                                .padding()
                            Text("No one lives in this Hab. Close this view, then tap on the Earth to hire Astronauts.")
                                .foregroundColor(.orange)
                                .font(.subheadline)
                            Spacer()
                        }
                        .frame(minWidth: 600, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, minHeight: 350, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment:.topLeading)
                    } else {
                        HStack {
                            // Left List
                            List(controller.inhabitants) { person in
                                
                                ActivityPersonCell(person: person, selected: person == controller.selectedPerson)
                                    .onTapGesture(count: 1, perform: {
                                        controller.didSelect(person: person)
                                    })
                                
                            }
                            .frame(minWidth: 100, maxWidth: 215, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                            .background(GameColors.darkGray)
                            
                            Divider()
                            // No Selection
                            HStack {
                                Spacer()
                                ZStack {
                                    Image("HabInside")
                                        .resizable()
                                        .aspectRatio(contentMode: ContentMode.fit)
                                    
                                    VStack {
                                        Image(systemName: "camera.metering.none")
                                            .font(.largeTitle)
                                            .padding()
                                        Text("No One selected")
                                        Text("Select someone to view details.")
                                    }
                                    .padding()
                                    .background(Color.black.opacity(0.5))
                                    .cornerRadius(12)
                                    .foregroundColor(.white)
                                    
                                    Spacer()
                                }
                            }
                            //.padding()
                        }
                    }
                case .selected(_):
                    HStack {
                        
                        // Left List
                        List(controller.inhabitants) { person in
                            ActivityPersonCell(person: person, selected: person == controller.selectedPerson)
                                .onTapGesture(count: 1, perform: {
                                    controller.didSelect(person: person)
                                })
                        }
                        .frame(minWidth: 150, maxWidth: 230, maxHeight: .infinity, alignment: .leading)
                        
                        // Details go here
                        ScrollView {
                            PersonDetail(controller: self.controller, person:controller.selectedPerson!)
                        }
                    }
            }
            
        }
        .frame(minWidth: 650, idealWidth: 750, maxWidth: 1000, minHeight: 350, idealHeight: 500, maxHeight: 900, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        .background(GameColors.darkGray)
    }
    
    func workoutAction() {
        guard let person = controller.selectedPerson else {
            return
        }
        let workoutActivity = LabActivity(time: 60, name: "Workout")
        person.activity = workoutActivity
        print("Person working out")
    }
}

struct HabModuleHeaderView: View {
    
    var module:HabModule
    private var title = "Hab Module"
    
    init(module:HabModule) {
        self.module = module
        if module.name == "untitled" || module.name == "Untitled" {
            self.title = "Hab Module"
        } else {
            self.title = module.name
        }
    }
    
    var body: some View {
        VStack(alignment:.leading) {
            Group {
                HStack {
                    Text("🏠").font(.largeTitle)
                        .padding(.leading, 6)
                    Text(title)
//                        .font(.largeTitle)
                        .font(GameFont.title.makeFont())
                        .padding([.leading], 6)
//                        .foregroundColor(.green)
                }
                
//                HStack(alignment: .lastTextBaseline) {
//                    Text("ID: \(module.id)")
//                        .foregroundColor(.gray)
//                        .font(.caption)
//                        .padding(.leading, 6)
//                    Text("\(module.name)")
//                        .foregroundColor(.green)
//                        .padding(.leading, /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
//                }
            }
        }
    }
}

// MARK: - Previews

struct HeaderView_Previews: PreviewProvider {
    
    static var previews: some View {
        if let module = LocalDatabase.shared.station.habModules.first {
            return HabModuleHeaderView(module: module) //ModuleHeaderView(hab:module)
        } else {
            return HabModuleHeaderView(module: HabModule.example)//ModuleHeaderView(hab: HabModule.example)
        }
    }
}

struct HabModuleView_Previews: PreviewProvider {
    static var previews: some View {
        let habModule = LocalDatabase.shared.station.habModules.first ?? HabModule(module: Module(id: UUID(), modex: .mod0))
        return HabModuleView(module: habModule)
    }
}
