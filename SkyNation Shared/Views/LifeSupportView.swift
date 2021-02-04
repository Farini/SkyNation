//
//  LifeSupportView.swift
//  SkyTestSceneKit
//
//  Created by Farini on 9/26/20.
//  Copyright © 2020 Farini. All rights reserved.
//

import SwiftUI

enum LSSSegment: String, CaseIterable {
    case AirLevels
    case Resources
    case Energy
    case Accounting
}

enum LSSViewState {
    case Air
    case Resources(type:RSSType)
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
    
//    @State private var airOption:LSSSegment = .AirLevels
    @State var selectedTank:Tank?
    @State var selectedPeripheral:PeripheralObject?
    @State var selectedBox:StorageBox?
    
    var goodQualities:[AirQuality] = [.Great, .Good]
    
    init() {
        self.controller = LSSModel()
    }
    
    var body: some View {
        
        VStack {
            
            VStack {
                
                // General Header
                HStack {
                    
                    VStack(alignment:.leading) {
                        Text("♻️ Life Support Systems")
                            .font(.largeTitle)
                        Text("Where life is supported")
                            .foregroundColor(.gray)
                            .font(.caption)
                    }
                    
                    Spacer()
                    Text("S$:3,456")
                        .foregroundColor(.green)
                    
                    // Tutorial
                    Button(action: {
                        print("Tutorial action")
                    }, label: {
                        Image(systemName: "questionmark.diamond")
                            .resizable()
                            .aspectRatio(contentMode:.fit)
                            .frame(width:34, height:34)
                    })
                    .buttonStyle(GameButtonStyle(foregroundColor: .white, backgroundColor: .black, pressedColor: .orange))
                    .padding(.trailing, 6)
                    
                    // Close
                    Button(action: {
                        print("Close action")
                        NotificationCenter.default.post(name: .closeView, object: self)
                    }, label: {
                        Image(systemName: "xmark.circle")
                            .resizable()
                            .aspectRatio(contentMode:.fit)
                            .frame(width:34, height:34)
                    })
                    .buttonStyle(GameButtonStyle(foregroundColor: .white, backgroundColor: .black, pressedColor: .orange))
                    .padding(.trailing, 6)
                }
                
                // Segment Picker
                Picker("", selection: $controller.segment) { // Picker("", selection: $airOption) {
                    ForEach(LSSSegment.allCases, id:\.self) { airOpt in
                        Text(airOpt.rawValue)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            .padding([.top, .leading, .trailing])
            Divider()
            
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
                                        
                                        
                                        let foodLasting = Int(controller.availableFood.count / max(1, controller.inhabitants))
                                        let waterLasting = Int(controller.liquidWater / max(1, (controller.inhabitants * GameLogic.waterConsumption)))
                                        
                                        Text("Others")
                                            .font(.title)
                                            .foregroundColor(.orange)
                                            .padding([.top, .bottom])
                                        
                                        Text("💦 Drinkable Water: \(controller.liquidWater). ⏱ \(waterLasting) hrs.")
                                            .foregroundColor(waterLasting > 8 ? .green:.red)
                                        Text("🍽 Edible Food: \(controller.availableFood.count). ⏱ \(foodLasting) hrs.")
                                            .foregroundColor(foodLasting > 8 ? .green:.red)
                                        
                                        if let wasteLiquid = controller.boxes.filter({ $0.type == .wasteLiquid }).map({ $0.current }).reduce(0, +) {
                                            Text("Waste Water: \(wasteLiquid)")
                                        }
                                        if let wasteSolid = controller.boxes.filter({ $0.type == .wasteSolid }).map({ $0.current }).reduce(0, +) {
                                            Text("💩 Solid Waste: \(wasteSolid)")
                                        }
                                        Text("🛰📡 Antenna + 🪙 \(controller.station.truss.moneyFromAntenna())")
                                        
                                        
                                        
                                    }
                                    
                                    Spacer()
                                    
                                    // Timer
                                    VStack {
                                        Text("Account: \(controller.accountDate, formatter:GameFormatters.dateFormatter)")
                                        Text("Head count: \(controller.inhabitants)")
                                    }
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
                                
                                // Peripherals
                                Section(header: Text("Peripherals")) {
                                    ForEach(controller.peripherals) { peripheral in
                                        Text("\(peripheral.peripheral.rawValue)")
                                            .onTapGesture(count: 1, perform: {
                                                controller.didSelect(utility: peripheral)
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
                                case .Peripheral(let periObject):
                                    
                                    ScrollView() {
                                        
                                        // Peripheral
                                        PeripheralDetailView(controller: self.controller, peripheral: periObject)
                                    }
                                    .frame(maxWidth:.infinity, minHeight:200, maxHeight:.infinity)
                                    
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
                    case .Energy:
                        ScrollView {
                            // Energy
                            EnergyOverview(energyLevel: $controller.levelZ, energyMax: $controller.levelZCap, energyProduction: controller.energyProduction, batteryCount: controller.batteries.count, solarPanelCount: controller.solarPanels.count, peripheralCount: controller.peripherals.count, deltaZ: $controller.batteriesDelta, conumptionPeripherals: $controller.consumptionPeripherals, consumptionModules: $controller.consumptionModules)
                            
                            BatteryCollectionView(controller.batteries)
                        }
                    case .Systems:
                        ScrollView {
                            Text("Accounting").font(.headline)
                            Text("Air Vol. \(controller.air.getVolume())")
                            Text("O2: \(controller.air.o2)")
                            Text("CO2: \(controller.air.co2)")
                            //                            Text("N2: \(lssModel.air.n2)")
                            Divider()
                            VStack {
                                ForEach(controller.accountingProblems, id:\.self) { problem in
                                    Text(problem)
                                }
                            }
                            
                            if controller.accountingReport != nil {
                                let report = controller.accountingReport!
                                Divider()
                                VStack {
                                    Text("🗒 Report").font(.title)
                                    Text("📆: \(GameFormatters.dateFormatter.string(from: report.date))")
                                        .padding([.top], 4)
                                        .padding([.bottom], 6)
                                    
                                    Text("Air Start (V): \(report.airStart.getVolume())")
                                    
                                    Text("Energy Start: \(report.energyStart)")
                                    Text("Energy Input: \(report.energyInput)")
                                    Text("Energy Finish:\(report.energyFinish ?? 0)")
                                    
                                    Text("💩 \(report.poopFinish ?? 0)")
                                    Text("Pee: \(report.wasteWaterFinish ?? 0)")
                                    Text("Air adjustment: \(report.tankAirAdjustment ?? 0)")
                                }
                            }
                            Divider()
                            HStack {
                                Button("Accounting") {
                                    print("Run accounting")
                                    controller.runAccounting()
                                }
                                Button("💾 Save") {
                                    print("Test what?")
                                    controller.saveAccounting()
                                }
                            }
                        }
                }
                /*
                switch airOption {
                    case .AirLevels:
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
                                        
                                        
                                        let foodLasting = Int(controller.availableFood.count / max(1, controller.inhabitants))
                                        let waterLasting = Int(controller.liquidWater / max(1, (controller.inhabitants * GameLogic.waterConsumption)))
                                        
                                        Text("Others")
                                            .font(.title)
                                            .foregroundColor(.orange)
                                            .padding([.top, .bottom])
                                        
                                        Text("💦 Drinkable Water: \(controller.liquidWater). ⏱ \(waterLasting) hrs.")
                                            .foregroundColor(waterLasting > 8 ? .green:.red)
                                        Text("🍽 Edible Food: \(controller.availableFood.count). ⏱ \(foodLasting) hrs.")
                                            .foregroundColor(foodLasting > 8 ? .green:.red)
                                        
                                        if let wasteLiquid = controller.boxes.filter({ $0.type == .wasteLiquid }).map({ $0.current }).reduce(0, +) {
                                            Text("Waste Water: \(wasteLiquid)")
                                        }
                                        if let wasteSolid = controller.boxes.filter({ $0.type == .wasteSolid }).map({ $0.current }).reduce(0, +) {
                                            Text("💩 Solid Waste: \(wasteSolid)")
                                        }
                                        
                                        
                                        
                                    }
                                    
                                    Spacer()
                                    
                                    // Timer
                                    VStack {
                                        Text("Account: \(controller.accountDate, formatter:GameFormatters.dateFormatter)")
                                        Text("Head count: \(controller.inhabitants)")
                                    }
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
                    case .Resources:
                        // Tanks + Peripherals
                        Group {
                            HStack {
                                
                                // Left View: List of Resources
                                List() {
                                    // Tanks
                                    Section(header: Text("Tanks")) {
                                        ForEach(controller.tanks) { tank in
                                            TankRow(tank: tank)
                                                .onTapGesture(count: 1, perform: {
                                                    selectedPeripheral = nil
                                                    selectedBox = nil
                                                    selectedTank = tank
                                                })
                                        }
                                    }
                                    
                                    // Peripherals
                                    Section(header: Text("Peripherals")) {
                                        ForEach(controller.peripherals) { peripheral in
                                            Text("\(peripheral.peripheral.rawValue)")
                                                .onTapGesture(count: 1, perform: {
                                                    selectedTank = nil
                                                    selectedBox = nil
                                                    selectedPeripheral = peripheral
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
                                                selectedTank = nil
                                                selectedPeripheral = nil
                                                selectedBox = storageBox
                                            })
                                        }
                                    }
                                }
                                .frame(minWidth:180, maxWidth:220, minHeight:200, maxHeight: .infinity)
                                
                                // Right: Detail View
                                ScrollView() {
                                    VStack {
                                        // Tank
                                        if selectedTank != nil {
                                            
                                            TankView(tank: selectedTank!, model: self.controller)
                                            
                                        }else if selectedPeripheral != nil {
                                            // Peripheral
                                            PeripheralDetailView(controller: self.controller, peripheral: selectedPeripheral!)
                                            
                                        }else if selectedBox != nil {
                                            // Storage Box
                                            StorageBoxDetailView(box:selectedBox!)
                                            
                                        } else {
                                            
                                            // No Selection
                                            VStack(alignment: .center) {
                                                Spacer()
                                                Text("Nothing selected").foregroundColor(.gray)
                                                Divider()
                                                Text("Select something").foregroundColor(.gray)
                                                Spacer()
                                            }
                                            
                                        }
                                    }
                                    
                                }
                                .frame(maxWidth:.infinity, minHeight:200, maxHeight:.infinity)
                            }
                            .frame(maxWidth:.infinity, minHeight:200, maxHeight:.infinity)
                        }//.padding(3)
                    case .Energy:
                        ScrollView {
                            // Energy
                            EnergyOverview(energyLevel: $controller.levelZ, energyMax: $controller.levelZCap, energyProduction: controller.energyProduction, batteryCount: controller.batteries.count, solarPanelCount: controller.solarPanels.count, peripheralCount: controller.peripherals.count, deltaZ: $controller.batteriesDelta, conumptionPeripherals: $controller.consumptionPeripherals, consumptionModules: $controller.consumptionModules)
                            
                            BatteryCollectionView(controller.batteries)
                        }
                    case .Accounting:
                        // Accounting
                        ScrollView {
                            Text("Accounting").font(.headline)
                            Text("Air Vol. \(controller.air.getVolume())")
                            Text("O2: \(controller.air.o2)")
                            Text("CO2: \(controller.air.co2)")
//                            Text("N2: \(lssModel.air.n2)")
                            Divider()
                            VStack {
                                ForEach(controller.accountingProblems, id:\.self) { problem in
                                    Text(problem)
                                }
                            }
                            
                            if controller.accountingReport != nil {
                                let report = controller.accountingReport!
                                Divider()
                                VStack {
                                    Text("🗒 Report").font(.title)
                                    Text("📆: \(GameFormatters.dateFormatter.string(from: report.date))")
                                        .padding([.top], 4)
                                        .padding([.bottom], 6)
                                    
                                    Text("Air Start (V): \(report.airStart.getVolume())")
                                    
                                    Text("Energy Start: \(report.energyStart)")
                                    Text("Energy Input: \(report.energyInput)")
                                    Text("Energy Finish:\(report.energyFinish ?? 0)")
                                    
                                    Text("💩 \(report.poopFinish ?? 0)")
                                    Text("Pee: \(report.wasteWaterFinish ?? 0)")
                                    Text("Air adjustment: \(report.tankAirAdjustment ?? 0)")
                                }
                            }
                            Divider()
                            HStack {
                                Button("Accounting") {
                                    print("Run accounting")
                                    controller.runAccounting()
                                }
                                Button("💾 Save") {
                                    print("Test what?")
                                    controller.saveAccounting()
                                }
                            }
                        }// .padding()
                }
                */
            }
            
        }
        .frame(minWidth: 700, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, minHeight: 250, maxHeight: .infinity, alignment:.topLeading)
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



struct LifeSupportView_Previews: PreviewProvider {
    static var previews: some View {
        LifeSupportView()
    }
}

struct TankView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Tank: - Big")
            TankView(tank:LocalDatabase.shared.station!.truss.getTanks().first!)
            Divider()
            Text("Tank: - Small")
            TankViewSmall(tank: LocalDatabase.shared.station!.truss.getTanks().first!)
        }
        
    }
}

//struct

// FIXME: - Transfer Code.
// Put this code in an Appropriate file

extension PeripheralObject {
    func getImage() -> Image? {
        switch self.peripheral {
            case .Airlock:
                return Image("Airlock")
            case .Antenna:
                return Image("Antenna")
            case .Condensator:
                return Image("Condensator")
            case .Methanizer:
                return Image("Methanizer")
            case .Radiator:
                return Image("Radiator")
            case .Roboarm:
                return Image("Roboarm")
            case .ScrubberCO2:
                return Image("Scrubber")
            case .solarPanel:
                return Image("SolarPanel")
            case .storageTank:
                return Image("Tank")
            default:
                print("Don't have an image for that yet")
                return nil
        }
    }
}
