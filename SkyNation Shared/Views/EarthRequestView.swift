//
//  EarthRequestView.swift
//  SkyTestSceneKit
//
//  Created by Farini on 9/15/20.
//  Copyright © 2020 Farini. All rights reserved.
//

import SwiftUI

struct EarthRequestView: View {
    
    @Environment(\.presentationMode) var presentationMode // To Dismiss
    
    @ObservedObject var controller:EarthRequestController = EarthRequestController()
    
    private var ingredientColumns: [GridItem] = [
        GridItem(.flexible(minimum: 120)),
        GridItem(.flexible(minimum: 120)),
        GridItem(.flexible(minimum: 120))
    ]
    
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
                        NotificationCenter.default.post(name: .closeView, object: self)
//                        self.presentationMode.wrappedValue.dismiss()
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
                    
                    case .Ordering(let order):
                        // What has already picked
                        Group {
                            
                            Text("Order")
                                .font(.title)
                            
                            ForEach(order.ingredients, id:\.id) { storageBox in
                                Text(storageBox.type.rawValue)
                                    .foregroundColor(.green)
                            }
                            ForEach(order.tanks, id:\.id) { tank in
                                Text(tank.type.rawValue)
                            }
                            ForEach(order.people, id:\.id) { person in
                                PersonRow(person: person)
                            }
                            
                            Divider()
                        }
                        
                        Picker(selection: $controller.orderAisle, label: Text("Aisle")) {
                            ForEach(EarthViewPicker.allCases, id:\.self) { earth in
                                Text(earth.rawValue)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        switch controller.orderAisle {
                            case .People:
                                LazyVGrid(columns: ingredientColumns, alignment:.center, spacing:8) {
                                    ForEach(PeopleMaker.shared.people) { person in
                                        PersonRow(person: person)
                                            .padding(8)
                                            .onTapGesture {
                                                controller.addToHire(person: person) //hire(person: person)
                                        }
                                    }
                                }

                            case .Ingredients:
                                LazyVGrid(columns: ingredientColumns, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 8, pinnedViews: /*@START_MENU_TOKEN@*/[]/*@END_MENU_TOKEN@*/) {
                                    ForEach(Ingredient.allCases.filter{$0.orderable}, id:\.self) { ingredient in
                                        IngredientView(ingredient: ingredient, hasIngredient: nil, quantity: ingredient.boxCapacity())
                                            .padding(3)
                                            .onTapGesture {
                                                controller.addToCart(ingredient: ingredient) //order(ingredient: ingredient)
                                            }
                                    }
                                }

                            case .Tanks:
                                LazyVGrid(columns: ingredientColumns, alignment:.center, spacing:8, pinnedViews:[]) {
                                    ForEach(TankType.allCases, id:\.self) { tankType in
                                        
                                        HStack {
                                            Image("Tank")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 42, height: 42)
                                            
                                            Text(tankType.rawValue).font(.subheadline).padding(3)
                                                
                                        }
                                        .onTapGesture {
                                            controller.addToCart(tankType: tankType)//order(tankType: TankType.allCases[index])
                                        }
                                        
                                    }
                                }
                        }
                        
                    case .Reviewing(let order):
                        
                        // What has already picked
                        Group {
                            
                            Text("Review order")
                                .font(.title)
                                .padding([.bottom], 6)
                            
                            // Quantity / Weight
                            HStack {
                                Image(systemName: "scalemass")
                                Text("\(controller.orderQuantity)00 / \(GameLogic.earthOrderLimit)00 Kg")
                            }
                            .font(.title2)
                            
                            HStack {
                                Image("Currency")
                                    .renderingMode(.template)
                                    .resizable()
                                    .fixedSize()
                                    .frame(width: 42, height: 42, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                                    .aspectRatio(contentMode: .fill)
                                VStack {
                                    Text("Current \(controller.money)").foregroundColor(.green)
                                    Text("(-) Costs \(controller.orderCost)").foregroundColor(.gray)
                                    Text("Balance: \(controller.money - controller.orderCost)").foregroundColor(.orange)
                                }
                            }
                            
                            Divider()
                            
                            Text("Items")
                                .font(.title2)
                                .foregroundColor(.orange)
                            
                            LazyVGrid(columns: ingredientColumns, alignment: .center, spacing: 8) {
                                ForEach(order.ingredients, id:\.id) { storageBox in
                                    IngredientView(ingredient: storageBox.type, hasIngredient: nil, quantity: storageBox.type.boxCapacity())
                                        .padding(3)
                                }
                                ForEach(order.tanks, id:\.id) { tank in
                                    TankRow(tank: tank)
                                        .padding(6)
                                }
                                ForEach(order.people, id:\.id) { person in
                                    PersonRow(person: person)
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
//                Divider()
            }
            .frame(minWidth: 600, maxWidth: .infinity, minHeight: 275, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment:.topLeading)
            
            Divider()
            
            // Footer Buttons
            VStack {
                HStack {
                    
                    switch controller.orderStatus {
                        case .Ordering(_):
//                            Text("Ordering: \(controller.orderQuantity) items.")
//                            Text("Total: \(controller.orderCost)")
                            
                            Button("Continue") {
                                controller.reviewOrder()
                            }
                            Button("Cancel") {
                                controller.clearOrder()
                            }
                            
                        case .Reviewing(_):
                            
//                            Text("Reviewing \(controller.orderQuantity) items.")
//                            Text("Total: \(controller.orderCost)")
                            
                            Button("Place Order") {
                                let success = self.confirmOrder()
                                if success {
                                    print("Order placed")
                                } else {
                                    print("See order error")
                                }
                            }
                            
                            Button("Resume") {
                                controller.resumeOrder()
                            }
                            Button("Start Over") {
                                controller.clearOrder()
                            }
                        case .OrderPlaced:
                            Text("Order Placed")

                        case .Delivering:
//                            Text("Delivering")
//                                .font(.headline)
//                                .foregroundColor(.blue)
                            
                            Button("🚫 Reject") {
                                controller.clearOrder()
                            }
                            .foregroundColor(.red)
                            
                            Button("✅ Accept") {
                                controller.acceptDelivery()
                            }
                    }
                }
                
                if !controller.errorMessage.isEmpty {
                    Text("* \(controller.errorMessage)")
                        .foregroundColor(.red)
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

/*
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
*/

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

struct IngredientRow:Identifiable {
    let id = UUID()
    let cells:[IngredientView]
}

struct EarthRequestView_Previews: PreviewProvider {
    static var previews: some View {
        EarthRequestView()
    }
}

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
