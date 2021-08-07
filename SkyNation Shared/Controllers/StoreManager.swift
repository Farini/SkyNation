//
//  StoreManager.swift
//  SkyNation
//
//  Created by Carlos Farini on 8/6/21.
//

import Foundation
import StoreKit


protocol StoreManagerDelegate: AnyObject {
    
    /// Provides the delegate with the error encountered during the product request.
    func storeOperatorDidReceiveMessage(_ message: String)
    
    // new
    
    func storeOperatorDidReceiveProducts(_ products:[SKProduct])
    func handlePurchased(_ transaction:SKPaymentTransaction)
    func handleFailed(_ transaction: SKPaymentTransaction)
    func handleRestored(_ transaction: SKPaymentTransaction)
}

enum ShoppingStep {
    
    case product
    case kit(product:GameProduct)
    case buying(product:GameProduct)
    
    case receipt
    case error(message:String)
    
    var displayName:String {
        switch self {
            case .product: return "Product"
            case .kit(product: _): return "Kit"
            case .buying(product: _): return "Buying Product"
                
            case .receipt: return "Receipt"
            case .error(message: _): return "Error"
        }
    }
}

class StoreController: ObservableObject, StoreManagerDelegate {
    
    
    /// Keeps track of all valid products. These products are available for sale in the App Store.
    @Published var appStoreProducts:[SKProduct] = []
    @Published var gameProducts:[GameProduct] = []
    
    // Selection
    @Published var selectedProduct:GameProduct?
    @Published var selectedKit:Purchase.Kit = Purchase.Kit.SurvivalKit
    @Published var step:ShoppingStep = .product
    
    @Published var errorMessage:String = ""
    @Published var alertMessage:String?
    
    var isAuthorizedForPayments: Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    /// Keeps track of all invalid product identifiers.
    @Published var invalidProductIdentifiers = [String]()
    
    /// Product Identifiers array
    @Published var productIdentifiers:[String] = GameProductType.allCases.map({ $0.storeIdentifier })
    
    /// Keeps a strong reference to the product request
    var productRequest: SKProductsRequest!
    
    /// Keeps track of all purchases.
    var purchased = [SKPaymentTransaction]()
    
    /// Keeps track of all restored purchases.
    var restored = [SKPaymentTransaction]()
    
    /// Indicates whether there are restorable purchases.
    @Published var hasRestorablePurchases = false
    
    private var storeOperator:StoreOperator?
    
    // MARK: - Methods
    
    init() {
        self.storeOperator = StoreOperator(delegate: self)
//        self.productRequest = SKProductsRequest
        self.fetchProducts(matchingIdentifiers: productIdentifiers)
    }
    
    /// Fetches information about your products from the App Store.
    /// - Tag: FetchProductInformation
    fileprivate func fetchProducts(matchingIdentifiers identifiers: [String]) {
        
        // Create a set for the product identifiers.
        let productIdentifiers = Set(identifiers)
        
        // Initialize the product request with the above identifiers.
        if nil == productRequest {
            productRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        }
        
        // Check Store Operator
        if storeOperator == nil {
            self.storeOperator = StoreOperator(delegate: self)
        }
        productRequest.delegate = storeOperator
        
        // Send the request to the App Store.
        productRequest.start()
    }
    
    // MARK: - Helper Methods
    
    /// - returns: Existing product's title associated with the specified payment transaction.
    func title(matchingPaymentTransaction transaction: SKPaymentTransaction) -> String {
        let title:String = self.gameProducts.first(where: { $0.id == transaction.payment.productIdentifier })?.displayName ?? transaction.payment.productIdentifier
        return title
    }
    
    // MARK: - Purchasing
    
    /// Create and add a payment request to the payment queue.
    private func buyGameProduct(_ product:GameProduct) {
        let payment = SKMutablePayment(product: product.storeProduct)
        SKPaymentQueue.default().add(payment)
    }
    
    /// Called when user chooses which product to buy
    func didSelectProduct(_ product:GameProduct) {
        self.selectedProduct = product
        self.step = .kit(product: product)
    }
    
    func didSelectKit(_ kit:Purchase.Kit) {
        
        guard let product:GameProduct = selectedProduct else {
            alertMessage = "No Selected Product to buy"
            return
        }
        
        self.selectedKit = kit
        self.step = .buying(product: product)
        
    }
    
    /// User clicked "Buy"
    func confirmPurchase() {
        
        guard let product:GameProduct = selectedProduct else {
            alertMessage = "No Selected Product to buy"
            return
        }
        
        self.buyGameProduct(product)
    }
    
    func cancelPurchase() {
        self.step = .product
    }
    
    /// Restores all previously completed purchases.
    func restore() {
        if !restored.isEmpty {
            restored.removeAll()
        }
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    // MARK: - Store Manager Delegate
    
    /// Error Messages
    func storeOperatorDidReceiveMessage(_ message: String) {
        self.errorMessage = message
    }
    
    /// Products Available
    func storeOperatorDidReceiveProducts(_ products: [SKProduct]) {
        
        let allProducts:[GameProductType] = GameProductType.allCases
        
        var gameProducts:[GameProduct] = []
        var removedProducts:[String] = []
        
        // Check that array productIdentifiers contains every store product
        for product in products {
            
            if let pType:GameProductType = allProducts.first(where: { $0.storeIdentifier == product.productIdentifier }) {
                let gProduct = GameProduct(type: pType, storeProduct: product)
                gameProducts.append(gProduct)
            }
            
            // Check new (unimplemented) products
            if !productIdentifiers.contains(product.productIdentifier) {
                print("⚠️ Product Identifiers does NOT contain product. Is this a new product?")
            }
        }
        
        let storeIds = products.map({ $0.productIdentifier })
        for pid in productIdentifiers {
            if !storeIds.contains(pid) {
                print("⚠️ Object GameProductType does NOT contain store product. Was it removed from the App Store ?")
                removedProducts.append(pid)
            }
        }
        
        DispatchQueue.main.async {
            self.invalidProductIdentifiers = removedProducts
            
            if gameProducts.isEmpty {
                self.errorMessage = "No game products were found."
            }
            
            // Update published variables.
            self.appStoreProducts = products
            self.gameProducts = gameProducts
        }
        
    }
    
    /// Handles successful purchase transactions.
    func handlePurchased(_ transaction: SKPaymentTransaction) {
        
        guard let player = LocalDatabase.shared.player else { fatalError() }
        
        if let gProduct:GameProduct = gameProducts.first(where: { $0.id == transaction.payment.productIdentifier }) {
            
            // Tokens
            let tokenAmount = gProduct.type.tokenAmount
            let moneyAmount = gProduct.type.moneyAmount
            
            print("Player about to get \(tokenAmount) tokens, and \(moneyAmount) SkyCoins")
            
            // Purchase
            let purch = Purchase(product: gProduct.type, kit: self.selectedKit, receipt: transaction.payment.productIdentifier)
            
            // Add the tokens
            let tokens = purch.getTokens()
            player.wallet.tokens.append(contentsOf: tokens)
            
            // FIXME: - add 'invite' token
            // Invite tokens
            
            // Add the money
            let money = player.money + moneyAmount
            player.money = money
            
            // Save Player
            let result = LocalDatabase.shared.savePlayer(player: player)
            print("Saving player: \(result)")
            
            // Kit
            // Add items from Kit
            print("Adding items from Kit")
            if let station = LocalDatabase.shared.station {
                for (tank, value) in selectedKit.tanks {
                    guard value > 0 else { break }
                    for _ in 1...value {
                        let newTank = Tank(type: tank, full: true)
                        station.truss.tanks.append(newTank)
                    }
                }
                for (ing, value) in selectedKit.boxes {
                    guard value > 0 else { break }
                    for _ in 1...value {
                        if ing == .Battery {
                            station.truss.batteries.append(Battery(shopped: true))
                        } else if ing == .Food {
                            let foods = DNAOption.allCases.filter({ $0.isAnimal == false && $0.isMedication == false })
                            station.food.append(foods.randomElement()!.rawValue)
                        } else if ing == .wasteLiquid || ing == .wasteSolid {
                            let box = StorageBox(ingType: ing, current: 0)
                            station.truss.extraBoxes.append(box)
                        } else {
                            let box = StorageBox(ingType: ing, current: ing.boxCapacity())
                            station.truss.extraBoxes.append(box)
                        }
                    }
                }
                
                LocalDatabase.shared.saveStation(station: station)
            }
            
        }
        
        purchased.append(transaction)
        
        // Finish the successful transaction.
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    /// Handles failed purchase transactions.
    func handleFailed(_ transaction: SKPaymentTransaction) {
        //        var message = "\(Messages.purchaseOf) \(transaction.payment.productIdentifier) \(Messages.failed)"
        
        if let error = transaction.error {
            //            message += "\n\(Messages.error) \(error.localizedDescription)"
            print("Failed Transaction: \(error.localizedDescription)")
        }
        
        // Do not send any notifications when the user cancels the purchase.
        if (transaction.error as? SKError)?.code != .paymentCancelled {
            //            DispatchQueue.main.async {
            //                self.delegate?.storeObserverDidReceiveMessage(message)
            //            }
        }
        // Finish the failed transaction.
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    /// Handles restored purchase transactions.
    func handleRestored(_ transaction: SKPaymentTransaction) {
        hasRestorablePurchases = true
        restored.append(transaction)
        print("Handle restored: \(transaction.payment.productIdentifier).")
        
        //        DispatchQueue.main.async {
        //            self.delegate?.storeObserverRestoreDidSucceed()
        //        }
        
        // Finishes the restored transaction.
        //        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
}

//SKProductsRequestDelegate, SKRequestDelegate, StoreManagerDelegate {
class StoreOperator: NSObject {
    
    var delegate:StoreManagerDelegate
    
    init(delegate:StoreManagerDelegate) {
        self.delegate = delegate
    }
    
    // Actions:
    // Fetch Products
    
    // Buy
    // Restore
    
}

// MARK: - SKRequestDelegate

extension StoreOperator: SKRequestDelegate {
    
    /// Called when the product request failed.
    func request(_ request: SKRequest, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.delegate.storeOperatorDidReceiveMessage(error.localizedDescription)
        }
    }
}


extension StoreOperator: SKProductsRequestDelegate {
    
    /// Used to get the App Store's response to your request and notify your observer.
    /// - Tag: ProductRequest
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        // products contains products whose identifiers have been recognized by the App Store. As such, they can be purchased.
        if !response.products.isEmpty {
//            availableProducts = response.products
            delegate.storeOperatorDidReceiveProducts(response.products)
        }
        
        // invalidProductIdentifiers contains all product identifiers not recognized by the App Store.
        if !response.invalidProductIdentifiers.isEmpty {
//            invalidProductIdentifiers = response.invalidProductIdentifiers
        }
        
        //        if !availableProducts.isEmpty {
        //            storeResponse.append(Section(type: .availableProducts, elements: availableProducts))
        //        }
        
        //        if !invalidProductIdentifiers.isEmpty {
        //            storeResponse.append(Section(type: .invalidProductIdentifiers, elements: invalidProductIdentifiers))
        //        }
        
        //        if !storeResponse.isEmpty {
        //            DispatchQueue.main.async {
        //                self.delegate?.storeManagerDidReceiveResponse(self.storeResponse)
        //            }
        //        }
    }
}

/// Extends StoreObserver to conform to SKPaymentTransactionObserver.
extension StoreOperator: SKPaymentTransactionObserver {
    
    /// Called when there are transactions in the payment queue.
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
                case .purchasing: break
                // Do not block the UI. Allow the user to continue using the app.
                case .deferred: print("Deferred")
                // The purchase was successful.
                case .purchased: delegate.handlePurchased(transaction)
                // The transaction failed.
                case .failed: delegate.handleFailed(transaction)
                // There're restored products.
                case .restored: delegate.handleRestored(transaction)
                @unknown default: fatalError("Unknown payment transaction")
            }
        }
    }
    
    /// Logs all transactions that have been removed from the payment queue.
    func paymentQueue(_ queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            print("\(transaction.payment.productIdentifier) - Removed from payment queue")
        }
    }
    
    /// Called when an error occur while restoring purchases. Notify the user about the error.
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        if let error = error as? SKError, error.code != .paymentCancelled {
            print("Error restoring transaction: \(error.localizedDescription)")
            //            DispatchQueue.main.async {
            //                self.delegate?.storeObserverDidReceiveMessage(error.localizedDescription)
            //            }
        }
    }
    
    /// Called when all restorable transactions have been processed by the payment queue.
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        print("All restorable transactions have been processed by the payment queue.")
        
//        if !hasRestorablePurchases {
//            DispatchQueue.main.async {
//                print("There are no restorable purchases.")
//                //                self.delegate?.storeObserverDidReceiveMessage(Messages.noRestorablePurchases)
//            }
//        }
    }
}
