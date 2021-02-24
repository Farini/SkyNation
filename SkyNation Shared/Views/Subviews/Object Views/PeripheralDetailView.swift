//
//  PeripheralDetailView.swift
//  SkyNation macOS
//
//  Created by Carlos Farini on 1/25/21.
//

import SwiftUI

struct PeripheralDetailView: View {
    
    @ObservedObject var controller:LSSModel
    var peripheral:PeripheralObject
    
    var body: some View {
        VStack {
            
            // Presentation
            Text("\(peripheral.peripheral.rawValue)")
                .font(.title)
            
            if let _ = peripheral.getImage() {
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
                if let d = peripheral.lastFixed?.timeIntervalSince(Date()) {
                    Text("Time (let d): \(d) s")
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
                    
                    
                    ForEach(controller.peripheralMessages, id:\.self) { msg in
                        Text(msg)
                            .foregroundColor(.green)
                            .frame(width: 300, alignment: .center)
                    }
                    
                    ForEach(controller.peripheralIssues, id:\.self) { msg in
                        Text(msg)
                            .foregroundColor(.red)
                            .frame(width: 300, alignment: .center)
                    }
                    
                    Button("Instant Use") {
//                        print("Instause!")
                        controller.instantUse(peripheral: peripheral)
                    }
                    Divider()
                }
            }
            
            // Buttons
            HStack {
                Button("Fix") {
//                    peripheral.isBroken.toggle()
//                    peripheral.lastFixed = Date()
                    controller.fixBroken(peripheral: peripheral)
                }
                .disabled(!peripheral.isBroken)
                
                Button("Break") {
                    peripheral.isBroken.toggle()
                }
                .disabled(peripheral.isBroken)
                
//                Toggle("Power", isOn: $peripheral.powerOn)
            }
            .padding()
        }
    }
}

struct PeripheralSmallView: View {
    
    @State var peripheral:PeripheralObject
    
    var body: some View {
        VStack {
            peripheral.getImage()
            Text("\(peripheral.peripheral.rawValue)")
        }
    }
    
}

struct PeripheralDetailView_Previews: PreviewProvider {
    
    static var peripherals:[PeripheralObject] = [
        PeripheralObject(peripheral: .Electrolizer),
        PeripheralObject(peripheral: .Antenna),
        PeripheralObject(peripheral: .Condensator),
        PeripheralObject(peripheral: .ScrubberCO2),
        PeripheralObject(peripheral: .Radiator) ]
    
    static var previews: some View {
        ForEach(peripherals, id:\.id) { peri in
            PeripheralDetailView(controller:LSSModel(), peripheral: peri)
        }
        
    }
}
