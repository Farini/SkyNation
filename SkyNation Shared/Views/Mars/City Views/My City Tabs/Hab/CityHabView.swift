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
    
    @ObservedObject var controller:CityController
    @Binding var people:[Person]
    var city:CityData
    
    @State var selection:Person?
    @State fileprivate var selectState:HabSelection = .empty
    
    var body: some View {
        VStack(alignment:.leading) {
            
            HStack {
                // Left List
                List {
                    Section(header:Text("Hab Limit: \(city.checkForRoomsAvailable())")) {
                        ForEach(people) { person in
                            ActivityPersonCell(person: person, selected: selection == person)
                                .onTapGesture {
                                    self.selection = person
                                    self.selectState = .selected(person: person)
                                }
                        }
                    }
                    
                    if people.isEmpty {
                        Text("No one here").foregroundColor(.gray)
                    }
                    
                }
                .frame(minWidth: 180, idealWidth: 200, maxWidth: 220, minHeight: 300, idealHeight: 300, maxHeight: .infinity, alignment: .top)
                
                HStack {
                    
                    switch selectState {
                        case .empty:
                            
                            Spacer()
                            Text("< No Selection >").foregroundColor(.gray)
                            Spacer()
                            
                        case .selected(let person):
                            ScrollView {
//                                PersonDetail(controller: self.controller, person:controller.selectedPerson!)
//                                PersonSmallView(person: person)
                                PersonDetailView(person: person) { personAction in
                                    controller.personalAction(personAction, person: person)
                                }
                            }
                    }
                }
            }
            
            
            // Selection
        }
    }
}

struct CityHabView_Previews: PreviewProvider {
    static var previews: some View {
        CityHabView(controller: CityController(), people: .constant(LocalDatabase.shared.city?.inhabitants ?? []), city: LocalDatabase.shared.city!)
    }
}
