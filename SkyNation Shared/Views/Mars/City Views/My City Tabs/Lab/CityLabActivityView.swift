//
//  CityLabActivityView.swift
//  SkyNation
//
//  Created by Carlos Farini on 9/25/21.
//

import SwiftUI

enum ActivityDismissalState {
    case cancelled
    case useToken(token:GameToken)
    case finishedRecipe(recipe:Recipe)
    case finishedTech(tech:CityTech)
}

struct CityLabActivityView: View {
    
    @ObservedObject var activityModel:LabActivityViewModel
    @State var labActivity:LabActivity
    
    var dismissActivity:((ActivityDismissalState) -> ())
    
    /// Show an alert for spending tokens
    @State private var tokenSpendAlert:Bool = false
    @State private var cancelActivityAlert:Bool = false
    
    @State private var badNews:String = ""
    @State private var goodNews:String = ""
    
    var body: some View {
        
        VStack(spacing:4) {
            
            Text("🔬 Activity: \(labActivity.activityName)")
                .font(.largeTitle)
                .foregroundColor(.blue)
            Divider()
            
            Group {
                Text("Started: \(GameFormatters.dateFormatter.string(from: labActivity.dateStarted))")
                Text("Total: \(Int(activityModel.totalTime)) seconds")
                Text("⏱ Remaining: \(Int(activityModel.timeRemaining)) seconds")
                Text("Ends: \(GameFormatters.dateFormatter.string(from:labActivity.dateEnds))")
            }
            
            GameActivityView(activity: labActivity)
            Text(badNews).foregroundColor(.red)
            Text(goodNews).foregroundColor(.green)
            
            switch activityModel.activityState {
                case .running(_):
                    HStack {
                        
                        // Token
                        Button(action: {
                            print("Token")
                            self.tokenSpendAlert = true
                            
                        }, label:{
                            HStack {
#if os(macOS)
                                Image(nsImage: GameImages.tokenImage)
                                    .resizable()
                                    .aspectRatio(1.0, contentMode: .fit)
                                    .frame(width: 20, height: 20, alignment: .center)
#elseif os(iOS)
                                Image(uiImage: GameImages.tokenImage)
                                    .resizable()
                                    .aspectRatio(1.0, contentMode: .fit)
                                    .frame(width: 20, height: 20, alignment: .center)
#endif
                                Text("Token")
                            }
                        })
                            .buttonStyle(GameButtonStyle())
                            .alert(isPresented: $tokenSpendAlert) {
                                Alert(title: Text("Token"), message: Text("Spend 1 token to reduce an hour on this activity?"), primaryButton: .default(Text("Yes")) {
                                    self.spendToken()
                                }, secondaryButton: .cancel())
                            }
                        
                        // Cancel
                        Button(action: {
//                            print("Cancel activity")
                            self.cancelActivityAlert = true
                        }, label:{
                            Text("Cancel")
                        })
                            .buttonStyle(GameButtonStyle(labelColor: .red))
                            .alert(isPresented: $cancelActivityAlert) {
                                Alert(title: Text("Cancel"), message: Text("Are you sure you want to cancel this activity? You won't get the costs back."), primaryButton: .default(Text("Yes")) {
                                    self.cancelActivity()
                                }, secondaryButton: .cancel())
                            }
                    }
                    
                case .finished:
                    HStack {
                        
                        // Throw away
                        Button(action: {
                            print("Throw out")
                            //                        controller.throwAwayTech()
                            
                        }, label:{
                            Text("Throw Away")
                        })
                            .buttonStyle(NeumorphicButtonStyle(bgColor: .blue))
                        
                        // Collect
                        Button(action: {
                            
                            print("Collect activity")
                            self.collectActivity()
                            
                        }, label:{
                            Text("Collect")
                        })
                            .buttonStyle(NeumorphicButtonStyle(bgColor: .blue))
                    }
            }
//            if activityModel.timeRemaining > 0 {
//
//            }else{
//
//            }
            
        }.padding()
        
        
        
            .onAppear() {
//                self.progress = Double(activityModel.timeRemaining)/activityModel.totalTime
            }
        
            .onDisappear() {
                self.activityModel.stop()
            }
    }
    
    func stopActivity() {
        self.activityModel.stop()
        self.activityModel.timer.invalidate()
        
        self.dismissActivity(.cancelled)
    }
    
    func cancelActivity() {
        self.stopActivity()
    }
    
    func spendToken() {
        
        guard let player = LocalDatabase.shared.player else {
            badNews = "No Local Player"
            return
        }
        
        /*
        guard let cityActivity = cityData.labActivity,
            cityActivity.id == self.labActivity.id else {
            print("No activity")
            badNews = "No Activity"
            return
        }
         */
        
        if let newToken = player.requestToken() {
            
            self.dismissActivity(.useToken(token: newToken))
            
//            let result = player.spendToken(token: newToken, save: true)
//            if result == true {
//
//                // Update Activitu
//                cityActivity.dateEnds.addTimeInterval(-3600)
//                cityData.labActivity = cityActivity
//                let workers = cityData.inhabitants.filter({ $0.activity?.id == labActivity.id })
//                for person in workers {
//                    person.activity = cityActivity
//                }
//
//                // Model boost
//                self.activityModel.hourBoost()
//
//                // Save
//                do {
//                    try LocalDatabase.shared.saveCity(cityData)
//                    // Success
//                    goodNews = "Reduced one hour, for one token."
//
//                } catch {
//                    // Fail
//                    badNews = "Error: \(error.localizedDescription)"
//                }
//            } else {
//                // fail
//                badNews = "Unable to spend token for player."
//            }
        } else {
            // No Tokens
            badNews = "No Tokens left 😭"
        }
    }
    
    func collectActivity() {
        
        self.stopActivity()
        
        if let recipe = Recipe(rawValue: self.labActivity.activityName) {
            
            // Recipe
            self.dismissActivity(.finishedRecipe(recipe: recipe))
//            self.collectRecipe(recipe: recipe)
            
        } else if let tech:CityTech = CityTech(rawValue: self.labActivity.activityName) {
            
            // Tech
//            self.collectTech(tech: tech)
            self.dismissActivity(.finishedTech(tech: tech))
            
        } else {
            
            self.badNews = "Unrecognized Activity"
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3.0) {
                self.dismissActivity(.cancelled)
            }
        }
    }
    
    func collectRecipe(recipe:Recipe) {
        
        /*
        // Recipe
        print("Collecting Recipe: \(recipe.rawValue)")
        
        var madePeripheral:PeripheralObject? = nil
        
        switch recipe {
                
            case .Condensator:
                madePeripheral = PeripheralObject(peripheral: .Condensator)
                
            case .ScrubberCO2:
                madePeripheral = PeripheralObject(peripheral: .ScrubberCO2)
                
            case .Electrolizer:
                madePeripheral = PeripheralObject(peripheral: .Electrolizer)
                
            case .Methanizer:
                madePeripheral = PeripheralObject(peripheral: .Methanizer)
                
            case .Radiator:
                madePeripheral = PeripheralObject(peripheral: .Radiator)
            case .SolarPanel:
                print("Solar panel is its own beast")
                //                    madePeripheral = PeripheralObject(peripheral: .sola)
            case .Battery:
                
                let battery = Battery(shopped: false)
                // add to city
                cityData.batteries.append(battery)
                // save city
                
            case .StorageBox:
                print("Storagebox")
                // Choose Ingredient?
                
            case .tank:
                // tank
                let newTank:Tank = Tank(type: .empty, full: false)
                cityData.tanks.append(newTank)
                
            case .WaterFilter:
                madePeripheral = PeripheralObject(peripheral: .WaterFilter)
            case .BioSolidifier:
                madePeripheral = PeripheralObject(peripheral: .BioSolidifier)
            case .Cement:
                //                    madePeripheral = PeripheralObject(peripheral: .Radiator)
                let newBox = StorageBox(ingType: .Cement, current: Ingredient.Cement.boxCapacity())
                cityData.boxes.append(newBox)
                
            case .ChargedGlass:
                let glass = StorageBox(ingType: .Glass, current: Ingredient.Glass.boxCapacity())
                cityData.boxes.append(glass)
                
            case .Alloy:
                let alloy = StorageBox(ingType: .Alloy, current: Ingredient.Alloy.boxCapacity())
                cityData.boxes.append(alloy)
                
            default:
                print("Invalid activity")
        }
        
        if let peripheral = madePeripheral {
            cityData.peripherals.append(peripheral)
        }
        
        do {
            try LocalDatabase.shared.saveCity(cityData)
            // Success
            self.goodNews = "Recipe \(recipe.rawValue) collected"
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0) {
                self.dismissActivity()
            }
        } catch {
            // Deal with error
            self.badNews = "Error: \(error.localizedDescription)"
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3.0) {
                self.dismissActivity()
            }
        }
         */
        
    }
}

struct CityLabActivityView_Previews: PreviewProvider {
    
    static var previews: some View {
        let model = LabActivityViewModel(labActivity: makeActivity())
        CityLabActivityView(activityModel: model, labActivity: model.activity) { dismState in
            print("Dismissed ????")
        }
        .frame(width: 500, height: 600, alignment: .center)
    }
    
    static func getCityData() -> CityData {
        return LocalDatabase.shared.loadCity()!
    }
    
    static func makeActivity() -> LabActivity {
        let test = LabActivity(time: 300, name: "Test Act")
        return test
    }
}
