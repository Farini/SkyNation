//
//  MarsCityCreatorView.swift
//  SkyNation
//
//  Created by Carlos Farini on 2/27/21.
//

import SwiftUI


struct MarsCityCreatorView: View {
    
    @State var posdex:Posdex
    @State var city:DBCity?
    @ObservedObject var controller = CityController()
    
    // LSS -> Reuse LSS View
    
    var body: some View {
        
        VStack {
            
            // Title
            HStack {
                
                Text(controller.cityTitle).font(.title)
                
                if controller.isMyCity {
                    CityMenu()
//                    Button("Add Something") {
//                        controller.addSomethingToCity()
//                    }
                }
                
                Spacer()
                Button("X") {
                    NotificationCenter.default.post(name: .closeView, object: self)
                }
                .buttonStyle(SmallCircleButtonStyle(backColor: .blue))
            }
            .padding(.horizontal, 8)
            
            Divider()
            
            switch controller.viewState {
                case .loading:
                    Text("Loading")
                case .unclaimed:
                    
                    Image(systemName: "mappin.and.ellipse").font(.title)
                    Text("Unclaimed City").foregroundColor(.gray)
                    Text("Posdex: \(posdex.rawValue) \(posdex.sceneName)").padding()
                    Text("If you don't have a city yet, you may claim this one to get started.").foregroundColor(.gray)
                    
                case .mine(let cData):
                    
                    ScrollView(.vertical, showsIndicators: true) {
                        Text("City Data").foregroundColor(.orange)
                        // Text("Boxes: \(cData.boxes.debugDescription)")
                        
                        // Boxes
                        LazyVGrid(columns: [GridItem(.fixed(100)), GridItem(.fixed(100)), GridItem(.fixed(100))], alignment: .center, spacing: 8, pinnedViews: [], content: {
                            
                            ForEach(controller.cityData!.boxes) { box in
                                IngredientView(ingredient: box.type, hasIngredient: true, quantity: box.current)
                            }
                        })
                        
                        Text("Batteries: \(cData.batteries.debugDescription)")
                        //BatteryCollectionView(controller.cityData!.batteries)
                        LazyVGrid(columns: [GridItem(.fixed(120)), GridItem(.fixed(120)), GridItem(.fixed(120))], alignment: .center, spacing: 8, pinnedViews: [], content: {
                            ForEach(controller.cityData!.batteries) { battery in
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
                        
                        Text("Peripherals: \(cData.peripherals.debugDescription)")
                        LazyVGrid(columns: [GridItem(.fixed(100)), GridItem(.fixed(100)), GridItem(.fixed(100))], alignment: .center, spacing: 8, pinnedViews: [], content: {
                            ForEach(controller.cityData!.peripherals) { peripheral in
                                
                                PeripheralSmallView(peripheral: peripheral)
                            }
                        })
                        
                        Text("Tanks: \(cData.tanks.debugDescription)")
                        LazyVGrid(columns: [GridItem(.fixed(150)), GridItem(.fixed(150)), GridItem(.fixed(150))], alignment: .center, spacing: 8, pinnedViews: [], content: {
                            ForEach(controller.cityData!.tanks) { tank in
                                TankRow(tank: tank)
                            }
                        })
                    }
                case .foreign(let pid):
                    
                    Text("Foreign")
                    if let pp = MarsBuilder.shared.players.filter({ $0.id == pid }).first {
                        Text("Other Player")
                        Group {
                            Text(pp.name)
                            Image(pp.avatar)
                                .resizable()
                                .frame(width:64, height:64)
                            Text(pp.activity())
                        }
                        Group {
                            Text("Occupied City").foregroundColor(.red).padding()
                            Text("City name: \(controller.city!.name)")
                        }
                    }
            }
            
            Divider()
            
            // Buttons
            HStack {
                
                Button("Claim city") {
                    print("Should claim it")
                    SKNS.claimCity(user: SKNUserPost(player: LocalDatabase.shared.player!), posdex: posdex) { (city, error) in
                        if let city = city {
                            print("We have a city !!!!")
                            print("CID: \(city.id)")
                            
                        } else {
                            print("No City. Error: \(error?.localizedDescription ?? "n/a")")
                        }
                    }
                }
                .buttonStyle(NeumorphicButtonStyle(bgColor: .orange))
                .disabled(city != nil && LocalDatabase.shared.player?.cityID == nil)
                
                Button("Close") {
                    print("Close dialogue")
                    NotificationCenter.default.post(name: .closeView, object: nil)
                    
                }
                .buttonStyle(NeumorphicButtonStyle(bgColor: .orange))
            }
            .padding()
            .onAppear() {
                self.controller.loadAt(posdex: posdex)
            }
            
        }
        .frame(minWidth: 500, minHeight: 300, alignment: .center)
        
    }
}

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
    
    @State var menuItem:CityMenuItem = .hab
    
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

// City Types
// 1. Unclaimed (free)
//  1a. Player does NOT have a city (can claim)
//  1b. Player has a city (cannot claim)
// 2. Ocupied
//      Player Content
//      DBCity data
//      if (president) - 🥾👢Evict
// 3. Mine


struct MarsCityCreatorView_Previews: PreviewProvider {
    
    // My City: .city9
    // Other: .city1
    // Unclaimed: .city8
    
    static var previews: some View {
        MarsCityCreatorView(posdex: .city9, city: nil)
    }
}

struct CityMenu_Previews: PreviewProvider {
    static var previews: some View {
        CityMenu()
    }
}
