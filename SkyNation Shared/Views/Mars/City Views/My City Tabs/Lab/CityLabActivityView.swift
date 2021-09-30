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

enum ActivityState {
    case running(remaining:Int)
    case finished
}

struct CityLabActivityView: View {
    
    var labActivity:LabActivity
    
    // activity, cancel:Bool
    var action:((LabActivity, Bool) -> ())
    
    init(activity:LabActivity, callBack:@escaping ((LabActivity, Bool) -> ())) {
        self.labActivity = activity
        self.action = callBack
    }
    
    // Timer
    @State private var activityState:ActivityState = .finished
    @State private var shouldRun:Bool = true
    
    @State private var timeRemaining:Double = 0
    @State private var totalTime:Double = 0
    
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
                Text("Date Now: \(GameFormatters.fullDateFormatter.string(from: Date()))")
                Text("Started: \(GameFormatters.fullDateFormatter.string(from: labActivity.dateStarted))")
                Text("Total: \(Int(totalTime)) seconds")
                Text("⏱ \(timeRemaining.stringFromTimeInterval())")
                Text("Of \(totalTime.stringFromTimeInterval())")
                
//                Text("⏱ Remaining: \(Int(activityModel.timeRemaining)) seconds")
                Text("Ends: \(GameFormatters.fullDateFormatter.string(from:labActivity.dateEnds))")
                Text("Ends II \(DateFormatter.localizedString(from: labActivity.dateStarted, dateStyle: .medium, timeStyle: .medium))")
                Text("Ends III \(labActivity.dateEnds.debugDescription)")
            }
            
            GameActivityView(activity: labActivity)
            Text(badNews).foregroundColor(.red)
            Text(goodNews).foregroundColor(.green)
            
            switch activityState {
                case .finished:
                    HStack {
                        
                        // Throw away
                        Button(action: {
                            print("Throw out")
                            //                        controller.throwAwayTech()
                            // Pass true to cancel
                            self.action(labActivity, true)
                        }, label:{
                            Text("Throw Away")
                        })
                            .buttonStyle(NeumorphicButtonStyle(bgColor: .blue))
                        
                        // Collect
                        Button(action: {
                            
                            print("Collect activity")
                            // self.collectActivity()
//                            if let recipe = Recipe(rawValue: labActivity.activityName) {
//                                self.dismissActivity(.finishedRecipe(recipe: recipe))
//                            }else if let tech = CityTech(rawValue: labActivity.activityName) {
//                                self.dismissActivity(.finishedTech(tech: tech))
//                            }
                            self.shouldRun = false
                            self.action(labActivity, false)
                            
                        }, label:{
                            Text("Collect")
                        })
                            .buttonStyle(NeumorphicButtonStyle(bgColor: .blue))
                    }
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
//                                    self.spendToken()
                                    print("Spend token")
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
            }
            
        }.padding()
        
            .onAppear() {
                if Date().compare(self.labActivity.dateEnds) == .orderedAscending {
                    self.incrementCounter()
                } else {
                    self.activityState = .finished
                }
            }
        
            .onDisappear() {
//                self.stop()
            }
    }
    
    func stopActivity() {
//        self.activityModel.stop()
//        self.activityModel.timer.invalidate()
//        self.stop()
        
//        self.dismissActivity(.cancelled)
    }
    
    func cancelActivity() {
//        self.stopActivity()
        self.shouldRun = false
        self.action(labActivity, true)
    }
    
    /*
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
    
    
    */
    
    func incrementCounter() {
        
        let tr = labActivity.dateEnds.timeIntervalSince(Date())
        self.timeRemaining = tr
        
        let total = labActivity.dateEnds.timeIntervalSince(labActivity.dateStarted)
        self.totalTime = total
        
        if tr > total {
            print("Something wrong. Time is wrong.")
            self.activityState = .finished
            return
        }
        
        if tr <= 0 {
            self.activityState = .finished
            return
        } else {
            self.activityState = .running(remaining: Int(tr))
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                if shouldRun {
                    incrementCounter()
                }
            }
        }
    }
    
}

struct CityLabActivityView_Previews: PreviewProvider {
    
    static var previews: some View {
        CityLabActivityView(activity: makeActivity()) { action, cancelled in
            print("action")
        }
        .frame(width: 500, height: 600, alignment: .center)
    }
    
    static func getCityData() -> CityData {
        return LocalDatabase.shared.cityData!
    }
    
    static func makeActivity() -> LabActivity {
        if let cityActivity = LocalDatabase.shared.cityData!.labActivity {
            return cityActivity
        }
        let test = LabActivity(time: 300, name: "Test Act")
        return test
    }
}
