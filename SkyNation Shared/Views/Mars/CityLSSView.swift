//
//  CityLSSView.swift
//  SkyNation
//
//  Created by Carlos Farini on 9/1/21.
//

import SwiftUI

struct CityLSSView: View {
    
    @ObservedObject var controller:CityLSSController = CityLSSController()
    @State var popTutorial:Bool = false
    
    var header: some View {
        
        VStack {
            HStack() {
                
                VStack(alignment:.leading) {
                    Text("♻️ Life Support Systems")
                        .font(.largeTitle)
                    Text("Where life is supported")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
                
                Spacer()
                
                // Tutorial
                Button(action: {
                    print("Question ?")
                    popTutorial.toggle()
                }, label: {
                    Image(systemName: "questionmark.circle")
                        .font(.title2)
                })
                .buttonStyle(SmallCircleButtonStyle(backColor: .orange))
                .popover(isPresented: $popTutorial) {
                    TutorialView(tutType: .LSSView)
                }
                
                // Close
                Button(action: {
                    NotificationCenter.default.post(name: .closeView, object: self)
                }) {
                    Image(systemName: "xmark.circle")
                        .font(.title2)
                }.buttonStyle(SmallCircleButtonStyle(backColor: .pink))
                
            }
            .padding([.leading, .trailing, .top], 8)
            
            // Segment Picker
            Picker("", selection: $controller.segment) { // Picker("", selection: $airOption) {
                ForEach(LSSTab.allCases, id:\.self) { airOpt in
                    Text(airOpt.rawValue)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding([.leading, .trailing])
            
            Divider()
                .offset(x: 0, y: -5)
        }
    }
    
    var body: some View {
        
        VStack {
            
            // Header
            header
            
            Group {
                switch controller.viewState {
                    case .Air:
                        ScrollView {
                            VStack {
                                LSSAirView(air:$controller.air, requiredAirVol:controller.requiredAir)
                            }
                        }
                    case .Resources(let type): // RSSType
                        HStack {
                            
                            // Left View: List of Resources
                            List() {
                                
                                // Tanks
                                Section(header:
                                            HStack {
                                                Text("Tanks")
                                                Spacer()
                                                Button("⇣") {
                                                    let tks = self.controller.tanks
                                                    let tks2 = tks.sorted(by: { $0.current < $1.current })
                                                    self.controller.tanks = tks2
                                                }
                                                .padding(.trailing, 6)
                                            }) {
                                    ForEach(controller.tanks) { tank in
                                        TankRow(tank: tank)
                                            .onTapGesture(count: 1, perform: {
                                                controller.didSelect(utility: tank)
                                            })
                                    }
                                }
                                
                                // Ingredients - Boxes
                                Section(header: Text("Ingredients")) {
                                    ForEach(controller.boxes) { storageBox in
                                        HStack {
                                            storageBox.type.image()! //?? Image(systemName:"questionmark")
                                                .resizable()
                                                .frame(width:28, height:28)
                                                .aspectRatio(contentMode: .fit)
                                            
                                            VStack(alignment:.leading) {
                                                Text("\(storageBox.type.rawValue)")
                                                Text("\(storageBox.current)/\(storageBox.type.boxCapacity())")
                                            }
                                            
                                        }
                                        .onTapGesture(count: 1, perform: {
                                            // Select Box Here
                                            controller.didSelect(utility: storageBox)
                                        })
                                    }
                                }
                            }
                            .frame(minWidth:180, maxWidth:220, minHeight:200, maxHeight: .infinity)
                            
                            
                            // Right View (Detail)
                            switch type {
                                case .Peripheral( _):
                                    
                                    ScrollView {
                                        VStack {
                                            Spacer()
                                            Text("Peripheral")
                                            Spacer()
                                        }
                                    }
                                    
                                    
                                case .Tank(let tankObject):
                                    
                                    ScrollView {
                                        TankView(tank: tankObject, delegator:self.controller)
                                    }
                                    .frame(maxWidth:.infinity, minHeight:200, maxHeight:.infinity)
                                    
                                case .Box(let storage):
                                    // Storage Box
                                    ScrollView {
                                        VStack {
                                            StorageBoxDetailView(box:storage)
                                                .frame(maxWidth:.infinity, minHeight:200, maxHeight:.infinity)
                                        }
                                    }
                                            
                                            
                                case .None:
                                    // No Selection
                                    VStack(alignment: .center) {
                                        Spacer()
                                        Text("Nothing selected").foregroundColor(.gray)
                                        Divider()
                                        Text("Select something").foregroundColor(.gray)
                                        Spacer()
                                    }
                                    .frame(maxWidth:.infinity, minHeight:200, maxHeight:.infinity)
                            }
                        }
                        
                    case .Machinery(let peripheral):
                        
                        MachineryView(delegator: controller, selected: peripheral)
                        
                    case .Energy:
                        ScrollView {

                            // Energy
                            EnergyOverview(energyLevel: $controller.levelZ, energyMax: $controller.levelZCap, energyProduction: controller.energyProduction, batteryCount: controller.batteries.count, solarPanelCount: controller.solarPanels.count, peripheralCount: controller.peripherals.count, deltaZ: $controller.batteriesDelta, conumptionPeripherals: $controller.consumptionPeripherals, consumptionModules: $controller.consumptionModules, batteries:$controller.batteries)
                        }
                        
                    case .Systems:
                        ScrollView {
                            
                            // Accounting Report
                            if controller.accountingReport != nil {
                                /*
                                let report = controller.accountingReport!
                                
                                HStack(spacing:12) {
                                    VStack(alignment:.leading) {
                                        Text("★ Status").foregroundColor(.orange)
                                        Text("👤 Head count: \(controller.inhabitants)")
                                        Text("☀️ Energy Input: \(report.energyInput)")
                                        //                                        Text("☁️ Air adjustment: \(report.tankAirAdjustment ?? 0)")
                                        Text("☁️ Air Quality: \(report.airStart.airQuality().rawValue)")//.font(.title2)
                                            .padding([.bottom])
                                            .foregroundColor([AirQuality.Good, AirQuality.Great].contains(report.airStart.airQuality()) ? Color.green:Color.orange)
                                        
                                        HStack(spacing:12) {
                                            #if os(macOS)
                                            Image(nsImage: GameImages.currencyImage)
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width:22, height:22)
                                            #else
                                            Image(uiImage: GameImages.currencyImage)
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width:22, height:22)
                                            #endif
                                            
                                            VStack(alignment:.leading) {
                                                let mot = controller.station.truss.moneyFromAntenna()
                                                let pot = LocalDatabase.shared.player?.money ?? 0
                                                
                                                Text("\(GameFormatters.numberFormatter.string(from:NSNumber(value:pot)) ?? "---") Sky Coins")//.font(.title2)
                                                Text("📡 lvl \(controller.station.truss.antenna.level), + 🪙 \(mot)").foregroundColor(.gray)
                                            }
                                        }
                                    }
                                    .padding(8)
                                    
                                    Divider()
                                    
                                    // Waste Management
                                    VStack(alignment:.leading) {
                                        
                                        Text("♳ Waste Management")
                                            .font(.title2)
                                            .foregroundColor(.orange)
                                            .padding([.bottom])
                                        
                                        let wasteLiquid = controller.boxes.filter({ $0.type == .wasteLiquid }).map({ $0.current }).reduce(0, +)
                                        let wasteLiquidCap = controller.boxes.filter({ $0.type == .wasteLiquid }).map({ $0.capacity }).reduce(0, +)
                                        
                                        if wasteLiquidCap > 0 {
                                            let wasteRatio:Double = Double(wasteLiquid) / Double(wasteLiquidCap)
                                            let wasteLiquidPct = Int(wasteRatio * 100.0)
                                            ProgressView("💦 liquid | \(wasteLiquid) of \(wasteLiquidCap). \(wasteLiquidPct)%", value: Float(wasteLiquid), total: Float(wasteLiquidCap))
                                        } else {
                                            Text("< No liquid waste container >").foregroundColor(.gray)
                                        }
                                        
                                        let wasteSolid = controller.boxes.filter({ $0.type == .wasteSolid }).map({ $0.current }).reduce(0, +)
                                        let wasteSolidCap = controller.boxes.filter({ $0.type == .wasteSolid }).map({ $0.capacity }).reduce(0, +)
                                        
                                        if wasteSolidCap > 0 {
                                            let solidPCT:Double = max(1.0, Double(wasteSolid)) / max(1.0, Double(wasteSolidCap))
                                            let wasteSolidPct = Int(solidPCT) * 100
                                            ProgressView("💩 solid |  \(wasteSolid) of \(wasteSolidCap). \(wasteSolidPct)%", value: Float(wasteSolid), total: Float(wasteSolidCap))
                                        } else {
                                            Text("< No solid waste container >").foregroundColor(.gray)
                                        }
                                    }
                                    .padding(8)
                                    .frame(maxWidth:250)
                                    
                                    Divider()
                                    
                                    VStack(alignment:.leading) {
                                        let foodLasting = Int(controller.availableFood.count / max(1, controller.inhabitants))
                                        let waterLasting = Int(controller.liquidWater / max(1, (controller.inhabitants * GameLogic.waterConsumption)))
                                        let oxygenLasting = Int(controller.air.o2 / max(1, (controller.inhabitants * 2)))
                                        
                                        Text("⏱ Future")
                                            .font(.title3)
                                            .foregroundColor(.orange)
                                        
                                        HStack {
                                            CautionStripeShape()
                                                .fill(Color.orange.opacity(0.5), style: FillStyle(eoFill: false, antialiased: true))
                                                .frame(width:64, height:14)
                                            Spacer()
                                        }
                                        
                                        
                                        Text("💦 Water: \(controller.liquidWater). ⏱ \(waterLasting) hrs.")
                                            .foregroundColor(waterLasting > 8 ? .green:.red)
                                        Text("🍽 Food: \(controller.availableFood.count). ⏱ \(foodLasting) hrs.")
                                            .foregroundColor(foodLasting > 8 ? .green:.red)
                                        Text("☁️ Oxygen: \(Int(controller.air.o2)). ⏱ \(oxygenLasting) hrs.")
                                            .foregroundColor(oxygenLasting > 8 ? .blue:.red)
                                        
                                        Spacer()
                                    }
                                    .padding(8)
                                }
                                */
                                
//                                AccountingReportView(report: report)
                                VStack {
                                    Spacer()
                                    Text("Acc repo")
                                    Spacer()
                                }
                                
                            } else {
                                // Future's View
//                                future
                                
                                Group {
                                    Text("Accounting").font(.headline)
                                    Text("Air Vol. \(controller.air.getVolume())")
                                    Text("O2: \(controller.air.o2)")
                                    Text("CO2: \(controller.air.co2)")
                                    Text("Head count: \(controller.inhabitants)")
                                }
                            }
                            Divider()
                        }
                        .frame(maxHeight:800)
                } // Ends viewState
            } // Ends group
        } // Ends VStack
        .frame(minWidth: 700, maxWidth: .infinity, minHeight: 250, maxHeight: .infinity, alignment:.topLeading)
    }
    
    /// Future displays how long water and food is going to last
    var future: some View {
        
        let foodLasting = Int(controller.availableFood.count / max(1, controller.inhabitants))
        let waterLasting = Int(controller.liquidWater / max(1, (controller.inhabitants * GameLogic.waterConsumption)))
        let oxygenLasting = Int(controller.air.o2 / max(1, (controller.inhabitants * 2)))
        
        return VStack(alignment:.leading) {
            
            Group {
                Text("⏱ Future")
                    .font(.title)
                    .foregroundColor(.orange)
                    .padding([.top, .bottom])
                
                Text("💦 Water: \(controller.liquidWater). ⏱ \(waterLasting) hrs.")
                    .foregroundColor(waterLasting > 8 ? .green:.red)
                Text("🍽 Food: \(controller.availableFood.count). ⏱ \(foodLasting) hrs.")
                    .foregroundColor(foodLasting > 8 ? .green:.red)
                Text("☁️ Oxygen: \(Int(controller.air.o2)). ⏱ \(oxygenLasting) hrs.")
                    .foregroundColor(oxygenLasting > 8 ? .blue:.red)
            }
            
            
            Text("⏱ Waste Management")
                .font(.title)
                .foregroundColor(.orange)
                .padding([.top, .bottom])
            
            if let wasteLiquid = controller.boxes.filter({ $0.type == .wasteLiquid }).map({ $0.current }).reduce(0, +) {
                Text("Waste Water: \(wasteLiquid)")
            }
            if let wasteSolid = controller.boxes.filter({ $0.type == .wasteSolid }).map({ $0.current }).reduce(0, +) {
                Text("💩 Solid Waste: \(wasteSolid)")
            }
            
            Text("🪙 Sky Coins")
                .font(.title)
                .foregroundColor(.orange)
                .padding([.top, .bottom])
            
            
            let pot = LocalDatabase.shared.player?.money ?? 0
//            Text("📡 Antenna + 🪙 \(mot)")
//            Text("\(mot/pot) %")
            Text("Total: \(GameFormatters.numberFormatter.string(from:NSNumber(value:pot)) ?? "---")")
        }
    }
}

struct CityLSSView_Previews: PreviewProvider {
    static var previews: some View {
        CityLSSView()
    }
}




