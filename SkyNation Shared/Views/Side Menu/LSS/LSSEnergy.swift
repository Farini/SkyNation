//
//  LSSEnergy.swift
//  SkyNation
//
//  Created by Carlos Farini on 1/17/22.
//

import SwiftUI

struct LSSEnergy: View {
    
    @ObservedObject var controller:LSSController
    
    var body: some View {
        
        VStack {
            Group {
                VStack {
                    HStack {
                        Text("Energy")
                            .font(.headline)
                            .foregroundColor(.orange)
                        ZStack {
                            ProgressBar(min: 0.0, max: Double(controller.zCapLevel), value: .constant(Double(controller.zCurrentLevel)), color: .red)
                            Text("Charge: \(controller.zCurrentLevel) kW")
                        }
                    }
                    .frame(idealHeight: 20, maxHeight: 20)
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        
                        Text("Breakdown of energy")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        Text("Solar Panels x \(controller.zPanels.count) Energy produced: \(controller.zProduction) kW/h")
                            .font(.callout)
                            .foregroundColor(.green)
                        
                        Text("Peripherals: \(controller.peripherals.count) Consumption: \(controller.zConsumeMachine) kW/h")
                            .font(.callout)
                            .foregroundColor(.orange)
                        
                        Text("Other Consumption: \(controller.zConsumeModules) kW/h")
                            .font(.callout)
                            .foregroundColor(.orange)
                        
                        Text("Human Consumption: \(controller.zConsumeHumans) kW/h")
                            .font(.callout)
                            .foregroundColor(.orange)
                        
                        HStack {
                            Text("Delta Z: \(controller.zDelta > 0 ? "+":"") \(controller.zDelta)")
                                .font(.callout)
                                .foregroundColor(controller.zDelta > 0 ? Color.green:Color.red)
                            Text("Delta Z refers to gaining or losing power in batteries")
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        Spacer()
                        
                    }.padding(.leading)
                }
            }
            .padding()
            
            // Batteries
            LazyVGrid(columns: [GridItem(.fixed(120)), GridItem(.fixed(120)), GridItem(.fixed(120)), GridItem(.fixed(120))], alignment: .center, spacing: 16, pinnedViews: /*@START_MENU_TOKEN@*/[]/*@END_MENU_TOKEN@*/, content: {
                ForEach(controller.batteries) { battery in
                    VStack {
                        Image("carBattery")
                            .renderingMode(.template)
                            .resizable()
                            .colorMultiply(.red)
                            .frame(width: 32.0, height: 32.0)
                            .padding([.top, .bottom], 8)
                        ProgressView("\(battery.current) of \(battery.capacity)", value: Float(battery.current), total: Float(battery.capacity))
                    }
                    .frame(width:100)
                    .padding([.leading, .trailing, .bottom], 6)
                    .background(Color.black)
                    .cornerRadius(12)
                    
                }
            })
                .padding([.bottom], 32)
        }
    }
}

struct LSSEnergy_Previews: PreviewProvider {
    static var previews: some View {
        
        LSSEnergy(controller: makeController())
            .frame(height:600)
    }
    
    static func makeController() -> LSSController {
        let ctrl = LSSController(scene: .SpaceStation)
        ctrl.updateTabSelection(tab: .Power)
        return ctrl
    }
}
