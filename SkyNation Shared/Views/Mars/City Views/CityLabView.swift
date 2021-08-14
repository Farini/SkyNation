//
//  CityLabView.swift
//  SkyNation
//
//  Created by Carlos Farini on 7/24/21.
//

import SwiftUI

struct CityLabView: View {
    var body: some View {
//        VStack {
//            HStack {
//                Text("City Lab").font(.title)
//                Spacer()
//            }
//            .padding(.horizontal, 6)
            
            HStack {
                List() {
                    Section(header: recipeHeader) {
                        ForEach(Recipe.marsCases, id:\.self) { recipe in
                            Text(recipe.rawValue).foregroundColor(.blue)
                        }
                    }
                    Section(header: techHeader) {
                        ForEach(CityTech.allCases, id:\.self) { tech in
                            Text(tech.rawValue).foregroundColor(.blue)
                        }
                    }
                }
                .frame(minWidth: 120, idealWidth: 150, maxWidth: 180, minHeight: 300, idealHeight: 500, maxHeight: .infinity, alignment: .center)
                
                ScrollView([.vertical, .horizontal], showsIndicators: true) {
                    HStack {
                        Spacer()
                        VStack {
                            Text("Detail View")
                            CityTechDiagram()
                        }
                        Spacer()
                    }
                }
            }
    }
    
    var recipeHeader: some View {
        HStack {
            Image(systemName: "list.bullet.rectangle")
            Text("Recipe")
        }
    }
    
    var techHeader: some View {
        HStack {
            Image(systemName: "list.bullet.indent")
            Text("Tech Tree")
        }
    }
}

struct CityLabView_Previews: PreviewProvider {
    static var previews: some View {
        CityLabView()
    }
}
