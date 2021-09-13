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

struct Peripheral_Previews: PreviewProvider {
    
    static var previews: some View {
        PeripheralSmallView(peripheral: PeripheralObject(peripheral: .Electrolizer))
    }
}
