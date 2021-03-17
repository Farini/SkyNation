//
//  EarthRequestView.swift
//  SkyTestSceneKit
//
//  Created by Farini on 9/15/20.
//  Copyright © 2020 Farini. All rights reserved.
//

import SwiftUI

struct EarthRequestView: View {
    
    @ObservedObject var controller:EarthRequestController = EarthRequestController()
    @State var infoPopover:Bool = false
    @State var alertRenewPeople:Bool = false
    
    private var ingredientColumns: [GridItem] = [
        GridItem(.fixed(200)),
        GridItem(.fixed(200)),
        GridItem(.fixed(200))
    ]
    
    var header: some View {
        
        Group {
            HStack() {
                VStack(alignment:.leading) {
                    Text("🌎 Earth").font(.largeTitle)
                    Text("Request ingredients from Earth")
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Money
                Text("S$: \(GameFormatters.numberFormatter.string(from: NSNumber(value: controller.money))!)")
                    .foregroundColor(.green)
                
                // Tutorial
                Button(action: {
                    print("Question ?")
                }, label: {
                    Image(systemName: "questionmark.circle")
                        .font(.title2)
                })
                .buttonStyle(SmallCircleButtonStyle(backColor: .orange))
                
                // Close
                Button(action: {
                    NotificationCenter.default.post(name: .closeView, object: self)
                }) {
                    Image(systemName: "xmark.circle")
                        .font(.title2)
                }.buttonStyle(SmallCircleButtonStyle(backColor: .pink))
                
            }
            .padding([.leading, .trailing, .top], 8)
            
            Divider()
                .offset(x: 0, y: -5)
        }
    }
    
    var body: some View {
        
        VStack {
            
            // Header
            header
            
            // Body
            ScrollView {
                
                switch controller.orderStatus {
                    
                    case .Ordering(let order):
                        
                        // Summary
                        Group {
                            
                            HStack {
                                
                                // Summary
                                VStack(alignment:.leading) {
                                    Text("Summary")
                                        .font(.title2)
                                        .foregroundColor(.gray)
                                    
                                    // Quantity / Weight
                                    HStack {
                                        Image(systemName: "scalemass")
                                        Text("\(controller.orderQuantity)00 / \(GameLogic.earthOrderLimit)00 Kg")
                                    }
                                    .font(.title2)
                                }
                                
                                Spacer()
                                
                                // Costs
                                HStack {
                                    
                                    // Order Ticket Popover
                                    Button(action: {
                                        infoPopover.toggle()
                                        
                                    }) {
                                        Image("Currency")
                                            .renderingMode(.template)
                                            .resizable()
                                            .fixedSize()
                                            .frame(width: 32, height: 32, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                                            .aspectRatio(contentMode: .fill)
                                    }
                                    .buttonStyle(NeumorphicButtonStyle(bgColor: .gray))
                                    .popover(isPresented: $infoPopover) {
                                        List {
                                            
                                            HStack {
                                                Text("Base Cost (Rocket): ")
                                                Spacer()
                                                Text("$ \(PayloadOrder.basePrice)")
                                            }
                                            .foregroundColor(.orange)
                                            
                                            Divider()
                                            ForEach(order.ingredients, id:\.id) { storageBox in
                                                HStack {
                                                    Text("\(storageBox.type.rawValue) x \(storageBox.capacity)")
                                                    Spacer()
                                                    Text("$ \(storageBox.type.price)")
                                                }
                                            }
                                            Divider()
                                            ForEach(order.tanks, id:\.id) { tank in
                                                HStack {
                                                    Text("Tank \(tank.type.rawValue)")
                                                    Spacer()
                                                    Text("$ \(tank.type.price)")
                                                }
                                            }
                                            Divider()
                                            ForEach(order.people, id:\.id) { person in
                                                HStack {
                                                    Text("\(person.name)")
                                                    Spacer()
                                                    Text("$ \(GameLogic.orderPersonPrice)")
                                                }
                                            }
                                            Divider()
                                            HStack {
                                                Text("Total")
                                                    .font(.headline)
                                                Spacer()
                                                Text("$ \(order.calculateTotal())")
                                                    .font(.headline)
                                            }
                                            
                                        }
                                    }
                                    
                                    VStack {
                                        Text("(-) Costs \(controller.orderCost)").foregroundColor(.gray)
                                        Text("Balance: \(controller.money - controller.orderCost)").foregroundColor(.orange)
                                    }
                                }
                            }
                            
                            Divider()
                        }
                        .padding([.leading, .trailing], 8)
                        
                        // Aisle Picker
                        Picker(selection: $controller.orderAisle, label: Text("")) {
                            ForEach(EarthViewPicker.allCases, id:\.self) { earth in
                                Text(earth.rawValue)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        switch controller.orderAisle {
                            case .People:
                                LazyVGrid(columns: ingredientColumns, alignment:.center, spacing:8) {
                                    ForEach(LocalDatabase.shared.gameGenerators?.people ?? []) { person in
                                        PersonOrderView(person: person)
                                            .onTapGesture {
                                                controller.addToHire(person: person)
                                            }
                                    }
                                    HStack {
                                        Image(systemName:"clock")
                                            .font(.title)
                                        VStack {
//                                            let delta = LocalDatabase.shared.gameGenerators!.datePeople.timeIntervalSince(Date())
                                            let oo = Calendar.current.dateComponents([.minute, .second], from: LocalDatabase.shared.gameGenerators!.datePeople, to: Date())
                                            Text("Refresh: \(oo.minute ?? 0)m \(oo.second ?? 0)s")
                                        }
                                    }
                                    .padding(8)
                                    .background(Color.black)
                                    .cornerRadius(6)
                                    .onTapGesture {
                                        alertRenewPeople.toggle()
                                    }
                                    .alert(isPresented: $alertRenewPeople, content: {
                                        Alert(title: Text("Refresh candidates"), message: Text("Spend 1 token to refresh candidates?"),
                                              primaryButton: .cancel(),
                                              secondaryButton: .destructive(Text("Yes"), action: {
                                                
                                                LocalDatabase.shared.gameGenerators?.spentTokenToUpdate(amt: 1)
                                                controller.orderAisle = .People
                                                
                                              }))
                                    })
                                }

                            case .Ingredients:
                                LazyVGrid(columns: ingredientColumns, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 8, pinnedViews: []) {
                                    
                                    ForEach(Ingredient.allCases.filter{$0.orderable}, id:\.self) { ingredient in
                                        
                                        IngredientOrderView(ingredient: ingredient)
                                            .onTapGesture {
                                                controller.addToCart(ingredient: ingredient)
                                            }
                                    }
                                }

                            case .Tanks:
                                LazyVGrid(columns: ingredientColumns, alignment:.center, spacing:8, pinnedViews:[]) {
                                    
                                    ForEach(TankType.allCases, id:\.self) { tankType in
                                        
                                        TankOrderView(tank: tankType)
                                            .onTapGesture {
                                                controller.addToCart(tankType: tankType)
                                            }
                                    }
                                }
                        }
                        
                    case .Reviewing(let order):
                        
                        // Review the order
                        Group {
                            
                            // Review
                            Group {
                                
                                HStack {
                                    
                                    // Summary
                                    VStack(alignment:.leading) {
                                        Text("Review")
                                            .font(.title2)
                                            .foregroundColor(.gray)
                                        
                                        // Quantity / Weight
                                        HStack {
                                            Image(systemName: "scalemass")
                                            Text("\(controller.orderQuantity)00 / \(GameLogic.earthOrderLimit)00 Kg")
                                        }
                                        .font(.title2)
                                    }
                                    
                                    Spacer()
                                    
                                    // Costs
                                    HStack {
                                        
                                        // Order Ticket Popover
                                        Button(action: {
                                            infoPopover.toggle()
                                            
                                        }) {
                                            Image("Currency")
                                                .renderingMode(.template)
                                                .resizable()
                                                .fixedSize()
                                                .frame(width: 32, height: 32, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                                                .aspectRatio(contentMode: .fill)
                                        }
                                        .buttonStyle(NeumorphicButtonStyle(bgColor: .gray))
                                        .popover(isPresented: $infoPopover) {
                                            List {
                                                
                                                HStack {
                                                    Text("Base Cost (Rocket): ")
                                                    Spacer()
                                                    Text("$ \(PayloadOrder.basePrice)")
                                                }
                                                .foregroundColor(.orange)
                                                
                                                Divider()
                                                ForEach(order.ingredients, id:\.id) { storageBox in
                                                    HStack {
                                                        Text("\(storageBox.type.rawValue) x \(storageBox.capacity)")
                                                        Spacer()
                                                        Text("$ \(storageBox.type.price)")
                                                    }
                                                }
                                                Divider()
                                                ForEach(order.tanks, id:\.id) { tank in
                                                    HStack {
                                                        Text("Tank \(tank.type.rawValue)")
                                                        Spacer()
                                                        Text("$ \(tank.type.price)")
                                                    }
                                                }
                                                Divider()
                                                ForEach(order.people, id:\.id) { person in
                                                    HStack {
                                                        Text("\(person.name)")
                                                        Spacer()
                                                        Text("$ \(GameLogic.orderPersonPrice)")
                                                    }
                                                }
                                                Divider()
                                                HStack {
                                                    Text("Total")
                                                        .font(.headline)
                                                    Spacer()
                                                    Text("$ \(order.calculateTotal())")
                                                        .font(.headline)
                                                }
                                                
                                            }
                                        }
                                        
                                        VStack {
                                            Text("(-) Costs \(controller.orderCost)").foregroundColor(.gray)
                                            Text("Balance: \(controller.money - controller.orderCost)").foregroundColor(.orange)
                                        }
                                    }
                                }
                                
                                Divider()
                            }
                            .padding([.leading, .trailing], 8)
                            
                            
                            Text("Items")
                                .font(.title2)
                                .foregroundColor(.orange)
                            
                            LazyVGrid(columns: ingredientColumns, alignment: .center, spacing: 8) {
                                
                                ForEach(order.ingredients, id:\.id) { storageBox in
                                    VStack {
                                        IngredientOrderView(ingredient: storageBox.type)
                                    }
                                }
                                
                                ForEach(order.tanks, id:\.id) { tank in
                                    TankOrderView(tank:tank.type)
                                }
                                
                                ForEach(order.people, id:\.id) { person in
                                    PersonOrderView(person: person)
                                }
                            }
                        }
                        
                    case .OrderPlaced:
                        
                        Group {
                            Text("Order Placed. Wait for delivery now.")
                                .foregroundColor(.orange)
                            
                        }
                        
                    case .Delivering:
                        
                        Group {
                            // Head
                            VStack {
                                Text("📦 Delivery")
                                    .font(.largeTitle)
                                    .foregroundColor(.orange)
                                Text("Here are the items being delivered")
                                    .foregroundColor(.gray)
                            }
                            .padding([.bottom], 6)
                            
                            Divider()
                            
                            LazyVGrid(columns: ingredientColumns, alignment: .center, spacing: 8, pinnedViews: /*@START_MENU_TOKEN@*/[]/*@END_MENU_TOKEN@*/) {
                                // Ingredients
                                ForEach(controller.currentOrder!.ingredients) { ingredient in
                                    IngredientView(ingredient: ingredient.type, hasIngredient: nil, quantity: nil)
                                        .padding(3)
                                }
                                // Tanks
                                ForEach(controller.currentOrder!.tanks) { tank in
                                    //                                    Text("Ingredient: \(tank.type.rawValue)")
                                    TankRow(tank: tank)
                                }
                                // People
                                ForEach(controller.currentOrder!.people) { person in
                                    PersonSmallView(person: person)
                                }
                            }
                        }
                }
            }
            .frame(minWidth: 620, maxWidth: .infinity, minHeight: 275, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment:.topLeading)
            
            Divider()
            
            // Footer Buttons
            VStack {
                
                // Errors
                if !controller.errorMessage.isEmpty {
                    Text("* \(controller.errorMessage)")
                        .foregroundColor(.red)
                }
                
                HStack {
                    
                    switch controller.orderStatus {
                        case .Ordering(_):
                            
                            Button(action: {
                                controller.clearOrder()
                            }) {
                                HStack {
                                    Image(systemName: "xmark.circle")
                                    Text("Clear")
                                }
                                .frame(minWidth: 75, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                            }
                            .buttonStyle(NeumorphicButtonStyle(bgColor: .gray))
                            
                            Button(action: {
                                controller.reviewOrder()
                            }) {
                                HStack {
                                    Image(systemName: "cart.fill")
                                    Text("Checkout")
                                }
                                .frame(minWidth: 75, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                            }
                            .buttonStyle(NeumorphicButtonStyle(bgColor: .gray))
                            
                        case .Reviewing(_):
                            
                            // Go Back
                            Button(action: {
                                controller.resumeOrder()
                            }) {
                                Image(systemName: "backward.frame")
                            }
                            .buttonStyle(NeumorphicButtonStyle(bgColor: .gray))
                            .help("Go back")
                            
                            
                            // Clear
                            Button(action: {
                                controller.clearOrder()
                            }) {
                                HStack {
                                    Image(systemName: "xmark.circle")
                                    Text("Clear")
                                }
                                .frame(minWidth: 75, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                            }
                            .buttonStyle(NeumorphicButtonStyle(bgColor: .gray))
                            
                            // Confirm
                            Button(action: {
                                let success = self.confirmOrder()
                                if success {
                                    print("Order placed")
                                    NotificationCenter.default.post(name: .closeView, object: self)
                                } else {
                                    print("See order error")
                                }
                            }) {
                                HStack {
                                    Image(systemName: "cart.fill")
                                    Text("Confirm")
                                }
                                .frame(minWidth: 75, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                            }
                            .buttonStyle(NeumorphicButtonStyle(bgColor: .gray))
                            
                            
                        case .OrderPlaced:
                            Text("Order Placed")

                        case .Delivering:
                            
                            Button(action: {
                                controller.clearOrder()
                            }) {
                                HStack {
                                    Image(systemName: "xmark.octagon.fill")
                                        .foregroundColor(.red)
                                    Text("Reject")
                                }
                                .frame(minWidth: 75, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                            }
                            .buttonStyle(NeumorphicButtonStyle(bgColor: .gray))
                            
                            Button(action: {
                                controller.acceptDelivery()
                            }) {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                    Text("Accept")
                                }
                                .frame(minWidth: 75, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                            }
                            .buttonStyle(NeumorphicButtonStyle(bgColor: .gray))
                            
                    }
                }
                
            }
            .padding(.vertical)
        }
        .frame(height: 550)
        
    }
 
    func confirmOrder() -> Bool {
        return controller.placeOrder()
    }
    
}

struct EarthRequestView_Previews: PreviewProvider {
    static var previews: some View {
        EarthRequestView()
    }
}


/*
class PeopleMaker {
    static var shared = PeopleMaker()
    private init() {
        var tmpPeople:[Person] = []
        // 20?
        for _ in 0..<16 {
            let person = Person(random: true)
            tmpPeople.append(person)
        }
        self.people = tmpPeople
    }
    var people:[Person] = []
}
*/

extension Array {
    /// Use this to divide views in stacks
    func chunked(into size:Int) -> [[Element]] {
        
        var chunkedArray = [[Element]]()
        
        for index in 0...self.count {
            if index % size == 0 && index != 0 {
                chunkedArray.append(Array(self[(index - size)..<index]))
            } else if(index == self.count) {
                chunkedArray.append(Array(self[index - 1..<index]))
            }
        }
        
        return chunkedArray
    }
}
