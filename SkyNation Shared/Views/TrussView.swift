//
//  TrussView.swift
//  SkyTestSceneKit
//
//  Created by Farini on 9/8/20.
//  Copyright © 2020 Farini. All rights reserved.
//

import SwiftUI

// Layout the Objects (Solar Panels + Radiators)

struct TrussLayoutView: View {
    
    let row1:[Int] = [11, 31, 13]
    let row2:[Int] = [12, 32, 14]
    let midRow:[Int] = [0]
    let row3:[Int] = [15, 33, 17]
    let row4:[Int] = [16, 34, 18]
    
    @ObservedObject var controller:TrussLayoutController = TrussLayoutController()
    @State var selectedComponent:TrussComponent?
    
    var body: some View {
        VStack {
            
            Text("Truss Arrangement")
                .font(.largeTitle)
                .padding([.top])
            
            Text("Tap, or click an item (origin), and then a destination to move it.")
                .foregroundColor(.gray)
            
            Divider()
            
            HStack(alignment: .top, spacing: 12) {
                
                // Left Most
                VStack {
                    ForEach(controller.truss.tComponents.filter({row1.contains($0.posIndex)})) { comp in
                        Text("\(comp.allowedType.rawValue)")
                            .foregroundColor(comp.itemID == nil ? .gray:.blue)
                            .padding(6)
                            .onTapGesture {
                                self.didSelect(item: comp)
                            }
                    }
                }
                
                // Mid Left
                VStack {
                    ForEach(controller.truss.tComponents.filter({row2.contains($0.posIndex)})) { comp in
                        Text("\(comp.allowedType.rawValue)")
                            .foregroundColor(comp.itemID == nil ? .gray:.blue)
                            .padding(6)
                            .onTapGesture {
                                self.didSelect(item: comp)
                            }
                    }
                }
                
                // Middle
                VStack {
                    ForEach(controller.truss.tComponents.filter({midRow.contains($0.posIndex)})) { comp in
                        Text("\(comp.allowedType.rawValue)")
                            .foregroundColor(comp.itemID == nil ? .gray:.blue)
                            .padding(6)
                            .onTapGesture {
                                self.didSelect(item: comp)
                            }
                    }
                }
                
                // Mid-Right
                VStack {
                    ForEach(controller.truss.tComponents.filter({row3.contains($0.posIndex)})) { comp in
                        Text("\(comp.allowedType.rawValue)")
                            .foregroundColor(comp.itemID == nil ? .gray:.blue)
                            .padding(6)
                            .onTapGesture {
                                self.didSelect(item: comp)
                            }
                    }
                }
                
                // Right-Most
                VStack {
                    ForEach(controller.truss.tComponents.filter({row4.contains($0.posIndex)})) { comp in
                        Text("\(comp.allowedType.rawValue)")
                            .foregroundColor(comp.itemID == nil ? .gray:.blue)
                            .padding(6)
                            .onTapGesture {
                                self.didSelect(item: comp)
                            }
                    }
                }
                
            }
            .padding()
            
            Divider()
            
            // Selection
            Group {
                Text("Selection")
                    .font(.title3)
                
                HStack(spacing: 12) {
                    if let selected = controller.selectedComponent {
                        TrussSelectionView(component: selected, descriptor: controller.describe(component: selected))
                    } else {
                        Text("Nothing selected")
                            .foregroundColor(.gray)
                    }
                    VStack {
                        Button("Save") {
                            controller.saveSetup()
                            GameWindow.closeWindow()
                        }
                        Button("Cancel") {
                            print("Cancel doesnt do much")
                            GameWindow.closeWindow()
                        }
                    }
                }
                
                
                if let message = controller.selectionMessage {
                    Text("\(message)")
                }
            }
            .padding()
            
        }
        
    }
    
    func didSelect(item:TrussComponent) {
        
        controller.didTap(component: item)
        
    }
    
}

struct TrussSelectionView: View {
    
    var component:TrussComponent
    var descriptor:String
    
    var body: some View {
        VStack {
            Text("\(component.allowedType.rawValue)")
            Text("POS \(component.posIndex)")
            Text(descriptor).foregroundColor(descriptor == "(Available)" ? .gray:.blue)
        }
        .padding(6)
        .background(Color.black)
        .cornerRadius(8)
        .padding(2)
    }
}

struct TrussComponentView: View {
    
    var component:TrussComponent
    
    var body: some View {
        VStack {
            Text("\(component.allowedType.rawValue)")
                .foregroundColor(component.itemID == nil ? .gray:.blue)
                .padding(6)
                
        }
    }
    
}

struct TrussView_Previews: PreviewProvider {
    static var previews: some View {
        TrussLayoutView()
    }
}

class TrussLayoutController: ObservableObject {
    
    private var station:Station
    
    @Published var truss:Truss
    @Published var slots:[TrussComponent]
    @Published var solarPanels:[SolarPanel]
    
    /// Panels that aren't in the Truss yet
    @Published var unassignedPanels:[SolarPanel] = []
    
    @Published var selectedComponent:TrussComponent?
    @Published var selectionMessage:String?
    
    init() {
        
        let station = LocalDatabase.shared.station!
        self.station = station
        self.truss = station.truss
        self.slots = station.truss.tComponents
        self.solarPanels = station.truss.solarPanels
        
        // After init
        self.autoAssignSolarPanels()
    }
    
    private func autoAssignSolarPanels() {
        
        for panel in solarPanels {
            do {
                try self.truss.addSolar(panel: panel)
                print("Solar assigned just now")
            } catch {
                if let gError = error as? AddingTrussItemProblem {
                    switch gError {
                        case .ItemAlreadyAssigned:
                            print("Item already assigned. This is ok")
                        case .NoAvailableComponent:
                            print("No available component")
                        case .Invalidated:
                            print("ERROR: see 'invalidated'")
                    }
                } else {
                    print("Another error occurred")
                }
            }
        }
    }
    
    func didTap(component:TrussComponent) {
        
        print("Selecting Component position index: \(component.posIndex), type:\(component.allowedType)")
        selectionMessage = nil
        
        if selectedComponent == nil {
            selectedComponent = component
        } else {
            // Previously selected component
            let previous:TrussComponent = selectedComponent!
            
            // Check if the same -> deselect
            if previous.id == component.id {
                // Same component. De-select
                print("De-selecting component")
                self.selectedComponent = nil
                return
            }
            
            if previous.allowedType == component.allowedType {
                // Swap? To swap, one must be busy and the other isn't
                if let previousID = previous.itemID, component.itemID == nil {
                    print("Swapping previous")
                    previous.itemID = nil
                    component.itemID = previousID
                    selectedComponent = nil
                    selectionMessage = "Swapped Components"
                    return
                } else if let currentID = component.itemID, previous.itemID == nil {
                    print("Swapping current")
                    component.itemID = nil
                    previous.itemID = currentID
                    selectedComponent = nil
                    selectionMessage = "Swapped Components"
                    return
                } else {
                    // They are either both busy, or both free. Set the selected to the current
                    self.selectedComponent = component
                    selectionMessage = "Updated selected component"
                }
            } else {
                // Different types. Just set the current selected
                self.selectedComponent = component
                selectionMessage = "Updated selected component"
            }
        }
    }
    
    func describe(component:TrussComponent) -> String {
        if component.itemID == nil { return "(Available)" } else {
            switch component.allowedType {
                case .Solar:
                    guard let panel = truss.solarPanels.first(where: { $0.id == component.itemID }) else { return "" }
                    return "Solar Panel \(panel.maxCurrent())kW/h"
                case .Radiator:
                    guard let peripheral = station.peripherals.first(where: { $0.id == component.itemID }) else { return "" }
                    return "Radiator \(peripheral.isBroken ? "(Broken)":"")"
                case .RoboArm:
                    guard let peripheral = station.peripherals.first(where: { $0.id == component.itemID }) else { return "" }
                    return "Roboarm \(peripheral.isBroken ? "(Broken)":"")"
            }
        }
    }
    
    func saveSetup() {
        print("Saving Truss Setup\n")
        // Save
        LocalDatabase.shared.saveStation(station: station)
        // Update the Scene
        SceneDirector.shared.didChangeTrussLayout()
    }
    
}

/*
struct TrussView: View {
    
    @ObservedObject var viewModel = TrussViewModel()
    
    var body: some View {
        VStack {
            Text("Truss").font(.headline).padding()
            Text("Lineup slots \(viewModel.slots)")
            
            TrussLineup(viewModel:self.viewModel, slots: $viewModel.slots)
            
            Text("Slots: \(viewModel.slots)").font(.headline)
            Button(action: {
                print("Expanding")
                DispatchQueue.main.async {
                    self.viewModel.expand()
                }
            }){
                Text("Expand")
            }
//            .disabled(!viewModel.truss.isExpandable())
            
            Text("Other [Limits]...")
            Text("Boxes: \(viewModel.truss.extraBoxes.count) of \(Truss.extraBoxesLimit)")
            Text("Solar: \(viewModel.truss.solarPanels.count) of \(Truss.solarPanelsLimit)")
            
        }
        .frame(minWidth: 200, maxWidth: 700, minHeight: 450, maxHeight: 600, alignment: .top)
        
        
    }
}
*/

/*
struct TrussLineup:View {
    
//    @ObservedObject var viewModel:TrussViewModel
    @Binding var slots:Int
    
    var body: some View {
        
        HStack {//(alignment: .center, spacing: 12) {
//            ForEach(viewModel.items, id:\.id) { slot in
//                TrussViewItem(item: slot)
//            }
//            ForEach(0..<self.slots) { slot in
//                TrussViewItem(item: self.$viewModel.items[slot])
//            }
            Text("Deprecated")
        }.padding()
        
    }
}
 */

/*
struct TrussViewItem:View {
    @Binding var item:TrussItem
    var body: some View {
        VStack {
            if item.pTop != nil {
                Button(action:{
                    print("Install")
                }, label: {
                    if item.pTop == PeripheralType.solarPanel {
                        Text("Solar ⬆️")
                    }else{
                        Text("Robo Arm")
                    }
                })
                .disabled(!item.unlocked)
            }else{
                Button(action:{
                    print("Install")
                }, label: {
                    Text("Empty")
                })
                .disabled(true)
            }
            
            Divider()
            Text("# \(item.tIndex)")
//            if item.installed == true {
//                Text("● Installed").foregroundColor(.gray)
//            }
            // Unlocked
            Text("🔑 \(item.unlocked == true ? "●":"○")")
                .foregroundColor(item.unlocked == true ? .green:.red)
            // Installed
            Text("⬇️ \(item.installed == true ? "●":"○")")
            .foregroundColor(item.installed == true ? .green:.red)
            
            if item.pMid != nil {
                if item.installed {
                    Button(action:{
                        print("Radiator")
                    }, label: {
                        Text("Radiator")
                    })
                }
//                Text("\(item.pMid!.rawValue)")
            }else{
                Button(action:{
                    print("Install")
                }, label: {
                    Text("Batt")
                })
                .disabled(!item.unlocked)
            }
            
            Button(action:{
                // print("Install")
            }, label: {
                Text("Storage")
            })
            .disabled(!item.unlocked)
            
            Divider()
            
            if item.tIndex < 2 || item.tIndex > 4 {
                Button(action:{
                    print("Install")
                }, label: {
                    Text("Solar ⬇️")
                })
                .disabled(!item.unlocked)
            }
            
            
        }
    }
}
*/
/*
struct TrussView_Previews: PreviewProvider {
    static var previews: some View {
        TrussView()
    }
}
*/

/*
class TrussViewModel:ObservableObject {
    
    @Published var slots:Int
    @Published var items:[TrussItem]
    @Published var truss:Truss
    
    init() {
        slots = 7
        items = []
        truss = Truss()
//        for item in truss.items {
//            items.append(item)
//        }
    }
    
    init(station:Station) {
        slots = 7
        truss = station.truss
        self.items = []
//        for item in station.truss.items {
//            self.items.append(item)
//        }
    }
    
    func expand() {
//        slots -= 2
//        truss.expand()
//        self.items = truss.items
        
    }
}
*/

