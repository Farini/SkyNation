//
//  MyCityView.swift
//  SkyNation
//
//  Created by Carlos Farini on 7/13/21.
//

import SwiftUI

// MARK: - My City

/// The View of the `CityData` that belongs to the `Player`
struct LocalCityView: View {
    
    @ObservedObject var controller:LocalCityController = LocalCityController()
    @State private var menuItem:CityMenuItem = .hab
    @State private var popTutorial:Bool = false
    
    /// The City Menu (Tabs)
    var header: some View {
        VStack {
            
            // Title, Tutorial, and Close Buttons
            HStack {
                Text("My City")
                    .font(GameFont.title.makeFont())
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
            .padding([.leading, .trailing, .top])
            
            // Tab Items
            HStack {
                ForEach(CityMenuItem.allCases, id:\.self) { mitem in
                    Text(mitem.string)
                        .modifier(GameTabModifier("", selected: menuItem == mitem))
                        .onTapGesture {
                            self.menuItem = mitem
                            controller.didSelectTab(tab: mitem)
                        }
                        .modifier(Badged("-"))
                }
                Spacer()
                Text(menuItem.string)
            }
            .font(.title)
            .padding(.horizontal)
            
            Divider()
                .offset(x:0, y:-3)

        }
        
    }
    
    var body: some View {
        VStack {
                        
            header

            switch controller.cityTab {
                    
                case .hab:
                    CityHabView(controller: controller, habState: .noSelection)
                    
                case .lab:
                    CityLabView(controller: controller)
                    
                case .bio:
                    CityBioView(controller: controller)
                    
                case .rss:
                    ScrollView {
                        VStack {
                            Group {
                                Text("Boxes").font(.title2)
                                
                                LazyVGrid(columns: [GridItem(.fixed(100)), GridItem(.fixed(100)), GridItem(.fixed(100))], alignment: .center, spacing: 8, pinnedViews: [], content: {
                                    
                                    ForEach(controller.cityData.boxes) { box in
                                        IngredientView(ingredient: box.type, hasIngredient: true, quantity: box.current)
                                    }
                                })
                            }
                        }
                        .frame(minWidth: 600, idealWidth: 750, maxWidth: 900)
                    }
                    
                case .collect:
                    CityOPCollectView(controller: controller)
                    
                case .rocket:
                    CityGarageView(controller: controller, garageState: .noSelection)
            }
        }
    }
}



// MARK: - Previews

struct MyCityView_Previews: PreviewProvider {
    
    static let menu:CityMenuItem = CityMenuItem.lab
    
    static var previews: some View {
        VStack {
            LocalCityView()
        }
    }
}
