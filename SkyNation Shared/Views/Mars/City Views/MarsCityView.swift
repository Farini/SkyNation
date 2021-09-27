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
    
    // MOVE THIS TO MyCityView or LocalCityView
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
            
            
            switch controller.viewState {
                case .loading:
                    
                    // Header
                    header
                    
                    Group {
                        Spacer()
                        Text("Loading City...").font(.title).foregroundColor(.gray)
                        HStack {
                            Spacer()
                            Text("🏛").font(.title)
                            Spacer()
                        }
                        Spacer()
                    }
                    .padding()
                    
                case .unclaimed:
                    
                    // Header
                    header
                    
                    Group {
                        
                        Image(systemName: "mappin.and.ellipse").font(.title)
                        Text("Unclaimed City").foregroundColor(.gray)
                        Text("Posdex: \(posdex.rawValue) \(posdex.sceneName)").padding()
                        Text("If you don't have a city yet, you may claim this one to get started.").foregroundColor(.gray)
                        
                        Spacer()
                        
                        // Button to Claim City (if player doesn't have one)
                        if controller.isClaimable() == true {
                            Button("Claim City") {
                                controller.claimCity(posdex: posdex)
                            }
                            .buttonStyle(NeumorphicButtonStyle(bgColor: .white))
                            .padding(.bottom, 8)
                        }
                        
                    }
                    
                case .mine(_):
                    
//                    MyCityView(controller: controller, cityData: cityData, cityTab: $cityMenuItem)
                    LocalCityView(controller: LocalCityController())
                    
                case .foreign(let pid):
                    
                    // Header
                    header
                    
                    ForeignCityView(controller: controller, posdex: self.posdex, player: MarsBuilder.shared.players.filter({ $0.id == pid }).first)
                    
            }
        }
        .frame(minWidth: 600, maxWidth:900, minHeight: 350, idealHeight: 500, maxHeight: 600)
        
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
