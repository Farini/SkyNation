//
//  GuildMakerForm.swift
//  SkyNation
//
//  Created by Carlos Farini on 12/24/21.
//

import SwiftUI

struct GuildMakerForm: View {
    
    enum GuildMakingSteps:Int, CaseIterable {
        case naming = 1
        case coloring
        case logo
        case openClose
        
        var stepDescription:String {
            switch self {
                case .naming: return "Name"
                case .coloring: return "Color"
                case .logo: return "Logo / Badge"
                case .openClose: return "Locked"
            }
        }
    }
    
    var action:((GuildCreate?) -> ())
    
    @State var currentStep:GuildMakingSteps = .naming
    @State private var isConfirming:Bool = false
    
    @State private var name:String = ""
    @State private var color:GuildColor = .red
    @State private var icon:GuildIcon = GuildIcon.allCases.randomElement()!
    @State private var isOpen:Bool = true
    
    private let shape = RoundedRectangle(cornerRadius: 8, style: .continuous)
    /// Max characters allowed in Guild name
    private let maxChar:Int = 12
    private let charRange = 3...12
    
    var body: some View {
        VStack {
            Text("Guild Maker").font(GameFont.title.makeFont())
            let curry = isConfirming ? currentStep.rawValue + 1:currentStep.rawValue
            StepperView(stepCounts: GuildMakingSteps.allCases.count, current: curry, stepDescription: isConfirming ? "Confirm":currentStep.stepDescription)
            
            if isConfirming == false {
                switch currentStep {
                    case .naming:
                        
                        Text("Guild Name").font(GameFont.section.makeFont())
                        TextField("Name", text: $name).frame(width:150)
                        Text("* name must be between 3 and 12 characters").foregroundColor(.gray).font(.footnote)
                        Text("\(name.count) of \(maxChar)")
                            .foregroundColor(charRange.contains(name.count) ? Color.gray:Color.red)
                        
                        
                        Button("Next") {
                            
                            if name.count > maxChar {
                                let newName = String(name.prefix(maxChar))
                                self.name = newName
                            }
                            
                            self.currentStep = .coloring
                        }
                        .buttonStyle(GameButtonStyle())
                        .padding(.top)
                        
                    case .coloring:
                        //                    Text("Pick color")
                        //                    Group {
                        Text("Select Guild Color").font(.title2).foregroundColor(.orange)
                        LazyHGrid(rows: [GridItem(.fixed(64), spacing: 8, alignment: .center)], alignment: .top, spacing: 8, pinnedViews: []) {
                            ForEach(GuildColor.allCases, id:\.self) { guildColor in
                                Rectangle()
                                    .fill(guildColor.color)
                                    .frame(width: 32, height: 32, alignment: .center)
                                    .cornerRadius(12)
                                    .background(Color.black)
                                    .overlay(
                                        shape
                                            .inset(by: 0.5)
                                            .stroke(color == guildColor ? Color.orange.opacity(0.9):Color.clear, lineWidth: 3)
                                    )
                                    .onTapGesture {
                                        self.color = guildColor
                                    }
                            }
                        }
                        //                    }
                        
                        Button("Next") {
                            self.currentStep = .logo
                        }
                        .buttonStyle(GameButtonStyle())
                    case .logo:
                        //                    Text("Pick logo")
                        // Icon
                        //                    Group {
                        Text("Select Guild Badge").font(.title2).foregroundColor(.orange)
                        LazyHGrid(rows: [GridItem(.fixed(64), spacing: 8, alignment: .center)], alignment: .top, spacing: 8, pinnedViews: []) {
                            ForEach(GuildIcon.allCases, id:\.self) { guildIcon in
                                Image(systemName: guildIcon.imageName)
                                    .font(.title)
                                    .padding(6)
                                    .cornerRadius(8)
                                    .background(Color.black)
                                    .overlay(
                                        shape
                                            .inset(by: 0.5)
                                            .stroke(icon == guildIcon ? Color.blue.opacity(0.9):Color.clear, lineWidth: 1)
                                    )
                                    .onTapGesture {
                                        self.icon = guildIcon
                                    }
                            }
                        }
                        Divider()
                        //                    }
                        Button("Next") {
                            self.currentStep = .openClose
                        }
                        .buttonStyle(GameButtonStyle())
                    case .openClose:
                        Text("Pick lock")
                        HStack(spacing:8) {
                            Image(systemName: "lock").font(.largeTitle).foregroundColor(isOpen ? .white:GameColors.darkGray)
                            Text("vs")
                            Image(systemName:"lock.slash").font(.largeTitle).foregroundColor(isOpen ? GameColors.darkGray:.white)
                        }
                        Toggle("Locked", isOn: $isOpen)
                        Text("Anyone can join an unlocked guild.\n A locked Guild only accepts new members that have an invite.").foregroundColor(.gray)
                        Button("Next") {
                            self.isConfirming = true
                        }
                        .buttonStyle(GameButtonStyle())
                }
            } else {
                
                // Layout Guild Row View
                GuildRow(guild: GuildSummary(id: UUID(), name: name, isOpen: isOpen, citizens: [], cities: [], outposts: [], icon: icon.rawValue, color: color.rawValue), selected: false)
                    .background(Color.black.opacity(0.25))
                    .frame(width:200)
                
                // add button
                Divider()
                
                HStack {
                    Button("Confirm") {
                        let gCreate = GuildCreate(name: name, icon: icon, color: color, president: LocalDatabase.shared.player.serverID ?? UUID(), isOpen: isOpen, invites: [])
                        self.action(gCreate)
                    }
                    .buttonStyle(GameButtonStyle())
                    
                    Button("Cancel") {
                        self.action(nil)
                    }
                    .buttonStyle(GameButtonStyle())
                }
                
            }
            
            Spacer()
            
        }
    }
    
    func validateForm() -> Bool {
        
        // Check if name is between 3 nd 12 chars
        guard charRange.contains(name.count) else {
            return false
        }
        
        return true
    }
    
    
}

struct GuildMakerForm_Previews: PreviewProvider {
    static var previews: some View {
        GuildMakerForm() { create in
            
        }
    }
}
