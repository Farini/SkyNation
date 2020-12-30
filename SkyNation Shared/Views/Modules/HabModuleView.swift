//
//  HabModuleView.swift
//  SkyTestSceneKit
//
//  Created by Farini on 9/14/20.
//  Copyright © 2020 Farini. All rights reserved.
//

import SwiftUI

struct HabModuleView: View {
    
    var module:HabModule
    @State var habPopoverOn:Bool = false
    @State var selectedPerson:Person?
    
    var body: some View {
        
        VStack(alignment:.leading) {
            
            // Header
            HStack (alignment: .center, spacing: nil) {
                
                HabModuleHeaderView(module: module)
                
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
                .buttonStyle(GameButtonStyle(foregroundColor: .white, backgroundColor: .black, pressedColor: .orange))
                .popover(isPresented: $habPopoverOn, content: {
                    VStack {
                        HStack {
                            Text("Rename")
                            Spacer()
                            Image(systemName: "textformat")
                                .fixedSize()
                                .scaledToFit()
                        }
                        
                        .onTapGesture {
                            print("Rename Action")
                            habPopoverOn.toggle()
                        }
                        Divider()
                        HStack {
                            // Text
                            Text("Change Skin")
                            // Spacer
                            Spacer()
                            // Image
                            Image(systemName: "circle.circle")
                                .fixedSize()
                                .scaledToFit()
                        }
                        .onTapGesture {
                            print("Reskin Action")
                            habPopoverOn.toggle()
                        }
                        
                        HStack {
                            Text("Tutorial")
                            Spacer()
                            Image(systemName: "questionmark.diamond")
                                .fixedSize()
                                .scaledToFit()
                        }
                        
                        .onTapGesture {
                            print("Reskin Action")
                            habPopoverOn.toggle()
                        }
                    }
                    .frame(width: 150)
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding(.leading, 6)
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
                .buttonStyle(GameButtonStyle(foregroundColor: .white, backgroundColor: .black, pressedColor: .orange))
                .padding(.trailing, 6)
            }
            
            Divider()
            
            // Left View
            if module.inhabitants.isEmpty {
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
                .frame(minWidth: 500, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, minHeight: 275, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment:.topLeading)
                
            }else{
                HStack {
                    // Left List
                    List(module.inhabitants) { person in
                        PersonRow(person: person, selected: person == selectedPerson).onTapGesture(count: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/, perform: {
                            self.selectedPerson = person
                        })
                    }
                    .frame(minWidth: 150, maxWidth: 230, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                    
                    Divider()
                    
                    // Right Detail View
                    if selectedPerson == nil {
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
                        }.padding()
                    } else {
                        // Details go here
                        ScrollView {
                            PersonDetail(person: selectedPerson!, workoutAction: workoutAction)
                        }
                    }
                    
                    Spacer()
                }
                .frame(minWidth: 500, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, minHeight: 275, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment:.topLeading)
            }
        }
    }
    
    func workoutAction() {
        guard let person = selectedPerson else {
            return
        }
        let workoutActivity = LabActivity(time: 60, name: "Working out")
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
                    Text("Name: \(module.name)")
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
