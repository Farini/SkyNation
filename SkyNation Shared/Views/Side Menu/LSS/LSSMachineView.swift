//
//  LSSMachineView.swift
//  SkyNation
//
//  Created by Carlos Farini on 1/17/22.
//

import SwiftUI

struct LSSMachineView:View {
    
    @ObservedObject var controller:LSSController
    
    /// The Peripheral selected.
    var peripheral:PeripheralObject
    
    var body: some View {
        
        // Detail View
        ScrollView {
            
            VStack {
                
                // Presentation
                Text("\(peripheral.peripheral.rawValue)")
                    .font(.title)
                
                if let detailImageName = peripheral.peripheral.detailImageName {
                    Image(detailImageName)
                } else if let _ = peripheral.getImage() {
                    peripheral.getImage()
                        .fixedSize()
                        .frame(width: 64, height: 64, alignment: .center)
                } else {
                    Image(systemName: "questionmark")
                        .fixedSize()
                        .frame(width: 64, height: 64, alignment: .center)
                }
                
                Text(peripheral.peripheral.describer)
                    .foregroundColor(.gray)
                    .frame(width: 300, alignment: .center)
                
                Divider()
                
                // Conditions
                Group {
                    Text("Breakable: \(peripheral.breakable ? "YES":"NO")")
                        .foregroundColor(peripheral.breakable ? Color.orange:Color.green)
                    
                    Text("Broken: \(peripheral.isBroken ? "YES":"NO")")
                        .foregroundColor(peripheral.isBroken ? Color.red:Color.green)
                    
                    Text("Power: \(peripheral.powerOn ? "On":"Off")")
                        .foregroundColor(peripheral.powerOn ? Color.green:Color.orange)
                    
                    // Time since fixed
                    if let lastFix = peripheral.lastFixed {
                        // Text("Time (let d): \(d) s")
                        let delta = Date().timeIntervalSince(lastFix)
                        let string = delta.stringFromTimeInterval()
                        Text("Fixed \(string) ago.")
                    }
                }
                
                Divider()
                
                if !peripheral.peripheral.instantUse.isEmpty {
                    Group {
                        Text("For 100 energy, this Peripheral can be used intantly to perform the following operation:")
                            .frame(width: 300, alignment: .center)
                            .foregroundColor(.gray)
                            .padding([.bottom], 6)
                        
                        Text(peripheral.peripheral.instantUse)
                            .frame(width: 300, alignment: .center)
                            .padding([.bottom], 6)
                        
                        ForEach(controller.periUseMessages, id:\.self) { msg in
                            Text(msg)
                                .foregroundColor(.orange)
                                .frame(width: 300, alignment: .center)
                        }
                        
                        ForEach(controller.periUseIssues, id:\.self) { msg in
                            Text(msg)
                                .foregroundColor(.red)
                                .frame(width: 300, alignment: .center)
                        }
                        
                        Button("Power Use") {
                            controller.instantUse(peripheral: peripheral)
                        }
                        .buttonStyle(NeumorphicButtonStyle(bgColor:.orange))
                        
                        Divider()
                    }
                }
                
                // Buttons
                HStack {
                    Button("Fix") {
                        controller.fixBroken(peripheral: peripheral)
                    }
                    .buttonStyle(NeumorphicButtonStyle(bgColor:.orange))
                    .disabled(!peripheral.isBroken)
                    
                    Button("Break") {
                        peripheral.isBroken.toggle()
                    }
                    .buttonStyle(NeumorphicButtonStyle(bgColor:.orange))
                    .disabled(peripheral.isBroken)
                    
                    Button(peripheral.powerOn ? "Power off":"Power on") {
                        peripheral.powerOn.toggle()
                    }
                    .buttonStyle(NeumorphicButtonStyle(bgColor:.orange))
                    .disabled(peripheral.isBroken)
                    //                Toggle("Power", isOn: $peripheral.powerOn)
                }
                .padding()
            }
        }
        .frame(minWidth: 400, maxWidth:.infinity)
    }
}
