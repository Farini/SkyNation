//
//  CityHabView.swift
//  SkyNation
//
//  Created by Carlos Farini on 7/24/21.
//

import SwiftUI

fileprivate enum HabSelection {
    case empty
    case selected(person:Person)
}

struct CityHabView: View {
    
    @ObservedObject var controller:LocalCityController
    
    @State var habState:HabModuleViewState {
        didSet {
            switch self.habState {
                case .noSelection:
                    selectedPerson = nil
                case .selected(let person):
                    selectedPerson = person
            }
        }
    }
    
    @State private var selectedPerson:Person?
    
    var body: some View {
        
        VStack(alignment:.leading) {
            
            HStack {
                
                // Left List
                List {
                    Section(header:Text("Hab Limit: \(controller.cityData.checkForRoomsAvailable())")) {
                        ForEach(controller.allStaff) { person in
                            ActivityPersonCell(person: person, selected: person == selectedPerson)
                                .onTapGesture {
                                    self.habState = .selected(person: person)
                                }
                        }
                    }
                    
                    if controller.allStaff.isEmpty {
                        Text("No one here").foregroundColor(.gray)
                    }
                }
                .frame(minWidth: 180, idealWidth: 200, maxWidth: 220, minHeight: 300, idealHeight: 300, maxHeight: .infinity, alignment: .top)
                
                HStack {
                    
                    switch habState {
                        case .noSelection:
                            Spacer()
                            Text("< No Selection >").foregroundColor(.gray)
                            Spacer()
                        case .selected(let person):
                            ScrollView {
                                PersonDetailView(person: person) { personAction in
                                    controller.personalAction(personAction, person: person)
                                }
                            }
                    }
                }
            }
        }
    }
}

struct CityHabView_Previews: PreviewProvider {
    static var previews: some View {
//        CityHabView(controller: LocalCityController(), people: .constant(LocalDatabase.shared.city?.inhabitants ?? []), city: LocalDatabase.shared.city!)
        CityHabView(controller: LocalCityController(), habState: .noSelection)
    }
}
