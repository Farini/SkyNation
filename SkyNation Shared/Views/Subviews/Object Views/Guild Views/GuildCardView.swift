//
//  GuildCardView.swift
//  SkyNation
//
//  Created by Carlos Farini on 12/15/21.
//

import SwiftUI

struct GuildCardView: View {
    
    var guildSum:GuildSummary
    var guildMap:GuildMap
    
//    enum Style {
//        case largeSummary
//        case largeDescriptive
//    }
    var shape = RoundedRectangle(cornerRadius: 16, style: .continuous)
    
    private enum FaceSide {
        case citizens, cities, outposts, preferences
    }
    @State private var face:FaceSide = .citizens
    
    var closeAction: () -> Void = {}
    var flipAction: () -> Void = {}
    
    init(guildMap:GuildMap) {
        self.guildMap = guildMap
        self.guildSum = guildMap.makeSummary()
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
                                    .padding(.bottom, 4)
                                
                                ForEach(guildMap.citizens, id:\.self) { citizen in
                                    SmallPlayerCardView(pCard: citizen.makePlayerCard())
                                }
                            }
                            .frame(minWidth: 170, maxWidth: 200)
                        }
                        
                    case .cities:
                        
                        Text("Cities: \(guildSum.cities.count)")
                        
                        ForEach(guildMap.cities, id:\.self) { city in
                            Text("\(city.name)") //\(String(city.id.uuidString.prefix(6)))")
                        }
                        
                        if guildMap.cities.isEmpty == true {
                            Text("< No Cities >").foregroundColor(.gray)
                        }
                        
                    case .outposts:
                        
                        Text("Outposts").font(.title2).foregroundColor(.blue)
                        ScrollView {
                            VStack {
                                ForEach(guildMap.outposts, id:\.id) { outpost in
                                    Text("\(outpost.type.rawValue) \(outpost.level)")
                                }
                                Text("Total level: \(guildMap.outposts.compactMap({ $0.level }).reduce(0, +))").foregroundColor(.orange)
                            }
                        }
                        
                    case .preferences:
                        
                        Text("Preferences").font(.title2).foregroundColor(.orange)
                        Image(systemName: guildSum.isOpen ? "lock.open":"lock")
                            .font(.largeTitle)
                        Text("Open: \(guildSum.isOpen ? "Yes":"No")")
                        Text(guildSum.isOpen ? "Guild is open for players to join.":"You must be invited to join this guild.").font(.footnote).foregroundColor(.gray)
                        
                        Text("📆 \(GameFormatters.dateFormatter.string(from: guildMap.election?.start ?? Date.distantFuture))")
                }
                
                Spacer()
                
                Divider()
                
                HStack {
//                    if controller.guildJoinState.joinButton {
//                        Button("Join") {
//                            controller.requestJoin(self.guildFull)
//                        }
//                        .buttonStyle(NeumorphicButtonStyle(bgColor:.blue))
//                    } else if controller.guildJoinState.leaveButton {
                        Button("Button") {
                            
                        }
                        .buttonStyle(NeumorphicButtonStyle(bgColor:.blue))
//                    }
                    
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
//                .scaleEffect(x: style == .largeDescriptive ? -1 : 1)
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

struct GuildCardView_Previews: PreviewProvider {
    static var previews: some View {
        GuildCardView(guildMap: GuildMap(name: "Testing inview", population: 5, mission: GuildMission(), makePresident: true))
    }
}
