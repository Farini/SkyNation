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
    case bio
    case rss
    case collect
    case rocket
    
    // ↯
    
    var string:String {
        switch self {
            case .hab: return "🏠"
            case .lab: return "🔬"
            case .bio: return "🧬"
            case .rss: return "♻️"
            case .collect: return "↯"
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
                .modifier(Badged())
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
            switch cityTab {
                case .hab:
                    CityHabView(people: $cityData.inhabitants, city: cityData, selection: nil)
                case .lab:
                    CityLabView(controller:controller)
                case .bio:
                    Text("BioView not implemented").foregroundColor(.gray)
                case .rss:
                    ScrollView {
                        VStack {
                            Group {
                                Text("Boxes").font(.title2)
                                
                                LazyVGrid(columns: [GridItem(.fixed(100)), GridItem(.fixed(100)), GridItem(.fixed(100))], alignment: .center, spacing: 8, pinnedViews: [], content: {
                                    
                                    ForEach(cityData.boxes) { box in
                                        IngredientView(ingredient: box.type, hasIngredient: true, quantity: box.current)
                                    }
                                })
                            }
                        }
                        .frame(minWidth: 600, idealWidth: 750, maxWidth: 900)
                    }
                case .collect:
//                    Text("Outpost Collection not implemented").foregroundColor(.gray)
                    CityOPCollectView(controller: controller)
                case .rocket:
                    CityGarageView(controller: controller, selectedVehicle: nil)
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
            MyCityView(controller:CityController(), cityData: MarsBuilder.shared.myCityData!, cityTab: .constant(menu))
        }
        
    }
}

struct CityMenu_Previews: PreviewProvider {
    static var previews: some View {
        CityMenu(menuItem: .constant(.hab))
    }
}
