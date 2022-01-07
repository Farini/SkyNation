//
//  GuildView.swift
//  SkyNation
//
//  Created by Carlos Farini on 2/28/21.
//

import SwiftUI

/// A Small View, representing a Guild
struct GuildSummaryView: View {
    
    var guildSum:GuildSummary
    
    let shape = RoundedRectangle(cornerRadius: 16, style: .continuous)
    
    var body: some View {
        VStack {
            Image(systemName: GuildIcon(rawValue: guildSum.icon)!.imageName)
                .font(.largeTitle)
                .foregroundColor(GuildColor(rawValue: guildSum.color)!.color)
                .padding(.bottom, 4)
            
            Text("\(guildSum.name)")
                .font(.title2)
                .foregroundColor(.yellow)
            
            Divider()
            
            Text("👤 \(guildSum.citizens.count)").padding(2)
            Text("🌆 \(guildSum.cities.count)").padding(2)
            Text("⚙️ \(guildSum.outposts.count)").padding(2)
            // Text("📆 \(GameFormatters.dateFormatter.string(from: guild.election))")
        }
        .frame(minWidth: 100, maxWidth: 120, minHeight: 120, maxHeight: 180, alignment: .center)
        .padding(.top, 8)
        .background(GameColors.transBlack)
        .cornerRadius(16)
        .overlay(
            shape
                .inset(by: 0.5)
                .stroke(Color.white.opacity(0.5), lineWidth: 2)
        )
        .contentShape(shape)
    }
}

struct EmptyGuildView: View {
    
    let shape = RoundedRectangle(cornerRadius: 16, style: .continuous)
    
    var body: some View {
        
        VStack {
            
            // Header (Icon + Name)
            VStack {
                Image(systemName: "questionmark")
                    .font(.largeTitle)
                    .foregroundColor(Color.gray)
                    .padding(4)
                
                Text("[ No Guild ]")
                    .font(.title2)
                    .foregroundColor(.gray)
                
                Divider()
            }
            .frame(minWidth: 100, maxWidth: 120, minHeight: 72, maxHeight: 82, alignment: .center)
            .padding(.top, 8)
            
                      // Page
             VStack {
                VStack {
                        Text("Citizens").font(.title2).foregroundColor(.gray)
                            .foregroundColor(Color.yellow)
                            .font(.title3)
                            .padding(.bottom, 4)
                        Text("Outposts").font(.title2).foregroundColor(.gray)
                            .foregroundColor(Color.white)
                            .font(.title3)
                            .padding(.bottom, 4)
                        Text("Cities").font(.title2).foregroundColor(.gray)
                            .foregroundColor(Color.yellow)
                            .font(.title3)
                            .padding(.bottom, 4)
                }
                .frame(minWidth: 170, maxWidth: 200)
                    
                 VStack {
                     Text("∅").font(.title)
                     Text("Select a Guild to join")
                     Text("Or Create a new one")
                 }
                 .font(.system(size: 12, weight: .bold, design: .monospaced))
                 .foregroundColor(.blue)
                
                
                Spacer()
                Divider()
                    
                 Text("No Guild selected.").foregroundColor(.gray)
                     .padding(6)
            }
            .frame(width: 220, height:250, alignment: .center)
            .clipShape(shape)
            .accessibilityElement(children: .contain)
        }
        .background(GameColors.transBlack)
        .cornerRadius(16)
        .overlay(
            shape
                .inset(by: 0.5)
                .stroke(Color.white.opacity(0.5), lineWidth: 2)
        )
        .contentShape(shape)
        
        
    }
}

struct GuildView: View {
    
    @ObservedObject var controller:GameSettingsController
    
    var guildFull:GuildFullContent
    var guildSum:GuildSummary
    
    /// Presentation Style
    var style: GuildView.Style
    enum Style {
        case largeSummary
        case largeDescriptive
    }
    var shape = RoundedRectangle(cornerRadius: 16, style: .continuous)
    
    private enum FaceSide {
        case citizens, cities, outposts, preferences
    }
    @State private var face:FaceSide = .citizens
    
    var closeAction: () -> Void = {}
    var flipAction: () -> Void = {}
    
    init(controller:GameSettingsController, guild:GuildFullContent, style:GuildView.Style) {
        self.controller = controller
        self.guildFull = guild
        self.guildSum = guild.makeSummary()
        self.style = style
    }
    
    var body: some View {
        
        VStack {
            
            // Header (Icon + Name)
            VStack {
                Image(systemName: GuildIcon(rawValue: guildSum.icon)!.imageName)
                    .font(.largeTitle)
                    .foregroundColor(GuildColor(rawValue: guildSum.color)!.color)
                    .padding(.bottom, 4)
                
                Text("\(guildSum.name)")
                    .font(.title2)
                    .foregroundColor(.yellow)
                
                Divider()
            }
            .frame(minWidth: 100, maxWidth: 120, minHeight: 72, maxHeight: 82, alignment: .center)
            .padding(.top, 8)
            
            // Page
            VStack {
                
                switch face {
                    case .citizens:
                        
                        ScrollView {
                            VStack {
                                Text("Citizens: \(guildSum.citizens.count)").font(.title2).foregroundColor(.green)
                                    .foregroundColor(style == .largeDescriptive ? Color.white:Color.yellow)
                                    .font(style == .largeSummary ? .title3:.body)
                                    .padding(.bottom, 4)
                                
                                ForEach(guildFull.citizens, id:\.self) { citizen in
                                    SmallPlayerCardView(pCard: citizen.makePlayerCard())
                                }
                            }
                            .frame(minWidth: 170, maxWidth: 200)
                        }
                        
                    case .cities:
                        
                        Text("Cities: \(guildSum.cities.count)")
                        
                        ForEach(guildFull.cities, id:\.self) { city in
                            Text("\(city.name)") //\(String(city.id.uuidString.prefix(6)))")
                        }
                        
                        if guildSum.cities.isEmpty == true {
                            Text("< No Cities >").foregroundColor(.gray)
                        }
                        
                    case .outposts:
                        
                        Text("Outposts").font(.title2).foregroundColor(.blue)
                        VStack {
                            ForEach(guildFull.outposts, id:\.id) { outpost in
                                Text("\(outpost.type.rawValue) \(outpost.level)")
                            }
                            Text("Total level: \(guildFull.outposts.compactMap({ $0.level }).reduce(0, +))").foregroundColor(.orange)
                        }
                        
                    case .preferences:
                        
                        Text("Preferences").font(.title2).foregroundColor(.orange)
                        Image(systemName: guildSum.isOpen ? "lock.open":"lock")
                        Text("Openness: \(guildSum.isOpen ? "Yes":"No")")
                        
                        Text("📆 \(GameFormatters.dateFormatter.string(from: guildFull.election))")
                }
                
                Spacer()
                
                Divider()
                
                HStack {
                    /*
                    if controller.guildJoinState.joinButton {
                        Button("Join") {
//                            controller.requestJoin(self.guildFull)
                        }
                        .buttonStyle(NeumorphicButtonStyle(bgColor:.blue))
                    } else if controller.guildJoinState.leaveButton {
                        Button("Leave") {
                            
                        }
                        .buttonStyle(NeumorphicButtonStyle(bgColor:.blue))
                    }
                    */
                    
                    Button("Flip") {
                        self.flipToNext()
                    }
                    .buttonStyle(NeumorphicButtonStyle(bgColor: .green))
                }
                .frame(height:32)
                .padding(.bottom, 8)
                
                
            }
            .frame(width: 220, height:300, alignment: .center)
            .clipShape(shape)
            
            .accessibilityElement(children: .contain)
        }
        .background(GameColors.transBlack)
        .cornerRadius(16)
        .overlay(
            shape
                .inset(by: 0.5)
                .stroke(Color.white.opacity(0.5), lineWidth: 2)
        )
        .contentShape(shape)
        
        
    }
    
    var backScene: some View {
        GeometryReader { geo in
            generateBarcode(from: guildSum.id)!
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: geo.size.width, height: geo.size.height)
//                .scaleEffect(displayingAsCard ? 1.0 : 0.5)
//                .offset(x: displayingAsCard ? 1.0 : 0.5)
                .frame(width: geo.size.width, height: geo.size.height)
                .scaleEffect(x: style == .largeDescriptive ? -1 : 1)
        }
        .accessibility(hidden: true)
    }
    
    func flipToNext() {
        switch face {
            case .citizens:
                self.face = .cities
            case .cities:
                self.face = .outposts
            case .outposts:
                self.face = .preferences
            case .preferences:
                self.face = .citizens
        }
    }
    
    func generateBarcode(from uuid: UUID) -> Image? {
        let data = uuid.uuidString.prefix(8).data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            
            if let output:CIImage = filter.outputImage {
                
                if let inverter = CIFilter(name:"CIColorInvert") {
                    
                    inverter.setValue(output, forKey:"inputImage")
                    
                    if let invertedOutput = inverter.outputImage {
                        #if os(macOS)
                        let rep = NSCIImageRep(ciImage: invertedOutput)
                        let nsImage = NSImage(size: rep.size)
                        nsImage.addRepresentation(rep)
                        return Image(nsImage:nsImage)
                        #else
                        let uiImage = UIImage(ciImage: invertedOutput)
                        return Image(uiImage: uiImage)
                        #endif
                    }
                    
                } else {
                    #if os(macOS)
                    let rep = NSCIImageRep(ciImage: output)
                    let nsImage = NSImage(size: rep.size)
                    nsImage.addRepresentation(rep)
                    return Image(nsImage:nsImage)
                    #else
                    let uiimage = UIImage(ciImage: output)
                    return Image(uiImage: uiimage)
                    #endif
                }
            }
        }
        
        return nil
    }
}

struct GuildView_Previews: PreviewProvider {
    
    static let rGuild = GuildFullContent(data: true)
    
    static var previews: some View {
        Group {
            let controller = GameSettingsController()
            
            GuildSummaryView(guildSum: rGuild.makeSummary())
            
            GuildView(controller: controller, guild: rGuild, style: .largeDescriptive)
                .aspectRatio(0.75, contentMode: .fit)
                .frame(width: 500, height: 400)
                .previewDisplayName("Large Descriptive")
            
            EmptyGuildView()
            
//            GuildView(guild: rGuild, style: .largeSummary)
//                .aspectRatio(0.75, contentMode: .fit)
//                .frame(width: 500, height: 400)
//                .previewDisplayName("Large Summary")
        }
        .previewLayout(.sizeThatFits)
    }
}
