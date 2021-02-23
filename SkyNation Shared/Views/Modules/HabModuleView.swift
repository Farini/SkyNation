//
//  HabModuleView.swift
//  SkyTestSceneKit
//
//  Created by Farini on 9/14/20.
//  Copyright © 2020 Farini. All rights reserved.
//

import SwiftUI

struct HabModuleView: View {
    
//    var module:HabModule
    @State var habPopoverOn:Bool = true
//    @State var selectedPerson:Person?
    
    @ObservedObject var controller:HabModuleController
    
    init(module:HabModule) {
        let controller = HabModuleController(hab: module)
        self.controller = controller
//        self.module
    }
    
    var body: some View {
        
        VStack(alignment:.leading) {
            
            // Header
            HStack (alignment: .center, spacing: nil) {
                
                HabModuleHeaderView(module: controller.habModule)
                
                Spacer()
                
                // Settings
                Button(action: {
                    print("Gear action")
                    habPopoverOn.toggle()
                }, label: {
                    Image(systemName: "ellipsis.circle")
                        .resizable()
                        .aspectRatio(contentMode:.fit)
                        .frame(width:34, height:34)
                })
                .buttonStyle(SmallCircleButtonStyle(backColor: .orange))
                .popover(isPresented: $habPopoverOn, content: {
                    ModulePopView(name: controller.habModule.name, module:controller.station.modules.filter({ $0.id == controller.habModule.id }).first!)
                })
                
                
                // Close
                Button(action: {
                    print("Close action")
                    NotificationCenter.default.post(name: .closeView, object: self)
                }, label: {
                    Image(systemName: "xmark.circle")
                        .resizable()
                        .aspectRatio(contentMode:.fit)
                        .frame(width:34, height:34)
                })
                .buttonStyle(SmallCircleButtonStyle(backColor: .orange))
                .padding(.trailing, 6)
            }
            
            Divider()
            
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
                            Text("No one lives here. Call for Dropoff, and hire people.")
                                .foregroundColor(.gray)
                                .font(.subheadline)
                            Spacer()
                        }
                        .frame(minWidth: 600, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, minHeight: 350, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment:.topLeading)
                    } else {
                        HStack {
                            // Left List
                            List(controller.inhabitants) { person in
                                PersonRow(person: person, selected: person == controller.selectedPerson)
                                    .onTapGesture(count: 1, perform: {
                                        controller.didSelect(person: person)
                                    })
                            }
                            .frame(minWidth: 150, maxWidth: 230, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                            
                            Divider()
                            // No Selection
                            HStack {
                                Spacer()
                                VStack {
                                    Image(systemName: "camera.metering.none")
                                        .font(.largeTitle)
                                        .padding()
                                    Text("No One selected")
                                    Text("Hab module shelters people")
                                }
                                .foregroundColor(.gray)
                                Spacer()
                            }
                            .padding()
                        }
                    }
                case .selected(_):
                    HStack {
                        
                        // Left List
                        List(controller.inhabitants) { person in
                            PersonRow(person: person, selected: person == controller.selectedPerson)
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
    
    var body: some View {
        VStack(alignment:.leading) {
            Group {
                HStack {
                    Text("🏠").font(.largeTitle)
                        .padding(.leading, 6)
                    Text("Habitation Module")
                        .font(.largeTitle)
                        .padding([.leading], 6)
                        .foregroundColor(.green)
                }
                
                HStack(alignment: .lastTextBaseline) {
                    Text("ID: \(module.id)")
                        .foregroundColor(.gray)
                        .font(.caption)
                        .padding(.leading, 6)
                    Text("\(module.name)")
                        .foregroundColor(.green)
                        .padding(.leading, /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                }
            }
        }
    }
}



// MARK: - Previews

struct HeaderView_Previews: PreviewProvider {
    
    static var previews: some View {
        if let module = LocalDatabase.shared.station?.habModules.first {
            return HabModuleHeaderView(module: module) //ModuleHeaderView(hab:module)
        } else {
            return HabModuleHeaderView(module: HabModule.example)//ModuleHeaderView(hab: HabModule.example)
        }
    }
}

struct HabModuleView_Previews: PreviewProvider {
    static var previews: some View {
        let habModule = LocalDatabase.shared.station?.habModules.first ?? HabModule(module: Module(id: UUID(), modex: .mod0))
        return HabModuleView(module: habModule)
    }
}

//struct SkinPopup_Previews: PreviewProvider {
//
//    static var previews: some View {
//        SkinPopupPicker()
//    }
//}
