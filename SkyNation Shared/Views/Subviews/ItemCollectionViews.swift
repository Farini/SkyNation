//
//  ItemCollectionViews.swift
//  SkyNation
//
//  Created by Carlos Farini on 12/29/20.
//

import Foundation
import SwiftUI

struct TankCollectionView: View {
    /// Grid View (1 row)
    private var gridRow:[GridItem] = [
        GridItem(.fixed(100), spacing: 12)
    ]
    
    var tanks:[Tank] // = [Tank(type: .o2), Tank(type: .ch4), Tank(type: .co2)]
    
    init(_ tanks:[Tank]) {
        self.tanks = tanks
    }
    
    var body: some View {
        ScrollView([.horizontal], showsIndicators: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/) {
            if tanks.isEmpty {
                Spacer()
                Text("<< No Tanks >>")
                    .font(.title)
                    .foregroundColor(.gray)
                    .padding()
                Spacer()
            } else {
                LazyHGrid(rows: gridRow, alignment: .center, spacing: 8, pinnedViews: [.sectionHeaders, .sectionFooters]) {
                    ForEach(tanks) { tank in
                        ZStack {
                            VStack {
                                Image("Tank")
                                    .resizable()
                                    .frame(width: 48, height: 48, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                                    .aspectRatio(contentMode: .fit)
                                
                                HStack {
                                    Text(tank.type.rawValue)
                                        .font(.title)
                                    Button(action: {
                                        print("Remove this tank")
                                    }, label: {
                                        Image(systemName: "trash")
                                    })
                                }
                            }
                            .padding()
                        }
                        .background(Color.black)
                        //                        .border(Color.gray, width:2)
                        .cornerRadius(12)
                    }
                }
                .padding([.leading, .trailing])
            }
        }
        .frame(minWidth: 200, idealHeight:140, maxHeight: 150, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        .background(Color.blue.opacity(0.1))
    }
}

struct BatteryCollectionView: View {
    /// Grid View (1 row)
    private var gridRow:[GridItem] = [
        GridItem(.fixed(100), spacing: 12)
    ]
    
    var batteries:[Battery]
    
    init(_ batteries:[Battery]) {
        self.batteries = batteries
    }
    
    var body: some View {
        ScrollView([.horizontal], showsIndicators: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/) {
            if batteries.isEmpty {
                Spacer()
                Text("<< No Batteries >>")
                    .font(.title)
                    .foregroundColor(.gray)
                    .padding()
                Spacer()
            } else {
                LazyHGrid(rows: gridRow, alignment: .center, spacing: 8, pinnedViews: [.sectionHeaders, .sectionFooters]) {
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
                }
                .padding([.leading, .trailing])
            }
        }
        .frame(minWidth: 200, idealHeight:80, maxHeight: 120, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        .background(Color.red.opacity(0.1))
    }
}

struct PeripheralCollectionView: View {
    /// Grid View (1 row)
    private var gridRow:[GridItem] = [
        GridItem(.fixed(100), spacing: 12)
    ]
    
    var peripherals:[PeripheralObject]
    
    init(_ peripherals:[PeripheralObject]) {
        self.peripherals = peripherals
    }
    
    var body: some View {
        ScrollView([.horizontal], showsIndicators: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/) {
            if peripherals.isEmpty {
                Spacer()
                Text("<< No Peripherals >>")
                    .font(.title)
                    .foregroundColor(.gray)
                    .padding()
                Spacer()
            } else {
                LazyHGrid(rows: gridRow, alignment: .center, spacing: 8, pinnedViews: [.sectionHeaders, .sectionFooters]) {
                    ForEach(peripherals) { peripheral in
                        VStack {
                            (peripheral.getImage() ?? Image(systemName: "questionmark"))
                                .renderingMode(.template)
                                .resizable()
                                .frame(width: 32.0, height: 32.0)
                                .padding([.top, .bottom], 8)
                            Text("\(peripheral.peripheral.rawValue)")
                                .foregroundColor(peripheral.isBroken ? .red:.white)
                        }
                        .frame(width:100)
                        .padding([.leading, .trailing, .bottom], 6)
                        .background(Color.black)
                        .cornerRadius(12)
                    }
                }
                .padding([.leading, .trailing])
            }
        }
        .frame(minWidth: 200, idealHeight:80, maxHeight: 120, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        .background(Color.green.opacity(0.1))
    }
}

// MARK: - Previews

struct NewTankview_Previews: PreviewProvider {
    static var previews: some View {
        TankCollectionView([Tank(type: .o2), Tank(type: .ch4), Tank(type: .co2)])
    }
}

struct BatteryCollection_Previews: PreviewProvider {
    static var previews: some View {
        BatteryCollectionView([Battery(shopped: true), Battery(shopped: false)])
    }
}

struct PeripheralCollection_Previews: PreviewProvider {
    static var previews: some View {
        PeripheralCollectionView([PeripheralObject(peripheral: .ScrubberCO2), PeripheralObject(peripheral: .Antenna), PeripheralObject(peripheral: .Methanizer)])
    }
}

