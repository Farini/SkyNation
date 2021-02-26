//
//  TutorialView.swift
//  SkyNation
//
//  Created by Carlos Farini on 2/26/21.
//

import SwiftUI

// How to show FULL text
// https://stackoverflow.com/questions/58675220/how-to-show-full-text-in-scroll-view-in-swift-ui
enum TutorialType {
    case LSSView
    case OrderView
    
    case LabView
    case HabView
    case BioView
    
    case Garage
    case Truss
    
}

struct TutorialView: View {
    
    @State var tutType:TutorialType
    
    var body: some View {
        
        switch tutType {
            case .LabView:
                ScrollView {
                    VStack(alignment:.leading, spacing:6) {
                        Text("Tutorial").font(.title)
                        Divider()
                        Text("Here you can make recipes, research the tech tree, and more.")
                        Text("To your left there is a list divided in two sections. Recipes and Tech Tree.")
                        Text("You can also click on the tree itself")
                        Text("Once you have one of these items selected, the view to your right displays the ingredients necessary to make the product, and the skills required to perform the task.")
                        Text("You can also pay tokens to reduce the time of making such product.")
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 6)
                }
                .frame(maxWidth: 400, maxHeight: 600, alignment: .top)
                
            case .HabView:
                ScrollView {
                    VStack(alignment:.leading, spacing:6) {
                        Text("Tutorial").font(.title)
                        Divider()
                        Text("This is where your inhabitants stay. Take good care of them")
                        Text("Select one of the inhabitants to view them in detail.")
                        Text("You may perform one of the tasks listed here in order to keep your staff happy and healthy. All of their other tasks depend on it.")
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 6)
                }
                .frame(maxWidth: 400, maxHeight: 600, alignment: .top)
            
            default: Text("Other Tutorial")
        }
        
        
    }
}

struct TutorialView_Previews: PreviewProvider {
    static var previews: some View {
        TutorialView(tutType: .LabView)
    }
}
