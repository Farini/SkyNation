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

struct PeripheralRowView: View {
    
    @Binding var peripheral:PeripheralObject
    var isSelected:Bool
    
    var body: some View {
        HStack {
            // Image
            peripheral.getImage()!
                .resizable()
                .frame(width:42, height:42)
            
            VStack(alignment:.leading) {
                Text("\(peripheral.peripheral.rawValue)")
                    .font(GameFont.section.makeFont())
                
                HStack {
                    Image(systemName: "power.circle")
                        .foregroundColor(peripheral.powerOn ? peripheral.isBroken ? .red:.green:.gray)
                    if peripheral.powerOn {
                        if peripheral.isBroken {
                            Text("broken").foregroundColor(.red)
                        } else {
                            Text("working")
                        }
                    } else {
                        Text("off").foregroundColor(.gray)
                    }
                }
            }
            
            Spacer()
        }
        .frame(width:180)
        .padding(6)
        .background(isSelected == true ? Color.blue.opacity(0.3):Color.clear)
        .cornerRadius(6)
        
    }
}

// MARK: - Previews

/*
struct Peripheral_Previews: PreviewProvider {
    
    static var previews: some View {
        PeripheralSmallView(peripheral: PeripheralObject(peripheral: .Electrolizer))
    }
}
*/

struct PeripheralRow_Previews: PreviewProvider {
    static let peri = PeripheralObject(peripheral: .Condensator)
//    static let peri2 = PeripheralObject(peripheral: .WaterFilter)
    
    static var previews: some View {
        VStack {
            ForEach(makePeripherals()){ peripheral in
                PeripheralRowView(peripheral: .constant(peripheral), isSelected: false)
//                PeripheralRowView(peripheral: .constant(peri2), isSelected: true)
            }
            PeripheralRowView(peripheral: .constant(peri), isSelected: true)
        }
    }
    
    static func makePeripherals() -> [PeripheralObject] {
        let peri = PeripheralObject(peripheral: .Condensator)
        let peri2 = PeripheralObject(peripheral: .WaterFilter)
        let peri3 = PeripheralObject(peripheral: .Electrolizer)
        peri3.powerOn = false
        return [peri, peri2, peri3]
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
