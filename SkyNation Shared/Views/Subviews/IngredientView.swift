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


struct IngredientView_Previews2: PreviewProvider {
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
                IngredientView(ingredient: Ingredient.Silicate, hasIngredient: nil, quantity: nil)
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
