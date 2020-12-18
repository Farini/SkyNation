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
    let row3:[Int] = [13, 33, 17]
    let row4:[Int] = [16, 34, 18]
    
    var truss = LocalDatabase.shared.station!.truss
    
    @State var selectedComponent:TrussComponent?
    
    var body: some View {
        VStack {
            
            Text("Truss Arrangement")
                .font(.largeTitle)
                .padding()
            
            Divider()
            
            HStack(alignment: .top, spacing: 12) {
                
                // Left Most
                VStack {
                    ForEach(truss.tComponents.filter({row1.contains($0.posIndex)})) { comp in
                        Text("\(comp.allowedType.rawValue)")
                            .foregroundColor(comp.itemID == nil ? .white:.blue)
                            .padding(6)
                            .onTapGesture {
                                self.didSelect(item: comp)
                            }
                            
                    }
                }
                
                // Mid Left
                VStack {
                    ForEach(truss.tComponents.filter({row2.contains($0.posIndex)})) { comp in
                        Text("\(comp.allowedType.rawValue)")
                            .foregroundColor(comp.itemID == nil ? .white:.blue)
                            .padding(6)
                            .onTapGesture {
                                self.didSelect(item: comp)
                            }
                    }
                }
                
                // Middle
                VStack {
                    ForEach(truss.tComponents.filter({midRow.contains($0.posIndex)})) { comp in
                        Text("\(comp.allowedType.rawValue)")
                            .foregroundColor(comp.itemID == nil ? .white:.blue)
                            .padding(6)
                            .onTapGesture {
                                self.didSelect(item: comp)
                            }
                    }
                }
                
                // Mid-Right
                VStack {
                    ForEach(truss.tComponents.filter({row3.contains($0.posIndex)})) { comp in
                        Text("\(comp.allowedType.rawValue)")
                            .foregroundColor(comp.itemID == nil ? .white:.blue)
                            .padding(6)
                            .onTapGesture {
                                self.didSelect(item: comp)
                            }
                    }
                }
                
                // Right-Most
                VStack {
                    ForEach(truss.tComponents.filter({row4.contains($0.posIndex)})) { comp in
                        Text("\(comp.allowedType.rawValue)")
                            .foregroundColor(comp.itemID == nil ? .white:.blue)
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
                if selectedComponent == nil {
                    Text("Nothing selected")
                        .foregroundColor(.gray)
                } else {
                    Text("\(selectedComponent!.allowedType.rawValue)")
                    Text("\(selectedComponent!.posIndex)")
                }
            }
            .padding()
            
        }
        
    }
    
    func didSelect(item:TrussComponent) {
        
        if let old = self.selectedComponent {
            if item == old {
                self.selectedComponent = nil
            } else {
                swap(origin: old, destination: item)
            }
        } else {
            self.selectedComponent = item
        }
    }
    
    func swap(origin:TrussComponent, destination:TrussComponent) {
        
        guard origin.allowedType == destination.allowedType else {
            return
        }
        
        if let itemID = origin.itemID  {
            if destination.itemID == nil {
                destination.itemID = itemID
                origin.itemID = nil
            } else {
                print("Exchanging same stuff")
            }
        } else {
            print("Origin item doesn't have an id.")
        }
    }
}

struct TrussView_Previews: PreviewProvider {
    static var previews: some View {
        TrussLayoutView()
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

