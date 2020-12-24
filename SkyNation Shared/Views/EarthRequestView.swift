//
//  EarthRequestView.swift
//  SkyTestSceneKit
//
//  Created by Farini on 9/15/20.
//  Copyright © 2020 Farini. All rights reserved.
//

import SwiftUI

struct EarthRequestView: View {
    
    private var ingredientColumns: [GridItem] = [
        GridItem(.flexible(minimum: 72)),
        GridItem(.flexible(minimum: 72)),
        GridItem(.flexible(minimum: 72))
    ]
    
    @Environment(\.presentationMode) var presentationMode // To Dismiss
//    @Environment(\.isPresented) var isPresented: Binding<Bool>?
    
    @State var selectedIngredients:[Ingredient] = []
    @State var selectedTanks:[TankType] = []
    @State var selectedPeople:[Person] = []
    @State private var currentSelectionType:EarthViewPicker = .People
    
    var money = LocalDatabase.shared.station!.money
    @State var orderCost:Double = EarthOrder.basePrice
    
    @ObservedObject var controller:EarthRequestController = EarthRequestController()
    
    var body: some View {
        
        VStack {
            
            // Header
            Group {
                HStack(alignment: VerticalAlignment.lastTextBaseline, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/) {
                    VStack(alignment:.leading) {
                        Text("🌎 Earth").font(.largeTitle).padding(.leading)
                        Text("Request ingredients from Earth")
                            .foregroundColor(.gray)
                            .padding(.leading)
                    }
                    
                    Spacer()
                    Text("S$: \(GameFormatters.numberFormatter.string(from: NSNumber(value: controller.money))!)")
                        .font(.title)
                        .foregroundColor(.green)
                        
                    
                    // Tutorial
                    Button(action: {
                        print("Tutorial action")
                    }, label: {
                        Image(systemName: "questionmark.diamond")
                            .resizable()
                            .aspectRatio(contentMode:.fit)
                            .frame(width:34, height:34)
                    })
                    .buttonStyle(GameButtonStyle(foregroundColor: .white, backgroundColor: .black, pressedColor: .orange))
                    
                    
                    // Close
                    Button(action: {
                        print("Close action")
                    }, label: {
                        Image(systemName: "xmark.circle")
                            .resizable()
                            .aspectRatio(contentMode:.fit)
                            .frame(width:34, height:34)
                    })
                    .buttonStyle(GameButtonStyle(foregroundColor: .white, backgroundColor: .black, pressedColor: .orange))
                    .padding(.trailing, 6)
                }
                Divider()
            }
            
            // Body
            ScrollView {
                
                switch controller.orderStatus {
                    
                    case .Ordering(_):
                        // What has already picked
                        Group {
                            Text("Delivery Order").font(.title)
                            if controller.selectedIngredients.isEmpty && controller.selectedTanks.isEmpty && controller.selectedPeople.isEmpty {
                                Text("<< Order is empty >>")
                                    .foregroundColor(.gray)
                            }
                            ForEach(controller.selectedIngredients, id:\.self) { order in
                                Text(order.rawValue).foregroundColor(.green)
                            }
                            ForEach(controller.selectedTanks, id:\.self) { tank in
                                Text(tank.rawValue)
                            }
                            ForEach(controller.selectedPeople) { person in
                                PersonRow(person: person)
                            }
                            Divider()
                        }
                        Picker(selection: $controller.currentSelectionType, label: Text("")) {
                            ForEach(EarthViewPicker.allCases, id:\.self) { earth in
                                Text(earth.rawValue)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        switch controller.currentSelectionType {
                            case .People:
                                LazyVGrid(columns: ingredientColumns, alignment:.center, spacing:8) {
                                    ForEach(PeopleMaker.shared.people) { person in
                                        PersonRow(person: person)
                                            .padding(8)
                                            .onTapGesture {
                                                controller.hire(person: person)
                                        }
                                    }
                                }

                            case .Ingredients:
                                LazyVGrid(columns: ingredientColumns, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 8, pinnedViews: /*@START_MENU_TOKEN@*/[]/*@END_MENU_TOKEN@*/) {
                                    ForEach(Ingredient.allCases.filter{$0.orderable}, id:\.self) { ingredient in
                                        IngredientView(ingredient: ingredient, hasIngredient: nil, quantity: ingredient.boxCapacity())
                                            .padding(3)
                                            .onTapGesture {
                                                controller.order(ingredient: ingredient)
                                            }
                                    }
                                }

                            case .Tanks:
                                LazyVGrid(columns: ingredientColumns, alignment:.center, spacing:8, pinnedViews:[]) {
                                    ForEach(0..<TankType.allCases.count) { index in
                                        
                                        HStack {
                                            Image("Tank")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 42, height: 42)
                                            
                                            Text(TankType.allCases[index].rawValue).font(.subheadline).padding(3)
                                                
                                        }
                                        .onTapGesture {
                                            controller.order(tankType: TankType.allCases[index])
                                        }
                                        
                                    }
                                }
                        }
                        
                    case .Reviewing:
                        Text("Reviewing")
                            .foregroundColor(.orange)
                        
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
                            
                            // Ingredients
                            LazyVGrid(columns: ingredientColumns, alignment: .center, spacing: 8, pinnedViews: /*@START_MENU_TOKEN@*/[]/*@END_MENU_TOKEN@*/) {
                                ForEach(controller.currentOrder!.ingredients) { ingredient in
                                    IngredientView(ingredient: ingredient.type, hasIngredient: nil, quantity: nil)
                                        .padding(3)
                                }
                            }
                            
                            if let order:PayloadOrder = controller.currentOrder {
                                
                                // Ingredients
                                ForEach(order.ingredients) { ingredient in
                                    Text("Ingredient: \(ingredient.type.rawValue)")
                                    IngredientView(ingredient: ingredient.type, hasIngredient: true, quantity: nil)
                                }
                                // Tanks
                                ForEach(order.tanks) { tank in
                                    Text("Ingredient: \(tank.type.rawValue)")
                                }
                                // People
                                ForEach(order.people) { person in
                                    PersonSmallView(person: person)
                                }
                            }
                        }
                        
                        
                    case .Delivered:
                        Text("Closed")
                            .foregroundColor(.orange)
                }
                Divider()
            }
            
            Divider()
            
            // Footer Buttons
            VStack {
                HStack {
                    
                    switch controller.orderStatus {
                        case .Ordering(let what):
                            Text("Ordering: \(what.rawValue)")
                            Text("Total: \(Int(self.orderCost))")
                            Button("Place Order") {
                                controller.placeOrder()
                            }
                            Button("Review") {
                                controller.reviewOrder()
                            }
                            Button("Cancel") {
                                controller.clearOrder()
                            }
                        case .Reviewing:
                            Text("Reviewing")
                            Text("Total: \(Int(self.orderCost))")
                            Button("Place Order") {
                                controller.placeOrder()
                            }
                            Button("Resume") {
                                controller.reviewOrder()
                            }
                            Button("Start Over") {
                                controller.clearOrder()
                            }
                        case .OrderPlaced:
                            Text("Order Placed")
                            Button("Order More") {
                                controller.orderMore()
                            }
                        case .Delivering:
                            Text("Delivery action")
                                .font(.headline)
                                .foregroundColor(.blue)
                            
                            Button("Reject") {
                                controller.clearOrder()
                            }
                            .foregroundColor(.red)
                            
                            Button("Accept") {
                                controller.acceptDelivery()
                            }
                            
                        case .Delivered:
                            Text("Closed")
                    }
                }
                
                if !controller.errorMessage.isEmpty {
                    Text("* \(controller.errorMessage)")
                        .foregroundColor(.red)
                }
            
            }
            .padding(.vertical)
        }
        .frame(height: 600)
        
    }
    
    func order(ingredient:Ingredient) {
        
        selectedIngredients.append(ingredient)
        updateOrder()
    }
    
    func hire(person:Person) {
        updateOrder()
        selectedPeople.append(person)
    }
    
    func order(tank:TankType) {
        updateOrder()
        selectedTanks.append(tank)
    }
    
    func updateOrder() {
        let order = EarthOrder()
        order.ingredients = selectedIngredients
        order.tanks = selectedTanks
        order.people = selectedPeople
        let cost = order.calculateTotal()
        self.orderCost = cost
    }
    
    func confirmOrder() -> Bool {
        if money - orderCost >= 0 {
            let station = LocalDatabase.shared.station!
            let order = EarthOrder()
            order.ingredients = selectedIngredients
            order.tanks = selectedTanks
            order.people = selectedPeople
            station.earthOrder = order
            station.money -= self.orderCost
            LocalDatabase.shared.saveStation(station: station)
            
            return true
            
        }
        
        return false
    }
    
    
}

#if os(macOS)
struct MyView: View {
    let myWindow:NSWindow?
    var body: some View {
        VStack{
            Text("This is in a separate window.")
            HStack{
                Button(action:{
                    showWindow()
                }) {
                    Text("Open another window")
                }
                Button(action:{
                    self.myWindow?.close()
                }) {
                    Text("Close this window")
                }
            }
        }
    .padding()
    }
    
    func showWindow() {
        var windowRef:NSWindow
        windowRef = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 100, height: 100),
            styleMask: [.titled, .closable, .miniaturizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        windowRef.contentView = NSHostingView(rootView: MyView(myWindow: windowRef))
//        windowRef.contentViewController?.presentAsModalWindow(<#T##viewController: NSViewController##NSViewController#>)
        windowRef.makeKeyAndOrderFront(nil)
    }
}
#endif

struct IngredientRow:Identifiable {
    let id = UUID()
    let cells:[IngredientView]
}

struct EarthRequestView_Previews: PreviewProvider {
    static var previews: some View {
        EarthRequestView()
    }
}

/*
struct MyWindow_Previews: PreviewProvider {
    static var previews: some View {
//        var windowRef:NSWindow
//        windowRef = NSWindow(
//            contentRect: NSRect(x: 0, y: 0, width: 100, height: 100),
//            styleMask: [.titled, .closable, .miniaturizable, .fullSizeContentView],
//            backing: .buffered, defer: false)
        
        return MyView(myWindow: nil)
        
        
    }
}
*/

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
