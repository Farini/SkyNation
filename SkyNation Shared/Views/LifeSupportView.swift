//
//  LifeSupportView.swift
//  SkyTestSceneKit
//
//  Created by Farini on 9/26/20.
//  Copyright © 2020 Farini. All rights reserved.
//

import SwiftUI

enum LSSTab:String, CaseIterable {
    case Air
    case Resources
    case Machinery
    case Power
    case System
}

enum LSSViewState {
    case Air
    case Resources(type:RSSType)
    case Machinery(object:PeripheralObject?)
    case Energy
    case Systems
}

enum RSSType {
    case Peripheral(object:PeripheralObject)
    case Tank(object:Tank)
    case Box(object:StorageBox)
    case None
}

struct LifeSupportView: View {
    
    @ObservedObject var controller:LSSModel
    
    var goodQualities:[AirQuality] = [.Great, .Good]
    
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
                }, label: {
                    Image(systemName: "questionmark.circle")
                        .font(.title2)
                })
                .buttonStyle(SmallCircleButtonStyle(backColor: .orange))
                
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
                            VStack(alignment:.leading) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Air Quality: \(controller.air.airQuality().rawValue)")
                                            .font(.title)
                                            .foregroundColor(goodQualities.contains(controller.air.airQuality()) ? .green:.orange)
                                        
                                        Text("Volume: \(Double(self.controller.air.getVolume()), specifier: "%.2f") m3 | Required: \(Double(self.controller.requiredAir), specifier: "%.2f") m3")
                                            .foregroundColor(GameColors.lightBlue)
                                        Text("Pressure: \(Double(self.controller.airPressure), specifier: "%.2f") KPa")
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
                                    AirCompositionView(air: controller.air)
                                        .padding([.bottom, .top], 20)
                                }
                                .padding([.bottom], 10)
                            }
                        }
                    case .Resources(let type): // RSSType
                        HStack {
                            
                            // Left View: List of Resources
                            List() {
                                // Tanks
                                Section(header: Text("Tanks")) {
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
                                        VStack {
                                            Text("\(storageBox.type.rawValue)")
                                            Text("\(storageBox.current)/\(storageBox.type.boxCapacity())")
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
                                        TankView(tank: tankObject, model: self.controller)
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
                        
                        MachineryView(controller: controller, selected: peripheral)

                    case .Energy:
                        ScrollView {
                            // Energy
                            EnergyOverview(energyLevel: $controller.levelZ, energyMax: $controller.levelZCap, energyProduction: controller.energyProduction, batteryCount: controller.batteries.count, solarPanelCount: controller.solarPanels.count, peripheralCount: controller.peripherals.count, deltaZ: $controller.batteriesDelta, conumptionPeripherals: $controller.consumptionPeripherals, consumptionModules: $controller.consumptionModules)
                            
//                            BatteryCollectionView(controller.batteries)
                            
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
                    case .Systems:
                        ScrollView {
                            
                            // Accounting Report
                            if controller.accountingReport != nil {
                                let report = controller.accountingReport!
                                VStack {
                                    Text("Current Status").font(.title).foregroundColor(.orange)
                                    Text("👤 Head count: \(controller.inhabitants)")
                                    Text("☀️ Energy Input: \(report.energyInput)")
                                    Text("☁️ Air adjustment: \(report.tankAirAdjustment ?? 0)")
                                }
                                AccountingReportView(report: report)
                            }
                            
                            // Future's View
                            future
                            
                            Divider()
                            
                            // General air condition?
                            Group {
                                Text("Accounting").font(.headline)
                                Text("Air Vol. \(controller.air.getVolume())")
                                Text("O2: \(controller.air.o2)")
                                Text("CO2: \(controller.air.co2)")
                                Text("Head count: \(controller.inhabitants)")
                            }
                            
                            Divider()
                            
                            // Accounting problems
                            VStack {
                                ForEach(controller.accountingProblems, id:\.self) { problem in
                                    Text(problem)
                                }
                            }
                        }
                }
                
            }
            
        }
        .frame(minWidth: 700, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, minHeight: 250, maxHeight: .infinity, alignment:.topLeading)
    }
    
    /// Future displays how long water and food is going to last
    var future: some View {
        
        let foodLasting = Int(controller.availableFood.count / max(1, controller.inhabitants))
        let waterLasting = Int(controller.liquidWater / max(1, (controller.inhabitants * GameLogic.waterConsumption)))
        let oxygenLasting = Int(controller.air.o2 / max(1, (controller.inhabitants * 2)))
        
        return VStack(alignment:.leading) {
            
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
            
            Text("⏱ Money")
                .font(.title)
                .foregroundColor(.orange)
                .padding([.top, .bottom])
            
            Text("🛰📡 Antenna + 🪙 \(controller.station.truss.moneyFromAntenna())")
            Text("TTL Money: \(LocalDatabase.shared.player?.money ?? 0)")
        }
    }
    
}

struct MachineryView:View {
    
    @ObservedObject var controller:LSSModel
    @State var selected:PeripheralObject?
    
    var body: some View {
        HStack {
            List(controller.peripherals) { peripheral in
                
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
                    PeripheralDetailView(controller: controller, peripheral: peripheral)
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
    
    // batteries, solar panels, peripherals, delta
    var body: some View {
        VStack {
            // Start With the energy View
//            Text("Z: \(energyLevel)").font(.headline).foregroundColor(.orange)
            
            
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
                        Text("Modules Consumption: \(consumptionModules) kW/h")
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
        }
        
    }
}

struct AccountingReportView: View {
    
    @State var report:AccountingReport
    
    var body: some View {
        VStack {
            Text("🗒 Report").font(.title).padding().foregroundColor(.orange)
            
            Text("Air Quality: \(report.airStart.airQuality().rawValue)")
            
            Text("📆 \(GameFormatters.dateFormatter.string(from: report.date))")
                .padding([.top], 4)
                .padding([.bottom], 6)
            
            Text("Compare").foregroundColor(.orange).font(.title)
            
            // Trying Stacks
            Group {
                HStack {
                    VStack(alignment:.trailing) {
                        Text("Name")
                            .foregroundColor(.gray)
                        Text("Energy")
                        Text("Water")
                        Text("Air Vol.")
                        Text("O2")
                        Text("CO2")
                    }
                    
                    VStack {
                        Text("Start")
                            .foregroundColor(.gray)
                        Text("\(report.energyStart)")
                        Text("\(report.waterStart)")
                        Text("\(report.airStart.getVolume())")
                        Text("\(report.airStart.o2)")
                        Text("\(report.airStart.co2)")
                    }
                    
                    VStack {
                        Text("Finish")
                            .foregroundColor(.gray)
                        Text("\(report.energyFinish ?? 0)")
                        Text("\(report.waterFinish ?? 0)")
                        Text("\(report.airFinish?.getVolume() ?? 0)")
                        Text("\(report.airFinish?.o2 ?? 0)")
                        Text("\(report.airFinish?.co2 ?? 0)")
                    }
                    
                    VStack {
                        Text("Difference")
                            .foregroundColor(.gray)
                        Text("+2")
                        Text("---")
                        Text("---")
                        Text("---")
                        Text("---")
                    }
                }
            }
            .padding()
            
            // Problems
            ForEach(report.listProblems(), id:\.self) { aProblem in
                Text(aProblem).foregroundColor(.red)
            }
            
            ForEach(report.listNotes(), id:\.self) { aNote in
                Text(aNote).foregroundColor(.gray)
            }
            
            
            Text("💩 \(report.poopFinish ?? 0)")
            Text("Pee: \(report.wasteWaterFinish ?? 0)")
            Text("Air adjustment: \(report.tankAirAdjustment ?? 0)")
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
    }
}


// FIXME: - Transfer Code.
// Put this code in an Appropriate file


