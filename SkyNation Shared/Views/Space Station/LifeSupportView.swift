//
//  LifeSupportView.swift
//  SkyTestSceneKit
//
//  Created by Farini on 9/26/20.
//  Copyright © 2020 Farini. All rights reserved.
//

import SwiftUI

struct LifeSupportView: View {
    
    @ObservedObject var controller:LSSModel
    @State var popTutorial:Bool = false
    
//    var goodQualities:[AirQuality] = [.Great, .Good]
    
    init() {
        self.controller = LSSModel()
    }
    
    var header: some View {
        
        Group {
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
                                    Text("Peripheral")
                                    
                                case .Tank(let tankObject):
                                    
                                    ScrollView {
//                                        TankView(tank: tankObject, model: self.controller)
                                        TankView(tank:tankObject, delegator:self.controller)
                                    }
                                    .frame(maxWidth:.infinity, minHeight:200, maxHeight:.infinity)
                                    
                                case .Box(let storage):
                                    // Storage Box
                                    StorageBoxDetailView(box:storage)
                                    .frame(maxWidth:.infinity, minHeight:200, maxHeight:.infinity)
                                    
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
                        
//                        MachineryView(controller: controller, selected: peripheral)
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
                                
                                AccountingReportView(report: report)
                            } else {
                                // Future's View
                                future
                                
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
        .frame(minWidth: 700, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, minHeight: 250, maxHeight: .infinity, alignment:.topLeading)
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
            
            let mot = controller.station.truss.moneyFromAntenna()
            let pot = LocalDatabase.shared.player?.money ?? 0
            Text("📡 Antenna + 🪙 \(mot)")
            Text("\(mot/pot) %")
            Text("Total: \(GameFormatters.numberFormatter.string(from:NSNumber(value:pot)) ?? "---")")
        }
    }
    
}

struct MachineryView:View {
    
    var delegator:LSSDelegate
//    @ObservedObject var controller:LSSModel
    @State var selected:PeripheralObject?
    
    var body: some View {
        HStack {
            List(delegator.getPeripherals()) { peripheral in
                
                HStack {
                    // Image
                    peripheral.getImage()
                        .frame(width:42, height:42)
                    VStack {
                        Text("\(peripheral.peripheral.rawValue)")
                        Text("Power: \(peripheral.powerOn ? "on":"false")\(peripheral.isBroken ? " broken":"")")
                            .foregroundColor((peripheral.isBroken || !peripheral.powerOn) ? .red:.white)
                    }
                }
                .onTapGesture {
                    self.selected = peripheral
                }
            }
            .frame(maxWidth: 200)
            
            // Detail View
            ScrollView {
                if let peripheral = selected {
//                    PeripheralDetailView(controller: controller, peripheral: peripheral)
                    PeripheralDetailView(delegator: delegator, peripheral: peripheral)
                } else {
                    noSelectionView
                }
            }
            .frame(minWidth: 400, maxWidth:.infinity)
        }
    }
    
    var noSelectionView: some View {
        VStack {
            Spacer()
            Text("Machine decription")
            Spacer()
        }
    }
}

// MARK: - Views Independent from Controllers

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
            .padding()
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Air Composition")
                    .font(.title)
                    .foregroundColor(.blue)
                    .padding()
                AirCompositionView(air: air)
                    .padding([.bottom, .top], 20)
            }
            .padding([.bottom], 10)
        }
    }
}

struct EnergyOverview:View {
    
    @Binding var energyLevel:Double
    @Binding var energyMax:Double
    var energyProduction:Int
    var batteryCount:Int
    var solarPanelCount:Int
    var peripheralCount:Int
    @Binding var deltaZ:Int
    @Binding var conumptionPeripherals:Int
    @Binding var consumptionModules:Int
    @Binding var batteries:[Battery]
    
    // batteries, solar panels, peripherals, delta
    var body: some View {
        VStack {
            
            // Energy
            Group {
                VStack {
                    HStack {
                        Text("Energy")
                        .font(.headline)
                        .foregroundColor(.orange)
                        ZStack {
                            ProgressBar(min: 0.0, max: energyMax, value: $energyLevel, color: .red)
                            Text("Z Level: \(energyLevel, specifier:"%.2f")")
                        }
                    }
                    .frame(idealHeight: 20, maxHeight: 20, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        
                        Text("Breakdown of energy")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        Text("Solar Panels x \(solarPanelCount) Energy produced: \(energyProduction) kW/h")
                            .font(.callout)
                            .foregroundColor(.green)
                        
                        Text("Peripherals: \(peripheralCount) Consumption: \(conumptionPeripherals) kW/h")
                            .font(.callout)
                            .foregroundColor(.orange)
                        
                        Text("Other Consumption: \(consumptionModules) kW/h")
                            .font(.callout)
                            .foregroundColor(.orange)
                        
                        HStack {
                            Text("Delta Z: \(deltaZ > 0 ? "+":"") \(deltaZ)")
                                .font(.callout)
                                .foregroundColor(deltaZ > 0 ? Color.green:Color.red)
                            Text("Delta Z refers to gaining or losing power in batteries")
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        Spacer()
                        
                    }.padding(.leading, /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                    
                    /*
                    HStack {
                        Image("carBattery")
                            .resizable()
                            .frame(width: 32.0, height: 32.0)
                        
                        Text("Batteries: \(batteryCount)")
                        Text("Solar Panels: \(solarPanelCount)")
                        Text("Peripherals: \(peripheralCount)")
                        Text("Delta Z: \(deltaZ)")
                    }.font(.callout)
                    */
                    
                }
            }
            .padding()
            
            // Batteries
            LazyVGrid(columns: [GridItem(.fixed(120)), GridItem(.fixed(120)), GridItem(.fixed(120)), GridItem(.fixed(120))], alignment: .center, spacing: 16, pinnedViews: /*@START_MENU_TOKEN@*/[]/*@END_MENU_TOKEN@*/, content: {
                ForEach(batteries) { battery in
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

struct AccountingReportView: View {
    
    @State var report:AccountingReport
    
    var body: some View {
        VStack {
            
            HStack(spacing:12) {
                Text("🗒 Accounting").font(.title).foregroundColor(.orange)
                Text("📆 \(GameFormatters.dateFormatter.string(from: report.date))")
                    .font(.title).foregroundColor(.orange)
                Spacer()
            }
            .padding(6)
            .padding(.top, 10)
            
            Divider()
            
            HStack {
                
                // Compare Table
                VStack {
                    Text("Compare").foregroundColor(.orange).font(.title2)
                    
                    HStack(spacing:12) {
                        VStack(alignment:.trailing) {
                            Text("Name").foregroundColor(.gray)
                            Text("Energy")
                            Text("Water")
                            Text("Air Vol.")
                            Text("O2")
                            Text("CO2")
                        }
                        
                        VStack {
                            Text("Start").foregroundColor(.gray)
                            Text("\(report.energyStart)")
                            Text("\(report.waterStart)")
                            Text("\(report.airStart.getVolume())")
                            Text("\(report.airStart.o2)")
                            Text("\(report.airStart.co2)")
                        }
                        
                        VStack {
                            Text("Finish").foregroundColor(.gray)
                            Text("\(report.energyFinish ?? 0)")
                            Text("\(report.waterFinish ?? 0)")
                            Text("\(report.airFinish?.getVolume() ?? 0)")
                            Text("\(report.airFinish?.o2 ?? 0)")
                            Text("\(report.airFinish?.co2 ?? 0)")
                        }
                        
                        VStack {
                            Text("+/-").foregroundColor(.gray)
                            Text("\((report.energyFinish ?? 0) - report.energyStart)")
                            Text("\((report.waterFinish ?? 0) - report.waterStart)")
                            Text("\((report.airFinish?.getVolume() ?? 0) - report.airStart.getVolume())")
                            Text("\((report.airFinish?.o2 ?? 0) - report.airStart.o2)")
                            Text("\((report.airFinish?.co2 ?? 0) - report.airStart.co2)")
                        }
                    }
                }
                .padding()
                
                Spacer()
            }
                
            // Problems + Notes
            VStack(alignment:.leading) {
                // Problems
                Group {
                    Text("⚠️ Issues")
                        .foregroundColor(.orange)
                        .font(.title3)
                    Divider()
                    
                    ForEach(report.listProblems(), id:\.self) { aProblem in
                        Text(aProblem).foregroundColor(.red)
                    }
                }
                
                Group {
                    Text("⚙️ Machinery")
                        .foregroundColor(.orange)
                        .font(.title3)
                        .padding(.vertical, 6)
                    Divider()
                    
                    ForEach(report.peripheralNotes, id:\.self) { perinote in
                        Text(perinote)
                    }
                }
                
                Group {
                    Text("👩‍🚀 Astronauts")
                        .foregroundColor(.green)
                        .font(.title3)
                        .padding(.vertical, 6)
                    
                    Divider()
                    ForEach(report.humanNotes, id:\.self) { humannote in
                        Text(humannote)
                    }
                    
                    Text("--- Waste Production ----").foregroundColor(.gray)
                    Text("💩  \(report.poopFinish ?? 0)")
                    Text("💦  \(report.wasteWaterFinish ?? 0)")
                    Divider()
                }
                
                
                Text("🗒 Notes")
                    .foregroundColor(.blue)
                    .font(.title3)
                    .padding(.vertical, 6)
                ForEach(report.listNotes(), id:\.self) { aNote in
                    Text(aNote).foregroundColor(.gray)
                }
            }
            
        }
        .padding()
        
    }
}

// MARK: - Previews

struct LifeSupportView_Previews: PreviewProvider {
    static var previews: some View {
        LifeSupportView()
    }
}

struct StationAccounting_Previews: PreviewProvider {
    static var previews: some View {
        AccountingReportView(report: AccountingReport.example()!)
            .frame(height:1500)
    }
}