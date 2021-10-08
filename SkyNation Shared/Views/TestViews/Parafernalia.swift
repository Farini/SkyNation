//
//  Parafernalia.swift
//  SkyTestSceneKit
//
//  Created by Farini on 9/19/20.
//  Copyright © 2020 Farini. All rights reserved.
//

import SwiftUI


struct TypographyView: View {
    var body: some View {
        VStack(alignment:.leading) {
            Text("Ailerons")
                .font(Font.custom("Ailerons", size: 24))
                .padding(.horizontal)
                .padding(.top)
                .foregroundColor(Color("LightBlue"))
            
            Divider()
            
            Group() {
                Text("Paragraph. The paragraph should be a fixed width font. Maybe Roboto mono?")
                    .font(Font.custom("Roboto Mono", size: 14))
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(3)
                    .padding(.bottom, 6)
                
                Text("There should also be a message in gray.")
                    .font(Font.custom("Roboto Mono", size: 14))
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundColor(.gray)
                    .padding(.bottom, 6)
                
                HStack {
                    VStack {
                        Text("ABCDEF 12345")
                            .font(Font.custom("Roboto Mono", size: 14))
                            .foregroundColor(.orange)
                        
                        Text("abcdef 12345")
                            .font(Font.custom("Roboto Mono", size: 14))
                        Text("FEDcba 12345")
                            .font(Font.custom("Roboto Mono", size: 14))
                            .foregroundColor(.green)
                        Text("TestMy Space")
                            .font(Font.custom("Roboto Mono", size: 14))
                            .foregroundColor(.blue)
                    }
                    VStack {
                        HStack {
                            Rectangle()
                                .foregroundColor(.orange)
                            Rectangle()
                                .foregroundColor(.green)
                            Rectangle()
                                .foregroundColor(.red)
                        }
                        HStack {
                            Rectangle()
                                .foregroundColor(Color("LightBlue"))
                            Rectangle()
                                .foregroundColor(.gray)
                        }
                        HStack {
                            Rectangle()
                                .foregroundColor(.black)
                            Rectangle()
                                .foregroundColor(Color("DarkGray"))
                        }
                        
                    }
                }
                
                
                
            }
            .padding(.horizontal)
            
            Divider()
            
            Text("Image + Selection")
                .font(Font.custom("Ailerons", size: 24))
                .padding(.leading)
            
            HStack {
                PeripheralObject(peripheral: .Airlock).getImage()
                    .padding()
                    .background(Color.black)
                    .cornerRadius(8)
                
                
                PeripheralObject(peripheral: .Airlock).getImage()
                    .padding()
                    .background(Color.black)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .inset(by: 0.5)
                            .stroke(Color.blue, lineWidth: 2)
                    )
                
            }
            .padding()
            
            
            
            CautionStripeShape()
                .fill(Color.orange, style: FillStyle(eoFill: false, antialiased: true))
                .foregroundColor(Color.white)
                .frame(width: 300, height: 15, alignment: .center)
            
            Text("status message")
                .font(Font.custom("Roboto Mono", size: 14))
                .padding(.leading)
                .foregroundColor(.red)
            
            Divider()
            
            HStack {
                Spacer()
                
                Button("Action") {
                    print("Act")
                }
                .buttonStyle(GameButtonStyle())
                .padding(.bottom)
                
                
                Button("Destroy") {
                    print("Act")
                }
                .buttonStyle(GameButtonStyle(labelColor: .red))
                .padding(.bottom)
                
                Spacer()
            }
            .padding(.horizontal)
            
        }
        .frame(width:300)
    }
}

struct TypographyView2: View {
    var body: some View {
        VStack(alignment:.leading) {
            Text("Roboto Slab")
                .font(Font.custom("Roboto Slab", size: 24))
                .padding(.horizontal)
                .padding(.top)
            
            Divider()
            
            Text("Paragraph. The paragraph should be a fixed width font. Maybe Roboto mono?")
                .font(Font.custom("Roboto Mono", size: 14))
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(3)
                .padding()
            
            Text("There should also be a paragraph in gray.")
                .font(Font.custom("Roboto Mono", size: 14))
                .padding()
                .foregroundColor(.gray)
            
            CautionStripeShape()
                .fill(Color.orange, style: FillStyle(eoFill: false, antialiased: true))
                .foregroundColor(Color.white)
                .frame(width: 300, height: 20, alignment: .center)
            
            Text("status message")
                .font(Font.custom("Roboto Mono", size: 14))
                .padding()
                .foregroundColor(.red)
            
            Divider()
            
            HStack {
                Button("Action") {
                    print("Act")
                }
                .buttonStyle(GameButtonStyle())
                .padding(.bottom)
                
                
                Button("Destroy") {
                    print("Act")
                }
                .buttonStyle(GameButtonStyle(labelColor: .red))
                .padding(.bottom)
            }
            .padding(.horizontal)
            
        }
        .frame(width:300)
    }
}

struct TypographyView_Previews: PreviewProvider {
    static var previews: some View {
        TypographyView()
//        TypographyView2()
    }
}

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

