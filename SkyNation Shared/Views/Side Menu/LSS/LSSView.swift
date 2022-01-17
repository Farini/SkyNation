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

struct LSSView2_Previews: PreviewProvider {
    static var previews: some View {
        LSSReportView(controller: LSSController(scene: .SpaceStation))
            .frame(height:1000)
    }
}
