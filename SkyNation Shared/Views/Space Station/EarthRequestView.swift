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
    @State var popoverTutorial:Bool = false
    @State var alertRenewPeople:Bool = false
    
    @State var selectedPeople:[Person] = []
    
    private var ingredientColumns: [GridItem] = [
        GridItem(.fixed(200)),
        GridItem(.fixed(200)),
        GridItem(.fixed(200))
    ]
    
    private var shape = RoundedRectangle(cornerRadius: 8, style: .continuous)
    
    var header: some View {
        
        Group {
            HStack() {
                VStack(alignment:.leading) {
                    Text("🌎 Earth")
                        .font(GameFont.title.makeFont())
                    Text("Order items needed.")
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Money
                HStack {
                    Image("Currency")
                        .renderingMode(.template)
                        .resizable()
                        .fixedSize()
                        .frame(width: 16, height: 16, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                        .aspectRatio(contentMode: .fill)
                    
                    Text(" \(GameFormatters.numberFormatter.string(from: NSNumber(value: controller.money))!)")
                        .foregroundColor(.green)
                }
                
                
                // Tutorial
                Button(action: {
                    popoverTutorial.toggle()
                }, label: {
                    Image(systemName: "questionmark.circle")
                        .font(.title2)
                })
                .buttonStyle(SmallCircleButtonStyle(backColor: .orange))
                .popover(isPresented: $popoverTutorial, content: {
                    TutorialView(tutType: .OrderView)
                })
                
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
        
        // Add Picker, Summary, and costs here
    }
    
    var body: some View {
        
        VStack {
            
            // Header
            header
            
            switch controller.orderStatus {
                
                case .Ordering(let order):
                    
                    
                    // Summary + Aisle
                    Group {
                        HStack(spacing:12) {
                            
                            // New Picker
                            EarthRequestTabView(selection: $controller.orderAisle) { selectedAisle in
                                self.controller.orderAisle = selectedAisle
                            }
                            Spacer()
                            
                            // Summary
                            VStack {
                                HStack {
                                    Text("Net Weight")
                                        .font(GameFont.section.makeFont())
                                        .foregroundColor(.gray)
                                    Image(systemName: "scalemass")
                                        .font(.title3)
                                        .foregroundColor(.gray)
                                }
                                
                                
                                // Quantity / Weight
                                HStack {
                                    
                                    Text("\(controller.orderQuantity)00 / \(GameLogic.earthOrderLimit)00 Kg")
                                }
                                .font(.title3)
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
                    .padding([.horizontal])
                    
                    
                    ScrollView {
                        
                        switch controller.orderAisle {
                            case .People:
                                LazyVGrid(columns: ingredientColumns, alignment:.center, spacing:8) {
                                    
                                    ForEach(LocalDatabase.shared.player.wallet.getPeople()) { person in
                                        
                                        PersonOrderView(person: person)
                                            .overlay(
                                                shape
                                                    .inset(by: 0.5)
                                                    .stroke(selectedPeople.contains(person) ? Color.blue.opacity(0.9):Color.clear, lineWidth: 1)
                                            )
                                            
                                            .onTapGesture {
                                                
                                                controller.addToHire(person: person)
                                                
                                                if selectedPeople.contains(person) {
                                                    selectedPeople.removeAll(where:  { $0.id == person.id })
                                                } else {
                                                    selectedPeople.append(person)
                                                }
                                            }
                                    }
                                    
                                    HStack {
                                        Image(systemName:"clock")
                                            .font(.title)
                                        VStack {
                                            let delay = Double(TimeInterval.oneDay) / 24.0 // 1hr
                                            let time:Double = LocalDatabase.shared.player.wallet.timeToGenerateNextPeople().rounded()
                                            let display = GameFormatters.humanReadableTimeInterval(delta: delay - time)
                                            
                                            Text("Refresh in \(display)")
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
                                                
                                            let player = LocalDatabase.shared.player
                                            if let token = player.requestToken() {
                                                    
                                                    let pplResult = player.wallet.getPeople(true)
                                                    guard !pplResult.isEmpty else { return }
                                                    
                                                    let result = player.spendToken(token: token, save: true)
                                                    print("Used Token: \(result)")
                                                } else {
                                                    controller.errorMessage = "Not enough tokens"
                                                }
                                                
                                                
                                              }))
                                    })
                                }
                                
                            case .Ingredients:
                                LazyVGrid(columns: ingredientColumns, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 8, pinnedViews: []) {
                                    
                                    ForEach(Ingredient.allCases.filter{$0.orderable}, id:\.self) { ingredient in
                                        
                                        IngredientOrderView(ingredient: ingredient)
                                            .overlay(
                                                shape
                                                    .inset(by: 0.5)
                                                    .stroke((controller.currentOrder?.ingredients.compactMap({ $0.type }) ?? []).contains(ingredient) ? Color.blue.opacity(0.9):Color.clear, lineWidth: 1)
                                            )
                                            .onTapGesture {
                                                controller.addToCart(ingredient: ingredient)
                                            }
                                    }
                                }
                                
                            case .Tanks:
                                LazyVGrid(columns: ingredientColumns, alignment:.center, spacing:8, pinnedViews:[]) {
                                    
                                    let typesSelected:[TankType] = controller.currentOrder?.tanks.compactMap({ $0.type }) ?? []
                                    
                                    ForEach(TankType.allCases, id:\.self) { tankType in
                                        let tSelected:Bool = typesSelected.contains(tankType)
                                        
                                        TankOrderView(tank: tankType)
                                            .overlay(
                                                shape
                                                    .inset(by: 0.5)
                                                    .stroke(tSelected ? Color.blue.opacity(0.9):Color.clear, lineWidth: 1)
                                            )
                                            .onTapGesture {
                                                controller.addToCart(tankType: tankType)
                                            }
                                    }
                                }
                        } // End Switch
                    } // End ScrollView
                
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
                        
                        ScrollView {
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
                        
                        // Items
                        ScrollView {
                            LazyVGrid(columns: ingredientColumns, alignment: .center, spacing: 8, pinnedViews: /*@START_MENU_TOKEN@*/[]/*@END_MENU_TOKEN@*/) {
                                
                                // Ingredients
                                ForEach(controller.currentOrder!.ingredients) { ingredient in
                                    IngredientView(ingredient: ingredient.type, hasIngredient: nil, quantity: nil)
                                        .padding(3)
                                }
                                // Tanks
                                ForEach(controller.currentOrder!.tanks) { tank in
                                    TankRow(tank: .constant(tank), selected:false)
                                }
                                // People
                                ForEach(controller.currentOrder!.people) { person in
                                    PersonSmallView(person: person)
                                }
                            }
                        }
                        
                    }
            }
            
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
        .background(GameColors.darkGray)
        .frame(minWidth: 660, idealWidth: 700, maxWidth: 900, minHeight: 500, idealHeight: 550, maxHeight: 600, alignment: .center)
        .cornerRadius(10)
    }
    
    func confirmOrder() -> Bool {
        return controller.placeOrder()
    }
    
}

struct EarthRequestTabView:View {
    
    @Binding var selection:EarthViewPicker
    var callBack:((EarthViewPicker) -> ()) = { _ in }
    
    // MARK: - Gradients
    private static let myGradient = Gradient(colors: [Color.red.opacity(0.6), Color.blue.opacity(0.7)])
    private static let unseGradient = Gradient(colors: [Color.red.opacity(0.3), Color.blue.opacity(0.3)])
    private let selLinear = LinearGradient(gradient: myGradient, startPoint: .topLeading, endPoint: .bottomTrailing)
    private let unselinear = LinearGradient(gradient: unseGradient, startPoint: .topLeading, endPoint: .bottomTrailing)
    
    var body: some View {
        HStack {
            ForEach(EarthViewPicker.allCases, id:\.self) { aisle in
                switch aisle {
                    case .Ingredients:
                        Image(systemName: "archivebox")
                            .resizable()
                            .frame(width:26, height:24)
                            .padding(8)
                            .background(selection == .Ingredients ? selLinear:unselinear)
                            .cornerRadius(4)
                            .clipped()
                            .overlay(
                                RoundedRectangle(cornerRadius: 4, style: .continuous)
                                    .inset(by: 0.5)
                                    .stroke(selection == .Ingredients ? Color.blue:Color.clear, lineWidth: 2)
                            )
                            .help("Ingredients")
                            .onTapGesture {
                                callBack(.Ingredients)
                            }
                    case .Tanks:
                        GameImages.imageForTank()
                            .resizable()
                            .frame(width:34, height:32)
                            .padding(4)
                            .background(selection == .Tanks ? selLinear:unselinear)
                            .cornerRadius(4)
                            .clipped()
                            .overlay(
                                RoundedRectangle(cornerRadius: 4, style: .continuous)
                                    .inset(by: 0.5)
                                    .stroke(selection == .Tanks ? Color.blue:Color.clear, lineWidth: 2)
                            )
                            .help("Tanks")
                            .onTapGesture {
                                callBack(.Tanks)
                            }
                    case .People:
                        Image(systemName: "person")
                            .resizable()
                            .frame(width:26, height:24)
                            .padding(8)
                            .background(selection == .People ? selLinear:unselinear)
                            .cornerRadius(4)
                            .clipped()
                            .overlay(
                                RoundedRectangle(cornerRadius: 4, style: .continuous)
                                    .inset(by: 0.5)
                                    .stroke(selection == .People ? Color.blue:Color.clear, lineWidth: 2)
                            )
                            .help("Tanks")
                            .onTapGesture {
                                callBack(.People)
                            }
                        
                }
            }
        }
    }
}

struct EarthRequestView_Previews: PreviewProvider {
    static var previews: some View {
        EarthRequestView()
            .preferredColorScheme(.dark)
            .frame(maxWidth:.infinity)
        
        EarthRequestTabView(selection: .constant(.Ingredients)) { _ in }
    }
}
