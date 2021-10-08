//
//  CityTechDiagram.swift
//  SkyNation
//
//  Created by Carlos Farini on 7/24/21.
//

import SwiftUI

struct CityTechDiagram: View {
    
    @State var action:((CityTech) -> (Void))
    
    @State var tree = CityTechTree().uniqueTree
    var cityData:CityData = LocalDatabase.shared.cityData ?? CityData(example: true, id: nil)
    
    init(city:CityData, callBack:@escaping((CityTech) -> ())) {
        self.cityData = city
        self.action = callBack
    }
    /*
     // activity, cancel:Bool
     var action:((LabActivity, Bool) -> ())
     
     init(activity:LabActivity, callBack:@escaping ((LabActivity, Bool) -> ())) {
     self.labActivity = activity
     self.action = callBack
     }
     */
    
    
    
    var body: some View {
        VStack {
            Diagram(tree: tree, node: { value in
                
                VStack {
                    
                    Text("\(value.value.shortName)")
                        .font(.callout)
                        .padding([.top, .leading, .trailing], 6)
                    
                    Text("\(value.value.rawValue)")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                }
                .background(CityTechTree().unlockedTechAfter(doneTech: self.cityData.tech).contains(value.value) ? Color.blue:Color.black)
                
                .cornerRadius(6)
                .padding(6)
                .onTapGesture {
                    self.action(value.value)
                }
                
//                .background(value.isUnlocked(station:station) ? Color.blue:Color.black)
//                .cornerRadius(6)
//                .padding(6)
//                .onTapGesture {
//                    controller.selectedFromDiagram(value.value)
//                }
            })
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
