//
//  MyCityView.swift
//  SkyNation
//
//  Created by Carlos Farini on 7/13/21.
//

import SwiftUI

// MARK: - My City Menu

enum CityMenuItem:Int, CaseIterable {
    case hab
    case lab
    case rss
    case rocket
    
    var string:String {
        switch self {
            case .hab: return "🏠"
            case .lab: return "🔬"
            case .rss: return "♻️"
            case .rocket: return "🚀"
        }
    }
}

struct CityMenu: View {
    
    @Binding var menuItem:CityMenuItem
    
    var body: some View {
        HStack {
            
            ForEach(CityMenuItem.allCases, id:\.self) { mitem in
                ZStack {
                    Circle()
                        .strokeBorder(menuItem == mitem ? Color.red:Color.gray, lineWidth: 2, antialiased: false)
                        .frame(width: 32, height: 32, alignment: .center)
                    Text(mitem.string)
                }
                .onTapGesture {
                    self.menuItem = mitem
                }
            }
        }
        .font(.title)
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}

// MARK: - My City View

struct MyCityView: View {
    
    @ObservedObject var controller:CityController
    @State var cityData:CityData
    @Binding var cityTab:CityMenuItem
    
    var body: some View {
        VStack {
//            Text("City Data")
//                .font(.title)
//                .foregroundColor(.orange)
            switch cityTab {
                case .hab:
                    CityHabView(people: $cityData.inhabitants, selection: nil)
                case .lab:
                    CityLabView()
                case .rss:
                    HStack {
                        Spacer()
                        Text("Resources")
                        Spacer()
                    }
                    
                case .rocket:
                    HStack {
                        Spacer()
                        Text("Rockets")
                        Spacer()
                    }
            }
            
            /*
            // Boxes
            Group {
                Divider()
                Text("Boxes").font(.title2)
                
                LazyVGrid(columns: [GridItem(.fixed(100)), GridItem(.fixed(100)), GridItem(.fixed(100))], alignment: .center, spacing: 8, pinnedViews: [], content: {
                    
                    ForEach(cityData.boxes) { box in
                        IngredientView(ingredient: box.type, hasIngredient: true, quantity: box.current)
                    }
                })
            }
            
            // Batteries
            Group {
                Divider()
                Text("Batteries").font(.title2)
                LazyVGrid(columns: [GridItem(.fixed(120)), GridItem(.fixed(120)), GridItem(.fixed(120))], alignment: .center, spacing: 8, pinnedViews: [], content: {
                    ForEach(cityData.batteries) { battery in
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
            }
            
            // Peripherals
            Group {
                Divider()
                Text("Peripherals").font(.title2)
                LazyVGrid(columns: [GridItem(.fixed(100)), GridItem(.fixed(100)), GridItem(.fixed(100))], alignment: .center, spacing: 8, pinnedViews: [], content: {
                    ForEach(cityData.peripherals) { peripheral in
                        
                        PeripheralSmallView(peripheral: peripheral)
                    }
                })
            }
            
            // Tanks
            Group {
                Divider()
                Text("Tanks").font(.title2)
                LazyVGrid(columns: [GridItem(.fixed(150)), GridItem(.fixed(150)), GridItem(.fixed(150))], alignment: .center, spacing: 8, pinnedViews: [], content: {
                    ForEach(cityData.tanks) { tank in
                        TankRow(tank: tank)
                    }
                })
            }
            */
        }
    }
}

// MARK: - Previews

struct MyCityView_Previews: PreviewProvider {
    static var previews: some View {
        MyCityView(controller:CityController(), cityData: MarsBuilder.shared.myCityData!, cityTab: .constant(.hab))
            .frame(height:900)
    }
}

struct CityMenu_Previews: PreviewProvider {
    static var previews: some View {
        CityMenu(menuItem: .constant(.hab))
    }
}
