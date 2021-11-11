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
//                VStack {
//
//                    Text("\(value.value.shortName)")
//                        .font(.callout)
//                        .padding([.top, .leading, .trailing], 6)
//
//                    Text("\(value.value.rawValue)")
//                        .font(.caption)
//                        .foregroundColor(.gray)
//
//                }
//                .background(CityTechTree().unlockedTechAfter(doneTech: self.cityData.tech).contains(value.value) ? Color.blue:Color.black)
//
//                .cornerRadius(6)
//                .padding(6)
//                .onTapGesture {
//                    self.action(value.value)
//                }
                
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
        VStack(spacing:3) {
            Text(item.shortName)
                .font(GameFont.section.makeFont())
                .padding([.top, .leading, .trailing], 6)
            
//            Divider()
//                .frame(width:100)
            Image(systemName: imageName)
                .font(.title)
                .foregroundColor(status == TechStatus.researched ? Color.green:Color.white)
            
        }
        .padding(5)
        .background(makeGradient())
        .cornerRadius(5)
        .padding(4)
        
    }
    
    var statusColor:Color {
        switch self.status {
            case .locked: return Color(.sRGB, red: 0.5, green: 0.1, blue: 0.1, opacity: 1.0)
            case .unlocked: return .blue//Color(.sRGB, red: 0.1, green: 0.1, blue: 0.6, opacity: 1.0)
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
