//
//  MarsCityView.swift
//  SkyNation
//
//  Created by Carlos Farini on 7/13/21.
//

import SwiftUI

struct MarsCityView: View {
    
    @ObservedObject private var controller = CityController()
    
    @State var posdex:Posdex
    
    @State private var cityMenuItem:CityMenuItem = .hab
    
    var header: some View {
        VStack {
            // Title
            HStack(spacing:8) {
                
                switch controller.viewState {
                    case .loading:
                        ProgressView()
                        Text("Loading city").font(.title).foregroundColor(.gray)
                    case .mine(_):
                        Text(controller.cityTitle).font(.title)
                        CityMenu(menuItem: $cityMenuItem)
                    case .foreign(_):
                        Text(controller.cityTitle).font(.title)
                        // If President -> Delete Button
                    case .unclaimed:
                        Text(controller.cityTitle).font(.title)
                }
                
                Spacer()
                Button("X") {
                    NotificationCenter.default.post(name: .closeView, object: self)
                }
                .buttonStyle(SmallCircleButtonStyle(backColor: .blue))
            }
            .padding(.horizontal, 8)
            .padding(.top, 6)
            
            Divider().offset(x: 0, y: -8)
        }
    }
    
    var body: some View {
        
        
        VStack {
            // Header
            header
            
            ScrollView(.vertical, showsIndicators: true) {
                VStack {
                    switch controller.viewState {
                        case .loading:
                            Group {
                                Text("Loading City...").font(.title).foregroundColor(.gray)
                                Text("🏛").font(.title)
                            }
                            .padding()
                        
                        case .unclaimed:
                            
                            Group {
                                Image(systemName: "mappin.and.ellipse").font(.title)
                                Text("Unclaimed City").foregroundColor(.gray)
                                Text("Posdex: \(posdex.rawValue) \(posdex.sceneName)").padding()
                                Text("If you don't have a city yet, you may claim this one to get started.").foregroundColor(.gray)
                                
                                // Button to Claim City (if player doesn't have one)
                                if controller.player.cityID == nil {
                                    Button("Claim City") {
                                        print("Should claim it")
                                        SKNS.claimCity(user: SKNUserPost(player: LocalDatabase.shared.player!), posdex: posdex) { (city, error) in
                                            if let city = city {
                                                print("We have a city !!!!")
                                                print("CID: \(city.id)")
                                                
                                                // Reload this city (in controller)
                                                controller.loadAt(posdex: posdex)
                                                
                                            } else {
                                                print("No City. Error: \(error?.localizedDescription ?? "n/a")")
                                            }
                                        }
                                    }
                                }
                            }
                        
                        case .mine(let cityData):
                            
                            MyCityView(controller: controller, cityData: cityData)
                            
                        case .foreign(let pid):
                            
                            ForeignCityView(controller: controller, posdex: self.posdex, player: MarsBuilder.shared.players.filter({ $0.id == pid }).first)
                            
                    }
                }
            }
            .frame(minWidth: 500, minHeight: 350)
        }
        .onAppear() {
            self.controller.loadAt(posdex: posdex)
        }
    }
}

struct MarsCityView_Previews: PreviewProvider {
    static var previews: some View {
        MarsCityView(posdex: .city9)
    }
}
