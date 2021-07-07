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
            
            HStack {
                if controller.isMyCity {
                    Text("My City").font(.title).foregroundColor(.green)
//                    Text("My city \(cData.id)")
                    Button("Add Something") {
                        controller.addSomethingToCity()
                    }
                } else {
                    Text("City View").font(.title)
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
                    Text("Unclaimed")
                case .mine(let cData):
                    Text("My city \(cData.id)")
                    Button("Add Something") {
                        controller.addSomethingToCity()
                    }
                default:
                    Text("Other")
            }
            
            if let city:DBCity = city {
                
                Group {
                    Text("Occupied City").foregroundColor(.red).padding()
                    Text("City name: \(city.name)")
                    Text("A: \(city.name)")
                    
                    if controller.cityData != nil {
                        Text("City Data").foregroundColor(.orange)
                        Text("Boxes: \(controller.cityData!.boxes.debugDescription)")
                        LazyVStack {
                            ForEach(controller.cityData!.boxes) { box in
                                IngredientView(ingredient: box.type, hasIngredient: true, quantity: box.current)
                            }
                        }
                        Text("Batteries: \(controller.cityData!.batteries.debugDescription)")
//                        LazyVStack {
//                            ForEach(controller.cityData!.batteries) { battery in
                                BatteryCollectionView(controller.cityData!.batteries)
//                            }
//                        }
                        Text("Peripherals: \(controller.cityData!.peripherals.debugDescription)")
                        LazyVStack {
                            ForEach(controller.cityData!.peripherals) { peripheral in
                                PeripheralSmallView(peripheral: peripheral)
                            }
                        }
                        Text("Tanks: \(controller.cityData!.tanks.debugDescription)")
                        LazyVStack {
                            ForEach(controller.cityData!.tanks) { tank in
                                TankRow(tank: tank)
                            }
                        }
                    }
                }
                
                Group {
                    Text("Vehicles").foregroundColor(.orange).font(.title3)
                    ForEach(controller.allVehicles, id:\.id) { vehicle in // SpaceVehicleContent
                        Text("\(vehicle.engine): \(vehicle.status)")
                            .onTapGesture {
                                print("Unpacking")
                                controller.unpackVehicle(vehicle: vehicle)
                            }
                    }
                }
                
                
            } else {
                
                Text("Unclaimed City").foregroundColor(.gray)
                Text("Posdex: \(posdex.rawValue) \(posdex.sceneName)")
                
            }
            
            Divider()
            
            // Buttons
            HStack {
//                Text("Claim this city")
                
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
        
    }
}

struct MarsCityCreatorView_Previews: PreviewProvider {
    static var previews: some View {
        MarsCityCreatorView(posdex: .city1, city: nil)
    }
}
