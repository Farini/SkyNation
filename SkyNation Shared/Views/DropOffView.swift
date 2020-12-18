//
//  DropOffView.swift
//  SkyTestSceneKit
//
//  Created by Farini on 9/7/20.
//  Copyright © 2020 Farini. All rights reserved.
//

import SwiftUI

struct DropOffView: View {
    
    var station:Station
    var order:EarthOrder
    @ObservedObject var viewModel:DropOffViewModel
    
    // Pass as State from view model
    @State var stationPeople:[Person] = []
    
    init(station:Station, order:EarthOrder) {
        self.station = station
        self.order = order
        self.viewModel = DropOffViewModel(station: station, order: order)
        self.stationPeople = viewModel.staffInStation
    }
    
    var body: some View {
        VStack {
            Text("Drop Off")
            .font(.headline)
            .padding(4)
            
            
            
            Text("People")
            .font(.headline)
            
            HStack {
                VStack {
                    Text("Home")
                    .font(.headline)
                    List {
                        ForEach(0..<station.checkForRoomsAvailable()) { idx in
                            Text("○ Open \(idx)").foregroundColor(.blue)
                        }
                        Section(header: Text("Staff")) {
                            ForEach(viewModel.staffInStation) { person in
                                PersonRow(person: person)
                            }
                        }
                        
                        // PersonRow(person: dropOff.people.first!)
                        
                    }
                    .frame(width: 220, height: 150, alignment: .leading)
                }
                VStack {
                    Text("Vehicle")
                    .font(.headline)
                    List(viewModel.staffInOrder) { person in
                        PersonRow(person: person)
                            .onTapGesture {
                                self.viewModel.transferPerson(fromStation: false, person: person)

                            }
                    }
                    /*
                    List {
                        ForEach(self.viewModel.staffInOrder) { person in
                            PersonRow(person: person)
                                .onTapGesture {
                                    self.viewModel.transferPerson(fromStation: false, person: person)
//                                    let result = station.addToStaff(person: person)
//                                    if result == true {
//                                        self.order.people.removeAll(where: {$0.id == person.id })
//                                        self.station.earthOrder = self.order
//                                        LocalDatabase.shared.saveStation(station: self.station)
//                                    }
                                }
                        }
                        /*
                        ForEach(0..<dropOff.people.count) { idx in
                            PersonRow(person: self.dropOff.people[idx])
                                .onTapGesture {
                                    let result = station.addToStaff(person: self.dropOff.people[idx])
                                    if result == true {
                                        self.dropOff.people.remove(at: idx)
                                    }
                                }
                        }*/
                    }
 */
                    .frame(width: 220, height: 150, alignment: .leading)
//                    .listStyle(SidebarListStyle())
                }
            }.padding(EdgeInsets(top: 2, leading: 4, bottom: 2, trailing: 4))
            
            Text("Ingredients")
            .font(.headline)
            
            HStack {
                VStack {
                    
                    List(viewModel.ingredientsInStation, id:\.hashValue) { ingredient in
                        IngredientView(ingredient: ingredient, hasIngredient: true, quantity: nil)
                                
                    }
                    .frame(width: 220, height: 120, alignment: .leading)
                }
                VStack {
                    
                    List {
                        ForEach(viewModel.ingredientsInOrder, id:\.hashValue) { ingredient in
                            IngredientView(ingredient: ingredient, hasIngredient: false, quantity: nil)
                                .onTapGesture {
                                    viewModel.transferIngredient(fromStation: false, ingredient: ingredient)
                                    /*
                                    let result = station.truss.addBoxWith(ingredient: ingredient)
                                    if result == true {
                                        self.order.ingredients.removeAll(where: {$0 == ingredient })
                                        self.station.earthOrder = self.order
                                        LocalDatabase.shared.saveStation(station: self.station)
                                    }
                                     */
                                }
                        }
                        /*
                        ForEach([Ingredient](dropOff.ingredients.keys), id:\.hashValue) { ingredient in
                            IngredientView(ingredient: ingredient, hasIngredient: false)
                                .onTapGesture {
                                    let result = station.truss.addBoxWith(ingredient: ingredient)
                                    if result == true {
                                        LocalDatabase.shared.saveStation(station: self.station)
                                    }else{
                                        print("Could not add box")
                                    }
                                }
                        }
                        */
                    }
                    .frame(width: 220, height: 120, alignment: .leading)
                }
            }.padding(EdgeInsets(top: 2, leading: 4, bottom: 2, trailing: 4))
            
            Text("Tanks")
            .font(.headline)
            
            HStack {
                VStack {
                    List(viewModel.tanksInStation, id:\.hashValue) { tank in
//                        ForEach(self.viewModel.tanksInStation, id:\.self) { tank in
                            Text("Tank \(tank.rawValue)")
//                        }
//                        ForEach(self.station.truss.getTanks()) { tank in
//                            Text("Tank \(tank.type.rawValue)")
//                        }
                        
                    }
                    .frame(width: 220, height: 120, alignment: .leading)
                }.padding(EdgeInsets(top: 2, leading: 4, bottom: 2, trailing: 4))
                VStack {
                    
                    List {
                        ForEach(self.viewModel.tanksInOrder, id:\.self) { tank in
                            Text("tank of \(tank.rawValue)")
                                .onTapGesture {
                                    viewModel.transferTank(fromStation: false, tank: tank)
//                                    let result = station.truss.addTank(tankType: tank)
//                                    if result == true {
//                                        self.order.tanks.removeAll(where: {$0 == tank })
//                                        self.station.earthOrder = self.order
//                                        LocalDatabase.shared.saveStation(station: self.station)
//                                    }
                                    LocalDatabase.shared.saveStation(station: self.station)
                                }
                        }
                    }
                    .frame(width: 220, height: 120, alignment: .leading)
                }
            }.padding(EdgeInsets(top: 2, leading: 4, bottom: 2, trailing: 4))
            
            
            HStack {
                Text("Total")
                .font(.headline)
                .padding(4)
                Text("S$:3,421.09")
                .font(.headline)
                .padding(4)
                    .foregroundColor(.orange)
                Button(action: {
                    self.station.earthOrder = nil
                }, label: {
                    Text("Reset")
                })
            }.padding()
            
        }
    }
}

struct DropOffView_Previews: PreviewProvider {
    static var previews: some View {
        DropOffView(station: LocalDatabase.shared.station!, order:EarthOrder.example)
    }
}

class DropOffViewModel:ObservableObject {
    
    @Published var staffInStation:[Person]
    @Published var staffInOrder:[Person]
    @Published var ingredientsInStation:[Ingredient]
    @Published var ingredientsInOrder:[Ingredient]
    @Published var tanksInStation:[TankType]
    @Published var tanksInOrder:[TankType]
    
    var station:Station
    var order:EarthOrder
    
    init(station:Station, order:EarthOrder) {
        self.station = station
        self.order = order
        
        self.staffInStation = station.getPeopleInRooms()
        self.staffInOrder = order.people
        let tmpIngredients = station.truss.extraBoxes
        var ingArray:[Ingredient] = []
        
        for item in tmpIngredients {
            ingArray.append(item.type)
        }
        self.ingredientsInStation = ingArray
        self.ingredientsInOrder = order.ingredients
        self.tanksInOrder = order.tanks
        let tmpTanks = station.truss.getTanks()
        var arrTanks:[TankType] = []
        for tank in tmpTanks {
            arrTanks.append(tank.type)
        }
        self.tanksInStation = arrTanks
    }
    
    func transferPerson(fromStation:Bool, person:Person) {
        if fromStation {
            self.staffInStation.removeAll(where: {$0.id == person.id})
            self.staffInOrder.append(person)
        }else{
            print("Transfering person")
            var oldStaff = self.staffInOrder
            oldStaff.removeAll(where: {$0.id == person.id})
            self.staffInOrder = oldStaff
            
            var newStaff = self.staffInStation
            newStaff.append(person)
            for member in newStaff {
                print("New Staff \(member.name)")
            }
            let result = self.station.addToStaff(person: person)
            if result == true {
                print("Result was true")
                self.staffInStation = newStaff
                LocalDatabase.shared.saveStation(station: station)
            }else{
                print("Result was bad")
            }
            
        }
    }
    
    func transferIngredient(fromStation:Bool, ingredient:Ingredient) {
        if fromStation {
            self.ingredientsInStation.removeAll(where: {$0 == ingredient})
            self.ingredientsInOrder.append(ingredient)
        }else{
            self.ingredientsInOrder.removeAll(where: {$0 == ingredient})
            self.ingredientsInStation.append(ingredient)
        }
    }
    
    func transferTank(fromStation:Bool, tank:TankType) {
        print("Transfering tank")
        if fromStation {
            self.tanksInStation.removeAll(where: {$0 == tank})
            self.tanksInOrder.append(tank)
        }else{
            print("Adding tank to station")
            self.tanksInOrder.removeAll(where: {$0 == tank})
            self.tanksInStation.append(tank)
            let result = self.station.truss.addTank(tankType: tank)
            print("Result: \(result)")
            
        }
    }
    
}
