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
            case .LSSView:
                ScrollView {
                    VStack(alignment: .leading) {
                        Group {
                            Text("Life Support Systems").font(.title3).foregroundColor(.orange)
                            Divider()
                            Text("Here you can look at the resources that your station has. You can also analyze how long some of those resources are going to last.")
                        }
                        Group {
                            Text("Air").font(.title3).foregroundColor(.orange)
                            Text("The air tab shows the quality of the air available to your inhabitants.")
                            Text("Resourcces").font(.title3).foregroundColor(.orange)
                            Text("Resources displays the items the Station has")
                            Text("Machinery").font(.title3).foregroundColor(.orange)
                            Text("Machinery displays the Peripherals and their current condition. You may want to turn some peripherals off to preserve energy, or make them work harder to achieve some goals.")
                        }
                        Group {
                            Text("Power").font(.title3).foregroundColor(.orange)
                            Text("The Power tab displays how much power is ccoming in from the solar panels, and how full the batteries are.")
                            Text("System").font(.title3).foregroundColor(.orange)
                            Text("System displays accounting reports generated by the Station.")
                        }
                    }
                    .padding(6)
                }
                .frame(maxWidth: 400, minHeight: 300, maxHeight: 500, alignment: .top)
            
            case .OrderView:
                ScrollView {
                    VStack(alignment:.leading, spacing:6) {
                        Text("Order").font(.title)
                        Divider()
                        Text("You may order Boxes of Ingredients, Tanks, and hire people here.")
                        Text("The list of candidates is renewed every hour.")
                        Text("Take your time, and plan ahead. Look and analyze how much your resources are going to last. Running out of oxygen (O2) may be deadly to your staff.")
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 6)
                }
                .frame(maxWidth: 400, maxHeight: 600, alignment: .top)
            
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
                
            case .BioView:
                ScrollView {
                    VStack(alignment:.leading, spacing:6) {
                        Text("Biology Module Tutorial").font(.title)
                        Divider()
                        Text("In this module you may create Bio Boxes")
                        Text("A BioBox is a set of life beings that may be adible, once the DNA is matched.")
                        Text("This is a way for the Space Station to produce food.")
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 6)
                }
                .frame(maxWidth: 400, maxHeight: 600, alignment: .top)
                
            case .Garage:
                ScrollView {
                    VStack(alignment:.leading, spacing:6) {
                        Text("Garage").font(.title)
                        Divider()
                        Text("The Garage allows you to build SpaceVehicles to send to Mars.")
                        Text("Bigger Vehicles need more experience to be built. They also need more ingredients and skills.")
                        Text("After you build your first Vehicle, you will be able to join a Guild")
                        Text("Planning").foregroundColor(.orange).font(.title3)
                        Text("The trip to Mars takes a long time. Make sure to plan well to be sustainable with your supplies.")
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 6)
                }
                .frame(maxWidth: 400, maxHeight: 600, alignment: .top)
                
            case .Truss:
                ScrollView {
                    VStack(alignment:.leading, spacing:6) {
                        Text("Truss").font(.title).foregroundColor(.orange)
                        Divider()
                        Text("The Truss is responsible for several unpressurized storage cargo.")
                        Text("It also connects the Solar Panels with the batteries, to charge them, and the radiators are also installed here.")
                        Text("You may rearrange the Solar Panels and Radiators as you wish.")
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
