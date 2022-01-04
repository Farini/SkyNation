//
//  LSSView.swift
//  SkyNation
//
//  Created by Carlos Farini on 9/12/21.
//

import SwiftUI

struct LSSView: View {
    
    @ObservedObject var controller:LSSController
    @State var popTutorial:Bool = false
    
    private static let myGradient = Gradient(colors: [Color.red.opacity(0.6), Color.blue.opacity(0.7)])
    private static let unseGradient = Gradient(colors: [Color.red.opacity(0.3), Color.blue.opacity(0.3)])
    private let selLinear = LinearGradient(gradient: myGradient, startPoint: .topLeading, endPoint: .bottomTrailing)
    private let unselinear = LinearGradient(gradient: unseGradient, startPoint: .topLeading, endPoint: .bottomTrailing)
    
    init(scene:GameSceneType) {
        self.controller = LSSController(scene: scene)
    }
    
    var body: some View {
        VStack {
            // Header
            header
            
            switch controller.viewState {
                case .Air:
                    ScrollView {
                        VStack {
                            LSSAirView(air:$controller.air, requiredAirVol:controller.requiredAir)
                        }
                    }
                // Tank, or Box
                case .Resources(let type):
                    HStack {
                        // Left View: List of Resources
                        List() {
                            // Tanks
                            Section(header: listHeader(box: false)
//                                        HStack {
//                                            Text("Tanks")
//                                            Spacer()
//                                /*
//                                            Button("⇣") {
//
////                                                switch controller.tankSorting {
////
////                                                    case .byEmptiness:
////                                                        controller.tankSorting = .byType
////                                                    case .byType:
////                                                        controller.tankSorting = .byEmptiness
////                                                }
////                                                controller.updateAllData()
//                                                controller.reorderTanks()
//                                            }
//                                            .padding(.trailing, 6)
//                                 */
//                                        }
                            ) {
                                    ForEach($controller.tanks, id:\.id) { tank in
                                    
                                    switch type {
                                        case .Tank(let selTank):
                                            // Tank here
                                            TankRow(tank: tank, selected: selTank == tank.wrappedValue)
                                                .listRowBackground(GameColors.darkGray)
                                                .onTapGesture(count: 1, perform: {
                                                    controller.updateState(newState: .Resources(type: .Tank(tank: tank.wrappedValue)))
                                                })
                                        default:
                                            TankRow(tank: tank, selected: false)
                                                .listRowBackground(GameColors.darkGray)
                                                .onTapGesture(count: 1, perform: {
                                                    controller.updateState(newState: .Resources(type: .Tank(tank: tank.wrappedValue)))
                                                })
                                    }
                                    
                                }
                            }
                            
                            // Ingredients - Boxes
                            Section(header: listHeader(box: true)) {
                                ForEach($controller.boxes) { storageBox in
                                    HStack {
                                        storageBox.wrappedValue.type.image()! //?? Image(systemName:"questionmark")
                                            .resizable()
                                            .frame(width:28, height:28)
                                            .aspectRatio(contentMode: .fit)
                                        
                                        VStack(alignment:.leading) {
                                            Text("\(storageBox.wrappedValue.type.rawValue)")
                                            Text("\(storageBox.wrappedValue.current)/\(storageBox.wrappedValue.type.boxCapacity())")
                                        }
                                        
                                    }
                                    .listRowBackground(GameColors.darkGray)
                                    .onTapGesture(count: 1, perform: {
                                        // Select Box Here
//                                        controller.didSelect(utility: storageBox)
                                        controller.updateState(newState: .Resources(type: .Box(box: storageBox.wrappedValue)))
                                    })
                                }
                            }
                        }
                        .frame(minWidth:180, maxWidth:220, minHeight:200, maxHeight: .infinity)
                        .modifier(GameListModifier())
                        
                        // Right View (Detail)
                        switch type {
                            case .Tank(let tankObject):
                                
                                ScrollView {
                                    let idx = controller.tanks.firstIndex(of: tankObject) ?? 0
                                    TankDetailView(controller: controller, tank: $controller.tanks[idx])
                                }
                                .frame(maxWidth:.infinity, minHeight:200, maxHeight:.infinity)
                                
                            case .Box(let storage):
                                
                                // Storage Box
                                StorageBoxDetailView(box:storage)
                                    .frame(maxWidth:.infinity, minHeight:200, maxHeight:.infinity)
                                
                            case .None:
                                // No Selection
                                VStack(spacing:6) {
                                    Spacer()
                                    Text("Tanks: \(controller.tanks.count)")
                                    Text("Empty Tanks: \(controller.tanks.filter({ $0.current == 0 }).count)")
                                    
                                    Button("Discard Empties") {
                                        controller.discardAllEmptyTanks()
                                    }
                                    .buttonStyle(GameButtonStyle())
                                    .padding(8)
                                    
                                    Text("Ingredient Boxes: \(controller.boxes.count)")
                                    Spacer()
                                    noSelectionView
                                    Spacer()
                                }
                                
                        }
                    }
                
                // Peripherals
                case .Machinery(let mType):
                    HStack {
                        List($controller.peripherals) { peripheral in
                            PeripheralRowView(peripheral: peripheral, isSelected: mType.isSelected(peripheral: peripheral.wrappedValue))
                                .listRowBackground(GameColors.darkGray)
                            .onTapGesture {
                                controller.updateState(newState: .Machinery(type: .Machine(peripheral: peripheral.wrappedValue)))
                            }
                        }
                        .frame(minWidth:180, maxWidth:220, minHeight:200, maxHeight: .infinity)
                        .modifier(GameListModifier())
                        
                        switch mType {
                            case .None:
                                // No Selection
                                VStack(spacing:6) {
                                    Spacer()
                                    Text("Peripherals: \(controller.peripherals.count)")
                                    Text("Broken: \(controller.peripherals.filter({ $0.isBroken == true }).count)").foregroundColor(.red)
                                    Text("Powered off: \(controller.peripherals.filter({ $0.powerOn == false }).count)").foregroundColor(.gray)
                                    
                                    // Peripherals issues + Fix all
                                    Text(controller.periUseIssues.joined(separator: ", "))
                                        .foregroundColor(.red)
                                    let pArray = controller.peripherals.filter({ $0.isBroken == true })
                                    if !pArray.isEmpty {
                                        Button("Fix \(pArray.count) broken") {
                                            for peripheral in pArray {
                                                controller.fixBroken(peripheral: peripheral)
                                                if controller.periUseIssues.isEmpty == false {
                                                    break
                                                }
                                            }
                                        }
                                        .buttonStyle(GameButtonStyle())
                                        .padding(8)
                                    }
                                    
                                    noSelectionView
                                    Spacer()
                                }
                                
                            case .Machine(let peripheral):
                                LSSMachineView(controller:controller, peripheral:peripheral)
                        }
                    }
                    
                case .Energy:
                    
                    ScrollView {
                        LSSEnergy(controller:controller)
                    }
                    .frame(maxHeight:800)
                    
                case .Systems:
                    ScrollView {
                        VStack {
                            LSSReportView(controller:controller)
                            Spacer()
                        }
                    }
                    //.frame(maxHeight:800)
                    
            }
        }
        .frame(minWidth: 700, minHeight: 350, idealHeight:500, maxHeight: .infinity, alignment:.topLeading)
        .background(GameColors.darkGray)
        .cornerRadius(10)
    }
    
    var tabber: some View {
        
        // Tabs
        VStack {
            HStack {
                ForEach(LSSTab.allCases, id:\.self) { aTab in
                    Text(aTab.emoji).font(.largeTitle)
                        .padding(5)
                        .background(controller.selectedTab == aTab ? selLinear:unselinear)
                        .cornerRadius(4)
                        .clipped()
                        .border(controller.selectedTab == aTab ? Color.blue:Color.clear, width: 1)
                        .cornerRadius(6)
                        .help(controller.selectedTab.rawValue)
                        .onTapGesture {
                            controller.updateTabSelection(tab: aTab)
                        }
                }
                
                Spacer()
            }
            .padding(.horizontal, 6)
            .font(.title3)
        }
    }
    
    var header: some View {
        Group {
            HStack() {
                VStack(alignment:.leading) {
                    Text("♻️ Life Support Systems")
                        .font(GameFont.title.makeFont())
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
            tabber
            
            Divider().offset(x: 0, y: -5)
        }
    }
    
    func listHeader(box:Bool) -> some View {
        HStack {
            Text(box == true ? "Boxes & Ingredients":"Tanks")
                .font(GameFont.section.makeFont())
                .foregroundColor(.blue)
            Spacer()
        }
    }
    
    var noSelectionView: some View {
        // No Selection
        VStack(alignment: .center) {
            Spacer()
            Text("< Nothing selected >").foregroundColor(.gray)
            Divider()
            Text("Select something to view details").foregroundColor(.gray)
            Spacer()
        }
        .frame(maxWidth:.infinity, minHeight:200, maxHeight:.infinity)
    }
    
}

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

struct LSSMachineView:View {
    
    @ObservedObject var controller:LSSController
    var peripheral:PeripheralObject
    
    var body: some View {
        
        // Detail View
        ScrollView {
            
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
                    .frame(width: 300, alignment: .center)
                
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
                
                if !peripheral.peripheral.instantUse.isEmpty {
                    Group {
                        Text("For 100 energy, this Peripheral can be used intantly to perform the following operation:")
                            .frame(width: 300, alignment: .center)
                            .foregroundColor(.gray)
                            .padding([.bottom], 6)
                        
                        Text(peripheral.peripheral.instantUse)
                            .frame(width: 300, alignment: .center)
                            .padding([.bottom], 6)
                        
                        ForEach(controller.periUseMessages, id:\.self) { msg in
                            Text(msg)
                                .foregroundColor(.orange)
                                .frame(width: 300, alignment: .center)
                        }
                        
                        ForEach(controller.periUseIssues, id:\.self) { msg in
                            Text(msg)
                                .foregroundColor(.red)
                                .frame(width: 300, alignment: .center)
                        }
                        
                        Button("Instant Use") {
                            //                        print("Instause!")
                            //                        controller.instantUse(peripheral: peripheral)
                            controller.instantUse(peripheral: peripheral)
                        }
                        .buttonStyle(NeumorphicButtonStyle(bgColor:.orange))
                        
                        Divider()
                    }
                }
                
                // Buttons
                HStack {
                    Button("Fix") {
                        controller.fixBroken(peripheral: peripheral)
                    }
                    .buttonStyle(NeumorphicButtonStyle(bgColor:.orange))
                    .disabled(!peripheral.isBroken)
                    
                    Button("Break") {
                        peripheral.isBroken.toggle()
                    }
                    .buttonStyle(NeumorphicButtonStyle(bgColor:.orange))
                    .disabled(peripheral.isBroken)
                    
                    Button(peripheral.powerOn ? "Power off":"Power on") {
                        peripheral.powerOn.toggle()
                    }
                    .buttonStyle(NeumorphicButtonStyle(bgColor:.orange))
                    .disabled(peripheral.isBroken)
                    //                Toggle("Power", isOn: $peripheral.powerOn)
                }
                .padding()
            }
        }
        
        .frame(minWidth: 400, maxWidth:.infinity)
    }
}

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

struct LSSReportView: View {
    
    @ObservedObject var controller:LSSController
    
    var body: some View {
        VStack {
            
            HStack(alignment:.top, spacing:8) {
                
                // General Status
                VStack(alignment:.leading) {
                    Text("★ Status")
                        .font(GameFont.section.makeFont())
                        .padding(.vertical, 4)
                        //.foregroundColor(.orange)
                    
                    HStack {
                        CautionStripeShape()
                            .fill(Color.orange.opacity(0.5), style: FillStyle(eoFill: false, antialiased: true))
                            .frame(width:64, height:8)
                        Spacer()
                    }
                    
                    Text("👤 Head count: \(controller.headCount)")
                    // Text("☀️ Energy Input: \(controller.zProduction)")
                    Text("☁️ Air Quality: \(controller.air.airQuality().rawValue)")
                        .padding([.bottom])
                        .foregroundColor([AirQuality.Good, AirQuality.Great].contains(controller.air.airQuality()) ? Color.green:Color.orange)
                    
                    HStack(spacing:8) {
                        #if os(macOS)
                        Image(nsImage: GameImages.currencyImage)
                            .aspectRatio(contentMode: .fit)
                            .frame(width:20, height:20)
                        #else
                        Image(uiImage: GameImages.currencyImage)
                            .aspectRatio(contentMode: .fit)
                            .frame(width:20, height:20)
                        #endif
                        
                        VStack(alignment:.leading) {
                            let dbShared = LocalDatabase.shared
                            let mot = dbShared.station.truss.moneyFromAntenna()
                            let pot = LocalDatabase.shared.player.money
                            
                            Text("\(GameFormatters.numberFormatter.string(from:NSNumber(value:pot)) ?? "---") Sky Coins")//.font(.title2)
                            Text("📡 lvl \(controller.station?.truss.antenna.level ?? 0), +  \(mot)/Hr").foregroundColor(.gray)
                        }
                    }
                }
                .padding(8)
                
                Divider()
                
                // Waste Management
                VStack(alignment:.leading) {
                    
                    Text("♳ Waste")
                        .font(GameFont.section.makeFont())
                        //.foregroundColor(.orange)
                        .padding(.vertical, 4)
                    
                    HStack {
                        CautionStripeShape()
                            .fill(Color.orange.opacity(0.5), style: FillStyle(eoFill: false, antialiased: true))
                            .frame(width:64, height:8)
                        Spacer()
                    }
                    
                    let wasteLiquid = controller.wLiquidCurrent
                    let wasteLiquidCap = controller.wLiquidCapacity
                    
                    if wasteLiquidCap > 0 {
                        let wasteRatio:Double = Double(wasteLiquid) / Double(wasteLiquidCap)
                        let wasteLiquidPct = Int(wasteRatio * 100.0)
                        ProgressView("💦 liquid | \(wasteLiquid) of \(wasteLiquidCap). \(wasteLiquidPct)%", value: Float(wasteLiquid), total: Float(wasteLiquidCap))
                    } else {
                        Text("< No liquid waste container >").foregroundColor(.gray)
                    }
                    
                    let wasteSolid = controller.wSolidCurrent
                    let wasteSolidCap = controller.wSolidCapacity
                    
                    if wasteSolidCap > 0 {
                        let solidPCT:Double = max(1.0, Double(wasteSolid)) / max(1.0, Double(wasteSolidCap))
                        let wasteSolidPct = Int(solidPCT * 100.0)
                        ProgressView("💩 solid |  \(wasteSolid) of \(wasteSolidCap). \(wasteSolidPct)%", value: Float(wasteSolid), total: Float(wasteSolidCap))
                    } else {
                        Text("< No solid waste container >").foregroundColor(.gray)
                    }
                }
                .padding(6)
                .frame(maxWidth:250)
                
                Divider()
                
                // Future (lasting)
                VStack(alignment:.leading) {
                    
                    let foodLasting = Int(controller.food.count / max(1, controller.headCount))
                    let waterLasting = Int(controller.liquidWater / max(1, (controller.headCount * GameLogic.waterConsumption)))
                    let oxygenLasting = Int(controller.air.o2 / max(1, (controller.headCount * 2)))
                    
                    Text("⏱ Future")
                        .font(GameFont.section.makeFont())
                        .padding(.vertical, 4)
//                        .foregroundColor(.orange)
                    
                    HStack {
                        CautionStripeShape()
                            .fill(Color.orange.opacity(0.5), style: FillStyle(eoFill: false, antialiased: true))
                            .frame(width:64, height:8)
                        Spacer()
                    }
                    
                    Text("💦 Water: \(controller.liquidWater). ⏱ \(waterLasting) hrs.")
                        .foregroundColor(waterLasting > 8 ? .green:.red)
                    Text("🍽 Food: \(controller.food.count). ⏱ \(foodLasting) hrs.")
                        .foregroundColor(foodLasting > 8 ? .green:.red)
                    Text("☁️ Oxygen: \(Int(controller.air.o2)). ⏱ \(oxygenLasting) hrs.")
                        .foregroundColor(oxygenLasting > 8 ? .blue:.red)
                    
                    // Spacer()
                }
                .padding(8)
            }
            
            if let report = controller.accountingReport {
                AccountingReportView(report: report)
            }
            
            Spacer()
        }
    }
}

struct AccountingReportView: View {
    
    @State var report:AccountingReport
    
    var body: some View {
        VStack {
            
            HStack(spacing:12) {
                Text("🗒 Report").font(GameFont.section.makeFont()) //.foregroundColor(.orange)
                Spacer()
                Text("\(GameFormatters.dateFormatter.string(from: report.date))")
                    .font(GameFont.section.makeFont()).foregroundColor(.gray)
                
            }
            .padding(6)
            .padding(.top, 10)
            
            Divider()
            
            HStack {
                
                // Compare Table
                VStack {
                    Text("Last Accounting Cycle").foregroundColor(.orange).font(.title2)
                        .padding(.bottom, 4)
                    
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
                .font(.system(.body, design: .monospaced))
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
                        Text(aProblem)
                            .foregroundColor(.red)
                            .font(GameFont.mono.makeFont())
                    }
                }
                
                Group {
                    Text("⚙️ Machinery")
                        .foregroundColor(.orange)
                        .font(.title3)
                        .padding(.vertical, 6)
                    Divider()
                    
                    ForEach(report.peripheralNotes, id:\.self) { perinote in
                        Text(perinote).font(GameFont.mono.makeFont())
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
                            //.font(.system(.body, design: .monospaced))
                            .font(GameFont.mono.makeFont())
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
                    Text(aNote)
                        .foregroundColor(.gray)
                        .font(GameFont.mono.makeFont())
                }
            }
            
            Spacer()
        }
        .padding()
        
    }
}

// MARK: - Previews

//struct LSSView_Previews: PreviewProvider {
//    static var previews: some View {
//        LSSView(scene: .SpaceStation)
//    }
//}

struct LSSView2_Previews: PreviewProvider {
    static var previews: some View {
        LSSReportView(controller: LSSController(scene: .SpaceStation))
            .frame(height:1500)
    }
}

//struct StationAccounting_Previews: PreviewProvider {
//    static var previews: some View {
//        AccountingReportView(report: AccountingReport.example()!)
//            .frame(height:1200)
//    }
//}
