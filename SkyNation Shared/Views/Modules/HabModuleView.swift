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
            
            // Top
            HStack {
                Button("OPT") {
                    print("action")
                    habPopoverOn.toggle()
                }
                .popover(isPresented: $habPopoverOn, content: {
                    VStack {
                        Button("Rename Module") {
                            print("action")
                            habPopoverOn.toggle()
                        }
                        Button("Empty Module") {
                            print("action")
                            habPopoverOn.toggle()
                        }
                    }
                })
                .padding(.leading, /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                Text("Habitation Module")
                    .font(.headline)
                    .padding(6)
                    .foregroundColor(.green)
                Text("ID: \(module.id)").foregroundColor(.gray).font(.caption)
                
            }
            
            Text("Name: \(module.name)")
                .foregroundColor(.green)
                .padding(.leading, /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                
            Divider()
            
            // Left View
            if module.inhabitants.isEmpty {
                List {
                    Text("No one lives here. Call for Dropoff, and hire people.")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                }
            }else{
                HStack {
                    // Left List
                    List(module.inhabitants) { person in
                        PersonRow(person: person).onTapGesture(count: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/, perform: {
                            self.selectedPerson = person
                        })
                    }
                    .frame(minWidth: 180, idealWidth: 200, maxWidth: 250, minHeight: 150, idealHeight: 150, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                    
                    // Right Detail View
                    if selectedPerson == nil {
                        VStack {
                            Text("No One selected")
                            Text("Hab module shelters people")
                        }.padding()
                    }else{
                        // Details go here
                        PersonDetail(person: selectedPerson!)
                        
                    }
                    
                    Spacer()
                }
            }
        }
    }
}

// MARK: - Previews

struct HabModuleView_Previews: PreviewProvider {
    static var previews: some View {
        let habModule = LocalDatabase.shared.station?.habModules.first ?? HabModule(module: Module(id: UUID(), modex: .mod0))
        return HabModuleView(module: habModule)
    }
}

struct ModuleHeaderView: View {
    
    var module:HabModule
    @State var habPopoverOn:Bool = false
//    @State var selectedPerson:Person?
    
    init(hab module:HabModule) {
        self.module = module
//        let name = module.name
//        let people = module.inhabitants
    }
    
    var body: some View {
        
        HStack {
            VStack(alignment:.leading) {
                Group {
                    // Top
                    HStack {
                        Text("🏠").font(.largeTitle)
                            .padding(.leading, 6)
                        Text("Habitation Module")
                            .font(.largeTitle)
                            .padding(6)
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
                    Divider()
                }
            }
            
            HStack {
                Button(action: {
                    print("Close action")
                }, label: {
                    Image(systemName: "xmark.circle")
                        .resizable()
                        .aspectRatio(contentMode:.fit)
                        .frame(width:34, height:34)
//                    Text("Close")
                })
                .buttonStyle(GameButtonStyle(foregroundColor: .white, backgroundColor: .black, pressedColor: .orange))
                .padding(.trailing, 6)
                
                // Settings
                Button(action: {
                    print("Gear action")
                    habPopoverOn.toggle()
                }, label: {
                    Image(systemName: "gearshape.fill")
                        .resizable()
                        .aspectRatio(contentMode:.fit)
                        .frame(width:34, height:34)
                    //                    Text("Close")
                })
                .buttonStyle(GameButtonStyle(foregroundColor: .white, backgroundColor: .black, pressedColor: .orange))
                .padding(.trailing, 6)
//                .contextMenu(ContextMenu(menuItems: {
//                    Label("Rename", systemImage: "textformat")
//                    Label("Change Skin", systemImage: "circle.circle")
//                }))
//
                .popover(isPresented: $habPopoverOn, content: {
                    VStack {

                        Button(action: {
                            print("rename")
                        }, label: {
                            Label("Rename", systemImage: "textformat")
                        })
                        .frame(width: 100)
                        Button(action: {
                            print("reskin")
                        }, label: {
                            Label("Change Skin", systemImage: "circle.circle")
                        })
                        .frame(width: 100)
                    }
//                    contextMenu(ContextMenu(menuItems: {
//                        Label("Rename", systemImage: "textformat")
//                        Label("Change Skin", systemImage: "circle.circle")
//                    }))
                })
            }
        }
        
    }
}

struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        
        if let module = LocalDatabase.shared.station?.habModules.first {
            return ModuleHeaderView(hab:module)
        } else {
            return ModuleHeaderView(hab: HabModule.example)
        }
        
        
    }
}
