//
//  IngredientView.swift
//  SkyTestSceneKit
//
//  Created by Farini on 9/26/20.
//  Copyright © 2020 Farini. All rights reserved.
//

import Foundation
import SwiftUI

struct IngredientView:View {
    
    let ingOptions:[Ingredient] = Ingredient.allCases
    var ingredient:Ingredient
    @State var hasIngredient:Bool?
    @State var quantity:Int?
    var image:Image = Image(systemName: "questionmark")
    
    init(ingredient:Ingredient, hasIngredient:Bool?, quantity:Int?) {
        self.ingredient = ingredient
        self.hasIngredient = hasIngredient
        self.quantity = quantity
        self.image = ingredient.image() ?? Image(systemName: "questionmark")
    }
    
    var body: some View {
        
        VStack {
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 42, height: 42)
//                .frame(width: 64.0, height: 64.0)
            
            Text("○ \(ingredient.rawValue)\(quantity != nil ? " x \(quantity!)":"")")
            .font(.callout)
                .foregroundColor(hasIngredient == nil ? .white:hasIngredient == true ? .green:.red)
        }
        .padding([.leading, .top], 6)
        .padding([.trailing, .bottom], 6)
    }
}

struct IngredientSufficiencyView:View {
    
    var ingredient:Ingredient
    var required:Int
    var available:Int
    
    var image:Image = Image(systemName: "questionmark")
    
    init(ingredient:Ingredient, required:Int, available:Int) {
        self.ingredient = ingredient
        self.required = required
        self.available = available
        if let img = ingredient.image() {
            self.image = img
        }
    }
    
    var body: some View {
        VStack {
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 42, height: 42)
            
            Text("○ \(ingredient.rawValue)")
                .font(.callout)
            Text("x\(required) of \(available)")
                .foregroundColor(available >= required ? .green:.red)
            
        }
    }
}

struct IngredientSmallReqView:View {
    var ingredient:Ingredient
    var required:Int
    var available:Int
    var image:Image = Image(systemName: "questionmark")
    
    init(ingredient:Ingredient, required:Int, available:Int) {
        self.ingredient = ingredient
        self.required = required
        self.available = available
        if let img = ingredient.image() {
            self.image = img
        }
    }
    var body: some View {
        HStack {
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 38, height: 38)
            
    
            Text("x\(required) of \(available)")
                .foregroundColor(available >= required ? .green:.red)
                .font(.title3)
            
        }
    }
}

struct StorageBoxDetailView:View {
    
    var box:StorageBox
    @State var alert:Bool = false
    
    var body: some View {
        let normalizedLevel:Float = Float(box.current)/Float(box.capacity)
        VStack {
            let image:Image = box.type.image() ?? Image(systemName: "questionmark")
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 52, height: 52)
                .padding(.top)
            
            Text("\(box.type.rawValue)")
            Text("\(box.current) of \(box.capacity)")
            ProgressView("", value: normalizedLevel)
                .frame(width: 150, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                .padding([.leading, .trailing])
                .foregroundColor(normalizedLevel < 0.4 ? .red:normalizedLevel > 0.75 ? .green:.orange)
            
            // Buttons
            HStack {
                Button("Throw away") {
                    print("Throw away action")
                    alert.toggle()
                }
            }
            .padding()
        }
        .alert(isPresented: $alert, content: {
            Alert(title: Text("Sure ?"), message: Text("Are you sure you want to throw this out?"), primaryButton: .cancel({
                print("Cancel")
            }), secondaryButton: .destructive(Text("Yes"), action: {
                print("Really throwing away")
            }))
        })
    }
}

struct IngredientOrderView:View {
    
    var ingredient:Ingredient
    @State var quantity:Int?
    var image:Image = Image(systemName: "questionmark")
    
    var body: some View {
        
        ZStack(alignment: Alignment(horizontal: .trailing, vertical: .top)) {
            
            VStack {
                HStack {
                    Spacer()
                    ingredient.image()?
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 42, height: 42)
                    Spacer()
                }
                
                Text("\(ingredient.rawValue) x \(ingredient.boxCapacity())")
                    
            }

            Text("$\(ingredient.price)")
                // .frame(maxWidth:40)
                .foregroundColor(.gray)
                .padding(4)
                .background(Color.black)
        }
        .padding(4)
        .background(Color.black)
        .cornerRadius(8)
        .frame(maxWidth:200)
        
    }
}


struct StorageBox_Previews: PreviewProvider {
    static var previews: some View {
        StorageBoxDetailView(box: StorageBox(ingType: .Aluminium, current: 10))
    }
}

struct IngredientView_Previews_2: PreviewProvider {
    static var previews: some View {
        HStack(alignment: .top, spacing: 20){
            VStack  {
                IngredientView(ingredient: Ingredient.Aluminium, hasIngredient: nil, quantity: 10)
                IngredientView(ingredient: Ingredient.Copper, hasIngredient: true, quantity: 8)
                IngredientView(ingredient: Ingredient.CarbonFiber, hasIngredient: nil, quantity: nil)
                IngredientView(ingredient: Ingredient.Sensor, hasIngredient: nil, quantity: nil)
                IngredientView(ingredient: Ingredient.SolarCell, hasIngredient: nil, quantity: nil)
                
            }
            VStack  {
                IngredientView(ingredient: Ingredient.Ceramic, hasIngredient: nil, quantity: nil)
                IngredientView(ingredient: Ingredient.Circuitboard, hasIngredient: nil, quantity: nil)
                IngredientView(ingredient: Ingredient.DCMotor, hasIngredient: nil, quantity: nil)
                IngredientView(ingredient: Ingredient.Food, hasIngredient: nil, quantity: nil)
                IngredientView(ingredient: Ingredient.Lithium, hasIngredient: nil, quantity: nil)
            }
            
            VStack {
                IngredientView(ingredient: Ingredient.Water, hasIngredient: nil, quantity: nil)
                IngredientView(ingredient: Ingredient.Silica, hasIngredient: nil, quantity: nil)
                IngredientView(ingredient: Ingredient.wasteSolid, hasIngredient: nil, quantity: nil)
                IngredientView(ingredient: Ingredient.Iron, hasIngredient: nil, quantity: nil)
                IngredientView(ingredient: Ingredient.Polimer, hasIngredient: nil, quantity: nil)
            }
        }
    }
}

struct IngredientSufficiency_Preview:PreviewProvider {
    static var previews: some View {
        VStack {
            IngredientSufficiencyView(ingredient: .Aluminium, required: 20, available: 30)
            IngredientSufficiencyView(ingredient: .DCMotor, required: 8, available: 4)
        }
    }
}

struct IngredientSmall_Preview:PreviewProvider {
    static var previews: some View {
        VStack {
            IngredientSmallReqView(ingredient: .Aluminium, required: 20, available: 30)
            IngredientSmallReqView(ingredient: .DCMotor, required: 8, available: 4)
        }
    }
}

struct IngredientOrder_Previews: PreviewProvider {
    
    static var previews: some View {
        LazyVGrid(columns: [GridItem(.fixed(200)), GridItem(.fixed(200)), GridItem(.fixed(200))], alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/, pinnedViews: /*@START_MENU_TOKEN@*/[]/*@END_MENU_TOKEN@*/, content: {
            
            ForEach(Ingredient.allCases.filter({$0.orderable == true }), id:\.rawValue) { ingredient in
                IngredientOrderView(ingredient: ingredient)
            }
        })
//        for ingredient in Ingredient.allCases.filter($0.orderable == true)
    }
}
