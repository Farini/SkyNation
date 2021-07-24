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
    
    @Binding var people:[Person]
    @State var selection:Person?
    @State fileprivate var selectState:HabSelection = .empty
    
    var body: some View {
        VStack(alignment:.leading) {
            
            // Header
            Text("Hab")
            Text("Limits")
            
            HStack {
                // Left List
                List(people) { person in
                    ActivityPersonCell(person: person, selected: selection == person)
                        .onTapGesture {
                            self.selection = person
                            self.selectState = .selected(person: person)
                        }
                }
                .frame(minWidth: 180, idealWidth: 200, maxWidth: 220, minHeight: 300, idealHeight: 300, maxHeight: .infinity, alignment: .top)
                
                HStack {
                    /*
                    Spacer()
                    Text("< No Selection >")
                    Spacer()
                     */
                    switch selectState {
                        case .empty:
                            
                            Spacer()
                            Text("< No Selection >").foregroundColor(.gray)
                            Spacer()
                            
                        case .selected(let person):
                            ScrollView {
//                                PersonDetail(controller: self.controller, person:controller.selectedPerson!)
                                PersonSmallView(person: person)
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
        CityHabView(people: .constant(LocalDatabase.shared.city?.inhabitants ?? []))
    }
}
