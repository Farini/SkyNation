//
//  PeripheralDetailView.swift
//  SkyNation macOS
//
//  Created by Carlos Farini on 1/25/21.
//

import SwiftUI

struct PeripheralDetailView: View {
    
    @State var peripheral:PeripheralObject
    
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
                .frame(width: 300, alignment: .leading)
            
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
            
            // Buttons
            HStack {
                Button("Fix") {
                    peripheral.isBroken.toggle()
                    peripheral.lastFixed = Date()
                }
                Button("Use (-10 Energy)") {
                    
                }
                Button("Break") {
                    
                }
                Button("Throw away") {
                    
                }
            }
            .padding()
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
            PeripheralDetailView(peripheral: peri)
        }
        
    }
}
