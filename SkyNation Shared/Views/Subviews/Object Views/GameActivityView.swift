//
//  GameActivityView.swift
//  SkyNation
//
//  Created by Carlos Farini on 1/6/21.
//

import SwiftUI

struct GameActivityView: View {
    
    var activity:LabActivity
    
    // Center of Circle gradients
    let gradientStart = Color("Prograd1")
    let gradientEnd = Color("Prograd2")
    
    // Fast Spinner Circle Track
    let circleTrackGradient = LinearGradient(gradient: .init(colors: [.init(white: 0.2), Color.black]), startPoint: .leading, endPoint: .trailing)
    let fastTrackBackground = LinearGradient(gradient: .init(colors: [Color.red, Color.orange]), startPoint: .leading, endPoint: .trailing)
    let fastTrackRotation: Double = .pi/12
    let fastTrackDuration: Double = 1
    
    @State var deltaTime:String = ""
    @State var percentage:CGFloat = 1.0
    
    @State var circleStart: CGFloat = 0.17
    @State var circleEnd: CGFloat = 0.2//0.325
    @State var rotationDegree: Angle = Angle.degrees(280)
    
    @State var stretched:Bool = false
    
    init(activity:LabActivity) {
        self.activity = activity
    }
    
    init(vehicle:SpaceVehicle) {
        
        switch vehicle.status {
                
            case .Creating, .Created:
                
                let activity = LabActivity(time: vehicle.engine.time, name: "Preparing")
                activity.dateStarted = vehicle.dateTravelStarts!
                activity.dateEnds = vehicle.dateTravelStarts!.addingTimeInterval(vehicle.engine.time)
                self.activity = activity
        
            case .Mars, .MarsOrbit:
                
                let activity = LabActivity(time: vehicle.engine.time, name: "Travelling")
                activity.dateStarted = vehicle.dateTravelStarts!
                activity.dateEnds = vehicle.dateTravelStarts!.addingTimeInterval(vehicle.travelTime ?? GameLogic.vehicleTravelTime)
                
                self.activity = activity
                
            default: fatalError("No Known space vehicle status can make a GameActivityView")
        }
    }
    
    var body: some View {
        VStack {
            Text("\(activity.activityName)")
                .font(.title3)
                .foregroundColor(.orange)
            
            ZStack {
                Circle()
                    .fill(LinearGradient(gradient: Gradient(colors: [gradientStart, gradientEnd]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 150, height: 150)
                    .modifier(PercentageIndicator(pct: max(0, percentage)))
                    .padding()
                // Fast Spinner Background
                Circle()
                    .stroke(style: StrokeStyle(lineWidth: 10))
                    .fill(circleTrackGradient)
                    .frame(width: 140, height: 140)
                // Fast Spinner
                Circle()
                    .trim(from: circleStart, to: circleEnd)
                    .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .fill(fastTrackBackground)
                    .frame(width: 140, height: 140)
                    .rotationEffect(self.rotationDegree)
            }
            .frame(width: 150, height: 150)
            .padding()
            
            Text(GameFormatters.dateFormatter.string(from: activity.dateStarted))
            Text(deltaTime)
            
        }
        .padding()
        .cornerRadius(8)
        .onAppear() {
            updateTime()
        }
    }
    
    func updateTime() {
        
        if Date().compare(activity.dateEnds) == .orderedAscending {
            
            let components = Calendar.current.dateComponents([.hour, .minute, .second], from: Date(), to: activity.dateEnds)
            deltaTime = "\(components.hour ?? 0)h \(components.minute ?? 0)m \(components.second ?? 0)s"
            
            let pctTotal = activity.dateEnds.timeIntervalSince(activity.dateStarted)
            let pctElapsed = Date().timeIntervalSince(activity.dateStarted)
            let newPercentage = CGFloat(pctElapsed/pctTotal)
            percentage = newPercentage
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                self.updateTime()
                withAnimation(Animation.easeInOut(duration:  self.fastTrackDuration)) {
                    self.rotationDegree += self.getRotationAngle()
                    stretched.toggle()
                    self.circleEnd = stretched ? .pi/8:.pi/12 //0.925
                }
            }
            
        } else {
            percentage = 1.0
            deltaTime = "Finished"
        }
    }
    
    func getRotationAngle() -> Angle {
        return stretched ? .degrees((360 * self.fastTrackRotation) + 15):.degrees(360 * self.fastTrackRotation)
    }
}

struct PersonActivityView: View {
    
    var activity:LabActivity
    
    // Center of Circle gradients
    let gradientStart = Color("Prograd1")
    let gradientEnd = Color("Prograd2")
    
    // Fast Spinner Circle Track
    let circleTrackGradient = LinearGradient(gradient: .init(colors: [.init(white: 0.2), Color.black]), startPoint: .leading, endPoint: .trailing)
    let fastTrackBackground = LinearGradient(gradient: .init(colors: [Color.blue, Color.green]), startPoint: .leading, endPoint: .trailing)
    let fastTrackRotation: Double = .pi/12
    let fastTrackDuration: Double = 1
    
    @State var deltaTime:String = ""
    @State var percentage:CGFloat = 1.0
    
    @State var circleStart: CGFloat = 0.17
    @State var circleEnd: CGFloat = 0.2//0.325
    @State var rotationDegree: Angle = Angle.degrees(280)
    
    @State var stretched:Bool = false
    
    init(activity:LabActivity) {
        self.activity = activity
    }
    
    var body: some View {
        VStack {
            Text("\(activity.activityName)")
                .font(.title3)
                .foregroundColor(.green)
            
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(circleTrackGradient)
                
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .fill(fastTrackBackground)
                VStack(spacing:1) {
                    Text(deltaTime).font(.title).foregroundColor(.white)
                    ProgressView(value: percentage, total: 1.0)
                        .padding(.horizontal)
                }
                
            }
            .frame(width:180, height:60)
            HStack {
                Text(GameFormatters.dateFormatter.string(from: activity.dateStarted))
                    .font(.system(size: 12, weight: .light, design: .monospaced))
                Spacer()
            }
            HStack {
                Spacer()
                Text(GameFormatters.dateFormatter.string(from: activity.dateEnds))
                    .font(.system(size: 12, weight: .light, design: .monospaced))
            }
            
            
        }
        .padding()
        .frame(width:212)
        .cornerRadius(8)
        .onAppear() {
            updateTime()
        }
    }
    
    func updateTime() {
        
        if Date().compare(activity.dateEnds) == .orderedAscending {
            
            let components = Calendar.current.dateComponents([.hour, .minute, .second], from: Date(), to: activity.dateEnds)
            deltaTime = "\(components.hour ?? 0)h \(components.minute ?? 0)m \(components.second ?? 0)s"
            
            let pctTotal = activity.dateEnds.timeIntervalSince(activity.dateStarted)
            let pctElapsed = Date().timeIntervalSince(activity.dateStarted)
            let newPercentage = CGFloat(pctElapsed/pctTotal)
            percentage = newPercentage
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                self.updateTime()
                withAnimation(Animation.easeInOut(duration:  self.fastTrackDuration)) {
                    self.rotationDegree += self.getRotationAngle()
                    stretched.toggle()
                    self.circleEnd = stretched ? .pi/8:.pi/12 //0.925
                }
            }
            
        } else {
            percentage = 1.0
            deltaTime = "Finished"
        }
    }
    
    func getRotationAngle() -> Angle {
        return stretched ? .degrees((360 * self.fastTrackRotation) + 15):.degrees(360 * self.fastTrackRotation)
    }
}

struct GameActivityView_Previews: PreviewProvider {
    
    static let activity = LabActivity(time: 45, name: "Test Activity")
    
    static var previews: some View {
        GameActivityView(activity: activity)
        PersonActivityView(activity: activity)
    }
}
