//
//  PeripheralDetailView.swift
//  SkyNation macOS
//
//  Created by Carlos Farini on 1/25/21.
//

import SwiftUI

struct PeripheralSmallView: View {
    
    @State var peripheral:PeripheralObject
    
    var body: some View {
        VStack {
            peripheral.getImage()
            Text("\(peripheral.peripheral.rawValue)")
        }
    }
}

struct PeripheralSmallSelectView: View {
    
    @State var peripheral:PeripheralObject
    @State var selected:Bool = false
    
    private let shape = RoundedRectangle(cornerRadius: 8, style: .continuous)
    private let unselectedColor:Color = Color.white.opacity(0.4)
    private let selectedColor:Color = Color.blue
    
    var body: some View {
        HStack {
            peripheral.getImage()!
                .resizable()
                .frame(width: 32, height: 32, alignment: .center)
            VStack {
                Text("\(peripheral.peripheral.rawValue)")
                Text(peripheral.isBroken ? "Broken":"Working")
                    .foregroundColor(peripheral.isBroken ? Color.red:Color.green)
            }
            .padding(.trailing, 4)
            
        }
        .padding(6)
        .overlay(
            shape
                .inset(by: selected ? 1.0:0.5)
                .stroke(selected ? selectedColor:unselectedColor, lineWidth: selected ? 1.5:1.0)
        )
    }
}

struct Peripheral_Previews: PreviewProvider {
    
    static var previews: some View {
        PeripheralSmallView(peripheral: PeripheralObject(peripheral: .Electrolizer))
    }
}

struct PeripheralSmallSelect_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack {
            Text("Selectable Tanks")
                .font(.title2)
                .foregroundColor(.orange)
                .padding()
            
            PeripheralSmallSelectView(peripheral: PeripheralObject(peripheral: .Electrolizer))
            PeripheralSmallSelectView(peripheral: PeripheralObject(peripheral: .Radiator), selected:true)
        }
        .padding(.bottom)
    }
}
