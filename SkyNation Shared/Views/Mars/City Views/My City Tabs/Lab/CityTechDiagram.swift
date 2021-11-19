//
//  CityTechDiagram.swift
//  SkyNation
//
//  Created by Carlos Farini on 7/24/21.
//

import SwiftUI

public enum TechStatus {
    case locked
    case unlocked
    case researched
}

struct CityTechDiagram: View {
    
    @State var action:((CityTech) -> (Void))
    
    @State var tree = CityTechTree().uniqueTree
    var cityData:CityData = LocalDatabase.shared.cityData ?? CityData(example: true, id: nil)
    
    init(city:CityData, callBack:@escaping((CityTech) -> ())) {
        self.cityData = city
        self.action = callBack
    }
    
    var body: some View {
        VStack {
            Diagram(tree: tree, node: { value in
                
                TechTreeItemView(item: value.value, status: statusFor(value.value))
                                .onTapGesture {
                                    self.action(value.value)
                                }
                
            })
        }
    }
    
    private func statusFor(_ tech:CityTech) -> TechStatus {
        if self.cityData.tech.contains(tech) {
            return .researched
        } else if CityTechTree().unlockedTechAfter(doneTech: self.cityData.tech).contains(tech) == true {
            return .unlocked
        } else {
            return .locked
        }
    }
}

struct CityTechDiagram_Previews: PreviewProvider {
    static var previews: some View {
        CityTechDiagram(city: LocalDatabase.shared.cityData!) { chosenTech in
            print("Chosen: \(chosenTech)")
        }
    }
}

/*
 One Item
 
 3 States:
    - locked
    - unlocked
    - researched
 */

struct TechTreeItemView: View {
    
    var item:CityTech
    var status:TechStatus
    
    var body: some View {
        
        switch status {
            case .locked:
                ZStack {
                    // Name
                    Text(item.shortName)
                        .font(GameFont.section.makeFont())
                        .padding([.top, .leading, .trailing], 6)
                    
                    // Image
                    Image(systemName: imageName)
                        .font(imageFont)
                        .padding(4)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(4)
                        .foregroundColor(Color.red)
                    
                }
                .padding(5)
                .background(makeGradient())
                .cornerRadius(5)
                .padding(4)
            case .unlocked:
                VStack(spacing:3) {
                    // Name
                    Text(item.shortName)
                        .font(GameFont.section.makeFont())
                        .padding([.top, .leading, .trailing], 6)
                    
                    // Image
                    Image(systemName: imageName)
                        .font(imageFont)
                        .foregroundColor(status == TechStatus.researched ? Color.green:Color.white)
                    
                }
                .padding(5)
                .background(makeGradient())
                .cornerRadius(5)
                .padding(4)
            case .researched:
                ZStack(alignment:.leading) {
                    // Name
                    Text(item.shortName)
                        .font(GameFont.section.makeFont())
                        .padding([.horizontal], 8)
                        .padding(.top, 8)
                        .foregroundColor(.gray)
                    
                    // Image
                        Image(systemName: imageName)
                            .font(.title2)
                            .background(Color.black.opacity(0.5))
                            .cornerRadius(4)
                            .foregroundColor(status == TechStatus.researched ? Color.green:Color.white)
                            .padding(.leading, 2)
                }
                .padding(5)
                .background(Color.black)
                .cornerRadius(5)
                .padding(4)
        }
    }
    
    var imageFont:Font {
        switch self.status {
        
            case .locked: return .title
            case .unlocked: return .title
            case .researched: return .title3
        }
    }
    
    var statusColor:Color {
        switch self.status {
            case .locked: return Color(.sRGB, red: 0.5, green: 0.1, blue: 0.1, opacity: 1.0)
            case .unlocked: return Color(.sRGB, red: 0.2, green: 0.3, blue: 0.8, opacity: 1.0)
            case .researched: return Color.black.opacity(1.0)
        }
    }
    
    var imageName:String {
        switch self.status {
            case .locked: return "lock"
            case .unlocked: return "lock.open"
            case .researched: return "checkmark.circle"
        }
    }
    
    func makeGradient() -> LinearGradient {
        return LinearGradient(colors: [statusColor, GameColors.darkGray, GameColors.darkGray, Color.black], startPoint: .bottom, endPoint: .top)
    }
    
}

struct TechItem_Previews: PreviewProvider {
    static var previews: some View {
        TechTreeItemView(item: CityTech.allCases.randomElement()!, status: .researched)
    }
}
