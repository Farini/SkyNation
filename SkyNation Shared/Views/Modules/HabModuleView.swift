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
