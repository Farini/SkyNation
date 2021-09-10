//
//  Parafernalia.swift
//  SkyTestSceneKit
//
//  Created by Farini on 9/19/20.
//  Copyright © 2020 Farini. All rights reserved.
//

import SwiftUI
/*
struct Parafernalia: View {
    @State var backgroundColor:Color = .red
    var station:Station
    var body: some View {
        VStack {
            HStack {
                Text("Opt")
                    .padding()
                    .contextMenu {
                        Button(action: {
                            self.backgroundColor = .red
                        }) {
                            Text("Red")
                        }
                        
                        Button(action: {
                            self.backgroundColor = .green
                        }) {
                            Text("Green")
                        }
                        
                        Button(action: {
                            self.backgroundColor = .blue
                        }) {
                            Text("Blue")
                        }
                    }
                Text("Parafernalia").font(.headline)
            }
            
            Divider()
            HStack(alignment: .top, spacing: 8) {
                VStack(alignment: .center, spacing: 4) {
                    
                    Text("Peripherals: \(station.peripherals.count)").font(.headline)
                    //                    Text("Objects: \(station.peripherals.count)")
                    //                    Divider()
                    ForEach(self.station.peripherals) { peri in
                        HStack {
                            Text("\(peri.peripheral.rawValue)")
                                .padding(3)
                            Text(peri.breakable ? "Breakable":"Unbreakable")
                                .foregroundColor(peri.breakable ? .orange:.green)
                        }
                    }
                }
                Divider()
                VStack(alignment: .center, spacing: 4) {
                    Text("Storage").font(.headline)
                    ForEach(self.station.truss.extraBoxes) { storage in
                        HStack {
                            Text("\(storage.type.rawValue)")
                                .padding(3)
                            Text("\(storage.current) of \(storage.capacity)")
                        }
                        
                    }
                }
                Divider()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Tanks").font(.headline)
                    ForEach(self.station.truss.getTanks()) { tank in
                        HStack {
                            Text("\(tank.type.rawValue) ")
                            Text("\(tank.current) of \(tank.capacity)")
                        }
                    }
                }
            }
            
            
            
        }.padding()
    }
}

struct Parafernalia_Previews: PreviewProvider {
    static var previews: some View {
        Parafernalia(station:LocalDatabase.shared.station!)
    }
}
*/

