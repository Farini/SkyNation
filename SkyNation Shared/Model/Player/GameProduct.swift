//
//  GameProduct.swift
//  SkyNation
//
//  Created by Carlos Farini on 8/7/21.
//

import Foundation


/// The 3 types of Product
enum GameProductType:Int, Codable, CaseIterable {
    
    /// A Five dollar product
    case five = 5
    
    /// Ten dollar product
    case ten = 10
    
    /// Twenty dollar product
    case twenty = 20
    
    /// Amount of Tokens that comes with this Product
    var tokenAmount:Int {
        return 3 * self.rawValue
    }
    
    /// Amount of Kits that comes with this Product
    var kitAmount:Int {
        return 2 * self.rawValue
    }
    
    var moneyAmount:Int {
        return self.rawValue * 8500
    }
    
    var displayName:String {
        switch self {
            case .five: return "Push Package"
            case .ten: return "Big Package"
            case .twenty: return "Huge Deal"
        }
    }
    
    var fakePrice:Double {
        switch self {
            case .five: return 5.0
            case .ten: return 10.0
            case .twenty: return 20.0
        }
    }
    
    var storeIdentifier:String {
        switch self {
            case .five: return "com.skynation.five"
            case .ten: return "com.skynation.ten"
            case .twenty: return "com.skynation.twenty"
        }
    }
}

import StoreKit

struct GameProduct:Identifiable, Hashable {
    
    var id:String // The product identifier
    var type:GameProductType
    
    var price:Double
    var priceString:String
    
    var displayName:String {
        return type.displayName
    }
    
    var storeProduct:SKProduct
    
    init(type:GameProductType, storeProduct:SKProduct) {
        self.id = storeProduct.productIdentifier
        self.type = type
        self.price = Double(truncating: storeProduct.price)
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = storeProduct.priceLocale
        
        self.priceString = formatter.string(from: storeProduct.price) ?? "unknown"
        
        self.storeProduct = storeProduct
    }
}


extension SKProduct {
    /// - returns: The cost of the product formatted in the local currency.
    var regularPrice: String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = self.priceLocale
        return formatter.string(from: self.price)
    }
}
