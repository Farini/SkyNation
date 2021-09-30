//
//  MyCityView.swift
//  SkyNation
//
//  Created by Carlos Farini on 7/13/21.
//

import SwiftUI

/// A View Containing the CityTabs
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
                .modifier(Badged())
            }
            
            
            
        }
        .font(.title)
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}

// MARK: - My City

/// The View of the `CityData` that belongs to the `Player`
struct LocalCityView: View {
    
    @ObservedObject var controller:LocalCityController = LocalCityController()
    @State private var menuItem:CityMenuItem = .hab
    
    /// The City Menu (Tabs)
    var header: some View {
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
                    controller.didSelectTab(tab: mitem)
//                    switch mitem {
//                        case .hab: controller.cityViewState = .hab(state: .noSelection)
//                        case .lab:
//                            print("clicklab")
//                            if let activity = controller.labActivity {
////                                controller.labActivity = activity
//                                controller.cityViewState = .lab(state: .activity(object: activity))
//                            } else {
//                                controller.cityViewState = .lab(state: .NoSelection)
//                            }
//                        case .bio: controller.cityViewState = .bio(state: .notSelected)
//                        case .rss: controller.cityViewState = .rss
//                        case .collect: controller.cityViewState = .collect
//                        case .rocket: controller.cityViewState = .rocket(state: .noSelection)
//                    }
                }
                .modifier(Badged())
            }
            
            Spacer()
            Button("X") {
                NotificationCenter.default.post(name: .closeView, object: self)
            }
            .buttonStyle(SmallCircleButtonStyle(backColor: .blue))
            
        }
        .font(.title)
        .padding(.horizontal)
        .padding(.vertical, 4)
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
            CityMenu(menuItem: .constant(menu))
            LocalCityView()
        }
    }
}

struct CityMenu_Previews: PreviewProvider {
    static var previews: some View {
        CityMenu(menuItem: .constant(.hab))
    }
}
