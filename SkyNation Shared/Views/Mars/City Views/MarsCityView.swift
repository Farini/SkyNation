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
    @State private var popTutorial:Bool = false
    
    
    var header: some View {
        VStack {
            // Title
            HStack(spacing:8) {
                
                switch controller.viewState {
                    case .loading:
                        ProgressView()
                        Text("Loading city").font(GameFont.title.makeFont()).foregroundColor(.gray)
                    case .mine(_):
                        Text(controller.cityTitle).font(GameFont.title.makeFont())
//                        CityMenu(menuItem: $cityMenuItem)
                    case .foreign(_):
                        Text(controller.cityTitle).font(GameFont.title.makeFont())
                    // If President -> Delete Button
                    case .unclaimed:
                        Text(controller.cityTitle).font(GameFont.title.makeFont())
                }
                
                Spacer()
                
                // Tut
                Button(action: {
                    print("Question ?")
                    popTutorial.toggle()
                }, label: {
                    Image(systemName: "questionmark.circle")
                        .font(.title2)
                })
                    .buttonStyle(SmallCircleButtonStyle(backColor: .orange))
                    .popover(isPresented: $popTutorial) {
                        TutorialView(tutType: .GuildCity)
                    }
                
                // Close
                Button(action: {
                    NotificationCenter.default.post(name: .closeView, object: self)
                }) {
                    Image(systemName: "xmark.circle")
                        .font(.title2)
                }.buttonStyle(SmallCircleButtonStyle(backColor: .pink))
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
                    
                    UnclaimedCityView()
                    
                    if controller.isClaimable() == true {
                        Text("Cities are the building blocks of the Mars Colony.")
                        Text("Select a city that you like the most, and claim it, to get started.")
                        
                        Divider()
                        
                        Button("Claim City") {
                            controller.claimCity(posdex: posdex)
                        }
                        .buttonStyle(NeumorphicButtonStyle(bgColor: .white))
                        .padding(.bottom, 8)
                    } else {
                        Text("Cities are the building blocks of the Mars Colony.")
                        Text("This city is available for any Guild member to claim.")
                        
                        Divider()
                        
                        Button("Claim City") {
                            controller.claimCity(posdex: posdex)
                        }
                        .disabled(true)
                        .buttonStyle(NeumorphicButtonStyle(bgColor: .white))
                        .padding(.bottom, 8)
                    }
                case .mine(_):
                    
                    LocalCityView()
                    
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

struct UnclaimedCityView:View {
    var body: some View {
        VStack {
            Text("Unclaimed")
            
            Image(systemName: "mappin.and.ellipse").font(.title)
            Text("Unclaimed City").foregroundColor(.gray)
            Text("If you don't have a city yet, you may claim this one to get started.").foregroundColor(.gray)
            
            Spacer()
        }
    }
}

struct MarsCityView_Previews: PreviewProvider {
    static var previews: some View {
        MarsCityView(posdex: .city9)
        UnclaimedCityView()
    }
}
