//
//  LSSAirView.swift
//  SkyNation
//
//  Created by Carlos Farini on 1/17/22.
//

import SwiftUI

struct LSSAirView:View {
    
    @Binding var air:AirComposition
    var requiredAirVol:Int
    
    private let goodQualities:[AirQuality] = [.Great, .Good]
    
    var body: some View {
        VStack(alignment:.leading) {
            let airPressure = Double(air.getVolume()) / max(1.0, Double(requiredAirVol)) * 100.0
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Air Quality: \(air.airQuality().rawValue)")
                        .font(.title)
                        .foregroundColor(goodQualities.contains(air.airQuality()) ? .green:.orange)
                    
                    Text("Volume: \(Double(air.getVolume()), specifier: "%.2f") m3 | Required: \(Double(requiredAirVol), specifier: "%.2f") m3")
                        .foregroundColor(GameColors.lightBlue)
                    Text("Pressure: \(airPressure, specifier: "%.2f") KPa")
                        .foregroundColor(.green)
                }
                
                Spacer()
                
            }
            .padding(.leading)
            .padding(.bottom, 6)
            
            Divider()
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Air Composition")
                    .font(.title)
                    .foregroundColor(.blue)
                    .padding(.leading)
                AirCompositionView(air: air)
                    .padding(.bottom, 20)
            }
            .padding([.bottom], 10)
        }
    }
}
